import random
import re
def togenerateRandomString(a=3,b=15):
    #generate random string;used to test illeagal command
    a = random.randint(a,b)
    s =''.join(random.sample(['z', 'y', 'x', 'w', 'v', 'u', 't', 's', 'r', 'q', 'p', 'o', 'n', 'm', 'l', 'k', 'j', 'i', 'h', 'g', 'f', 'e',
         'd', 'c', 'b', 'a','!','@','#','$','%','^','&','*','(',')','3','4','5','6','7','8','9'], a))
    return s
def splitBy(string,flag):
    flag = (str)(flag)
    s = string.split(flag)
    for i in s:
        print(i)
    return s
def containss(info,des_info):
    #if info containss des_info,return first find;elif not contain return -1;
    #info=info.encode("gbk")
    #des_info=des_info.encode("gbk")
    info = str(info)
    des_info = str(des_info)
    print (info)
    print (des_info)
    return info.find(des_info)
def getStringInfo(str,start,end):
    print(start,end)
    return    re.findall(r"%s(.+?)%s"%(start,end), str)

