import re 
def extractor(string):
    #print(string)
    first="{"
    last="(?s:.*)}"
    match1 = re.search(first,string) 
    match2 = re.search(last,string)

    if match1 == None or match2 == None:
        return None
    else:
    
        start = match1.start() 
        end = match2.end() 
        #print(start,end)
        cuttext= string[start +1  : end -1 ]
        return (cuttext) 

def getkeyval(string,key1):
    st = string
    key_val_dict = {}
    while extractor(st):
        st = extractor(st)
        #print(st)

        s= st.split(":")
        output=[]
        for i,j in enumerate(s):
            output.append(j.strip("{").strip("}").strip('\"'))

        key = ''.join('%s/' %i for i  in output[:-1])
        #print(key)
        key_val_dict[key] = output[len(output)-1]


        val = ''.join('%s' %i for i  in output[1:])
        key_val_dict[output[0] + '/']= val
        #print("key"+ str(l[len(l)-2]) + str(l[len(l)-1]))
        if st == None:
            break
    if key1[-2:] in key_val_dict:
        print("String ",string," key",key1," val",key_val_dict[key1[-2:]])
    else:
        print("String ",string," key",key1," is a invalid key")

if __name__ == "__main__":
    st = r'{"a":{"b":{"c":"d"}}}'
    getkeyval(st,'a')
    getkeyval(st,'a/b/c/')
    getkeyval(st,'as')
    st = r'{"a":{"b":{"c":{"d":"e"}}}}'
    getkeyval(st,'a')
    getkeyval(st,'a/b/')
    getkeyval(st,'a/b/c/d/')
    getkeyval(st,'as')

