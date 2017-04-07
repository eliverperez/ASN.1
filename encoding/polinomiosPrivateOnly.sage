from sage.all 	  import *
from brial        import *
from brial        import Block, declare_ring
from brial        import Polynomial
from brial        import Variable
from brial.gbrefs import load_file
from brial.gbcore import groebner_basis
from Encoder.sflash_encoder import SflashEncoder
from Decoder.sflash_decoder import SflashDecoder
from Utils.asn1 import ASN1
import resource

#Biblioteca para generar numeros enteros aleatorios
from random import randint

#Biblioteca sys
import sys

#Biblioteca para el anyo, mes, dia, hora, minutos, segundos
import datetime

#Biblioteca para medir tiempo de ejecucion
import time

# startProcMem = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss

###################################################
#                    Functions                    #
###################################################
def getFileHandler(msg, mode):
    ''' Prints "msg", asking for the name of a file to open
        in mode "mode". Returns error code and file handler '''
    fName = raw_input(msg)
    if ( fName != fName.replace(' ', '') ):
        print "\nFile name error: '{0}'\n".format(fName)
        fh = 0     # No file handler
        RC = 1
    else:
        RC = 0
        try:
            fh = open(fName, mode)
        except:
            print("\nCould not open file {0}\n".format(fName))
            RC = 2
            fh = 0    # No file handler
    return RC, fh

def readPK(fi):
    ''' Reads a file with fileHandler "fi", that contains in each line,
        a multivariate quadratic equation. The file
        has the Public Key. Returns a list with the correct
        names of variables for PolyBoRi (x1 as x(1)) and the index
        of the greater variable '''
    polySet   = []
    nums      = '0123456789'
    maxNumVar = ''
    maxNVInt  = 0
    for line in fi:         # Read file
        aux = ''
        line = line.replace( '\n', '' ).replace('^','**')
        fixing = False
        for i in range( len(line) ):
            ch = line[i]
            if ( fixing and ( ch in nums ) ):
                maxNumVar += ch
            if ( ch == 'x' ):                               # x(
                fixing = True
                aux += 'x('
                continue
            if ( fixing and ( ch not in nums ) ):           # x(nn) not EOL
                fixing = False
                aux += ')' + ch
                if ( maxNVInt < int( maxNumVar ) ): maxNVInt = int( maxNumVar )
                maxNumVar = ''
                continue
            elif ( fixing and ( i == ( len(line) - 1 ) ) ): # x(nn) in EOL
                fixing = False
                aux += ch + ')'
                if ( maxNVInt < int( maxNumVar ) ): maxNVInt = int( maxNumVar )
                maxNumVar = ''
                continue
            else:
                aux += ch
        polySet.append(aux)
    return polySet, maxNVInt

def writePolyForPolyBoRi(Poly, numVars, filename):
    ''' "Poly" must be a list of polynomials in PolyBoRi syntax.
        "numVars" is the maximum index number of an 'x' variable.
        This function, creates a file "filename" with the correct
        sintax so it can be loaded to compute its Groebner Basis '''
    fo = open(filename, "w")
    fo.write( 'declare_ring([Block("x", ' + \
              str( numVars ) + ', reverse=False)])\n' )
    fo.write( 'ideal = [' + '\n' )
    coma = ','
    for i in range( len(Poly) ):
        if ( i == ( len(Poly) - 1 ) ):
            coma = ''
        if (Poly[i] != "0"):
        	fo.write( Poly[i] + coma + '\n' )
    fo.write( ']\n' )
    fo.close()

def getYesNo(msg):
	''' Prints "msg", asking for an answer either yes or no
        Returns error code and answer read '''
	ans = raw_input(msg)
    # if(ans.lower() == "yes" || ans.lower() == "ye" || ans.lower() == "y")
	if(ans[0].lower() == "y"):
   		inp = 1
	else:
		inp = 0
	return inp

def getInteger(msg):
    ''' Prints "msg", asking for an integer greater than zero
        Returns error code and integer read '''
    intNumber = raw_input(msg)
    RC     = 0
    error  = False
    try:			# Is a number?
        intN = int(intNumber)
    except:
        print("\nNot a number {0}\n".format(intNumber))
        error =  True
        intN  = -1
        RC    =  1
    if ( ( not error ) and ( intNumber == 0 ) ):
        print "\nNumber error: '{0}'\n".format(intNumber)
        intN = -1
        RC   =  2
    return RC, intN

def fillOnes(polynomial, vectorSize):
	lenpoly = len(polynomial)
	zeros = ""
	for i in range(vectorSize - lenpoly):
		zeros += "1"
	return zeros + polynomial

def generatePolynomials(n, m, vars, F):
    PolySet = []
    for i in range(m):
        polynomial = 0
        for j in range(n):
            for k in xrange(j, n):
                p = F.random_element()
                polynomial += p * (vars[j]*vars[k])
        for j in range(n):
            p = F.random_element()
            polynomial += p * vars[j]
        p = F.random_element()
        polynomial += p
        PolySet.append(polynomial)
    return PolySet

def genPolynomials(n, m, vars, F, d, K):
    binSize = ((n * (n + 1) * d) / 2)
    p = 0
    PolySet = []
    pol = []
    for i in range(m):
        pol.append(0)
    PolySet = vector(K, pol)
    x = F.gen()
    for i in range(m):
        polynomialInt = Integer(getrandbits(binSize))
        polynomial = polynomialInt.binary()
        p = (p << binSize) | polynomialInt
        if(len(polynomial) < binSize):
            polynomial = fillOnes(polynomial, binSize)
        z = 0
        poly = 0
        for j in range(n):
            for k in xrange(j, n):
                index = d*z
                # coef = polynomial[index:index + d]
                coef = "1"
                z += 1
                if(d > 1):
                    poly += F.fetch_int(int(coef, 2)) * (vars[j] * vars[k])
                else:
                    poly += int(coef,2) * (vars[j] * vars[k])
                PolySet[i] = poly
    return PolySet, p


def writePolynomialsSageFormat(polynomials):
    file = open("sageFormat.py", "w")
    file.write("P = []\n")
    for i in range(len(polynomials)):
        file.write("P.append(" + str(polynomials[i]) + ")\n")

def writePoly(Poly, fh, lenPK, maxNV, k, avgTime):
    ''' Store in file handler "fh" the contents of the vector of
        polynomials in "Poly" and some additional data'''
    for i in range( len(Poly) ):
        fh.write( "Polynomial " + str(i) + ":\n" + str(Poly[i])+"\n\n" );
    fh.write( "\nNumber of input equations:  {0}\n".format( lenPK ) )
    fh.write( "Total number of variables:  {0}\n".format( maxNV ) )
    fh.write( "Number of output equations: {0}\n".format( len(Poly) ) )
    fh.write( "Number of loops made:       {0}\n".format( k ) )
    fh.write( "Average elapsed time:       {0} secs.\n".format(avgTime) )

def writePolys(PolySet, m, n, q):
	now = datetime.datetime.now()
	if(q):
        	filename = "PolynomialsN" + str(n) + "M" + str(m) + str(now.day) + str(now.month) + str(now.year) + str(now.hour) + str(now.minute) + str(now.second) + "_Q"
    	else:
        	filename = "PolynomialsN" + str(n) + "M" + str(m) + str(now.day) + str(now.month) + str(now.year) + str(now.hour) + str(now.minute) + str(now.second)
    	file = open(filename, "w")
	for i in range(m - 1):
		file.write(str(PolySet[i]) + "\n")
	file.write(str(PolySet[m - 1]))
	return filename

def subs(f, x, c):
    ''' Evaluates polynomial "f" in "x = c". "x" must be in the format "x(i)"
        and "c" MUST be 0 or 1. Returns the new polynomial with "x = c" '''
    i = x.index() 
    s = f.set() 
    if c == 0: 
        return Polynomial(s.subset0(i)) 
    else: 
        return Polynomial(s.subset1(i))+Polynomial(s.subset0(i))

def iniVarsAssig(noVars):
    ''' Returns a list of size "noVars" with values = -1, indicating the
        variable represented for each slot has not been assigned a value '''
    return [ -1 for i in range(noVars) ]

def addVarAssig(listVA, noVar, value):
    ''' In the list "listVA[noVar]" puts "value" '''
    listVA[ noVar ] = value

def subsVarsAssig(poly, listVA):
    ''' Substitutes in "poly" the values in "listVA" different from -1. The index in
        "listVA" with a 0 or 1 will be the index of the variable to substitute '''
    for i in range( len(listVA) ):
        if ( listVA[i] != -1 ):
            poly = subs( poly, x(i), listVA[i] )
    return poly

def getFstVarMon(monomial):
    ''' Returns the first variable in the monomial "monomial" '''
    return [ i for i in monomial.variables() ][0]

def getLstMonsDge1(poly):
    ''' Analyze "poly" and returns only the monomials which have degree
        greater or equal than 1 '''
    listMons = []
    aux      = [ i for i in poly.terms() ]
    for i in range( len(aux) ):
        if ( aux[i].deg() >= 1 ):
            listMons.append(aux[i])
    return listMons

def randVect(size):
    ''' Returns a random vector of size "size" with 0, 1 values
        randomly generated '''
    vect = []
    for i in range(size):
        vect.append( random.randint(0,1) )
    return vect

def equalZero(polys, y):
    ''' A set of polynomials "polys" equal to "y", are modified
        so that they returns a polynomial set equal to Zero, ready
        to compute a Groebner Basis. REMARK: Size of "polys" and "y"
        MUST be the same (this is not checked) '''
    for i in range( len(y) ):
        polys[i] += y[i]
    return polys

def endOfPoly(poly):
    ''' Analyse "poly" and returns a code: if it is empty (1), or has only one variable
        (2) or has only one variable plus the constant "1" (3). Or has only 1 (4).
        Otherwise returns (0) '''
    if ( poly == 0 ): 			# Polynomial empty (0)
        RC = 1
    elif ( (not poly.has_constant_part()) and
           (poly.nvariables() == 1 )):	# Number variables equal 1
        RC = 2
    elif ( poly.has_constant_part() and (poly.nvariables() == 1) ): 	# One variable + 1
        RC = 3
    elif ( poly.has_constant_part() and (poly.nvariables() == 0) ):    # Just 1
        RC = 4
    else:
        RC = 0
    return RC

def writeEvaluationFile(polynomials, variables):
	file = open("evaluation.py", "w")
	numVars = len(variables)
	varVal = "("
	for i in range(numVars - 1):
		varVal += str(variables[i]) + ","
	varVal += str(variables[numVars - 1]) + ")"
	for i in range(len(polynomials) - 1):
		file.write("evaluation.append(polynomials[" + str(i) + "]" + varVal + ")\n")
	file.write("evaluation.append(polynomials[" + str(len(polynomials) - 1) + "]" + varVal + ")")
	file.close()

def generateQPolynomials(p, k, m):
    Q = []
    for i in range(m):
        Q.append(0)
        for j in range(m):
            Q[i] += k.random_element() * p[j]
    return Q

def decodePolynomials(polynomials, n, m, vars, F, d, K):
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

def writePrivateKey(filename, n, m, theta, p, k, ext, K):
    bigPoly = p^k - 1
    file = open(filename + "_private", "w")
    file.write("S = " + "\n")
    for i in range(n):
        for j in range(n):
            if k == 1:
                file.write(str(Integer(getrandbits(1))) + " ")
            else:
                file.write(str(K.fetch_int(bigPoly)) + " ")
        file.write("\n")
    file.write("s = ")
    for i in range(n):
        if k == 1:
            file.write(str(Integer(getrandbits(1))) + " ")
        else:
            file.write(str(K.fetch_int(bigPoly)) + " ")
    file.write("\n")
    file.write("T = " + "\n")
    for i in range(m):
        for j in range(m):
            if k == 1:
                file.write(str(Integer(getrandbits(1))) + " ")
            else:
                file.write(str(K.fetch_int(bigPoly)) + " ")
        file.write("\n")
    file.write("t = ")
    for i in range(n):
        if k == 1:
            file.write(str(Integer(getrandbits(1))) + " ")
        else:
            file.write(str(K.fetch_int(bigPoly)) + " ")
    file.write("\nn = " + str(n) + "\n")
    file.write("m = " + str(m) + "\n")
    file.write("theta = " + str(theta) + "\n")
    file.write("p = " + str(p) + "\n")
    file.write("k = " + str(k) + "\n")
    file.write("ext = " + str(ext) + "\n")
    file.close()

print "**********Generate polynomials**********"

Debug = False

for I in xrange(2, 101):
    # msg   = '\nNumber of variables to use: '
    # RC, n = getInteger(msg)
    # if(RC != 0):
    # 	sys.exit(1)

    # msg   = '\nNumber of polynomials: '
    # RC, m = getInteger(msg)
    # if(RC != 0):
    # 	sys.exit(2)

    # msg   = '\nFinite field characteristic: '
    # RC, p = getInteger(msg)
    # if(RC != 0):
    # 	sys.exit(3)

    # msg   = '\nFinite field degree: '
    # RC, d = getInteger(msg)
    # if(RC != 0):
    # 	sys.exit(1)
    n = I
    m = n
    p = 2
    d = int(1)

    # R.<X> = GF(p)[]
    r = PolynomialRing(GF(p), 'X')
    k = GF(p**d, 'x', GF(p)['X'].irreducible_element(d))
    # k.<x> = GF(p**d, GF(p)['X'].irreducible_element(d))
    K = PolynomialRing(k, "x", n, order='deglex')

    #Vector para la codificacion de los polinomios
    #
    # Ejemplo de codificacion para un polinomio
    # vector:
    # (a00, a01, ..., ann, b0, b1, ..., bn, c)
    #
    # vectorSize = (n * (n + 1)) / 2
    vectorSize = (n * (n + 1)) + 1

    #len(Integer(getrandbits(2048)).binary())
    vars = []
    vars.append(1)
    for i in range(n):
    	vars.append(K.gens()[i])

    # PolySet = generatePolynomials(n, m, K.gens(), k)
    # PolySet, num = genPolynomials(n + 1, m, vars, k, d, K)
    now = datetime.datetime.now()
    filename = "PolynomialsN" + str(n) + "M" + str(m) + str(now.day) + str(now.month) + str(now.year) + str(now.hour) + str(now.minute) + str(now.second)
    # file = open(filename, "w")
    # filename = writePolys(PolySet, m, n, False)
    writePrivateKey(filename, n, n, 11, p, d, 100, k)

    ##########################################################
    ##########################################################
    ########        Encoding Polynomials ASN.1      ##########
    ##########################################################
    ##########################################################

    # msg   = '\nEncode polynomials (yes/no): '
    # inp = getYesNo(msg)
    # if(inp == 0):
    #     sys.exit(0)

    encoder = SflashEncoder("BER")

    # publicBin = encoder.encodePublicKey(PolySet, n, p, d)
    # # publicBin = encoder.encodePublicKey(PolySet, n, p, d, bin(num)[2:])

    # file = open(filename + ".pub", "wb")
    # file.write(publicBin)
    # print("Public key has been store in " + file.name)
    # file.close()

    AG = AffineGroup(n, k)
    affine1 = AG.random_element()
    affine2 = AG.random_element()
    theta = 11

    privateBin = encoder.encodePrivateKey(affine1, affine2, p, d, theta)

    file = open(filename + ".priv", "wb")
    file.write(privateBin)
    print("Private key has been store in " + file.name)
    file.close()

    ##########################################################
    ##########################################################
    ########        Decoding Polynomials ASN.1      ##########
    ##########################################################
    ##########################################################

    # decoder = SflashDecoder("BER")

    # file = open(filename + ".pub", "rb")

    # # publicKey = decoder.decodePublicKey(file)
    # # nd, pd, baseField, decodedPoly = decoder.decodePublicKey(file)
    # polys = decoder.decodePublicKey(file)

    # file.close()

    # file = open(filename + ".priv", "rb")

    # nPriv, SPriv, sPriv, mPriv, TPriv, tPriv, pPriv, baseFieldPriv, thetaPriv = decoder.decodePrivateKey(file)

    # file.close()