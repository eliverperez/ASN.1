from .sflash_record import *
from ..mi_encoder import MIEncoder
from ...Utils import utils
import base64

header = '-----BEGIN SFLASH PRIVATE KEY BLOCK-----\n'
footer = '\n-----END SFLASH PRIVATE KEY BLOCK-----'
class SflashEncoder(MIEncoder):
	'''def __init__(self):
		super(SflashEncoder, self).__init__()
		R.<X>=GF(2)[]
		k.<x>=GF(2**7,X**7+X+1)
		Rk.<T>=k[]
		K.<t>=k.extension(T**37+T**12+T**10+T**2+1)
		KR=PolynomialRing(K, "x", K.degree(), order='deglex')
		self.baseField = k
		self.extensionField = K
		self.ring = KR'''

	def printHeader(self, key):
		if(key == "public"):
			return '-----BEGIN SFLASH PUBLIC KEY BLOCK-----\n'
		else:
			return '-----BEGIN SFLASH PRIVATE KEY BLOCK-----\n'

	def printFooter(self, key):
		if(key == "public"):
			return '\n-----END SFLASH PUBLIC KEY BLOCK-----'
		else:
			return '\n-----END SFLASH PRIVATE KEY BLOCK-----'	

	def encodePublic(self, publicKey):
		pubRecord = SflashPublicRecord()
		system = publicKey.getSystem()
		n = system.parent().base_ring().ngens()
		# print "pubRecord.encode(self.encoding)"
		# print pubRecord.encode(self.encoding)
		systemBin = self.encodeSystem(publicKey.getSystem(), 1)
		#lst = [[2, n], [2, systemBin]]
		pubRecord.setNvars(len(system.parent().gens()))
		pubRecord.setPublicSystem(systemBin)
		# self.printKey(base64.b64encode(pubRecord.encode(self.encoding)))
		return self.printHeader("public") + self.printKey(base64.b64encode(pubRecord.encode(self.encoding))) + self.printFooter("public")
		#return self.encode(lst)

	'''
	'''
	def encodePrivate(self, privateKey):
		privRecord = SflashPrivateRecord()
		affine1 = privateKey.getAffine1()
		affine2 = privateKey.getAffine2()
		affine1Bin = self.encodeAffine(affine1, 1)
		affine2Bin = self.encodeAffine(affine2, 1)
		m = affine1.parent().degree()
		n = affine2.parent().degree()
		privRecord.setAffine1(affine1Bin)
		privRecord.setAffine2(affine2Bin)
		privRecord.setNdim(n)
		privRecord.setMdim(m)
		privRecord.setDelta(privateKey.getDelta())
		return self.printHeader("private") + self.printKey(base64.b64encode(privRecord.encode(self.encoding))) + self.printFooter("private")
		#lst = [[2, privateKey.getDelta()], [2, m], [2, affine1Bin], [2, n], [2, affine2Bin]]
		#return self.encoder.encode(lst)

	def printKey(self, key):
		length = 80
		rem = len(key) % length
		lines = int(len(key) / length)
		asnkey = ""
		for i in range(lines):
			asnkey += key[length * i:(length*i) + length] + "\n"
		if(rem != 0):
			asnkey += key[length * lines:(length*lines) + length]
		# print "\n\n\nkey"
		# print key
		# print "\n\n\nasnkey"
		# print asnkey
		return asnkey


'''	def decodePublic(self, b64Str):
		l = len(base64Str)
		b64Str = b64Str[len(header), l - len(footer)]
		valueTypeLst = base64.decode(b64Str)
		# The first element is the number of variables
		pubRecord = SflashPublicRecord()
		pubRecord.decode()
		n = binToInt(valueTypeLst[0][1])
		# Then the coded system
		binSyst = valueTypeLst[1][1]
		system = self.decodeSystem(n, binSyst, self.ring, 1)
		return SflashPublicKey(system)

	def decodePrivate(self, b64Str):
		valTpLst = self.encoder.decode(ba)
		# The first element is the random string delta
		delta = valTpLst[0][1]
		# Then the degree of the affine group 1 and the affine transform 1
		m = binToInt(valTpLst[1][1])
		affine1Bin = valTpLst[2][1]
		# Finally the degree of the affine group 2 and the affine transform 2
		n = binToInt(valTpLst[3][1])
		affine2Bin = valTpLst[4][1]
		affine1 = self.decodeAffine1(affine1Bin, m, 1)
		affine2 = self.decodeAffine1(affine2Bin, n, 1)
		return SflashPrivateKey(affine1, affine2, delta)'''

'''	def decodePublic(self, ba):
		valueTypeLst = self.encoder.decode(ba)
		# The first element is the number of variables
		n = binToInt(valueTypeLst[0][1])
		# Then the coded system
		binSyst = valueTypeLst[1][1]
		system = self.decodeSystem(n, binSyst, self.ring, 1)
		return SflashPublicKey(system)

	def decodePrivate(self, ba):
		valTpLst = self.encoder.decode(ba)
		# The first element is the random string delta
		delta = valTpLst[0][1]
		# Then the degree of the affine group 1 and the affine transform 1
		m = binToInt(valTpLst[1][1])
		affine1Bin = valTpLst[2][1]
		# Finally the degree of the affine group 2 and the affine transform 2
		n = binToInt(valTpLst[3][1])
		affine2Bin = valTpLst[4][1]
		affine1 = self.decodeAffine1(affine1Bin, m, 1)
		affine2 = self.decodeAffine1(affine2Bin, n, 1)
		return SflashPrivateKey(affine1, affine2, delta)'''

'''
	def encodeAffine(self, affine):
		deg = affine.matrix()[0,0].parent().polynomial().degree()
		affineMatrix = affine.matrix()[0: deg, 0: deg]
		affineVector = affine.matrix()[0:deg, deg: deg+1]
		affineMatrixInt = 0
		affineVectorInt = 0
		for i in range(deg):
			if affineVector[i] == 1:
				affineVectorInt = affineVectorInt | 1
			affineVectorInt << 1
			for j in range(deg):
				if affineMatrix[i,j] == 1:
					affineMatrixInt = affineMatrixInt | 1
				affineMatrixInt = affineMatrixInt << 1
		affineVectorInt = affineVectorInt >> 1
		affineMatrixInt = affineMatrixInt >> 1
		return intToBin(affineMatrixInt), intToBin(affineVectorInt)
'''

