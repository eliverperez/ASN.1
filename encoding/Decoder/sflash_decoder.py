from sage.all import *
# from sage.rings.all import *
# from sage.structure.all import *
# from sage.rings.finite_rings.finite_field_constructor import *
# # from sage.rings.finite_rings.finite_field_constructor.PolynomialRing import *
# from sage.rings.polynomial import *
from Encoder.sflash_record import *
from mi_decoder import MIDecoder
from Utils import utils
import base64

header = '-----BEGIN SFLASH PRIVATE KEY BLOCK-----\n'
footer = '\n-----END SFLASH PRIVATE KEY BLOCK-----'
class SflashDecoder(MIDecoder):

	def decodePublicKey(self, file):
		pubRecord = SflashPublicRecord()
		encoded = ""
		lines = file.readlines()
		for i in xrange(1, len(lines) - 1):
			encoded += lines[i]
		decoded = pubRecord.decode(self.encoding, base64.b64decode(encoded))
		p = int(decoded[0][0].prettyPrint())
		baseField = int(decoded[0][1].prettyPrint())
		n = int(decoded[0][2].prettyPrint())
		# Recover binary polynomials
		self.writeFile(p, baseField, n)
		# Declare polynomial ring over field Fp**baseField over n variables
		# Write file with sage instructions
		# f = open("polys.sage", "w")
		# f.write("R.<X> = GF(" + str(p) + ")[]\n")
		# f.write("k.<x> = GF(" + str(p) + "**" + str(baseField) + ", GF(" + str(p) + ")['X'].irreducible_element(" + str(baseField) + "))\n")
		# f.write("K = PolynomialRing(k, \"x\", " + str(n) + ", order='deglex')")
		# f.close()
		load("polys.sage")
		# Get variables in K
		# vars = []
		# vars.append(1)
		# for i in range(n):
		# 	vars.append(K.gens()[i])
		# return vars
		vars = self.getVars(K)
		print vars
		polySize = ((n+1)*(n+2)*baseField / 2)
		# polynomials = bin(int(decoded[0][3].prettyPrint()))[2:]
		polynomials = decoded[0][3].prettyPrint()
		res = polySize - (len(polynomials) % polySize)
		# Fill with zeros binary string
		if(res != polySize):
			for i in range(res):
				polynomials = "0" + polynomials
		# PolySet = genPolynomials(polynomials, n + 1, len(polynomials) / polySize, getVars(K), k, baseField, K)
		PolySet = self.decodePolynomials(polynomials, n + 1, len(polynomials) / (((n+1)*(n+2)*baseField)/2), vars, k, baseField, K)
		return PolySet

	def getVars(self, K):
		vars = []
		vars.append(1)
		for i in range(K.ngens()):
			vars.append(K.gens()[i])
		return vars

	def decodePolynomials(self, polynomials, n, m, vars, F, d, K):
        	binSize = ((n * (n + 1)) / 2) * d
	        PolySet = []
	        pol = []
	        for i in range(m):
	            pol.append(0)
	        PolySet = vector(K, pol)
	        x = F.gen()
	        for i in range(m):
	            # polynomial = Integer(getrandbits(binSize)).binary()
	            polynomial = polynomials[i*binSize:(i*binSize) + binSize]
	            z = 0
	            poly = 0
	            for j in range(n):
	                for k in xrange(j, n):
	                    index = d*z
	                    coef = polynomial[index:index + d]
	                    z += 1
	                    coefficient = 0
	                    for l in range(d-1):
	                        if coef[l] == "1":
	                            coefficient += x**((d - 1)-l)
	                    if coef[d-1] == "1":
	                        coefficient += 1
	                    poly += coefficient * (vars[j] * vars[k])
	            #PolySet.append(poly)
	                PolySet[i] = poly
	        return PolySet

	def writeFile(self, p, baseField, n):
		f = open("polys.sage", "w")
		f.write("R.<X> = GF(" + str(p) + ")[]\n")
		f.write("k.<x> = GF(" + str(p) + "**" + str(baseField) + ", GF(" + str(p) + ")['X'].irreducible_element(" + str(baseField) + "))\n")
		f.write("K = PolynomialRing(k, \"x\", " + str(n) + ", order='deglex')")
		f.close()

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

