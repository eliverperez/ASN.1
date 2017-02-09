from brial        import *
from brial        import Block, declare_ring
from brial        import Polynomial
from brial        import Variable
from brial.gbrefs import load_file
from brial.gbcore import groebner_basis
from Encoder.sflash_encoder import SflashEncoder
from Utils.asn1 import ASN1

#Biblioteca para generar numeros enteros aleatorios
from random import randint

#Biblioteca sys
import sys

#Biblioteca para el anyo, mes, dia, hora, minutos, segundos
import datetime

#Biblioteca para medir tiempo de ejecucion
import time

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

def fillZeros(polynomial, vectorSize):
	lenpoly = len(polynomial)
	zeros = ""
	for i in range(vectorSize - lenpoly):
		zeros += "0"
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
	binSize = ((n * (n + 1)) / 2) * d
	PolySet = []
    	pol = []
    	for i in range(m):
        	pol.append(0)
    	PolySet = vector(K, pol)
	x = F.gen()
	for i in range(m):
		polynomial = Integer(getrandbits(binSize)).binary()
		if(len(polynomial) < binSize):
			polynomial = fillZeros(polynomial, binSize)
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

print "**********Generate polynomials**********"

Debug = False

msg   = '\nNumber of variables to use: '
RC, n = getInteger(msg)
if(RC != 0):
	sys.exit(1)

msg   = '\nNumber of polynomials: '
RC, m = getInteger(msg)
if(RC != 0):
	sys.exit(2)

msg   = '\nFinite field characteristic: '
RC, p = getInteger(msg)
if(RC != 0):
	sys.exit(3)

msg   = '\nFinite field degree: '
RC, d = getInteger(msg)
if(RC != 0):
	sys.exit(1)

R.<X> = GF(p)[]
k.<x> = GF(p**d, GF(p)['X'].irreducible_element(d))
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

print "1"

# PolySet = generatePolynomials(n, m, K.gens(), k)
PolySet = genPolynomials(n + 1, m, vars, k, d, K)

print "2"

filename = writePolys(PolySet, m, n, False)

msg   = '\nEncode polynomials (yes/no): '
inp = getYesNo(msg)
if(inp == 0):
    sys.exit(0)

encoder = SflashEncoder("BER")

publicBin = encoder.encodePublicKey(PolySet, p, d)

msg   = '\nCalculate Groebner Bases (yes/no): '
inp = getYesNo(msg)
if(inp == 0):
	sys.exit(0)

Q = generateQPolynomials(PolySet, k, m)

q_filename = writePolys(Q, m, n, True)

polyfile = open(filename, "r")
q_file = open(q_filename, "r")

groebner_basis_file = open(filename + "_GroebnerBasisOutput", "w")
q_groebner_basis_file = open(q_filename + "_GroebnerBasisOutput", "w")

###################################################
#                     Main code                   #
###################################################
PK, maxNV = readPK(polyfile)                    # Convert file to PolyBoRi format
maxNV    += 1				    			# Not an index but a quantity
writePolyForPolyBoRi(PK, maxNV, "forPB.py")    # Generate file for Groebner Basis
# data = load_file("forPB")                   # Import file to use in GB
data = load("forPB.py")                   # Import file to use in GB

polynomials = ideal

print "poly = " + str(PK)
print "maxNV = " + str(maxNV)

####### Computes Groebner Basis for a set of polynomials equal to an
####### algebraic variety
startTime = time.time()
gb = groebner_basis( polynomials )
endTime = time.time()
timeTaken = endTime - startTime

print "\nComputed Groebner Basis:\n"
print gb



print "\nNumber of input equations:  {0}".format( len(PK) )
print "Total number of variables:  {0}".format( maxNV )
print "Number of output equations: {0}".format( len(gb) )
print "Elapsed time:       {0} secs.".format(timeTaken)
print "Field characteristic: \t", p
print "Field degree: \t", d

groebner_basis_file.write("Computed Groebner Basis:\n" + str(gb))
groebner_basis_file.write("\nNumber of input equations:  \t" + format( len(PK) ))
groebner_basis_file.write("\nTotal number of variables:  \t" + format( maxNV ))
# groebner_basis_file.write("\nNumber of loops made:       \t" + format( k ))
groebner_basis_file.write("\nElapsed time:       \t secs." + format(timeTaken))
groebner_basis_file.write("\nField characteristic: \t\t" + str(p))
groebner_basis_file.write("\nField degree: \t\t\t" + str(d))

groebner_basis_file.close()

# for i in range(len(times)):
#     print "Time taken GB "+str(i+1)+": " + str(times[i])

# writePoly(gb, fpOut, len(PK), maxNV, k, acumm/k)

# fpIn.close()
# fpOut.close()
polyfile.close()

###################################################
#  Find values of variables using Groebner Basis  #
###################################################
print "\nFinding values of variables using the Groebner Basis"

declare_ring([Block("x", maxNV, reverse=False)])
listVars   = iniVarsAssig(maxNV)	# Initialize list holding values of assigned variables
listMDge1  = []				# List to store monomials with degree greater than 1

for i in range( len(gb) ):
    poly = gb[i]			# Read forward each polynomial in Groebner Basis file
    if (Debug): print "\n{0}. Working with:\n{1}".format(i,poly)

    poly = subsVarsAssig(poly, listVars)	# Evaluate "poly" in already found variables

    if (Debug): print "Variables already found:",listVars
    if (Debug): print "Poly after substituting current variables:\n{0}".format(poly)

    while ( True ):                             # If there are monomials with deg>=1 do:
        listMDge1    = getLstMonsDge1(poly)	# Get monomials to use in this cycle
        if ( len(listMDge1) > 0 ):              # If there are monomials left:
            var = getFstVarMon( listMDge1[0] )	# Get first variable of monomial with deg>1
        else:
            break
        if (Debug): print "Variable to assign value: {0}.".format(var),
        status = endOfPoly(poly)
        if   ( status == 0 ):   # Several monomials in poly, still pending
            addVarAssig(listVars, var.index(), 0)
            if (Debug): print "Assigned value:",0
            poly = subsVarsAssig(poly, listVars)
            continue
        elif ( status == 1 ):   # All terms in "poly" evaluated to cero
            break               # so, continue with next polynomial
        elif ( status == 2 ):   # Just one variable left, set it as zero and next poly
            addVarAssig(listVars, var.index(), 0)
            if (Debug): print "Assigned value:",0
            break
        elif ( status == 3 ):   # Just one variable left plus a constant,
            addVarAssig(listVars, var.index(), 1)   # so, set it as one and next poly
            if (Debug): print "Assigned value:",1
            break
        else:                   # status = 4, INCONSISTENCY!!!
            if (Debug): print "Inconsistency in polynomial {0}. 1 = 0!!!".format(i)
            break

print "Variables found:"
for i in range( len(listVars) ):
    if ( listVars[i] != -1 ):
        print "x({0}) = {1}".format( i, listVars[i] )

writeEvaluationFile(polynomials, listVars)

evaluation = []

load("evaluation.py")

evaluationResult = True

for i in range(len(evaluation)):
	if(evaluation[i] != 0):
		evaluationResult = False
		break

if(evaluationResult):
	print "\nBases de groebner correctas\n"
else:
	print "\nResultados incorrectos\n"

print "\nVector de resultados de la evaluacion\n"

print evaluation





###################################################
#                     Main code                   #
###################################################
PK, maxNV = readPK(q_file)                    # Convert file to PolyBoRi format
maxNV    += 1                               # Not an index but a quantity
writePolyForPolyBoRi(PK, maxNV, "forPB_Q.py")    # Generate file for Groebner Basis
# data = load_file("forPB")                   # Import file to use in GB
data = load("forPB_Q.py")                   # Import file to use in GB

polynomials = ideal

####### Computes Groebner Basis for a set of polynomials equal to an
####### algebraic variety
startTime = time.time()
gb = groebner_basis( polynomials )
endTime = time.time()
timeTaken = endTime - startTime

print "\nQ-Computed Groebner Basis:\n"
print gb

print "\nNumber of input equations:  {0}".format( len(PK) )
print "Total number of variables:  {0}".format( maxNV )
print "Number of output equations: {0}".format( len(gb) )
print "Elapsed time:       {0} secs.".format(timeTaken)
print "Field characteristic: \t", p
print "Field degree: \t", d

q_groebner_basis_file.write("Computed Groebner Basis:\n" + str(gb))
q_groebner_basis_file.write("\nNumber of input equations:  \t" + format( len(PK) ))
q_groebner_basis_file.write("\nTotal number of variables:  \t" + format( maxNV ))
q_groebner_basis_file.write("\nElapsed time:       \t secs." + format(timeTaken))
q_groebner_basis_file.write("\nField characteristic: \t\t" + str(p))
q_groebner_basis_file.write("\nField degree: \t\t\t" + str(d))

q_groebner_basis_file.close()

# for i in range(len(times)):
#     print "Time taken GB "+str(i+1)+": " + str(times[i])

# writePoly(gb, fpOut, len(PK), maxNV, k, acumm/k)

# fpIn.close()
# fpOut.close()
q_file.close()

###################################################
#  Find values of variables using Groebner Basis  #
###################################################
print "\nFinding values of variables using the Groebner Basis"

declare_ring([Block("x", maxNV, reverse=False)])
listVars   = iniVarsAssig(maxNV)    # Initialize list holding values of assigned variables
listMDge1  = []             # List to store monomials with degree greater than 1

for i in range( len(gb) ):
    poly = gb[i]            # Read forward each polynomial in Groebner Basis file
    if (Debug): print "\n{0}. Working with:\n{1}".format(i,poly)

    poly = subsVarsAssig(poly, listVars)    # Evaluate "poly" in already found variables

    if (Debug): print "Variables already found:",listVars
    if (Debug): print "Poly after substituting current variables:\n{0}".format(poly)

    while ( True ):                             # If there are monomials with deg>=1 do:
        listMDge1    = getLstMonsDge1(poly) # Get monomials to use in this cycle
        if ( len(listMDge1) > 0 ):              # If there are monomials left:
            var = getFstVarMon( listMDge1[0] )  # Get first variable of monomial with deg>1
        else:
            break
        if (Debug): print "Variable to assign value: {0}.".format(var),
        status = endOfPoly(poly)
        if   ( status == 0 ):   # Several monomials in poly, still pending
            addVarAssig(listVars, var.index(), 0)
            if (Debug): print "Assigned value:",0
            poly = subsVarsAssig(poly, listVars)
            continue
        elif ( status == 1 ):   # All terms in "poly" evaluated to cero
            break               # so, continue with next polynomial
        elif ( status == 2 ):   # Just one variable left, set it as zero and next poly
            addVarAssig(listVars, var.index(), 0)
            if (Debug): print "Assigned value:",0
            break
        elif ( status == 3 ):   # Just one variable left plus a constant,
            addVarAssig(listVars, var.index(), 1)   # so, set it as one and next poly
            if (Debug): print "Assigned value:",1
            break
        else:                   # status = 4, INCONSISTENCY!!!
            if (Debug): print "Inconsistency in polynomial {0}. 1 = 0!!!".format(i)
            break

print "Variables found:"
for i in range( len(listVars) ):
    if ( listVars[i] != -1 ):
        print "x({0}) = {1}".format( i, listVars[i] )

writeEvaluationFile(polynomials, listVars)

evaluation = []

load("evaluation.py")

evaluationResult = True

for i in range(len(evaluation)):
    if(evaluation[i] != 0):
        evaluationResult = False
        break

if(evaluationResult):
    print "\nBases de groebner correctas\n"
else:
    print "\nResultados incorrectos\n"

print "\nVector de resultados de la evaluacion\n"

print evaluation





#################################################################
#################################################################
#######                 Write Polynomials P                ######
#################################################################
#################################################################

# writePolynomialsSageFormat(polynomials)

# nu = randint(0, 2^(m*m))


