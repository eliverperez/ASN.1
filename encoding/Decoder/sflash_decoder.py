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
		self.writeFile(p, baseField, n)
		load("polys.sage")
		vars = self.getVars(K)
		polySize = ((n+1)*(n+2)*baseField / 2)
		polynomials = decoded[0][3].prettyPrint()
		res = polySize - (len(polynomials) % polySize)
		# Fill with zeros binary string
		if(res != polySize):
			for i in range(res):
				polynomials = "0" + polynomials
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
