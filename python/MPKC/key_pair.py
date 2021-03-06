''' Empty classes for general PKC key storage '''

''' Base class for a PKC Public Key
'''
class PublicKey(object):
	def __init__(self):
		NotImplementedError( "Should have implemented this")
	
	def getEncoded(self):
		NotImplementedError( "Should have implemented this")
	
''' Base class for a PKC Private Key
'''
class PrivateKey(object):
	def __init__(self):
		NotImplementedError( "Should have implemented this")
    
	def getEncoded(self):
		NotImplementedError( "Should have implemented this")

''' Base class for a PKC KeyPair
'''
class KeyPair(object):
	def __init__(self, pubKey, privKey):
		self.public = pubKey
		self.private = privKey

	def getPublic(self):
		return self.public

	def getPrivate(self):
		return self.private

	def setPublic(self):
		self.public = public
    
	def setPrivate(self, private):
		self.private = private
