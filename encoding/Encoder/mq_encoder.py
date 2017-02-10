from Utils.utils import *

class MQEncoder(object):
	def __init__(self):
		self.__init__("BER")
#		self.encoder = ASN1("BER")

	def __init__(self, encoding):
		self.encoding =  encoding

	def encodeField(self, field):
		return self.encodeBinPolynomial(field.polynomial())
	

	def encodeBinPol(self, pol):
		return int(field.polynomial())

	def encodeAffine(self, affine, d = 0):
		baseField = affine.matrix()[0,0].parent()
		n = affine.parent().degree()
		if d == 0:
			d = baseField.degree()
		affineMatrix = affine.matrix()[0:n, 0:n]
		affineVector = affine.matrix()[0:n, n:n+1]
		bin = 0
		#Matrix elements
		for i in range(n):
		    for j in range(n):
		        c = polToInt(affineMatrix[i,j])
		        bin = (bin << d) | c
		#Vector elements
		for i in range(n):
		    c = polToInt(affineVector[i][0])
		    bin = (bin << d) | c
		return bin

	def encodeSystem(self, system, d, k):
		bin = 0
		m = len(system)
		n = len(system[0].parent().gens())
		if d == 0:
			d = system[0].parent().base_ring().degree()
		for i in range(m):
			polInt = self.encodeQuadraticPolynomial(system[i], d, k)
			bin = (bin << ((n+1)*(n+2)*d)/2) | polInt
		print "bin"
		print bin
		return bin

	# def encodeQuadraticPolynomial(self, pol, d, k):
	# 	bin = 0
	# 	vars = pol.parent().gens()
	# 	if d == 0:
	# 		d = pol.parent().base_ring().degree()
	# 	n = len(vars)
	# 	#Quadratic coefficients
	# 	for i in range(n):
	# 	    for j in range(i, n):
	# 	        # c = polToInt(pol.coefficient(vars[i]*vars[j]))
	# 	        print pol.coefficient(vars[i]*vars[j])
	# 	        c = k(pol.coefficient(vars[i]*vars[j])).integer_representation()
	# 	        bin = (bin << d) | c
	# 	        pol = pol - c*vars[i]*vars[j]
	# 	#Linear coefficients
	# 	for i in range(n):
	# 	    # c = polToInt(pol.coefficient(vars[i]))
	# 	    print pol.coefficient(vars[i])
	# 	    c = k(pol.coefficient(vars[i])).integer_representation()
	# 	    bin = (bin << d) | c
	# 	#Constant coefficient
	# 	# bin = (bin << d) | polToInt(pol.constant_coefficient())
	# 	bin = (bin << d) | k(pol.constant_coefficient()).integer_representation()
	# 	return bin

	def encodeQuadraticPolynomial(self, pol, d, k):
		bin = 0
		vars = pol.parent().gens()
		if d == 0:
			d = pol.parent().base_ring().degree()
		n = len(vars)
		#Constant coefficient
		# bin = (bin << d) | polToInt(pol.constant_coefficient())
		bin = (bin << d) | k(pol.constant_coefficient()).integer_representation()
		#Linear coefficients
		for i in range(n):
		    # c = polToInt(pol.coefficient(vars[i]))
		    # print pol.coefficient(vars[i])
		    c = k(pol.monomial_coefficient(vars[i])).integer_representation()
		    bin = (bin << d) | c
		#Quadratic coefficients
		for i in range(n):
		    for j in range(i, n):
		        # c = polToInt(pol.coefficient(vars[i]*vars[j]))
		        # print pol.coefficient(vars[i]*vars[j])
		        c = k(pol.coefficient(vars[i]*vars[j])).integer_representation()
		        bin = (bin << d) | c
		return bin

	# def encodeQuadraticPolynomial(self, pol, d, k, n):
	# 	bin = 0
	# 	if d == 0:
	# 		d = pol.parent().base_ring().degree()
	# 	coefficients = pol.coefficients()
	# 	quadraticpolynomials = (n * (n + 1)) / 2
	# 	totalpolynomials = ((n + 1) * (n + 2)) / 2
	# 	print totalpolynomials
	# 	bin = (bin << d) | coefficients[totalpolynomials - 1].integer_representation()
	# 	#Linear coefficients
	# 	for i in xrange(quadraticpolynomials + 1, totalpolynomials - 1):
	# 		bin = (bin << d) | coefficients[i].integer_representation()
	# 	#Quadratic coefficients
	# 	for i in range(quadraticpolynomials):
	# 	    bin = (bin << d) | coefficients[i].integer_representation()
	# 	return bin

	def decodeBinPol(self, ba, x):
		if type(bin) == bytearray:
			bin = binToInt(bin)
		f = 0
		i = 0
		while bin > 0:
			f = f + (bin & 1) * x**i
			bin = bin >> 1
			print(bin)
			i += 1
		return f
	
	def decodeQuadraticPolynomial(self, bin, ring, d = 0):
		vars = ring.gens()
		fgen = ring.base_ring().gen()
		n = len(vars)
		if type(bin) == bytearray:
			bin = binToInt(bin)
		if d == 0:
			d = ring.base_ring().degree()
		aux = 0
		for i in range(d):
			aux = aux << 1
		pol = ring(bin & aux)
		bin = bin >> d		
		for i in range(n)[::-1]:
			pol = pol + decodeBinPol(bin & aux, fgen) * vars[i]
			bin = bin >> d
		for i in range(n)[::-1]:
			for j in range(i, n)[::-1]:
				pol = pol + decodeBinPol(bin & aux, fgen) * vars[i] * var[j]
				bin = bin >> d
		return pol

	def decodeSystem(self, bin, ring, d = 0):
		if type(bin) == bytearray:
			bin = binToInt(bin)
		if d == 0:
			d = ring.base_ring().ngens()
		n = ring.ngens()
		idx = 0
		f = []
		aux = 0
		cont = 0
		for i in range(d*(n+1)*(n+2)/2):
			aux = aux << 1
		while bin > 0 and cont < 100:
			f.append(self.decodeQuadraticPolynomial(bin & aux, ring, d))
			bin = bin >> (d*(n+1)*(n+2)/2)
		return f
	
	def decodeAffine(self, bin, n, Fq, d = 0):
		if type(bin) == bytearray:
			bin = binToInt(bin)
		if d == 0:
			d = Fq.degree()
		gen = Fq.gen()
		idx = 0
		vec = matrix(1,n)
		mat = matrix(n)
		aux = 0
		for i in range(d):
			aux = aux << 1
		for i in range(n)[::-1]:
			vector[i] = decodeBinPol(bin & aux, gen)
			bin = bin >> d
		for i in range(n)[::-1]:
			for j in range(i, n)[::-1]:
				mat[i,j] = decodeBinPol(bin & aux, gen)
				bin = bin >> d
		AG = AffineGroup(Fq, n)
		return AG(mat, vec)

	def getEncoder(self):
		return self.encoder
