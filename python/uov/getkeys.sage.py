# This file was *autogenerated* from the file getkeys.sage
from sage.all_cmdline import *   # import sage library
_sage_const_3 = Integer(3); _sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_5 = Integer(5); _sage_const_4 = Integer(4)###################################################
#   Program to generate keys for authentication   #
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
load('cryptokeys.sage')
        
###################################################
#                  Initialization                 #
###################################################
if ( len( sys.argv ) == _sage_const_3  ):    # Decrypt only Public Key
    SKandPK = False
    encFile = sys.argv[_sage_const_1 ]
    PKFile  = sys.argv[_sage_const_2 ]
elif ( len( sys.argv ) == _sage_const_5  ):
    if ( sys.argv[_sage_const_1 ] == "-S" ):
        SKandPK = True
        encFile = sys.argv[_sage_const_2 ]
        SKFile  = sys.argv[_sage_const_3 ]
        PKFile  = sys.argv[_sage_const_4 ]
    else:
        print "\nBad parameter: {0}".format(argv[_sage_const_1 ])
        print "Usage: getkeys [-S] EncryptedFile [SKFile] PKFile\n\n"
        sys.exit(_sage_const_1 )
else:
    print "\nUsage: getkeys [-S] EncryptedFile [SKFile] PKFile\n\n"
    sys.exit(_sage_const_2 )
    
if ( not existFile( encFile ) ):
    print "\n\nFile {0} does not exist\n\n".format( encFile )
    sys.exit(_sage_const_3 )

extPI = ".ir"   # File name extension for files with polys represented as ints
extMV = ".mv"   # File name extension for files with Matrix an vector

###################################################
#                     Main code                   #
###################################################

####### Reading encrypted file with private and public key
CT_SK, CT_PK, error = getCTofSK_PK(encFile)
if ( error == True ):
    print "\n\nCorrupted encrypted file: {0}\n".format(encFile)
    sys.exit(_sage_const_4 )

####### Decrypting secret key:
if ( SKandPK ):
    print "\n\nDecrypting Secret Key."
    pp = askPP("\nPlease enter pass-phrase to decrypt private key: ")
    error = getSK(CT_SK, SKFile + extPI, SKFile + extMV, pp)
    if ( error ):
        print "\nError decrypting (wrong Pass-Phrase?)!!!"

####### Decrypting public key:
print "\n\nDecrypting Public Key."
getPK(CT_PK, PKFile + extPI, PKFile, easyK)

print "\ndone!\n"


