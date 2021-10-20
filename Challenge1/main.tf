# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.app}-${var.enviroment}-rg"
  location = "eastus"
}

# Create Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.app}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create Subnet
resource "azurerm_subnet" "main" {
  name                 = "${var.app}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "frontend" {
    name = "${var.app}-frontend"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = ["10.0.2.0/24"]

}

# Create Public IP
resource "azurerm_public_ip" "main" {
    name = "${var.app}-publicip"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method = "Static"
}

# Create Network Security Group
resource "azurerm_network_security_group" "main" {
    name                = "${var.app}-nsg"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix     = "*"
        destination_address_prefix = "*"
    }
}

# Create Network Interface
resource "azurerm_network_interface" "main" {
  name                = "${var.app}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.app}-ipconfiguration"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

# Associate Network Security Group to Network Interface
resource "azurerm_network_interface_security_group_association" "main" {
    network_interface_id      = azurerm_network_interface.main.id
    network_security_group_id = azurerm_network_security_group.main.id
}

# Create SSH Key Pair
resource "tls_private_key" "main_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Create Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "${var.app}-vm"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_F2"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
  computer_name         = "main"
  admin_username        = var.vm_admin_username
  disable_password_authentication = true
  
  # Set Virtual Machine Public Key
  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = tls_private_key.main_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  
  # Copy local index.php to remote virtual machine
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = var.vm_admin_username
      host        = azurerm_public_ip.main.ip_address
      private_key = tls_private_key.main_ssh.private_key_pem
      agent       = false
      timeout     = "2m"
    }
   source      = "index.php"
   destination = "/tmp/index.php"
  }

  # Install apache2 on virtual machine and move index.php to configured location
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.vm_admin_username
      host        = azurerm_public_ip.main.ip_address
      private_key = tls_private_key.main_ssh.private_key_pem
      agent       = false
      timeout     = "2m"
    }
    inline = [
      # Update
      "sudo apt update -y",

      # Create directory apache serves
      "sudo mkdir -p /var/www/html/", # 

      # Install apache
      "sudo apt-get install -y apache2", # install apache2 and php
      "sudo systemctl enable apache2.service", # enable start apache2 on reboots

      # Install php7.2
      "sudo apt update -y",
      "sudo apt install -y software-properties-common",
      "sudo add-apt-repository -y ppa:ondrej/php",
      "sudo apt update -y", # updates
      "sudo apt install -y php7.2",

      # Configure apache php7.2 mod
      "sudo a2enmod php7.2",
      "sudo service apache2 reload",

      # Remove default file from apache installation
      "sudo rm /var/www/html/index.html", 

      # Move index.php (copied over by Terraform "File" provisioner) to the directory apache serves
      "sudo mv /tmp/index.php /var/www/html/index.php" 
      ]
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                        = "${var.app}randkv"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
        "Backup", "Delete", "Get", "Set", "List", "Purge", "Recover", "Restore"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "random_password" "mysql-admin" {
  length  = 32
  special = true
}


resource "azurerm_key_vault_secret" "mysql-admin-password" {
    name =  "mysqlpassword"
    value = random_password.mysql-admin.result
    key_vault_id = azurerm_key_vault.example.id
  
}

resource "azurerm_key_vault_secret" "private-key" {
    name =  "privatekey"
    value = tls_private_key.main_ssh.private_key_pem
    key_vault_id = azurerm_key_vault.example.id
  
}

resource "azurerm_key_vault_secret" "public-key" {
    name =  "public"
    value = tls_private_key.main_ssh.public_key_openssh
    key_vault_id = azurerm_key_vault.example.id
  
}

# Azure MySQL Server
resource "azurerm_mysql_server" "main" {
  name                              = "${var.app}-mysqlserver"
  location                          = azurerm_resource_group.main.location
  resource_group_name               = azurerm_resource_group.main.name
  administrator_login               = var.mysql_administrator_login
  administrator_login_password      = random_password.mysql-admin.result
  sku_name                          = "B_Gen5_2"
  storage_mb                        = 5120
  version                           = "5.7"
  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  //public_network_access_enabled   = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_public_ip" "pip" {
    name = "${var.app}-pip"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method = "Dynamic"
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.main.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.main.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.main.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.main.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.main.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.main.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.main.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    ip_addresses = [azurerm_public_ip.main.ip_address]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}