
obj_dict =  dict( {'a':{'b':{'c':'d'}}})

keys_str = input("Enter the key for which value to be fetched : (use '/' as delemeter ) \n")    

keys = keys_str.split("/")
# ['a', 'b', 'c']

val = obj_dict

isFound = True

for key in keys:
   val = val.get(key, None)
   if val == None:
       isFound = False
       break

if isFound == True and val != None:
    print(val)