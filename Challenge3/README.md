Problem Statement : 

Write a function/program to find out the value of a key at any level in the object ( object is simuilar to json)

Example 1 Inputs : 

object = {“a”:{“b”:{“c”:”d”}}}

User input : key = a/b/c

Expected Output:
    Value = d


Example 2 Inputs : 

object = {“x”:{“y”:{“z”:”a”}}}

User input : key = x/y/z

Expected Output:
    Value = a

Solution : 

Algorithm/Process:

1. raw_object = Get the required object ( json form, key value should be enclosed by single or double quote)
2. dict_object = Convert raw_object into dictionary
3. keys_string = Get the input from user, keys delimited/seprated by '/'
4. keys = split the keys string by the delimiter and store the value into list or array
5. temp = Store a copy of original dict_object
6. is_found = take a flag set to true as if you already found the value of the keys sequence
7. for key in keys : [ loop through the keys ]
7.1.  temp = value of the key in temp, if not found assign default value could be NULL
7.2.  if temp is null
7.2.1    set the is_found = false means the value for key is not found
7.2.2    break out of the loop since there is nothing further we need to do
8. check if the is_found is still set to true and value of temp is not null
8.1 print the result
8.2 else print "NOT Found" 