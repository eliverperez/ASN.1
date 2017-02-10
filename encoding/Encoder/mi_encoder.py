from mq_encoder import MQEncoder
from mi_record import *
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

	def decodePublicKey(self, file):
		pubRecord = SflashPublicRecord()
		encoded = ""
		lines = file.readlines()
		for i in xrange(1, len(lines) - 1):
			encoded += lines[i]
		print pubRecord.decode(self.encoding, encoded)

	def encodeFields(self, baseField, extensionField):
		return polToInt(baseField.polynomial()), polToInt(extField.modulus())
