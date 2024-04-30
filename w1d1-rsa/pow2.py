
import hashlib
import time

def md5(text: str):
    """MD5加密"""
    return hashlib.md5(text.encode()).hexdigest()

def sha1(text: str):
    """生成sha1摘要"""
    return hashlib.sha1(text.encode()).hexdigest()
    
def sha256(text: str):
    """生成SHA256摘要"""
    # print(text)
    return hashlib.sha256(text.encode()).hexdigest()

def pow2(nickName = "zhtkeepup", oCount = 4):
    
    if nickName == None or nickName.strip()=="":
        nickName = "zhtkeepup"
    t1 = time.time()
    nonce = 0
    sss = ""
    while True:
        sss = sha256("%s%d" % (nickName, nonce) )
        if sss[ : oCount] == "0" * oCount :
            t2 = time.time()
            print(sss)
            break
        nonce += 1
    return "%s%d" % (nickName, nonce)

# 123
if __name__ == "__main__":
    k = 4
    nick_nonce = pow2(oCount = k)
    print("符合%d个0开头哈希值的nick_nonce=%s\n\n" % (k, nick_nonce) )

    

