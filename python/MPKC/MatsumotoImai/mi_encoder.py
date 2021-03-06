from ..mq_encoder import MQEncoder
from .mi_record import *
#from ..Utils.asn1 import ASN1

class MIEncoder(MQEncoder):
	def encodePublic(self, publicKey):
		pubRecord = MIPublicRecord()
		baseField = publicKey.getBaseField()
		extField = publicKey.getExtensionField()
		system = publicKey.getSystem()
		deg = baseField.polynomial().degree()
		systemBin = self.encodePublicSystem(system, deg)
		basePolyInt, extPolyInt = self.encodeFields(baseField, extField)

		pubRecord.setPrimeField(2)
		pubRecord.setBaseField(basePolyInt)
		pubRecord.setExtensionField(extPolyInt)
		pubRecord.setNvars(len(system.parent().gens()))
		pubRecord.setPublicSystem(systemInt)
		return '-----BEGIN PRIVATE KEY BLOCK-----\n' + pubRecord.encode(self.encoding) + '\n-----END PUBLIC KEY BLOCK-----'

	def encodePrivate(self, privateKey):
		baseField = privateKey.getBaseField()
		extField = privateKey.getExtensionField()
		basePolyInt, extPolyInt = encodeFields(baseField, extField)
		theta = privateKey.getTheta()
		affine1 = privateKey.getAffine1()
		affine2 = privateKey.getAffine2()
		m = affine1.parent().degree()
		n = affine2.parent().degree()
		deg = baseField.polynomial().degree()
		affine1Bin = self.encodeAffine(privateKey.getAffine1(), deg)
		affine2Bin = self.encodeAffine(privateKey.getAffine2(), deg)

		privRecord = MIPublicRecord()
		privRecord.setPrimeField(privateKey.getBaseField())
		privRecord.setExtensionField(privateKey.getExtensionField())
		privRecord.setNvars(len(system.parent().gens()))
		privRecord.setPublicSystem(publicKey.getSystem())
		return '-----BEGIN PRIVATE KEY BLOCK-----\n' + privRecord.encode(self.encoding) + '\n-----END PUBLIC KEY BLOCK-----'

	''' Encoded public key contains:
		BaseField: Binary array representing the irreducible polynomial over F2 (0-1 coefficients)
		Extension Field: Binary array representing (0-1 coefficinets)
		n: Number of variables
		Coefficient Matrix: A big integer with coefficient size defined by the polynomial of the base field
	def encodePublic(self, publicKey):
		baseField = publicKey.getBaseField()
		extField = publicKey.getExtensionField()
		basePolyBin, extPolyBin = self.encodeFields(baseField, extField)
		system = publicKey.getSystem()
		n = len(system.parent().gens())
		deg = baseField.polynomial().degree()
		systemBin = self.encodePublicSystem(system, deg)
		lst = [[2, basePolyBin], [2, extPolyBin], [2, n], [2, systemBin]]
		return self.encoder.encode(lst)'''

	'''
	def encodePrivate(self, privateKey):
		baseField = privateKey.getBaseField()
		extField = privateKey.getExtensionField()
		basePolyBin, extPolyBin = encodeFields(baseField, extField)
		theta = privateKey.getTheta()
		affine1 = privateKey.getAffine1()
		affine2 = privateKey.getAffine2()
		m = affine1.parent().degree()
		n = affine2.parent().degree()
		deg = baseField.polynomial().degree()
		affine1Bin = self.encodeAffine(privateKey.getAffine1(), deg)
		affine2Bin = self.encodeAffine(privateKey.getAffine2(), deg)
		lst = [[2, basePolyBin], [2, extPolyBin], [2, theta], [2, m], [2, affine1Bin], [2, n], [2, affine2Bin]]
		return self.encoder.encode(lst)'''

	def encodeFields(self, baseField, extensionField):
		return polToInt(baseField.polynomial()), polToInt(extField.modulus())

'''	def getEncoder(self):
		return self.encoder'''
