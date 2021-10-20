variable "app" {
  type = string
}

variable "enviroment" {
  type = string
  default = "dev"
}

variable "vm_admin_username" {
    type = string
    sensitive = true
}

variable "mysql_administrator_login" {
    type = string
    sensitive = true
}

