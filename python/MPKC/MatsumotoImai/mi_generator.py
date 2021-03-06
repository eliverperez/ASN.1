#load('mi_key_pair.sage')
from sage.all import *
from .mi_key_pair import *

''' Class for generation of Matsumoto-Imai key pairs. It is required to know the base field (coefficients) and the extension field
'''
class MIKeyGenerator(object):
    ''' Basic constructor. No variations will take place
    '''
    def __init__(self, baseField, extensionField):
        self.baseField = baseField
        self.extensionField = extensionField
        self.variation = MQVariation
    
    ''' Constructor for schemes with variations
    '''
    def __init__(self, baseField, extensionField, variation):
        self.baseField = baseField
        self.extensionField = extensionField
        self.variation = variation
    
    ''' Create a key pair
    '''
    def generateKeyPair(self):
        private = self.generatePrivate()
        public = self.generatePublic(private)
        return KeyPair(public, private)
    
    def generatePrivate(self):
        # Affine transformations
        affine = self.generateAffine(2)
        theta = self.chooseTheta()
        private = MIPrivateKey(self.baseField, self.extensionField, affine[0], affine[1], theta)
        private = self.applyPrivateVariation(private)
        return private        
    
    def generatePublic(self, privateKey):
        public = MIPublicKey(self.baseField, self.extensionField, self.getPublicSystem(privateKey.getAffine1(), privateKey.getAffine2(), privateKey.getTheta()))
        public = self.applyPublicVariation(public)
        return public
        
    def chooseTheta(self):
        NotImplementedError("Implement me!!")
    
    def applyPrivateVariation(self, privateKey):
        return self.variation.applyPrivate(privateKey)
        
    def applyPublicVariation(self, publicKey):
        return self.variation.applyPublic(publicKey)
    
    def getInverseExp(self):
        NotImplementedError("Implement me!!")
        
    '''
    '''
    def getPublicSystem(self, affine1, affine2, theta):
        # Polynomial Ring with coefficients in the Base Field
        K = self.extensionField
        deg=K.degree()
        q = self.baseField.order()
        KR=PolynomialRing(K,"x",deg,order='deglex')
        vars=KR.gens()
        I=[]
        for i in range(deg):
            I.append(vars[i]**q-vars[i])
        KRQ=KR.quotient(I)
    
        #Transform from elements in k^n to K
        Kgen=K.gen()
        pows=[]
        for i in range(deg):
            pows.append(Kgen**i)
    
        # Matrix and vector of affine Transformations
        ms=matrix(KR,affine1.matrix()[0:deg,0:deg])
        vs=vector(KR,affine1.matrix()[0:deg,deg:deg+1])
        mt=matrix(KR,affine2.matrix()[0:deg,0:deg])
        vt=vector(KR,affine2.matrix()[0:deg,deg:deg+1])
        
        # Apply affine1 and transform to element in K
        Kelm=( KRQ( (ms*vector(vars)+vs) * vector(pows) )**(q**theta+1)).lift()
        
        #Initialize the polynomial vector
        pols=[]
        for i in range(deg):
            pols.append(0)
        polVec=vector(KR,pols)
        
        #Recover the polynomials
        for i in range(deg):
            for j in range(deg):
                c = Kelm.coefficient(vars[i]*vars[j])
                polVec = polVec + vector(KR, K(c).list())*(vars[i]*vars[j])
                Kelm = Kelm - c*(vars[i]*vars[j])
            c=Kelm.coefficient(vars[i])
            polVec = polVec + vector(KR,K(c).list())*vars[i]
            Kelm=Kelm - c*(vars[i])
        polVec=polVec + vector(KR,K(Kelm.constant_coefficient()).list())
        
        # Apply affine2
        polVec = mt * polVec + vt
        return polVec
    
    ''' Generates an affine tranformation in the given Field
    '''
    def generateAffine(self, n):
        # Generate random affine bijective transformation with elements in the Base Field
        AG = AffineGroup(n, self.baseField)
        return AG.random_element()
