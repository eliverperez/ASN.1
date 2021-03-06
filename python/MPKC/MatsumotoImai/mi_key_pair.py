#load('key_pair.sage')
from ..key_pair import *
''' Basic Matsumoto-Imai Based key storage classes '''

''' Basic MI class for public key. Consists only of the public quadratic system
'''
class MIPublicKey(PublicKey):
    def __init__(self):
        ValueError("Must provide polynomial system")
        
    def __init__(self, baseField, extensionField, system):
        self.system = system
        self.baseField = baseField
        self.extensionField = extensionField
        
    def getSystem(self):
        return self.system    
    
    def setSystem(self, pubSet):
        self.system = pubSet
	
	def getBaseField(self):
		return self.baseField
	
	def setBaseField(self, baseField):
		self.baseField = baseField
	
	def getExtensionField(self):
		return self.extensionField
	
	def setExtensionField(self, extensionField):
		self.extensionField = extensionField
            
''' Basic MI class for private key. It consists of a pair of affine transformations S, T and the parameter \theta for quadratic function Q
    s: Affine transformation (Fq)^n -> (Fq)^n
    t: Affine transformation (Fq)^m -> (Fq)^m
'''
class MIPrivateKey(PrivateKey):
    def __init__(self, baseField, extensionField, affine1, affine2, theta):
        self.baseField = baseField
        self.extensionField = extensionField        
        self.affine1=affine1
        self.affine2=affine2
        self.theta=theta
        
    def getAffine1(self):
        return self.affine1
            
    def getAffine2(self):
        return self.affine2
    
    def getTheta(self):
        return self.theta
	
	def getBaseField(self):
		return self.baseField
	
	def setBaseField(self, baseField):
		self.baseField = baseField
	
	def getExtensionField(self):
		return self.extensionField
	
	def setExtensionField(self, extensionField):
		self.extensionField = extensionField
