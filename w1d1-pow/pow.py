
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

def main(nickName = "zhtkeepup", oCount = 4):
    if oCount > 10:
        raise Exception("error!")
    
    if nickName == None or nickName.strip()=="":
        nickName = "zhtkeepup"
    t1 = time.time()
    nonce = 0
    sss = ""
    while True:
        sss = sha256("%s%d" % (nickName, nonce) )
        if sss[ : oCount] == "0000000000"[ : oCount] :
            t2 = time.time()
            break
        nonce += 1
    return (t2 - t1, sss)

if __name__ == "__main__":
    for k in range(4, 8):
        t, s = main(oCount = k)
        print("计算%d个0开头的哈希值耗时 %.4f 秒. 结果=%s\n\n" % (k, t, s) )

    

