###################################################
#           SHA256 hashing of a Public Key        #
#                                                 #
#   Jose Luis Juan Herrera Garcia       May, 2015 #
#   Thesis work                                   #
#   Computer science graduate studies             #
###################################################

###################################################
#                      Add-on's                   #
###################################################
import os
import sys
from Crypto.Hash import SHA256

###################################################
#                    Constants                    #
###################################################

###################################################
#                    Functions                    #
###################################################
def inputFile(Msg):
    ''' Reads the name of an input file and creates
        a filehandler for it. If the file exists
        also returns the size of it '''
    fName = raw_input(Msg)
    fsize = 0
    if ( fName != fName.replace(' ', '') ):
        print "\nInput file name error: '{0}'\n".format(fName)
        fpIn = 0     # No file handler
        RC = 1
    else:
        RC = 0
        try:
            fpIn = open(fName, "rb")
            fsize = os.path.getsize(fName)
        except:
            print("\nFile {0} does not exist\n".format(fName))
            RC = 2
            fpIn = 0    # No file handler
    return RC, fpIn, fsize

def outputFile(Msg):
    ''' Reads the name of an output file and creates
        a filehandler for it. If the file exists
        it will be cleared '''
    fName = raw_input(Msg)
    if ( fName != fName.replace(' ', '') ):
        print "\nOutput file name error: '{0}'\n".format(fName)
        fpOut = 0     # No file handler
        RC    = 1
    else:
        RC = 0
        try:
            fpOut = open(fName, "wb")
        except:
            print("\nCould not create {0}\n".format(fName))
            RC = 2
            fpOut = 0    # No file handler
    return RC, fpOut

def hashBF(fp, offset, nbytes, pHash):
    ''' From file pointer "fp" and starting at position "offset"
        of that file, reads "nbytes" then appends "pHash" and
        computes the SHA256 hash. This values is returned '''
    hFunc = SHA256.new()            # Create SHA256 object
    toHash = ''
    fp.seek(offset)
    for i in range(nbytes):
        toHash += fp.read(1)
    toHash += pHash
    hFunc.update(toHash)
    return hFunc.digest(), hFunc.hexdigest()

###################################################
#                  Initialization                 #
###################################################
RC, fpi, fsize = inputFile('\nPublic key file name to hash: ') # File to hash
if ( RC != 0 ): sys.exit(1)
print "Public key file size: {0}\n".format(fsize)

RC, fpo = outputFile('Hash file name: ')      # File to store hash
if ( RC != 0 ): sys.exit(2)

###################################################
#                     Main code                   #
###################################################
h_dec, h_hex = hashBF( fpi, 0, fsize, '' )
fpo.write(h_hex)
print "\nComputed hash:", h_hex

fpo.close()
fpi.close()
print "\ndone!"

