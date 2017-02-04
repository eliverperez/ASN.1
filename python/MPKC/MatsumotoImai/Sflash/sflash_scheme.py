import hashlib
class SflashScheme(object):
    
    def __init__(self):
        # Finite fields as stablished in the SFLASH standard
        r.<X>=GF(2)[]
        k.<x>=GF(2**7,X**7+X+1)
        R.<T>=k[]
        K.<t>=k.extension(T**37+T**12+T**10+T**2+1)
        self.baseField = k
        self.extensionField = K
        i,j = var('i','j')
        self.inverseExp = 2**258+sum(sum(2**j,j,154*i+76,154*i+152),i,0,17)
        self.hash_alg = 'SHA1'
    
    def getKey(self):
        return self.key
    
    def update(self, key):
        self.key = key
    
    def getBaseField(self):
        return self.baseField
        
    def getExtensionField(self):
        return self.extensionField
    
    def sign(self, msg):
        Y = self.toFieldElement(msg)    
        
        #Compute T^{-1}(y_1,...,y_n)
        B = self.key.getAffine2().inverse()(Y)
                
        # Inverse for Matsumoto-Imai map
        y = self.cstarInverse(B)
        
        #Finally get S^{-1}(x'_1,...,x'_n)
        S = self.key.getAffine1().inverse()(y)
        return self.toByteArray(S)
    
    def cstarInverse(self, B):
        K = self.getExtensionField()  
        #Transform from k^n to K
        Kgen=K.gen()
        p=[]
        for i in range(K.degree()):
            p.append(Kgen**i)
        B = B.dot_product(vector(p))
        
        #Compute B^{h}
        A = B**(self.getInverseExp())
        
        #Transform from K to k^n
        y = vector(A.list())
        return y
        
    def getInverseExp(self):
        return self.inverseExp
    
    def toFieldElement(self, byteArray):
        V = self.getHashed(byteArray)
        hash = hashlib.new(self.hash_alg)
        hash.update(V + self.key.getDelta())
        W = bytearray(hash.digest())[0:10]
        Y = vector(self.baseField, 37)
        Y[0:26] = binToGF2nElm(V, self.baseField)
        Y[26:37] = binToGF2nElm(W, self.baseField)
        return Y;
    
    def toByteArray(self, fieldArray):
        return GF2nElmToBin(fieldArray, self.baseField)
    
    def verify(self, msg, sign):
        V = self.getHashed(msg)
        Y =  binToGF2nElm(V, self.baseField)
        yp = binToGF2nElm(sign, self.baseField)
        Yp = []
        for i in range(37):
            Yp.append(yp[i])
        Yp = self.key.getSystem()(Yp)
        if (Y == Yp):
            return True
        else:
            return False
            
    def getHashed(self, msg):
        hash = hashlib.new(self.hash_alg)
        hash.update(msg)
        m1 = bytearray(hash.digest())
        hash = hashlib.new(self.hash_alg)
        hash.update(m1)
        m2 = bytearray(hash.digest())
        V = bytearray(23)
        V[0:20] = m1
        V[20:23] = m2[0:3]
        return V
