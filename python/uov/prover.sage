###################################################
#        Program to read secret key set           #
#             from a couple of files              #
#                                                 #
#   Jose Luis Juan Herrera Garcia       May, 2015 #
#   Thesis work                                   #
#   Computer science graduate studies             #
#   CINVESTAV                                     #
###################################################

reset() # Erase all previously defined variables

###################################################
#                      Add-on's                   #
###################################################
import copy
import sys
load('uov.sage')

###################################################
#                    Functions                    #
###################################################

###################################################
#                  Initialization                 #
###################################################
if ( len( sys.argv ) != 2 ):
    print "\nUsage: genkey SecKeyFile\n"
    sys.exit(1)
else:
    SKFile    = sys.argv[1]

extPI = ".ir"   # File name extension for files with polys represented as ints
extMV = ".mv"   # File name extension for files with Matrix an vector
CTE  = 100000   # Just a constant to be added to the constant term of poly
porc = 1.0/3.0  # Percentage of Oil variables

###################################################
#                     Main code                   #
###################################################
####### Reading Secret Key file represented as integers
print "\nReading file with Integer Representation of a secret polynomial \
system ({0}{1})\n".format(SKFile, extPI)
n, o, secIntRep = readInt(SKFile + extPI)
print "Number of variables:        ", n
print "Number of vinegar variables:", n-o
print "Number of oil variables:    ", o

####### Define variables for polynomial environment
print "\nDefining data structures for polynomial management"
v = n-o         # Number of Vinegar variables
a = list(var('a%d' % i) for i in range(n))  # Define 'a' list.
x = list(var('x%d' % i) for i in range(n))  # Define 'x' list. No matter
                                            # its content
k = PolynomialRing( GF(2), len(a) + len(x),
                    a + x )                 # Polynomial ring in 'n' variables
for i in range(n):          # Now 'a' and 'x' list have generators
    a[i] = k.gen(i)
    x[i] = k.gen(len(a) + i)
yUOV = vector(GF(2), o)     # Evaluation of polynomial (PiUOV)
Ms    = matrix(GF(2), n, n) # Matrix for affine transformation
vs    = vector(GF(2), n)    # Vector for affine transformation
PiUOV = vector(k, o)        # 'o' polynomials will be generated

####### Coding an integer represented secret key, back to polynomial secret key
print "\nConverting read data of an integer representation secret polynomial \
to a real polynomial system"
PiUOV = int2PolySys(secIntRep, n, a)
printPolyVect(PiUOV, "Secret polynomials:")

####### Reading matrix and vector of secret key
print "\nReading matrix and vector from file ({0}{1})\n".\
      format(SKFile, extMV)
n, Ms, vs = readMat(SKFile + extMV)
print "Matrix read:\n{0}".format(Ms)
print "\nVector read:\n{0}".format(vs)

###################################################
#                 Code for protocol               #
###################################################
print "\ndone!\n"

