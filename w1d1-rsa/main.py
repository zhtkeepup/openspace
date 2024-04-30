# pip install pycryptodome

import base64
# from Crypto.PublicKey import RSA
from Crypto.Hash import SHA
from Crypto.Signature import PKCS1_v1_5 as PKCS1_signature
from Crypto.Cipher import PKCS1_v1_5 as PKCS1_cipher

import pow2

import sys

from Crypto import Random
from Crypto.PublicKey import RSA
 

private_key_file = 'key/rsa_private_key.pem'
public_key_file = 'key/rsa_public_key.pem'
 
def generate_key():
    global private_key_file, public_key_file
    random_generator = Random.new().read
    rsa = RSA.generate(2048, random_generator)
    # 生成私钥
    private_key = rsa.exportKey()
    # print(private_key.decode('utf-8'))
    # 生成公钥
    public_key = rsa.publickey().exportKey()
    # print(public_key.decode('utf-8'))

    with open(private_key_file, 'wb')as f:
        f.write(private_key)
        
    with open(public_key_file, 'wb')as f:
        f.write(public_key)



















def get_key(key_file):
    with open(key_file) as f:
        data = f.read()
        key = RSA.importKey(data)

    return key

def signature_with_private(msg):
    global private_key_file
    print("signature_with_private, msg=", msg)
    private_key = get_key(private_key_file)
    signer = PKCS1_signature.new(private_key)
    digest = SHA.new()
    digest.update(msg.encode("utf8"))
    sign = signer.sign(digest)
    signature = base64.b64encode(sign)
    signature = signature.decode('utf-8')
    return signature

def verify_with_public(msg, signature_text):
    global public_key_file
    # print("\n\n\nverify_with_public, msg=", msg)
    # print("verify_with_public, signature_text=", signature_text)
    publick_key = get_key(public_key_file)
    verifier = PKCS1_signature.new(publick_key)
    digest = SHA.new()
    digest.update(msg.encode("utf8"))
    rtn = verifier.verify(digest, base64.b64decode(signature_text))
    # print("\n\nverify_with_public:", rtn)
    return rtn
    

 # True





if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1]=='ggg':
        # 生成公钥私钥对
        generate_key()
        sys.exit(0)
    #
    # 测试加密解密

    # 获取符合前缀4个0哈希值的nonce（及用户名id）
    nick_nonce = pow2.pow2(nickName = "zhtkeepup", oCount = 4)
    print("明文信息:", nick_nonce)
    sign_text = signature_with_private(nick_nonce)
    print("\n未篡改预期得到True, 实际结果=", verify_with_public(nick_nonce, sign_text) )
    print("\n信息被篡改预期得到False, 实际结果=", verify_with_public(nick_nonce[1:], sign_text) )


