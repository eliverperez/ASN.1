###################################################
#   Functions to encrypt/decrypt files with keys  #
#                                                 #
#   Jose Luis Juan Herrera Garcia       May, 2015 #
#   Thesis work                                   #
#   Computer science graduate studies             #
#   CINVESTAV                                     #
###################################################

###################################################
#                      Add-on's                   #
###################################################
import sys
import getpass
from Crypto.Cipher import AES
from Crypto import Random
from Crypto.Hash import SHA256

###################################################
#                    Functions                    #
###################################################
class AESCipher:
    def __init__( self, key ):
        self.key = key

    def encrypt( self, raw ):
        raw = pad(raw)
        iv = Random.new().read( AES.block_size )
        cipher = AES.new( self.key, AES.MODE_CBC, iv )
        return ( iv + cipher.encrypt( raw ) )

    def decrypt( self, enc ):
        iv = enc[:16]
        cipher = AES.new(self.key, AES.MODE_CBC, iv )
        return unpad(cipher.decrypt( enc[16:] ))
    
def readPP(msg):
    ''' Reads from keyboard passphrase to use to encrypt
        secret key '''
    equal = False
    while ( not equal ):
        pp = ''
        while ( pp == '' ):
            pp = getpass.getpass(msg)
        pp2 = getpass.getpass("Retype pass-phrase: ")
        if ( pp == pp2 ):
            equal = True
        else:
            print "Pass-phrase do not match."
    hFunc = SHA256.new()
    hFunc.update(pp)
    return hFunc.hexdigest()[:16]   # So passphrase be of 16 characters

def askPP(msg):
    ''' Reads from keyboard passphrase, normally used to decrypt a file
        that's why it does not confirm the password '''
    pp = ''
    while ( pp == '' ):
        pp = getpass.getpass(msg)
    hFunc = SHA256.new()
    hFunc.update(pp)
    return hFunc.hexdigest()[:16]   # So passphrase be of 16 characters

def genInt(listInt, n):
    ''' Returns the contents of "listInt". The first two fields
        are the total number of variables "n" and the total
        number of polynomials "len(listInt)". '''
    PT  = str(n) + "\n"                 # Total number of variables
    PT += str(len(listInt)) + "\n"    # Total number of polynomials
    for i in range( len(listInt) ):
        for j in range( len(listInt[i]) ):
            PT += str(listInt[i][j]) + ' '
        PT += "\n"
    return PT

def genSKEnc(Poly, Mat, vec, key):
    ''' Returns the encryption of polynomials in private key,
        the matrix "Mat" and vector "vec", encrypted with key "key" '''
    
    n = Mat.nrows()
    
    PolyInt = polySys2Int(Poly, n, 'a') # Polynomials to integer representation
    PT = genInt(PolyInt, n)             # Write to variable

    PT += str(n) + "\n"                 # Only number of rows (n x n matrix)
    for i in range( Mat.nrows() ):      # Write matrix
        aux = Ms[i]
        aux = vect2Bin( aux ).replace('(','').replace(')','')
        aux = str(int( aux, 2 ))
        PT += aux + " "
    PT += "\n"
    aux = vs                            # Write vector
    aux = vect2Bin( aux ).replace('(','').replace(')','')
    aux = str(int( aux, 2 ))
    PT += aux
#    aes = AESCipher(key)                # Create block cipher
#    return aes.encrypt(PT)              # Returns cipher text
    return PT

def genPKEnc(Poly, n, key):
    ''' Returns the encryption of the number of variables "n",
        the number of equations, followed by the integer representation
        of the plain polynomials in public key '''
    PT  = genInt(polySys2Int(Poly, n, 'x'), n)          
    for i in range( len(Poly) ):      # Write polynomials "as is" to PT
        PT += str(Poly[i])+"\n"
#    aes = AESCipher(key)                # Create block cipher
#    return aes.encrypt(PT)              # Returns cipher text
    return PT

def writeKeysEnc(SKPoly, Mat, vec, PKPoly, keySK, keyPK, filename):
    ''' Creates a file "filename" and saves in it the encryption of the
        secret key using "keySK" then a separator and then the encryption
        of the public key using "keyPK". If "filename" exists,
        it will be cleared '''
    fo = open(filename, "wb")   # Open file to store SK + PK encrypted
    n  = Mat.nrows()
    CT = genSKEnc(SKPoly, Mat, vec, keySK)  # Encryption of secret key
    fo.write(CT)                            # Write secret key to file
    fo.write(separator)                     # Write separator to file
    CT = genPKEnc(PKPoly, n, keyPK)         # Encryption of public key
    fo.write(CT)                            # Write public key to file
    fo.close()

def existFile(fileName):
    ''' Just check if file "fileName" can be open for reading '''
    try:
        fh     = open(fileName, "rb")
        fh.close()
        status = True
    except:
        status = False
    return status

def getCTofSK_PK(encFN):
    ''' Reads a file "encFN" and returns a string with the cipher text
        of the secret key and another string with the cipher text of the
        public key. It is supposed, that in the file, these two strings are
        separated by the global string "separator". If it is not case 'error'
        returns in True and the ciphertext returned are not valid '''
    error     = True
    LS        = len(separator)      # Size of global variable 'separator'
    fhENC     = open( encFN, "rb" )
    CT_SK     = ''
    CT_PK     = ''
    readingSK = True
    i         = 0           # Pointer to characters in 'separator'
    pseudoSep = ''

    aux = fhENC.read(1)
    while ( aux != "" ):
        if ( (aux != separator[i]) and readingSK ):
            if ( i > 0 ):
                CT_SK    += pseudoSep
                i         = 0      # Pointer to characters in 'separator'
                pseudoSep = ''
            CT_SK += aux
        elif ( not readingSK ):
            CT_PK += aux
        else:
            pseudoSep += aux
            if ( len( pseudoSep ) == LS ):
                i         = 0
                readingSK = False
                error     = False
            else:
                i += 1
        aux = fhENC.read(1)
    fhENC.close()
    return CT_SK, CT_PK, error

def splitPT_SK(SK_PT):
    ''' Split "SK_PT" into polynomials integer representation and
        matrix-vector integer representation '''
    nl       = "\n"                 # New line
    PT       = SK_PT.splitlines()   # Convert SK_PT to a list

    error = False
    SKir  = ''
    SKmv  = ''
    try:
        n        = int( PT[0] )     # Just to see it is a number
        numPolys = int( PT[1] )     # Second field = number of polynomials
    except:
        error = True
    if ( (not error) and ( len(PT) == (numPolys +5) ) ):
        SKir     = PT[0] + nl + PT[1] + nl
        for i in range( numPolys ):
            SKir += PT[i + 2] + nl
        ptrMV = numPolys + 2
        SKmv     = PT[ptrMV] + nl + PT[ptrMV+1] + nl + PT[ptrMV+2] + ' ' + nl
    return SKir, SKmv, error

def splitPT_PK(PK_PT):
    ''' Split "PK_PT" into polynomials integer representation
        and raw polynomials '''
    nl       = "\n"                 # New line
    PT       = PK_PT.splitlines()   # Convert PK_PT to a list
    numPolys = int( PT[1] )         # Second field = number of polynomials
    PKir     = PT[0] + nl + PT[1] + nl
    for i in range( numPolys ):
        PKir += PT[i + 2] + nl
    ptrPolys  = numPolys + 2
    PK        = ''
    for i in range( ptrPolys, ptrPolys+numPolys ):
        PK += PT[i] + nl
    return PKir, PK

def getSK(SK_CT, outIR, outMV, key):
    ''' String "SK_CT" must be an encryption of the secret key
        Using key "key" will try to decrypt the string
        writing the output of the polynomials in integer representation
        to the "outIR" file and the matrix and vector to the "outMV" file.
        If files "outIR" or "outMV" already exists, they will be cleared '''
    fhIR  = open(outIR, "w")
    fhMV  = open(outMV, "w")
    
    #aes = AESCipher(key)                # Create block cipher
    #PT  = aes.decrypt(SK_CT)            # decrypt cipher text
    PT  = SK_C
    SKir, SKmv, error = splitPT_SK(PT)
    if ( not error ):
        fhIR.write( SKir )
        fhMV.write( SKmv )
    
    fhMV.close()
    fhIR.close()
    return error

def getPK(PK_CT, outIR, outPo, key):
    ''' String "PK_CT" must be an encryption of the public key
        Using key "key" will try to decrypt the string
        writing the output of the polynomials in integer representation
        to the "outIR" file and the raw polynoials to the "outPo" file.
        If files "outIR" or "outPo" already exists, they will be cleared '''
    fhIR  = open(outIR, "w")
    fhP   = open(outPo, "w")
    
    aes = AESCipher(key)                # Create block cipher
    PT  = aes.decrypt(PK_CT)            # decrypt cipher text
    PKir, PK = splitPT_PK(PT)
    fhIR.write( PKir )
    fhP.write( PK )
    
    fhP.close()
    fhIR.close()

####### For encryption:
easyK = "abcdefghijklmnop"  # To encrypt public key. Must be 16 chars!
BS    = 16
pad   = lambda s: s + (BS - len(s) % BS) * chr(BS - len(s) % BS) 
unpad = lambda s : s[:-ord(s[len(s)-1:])]
separator = "End of Secret Key. Start of Public Key."











#Store the public key set
def storePublicKey(polSet, filePath):
    file = open(filePath, 'w')
    file.write(str(len(polSet)) + '\n')
    for i in range(len(polSet)):
        file.write(str(polToInt(polSet[i])) + '\n')
    file.close()

def polToInt(p):
    bin = 0
    vars = p.parent().gens()
    varNum = len(vars)
    #Quadratic coefficients
    for i in range(varNum):
        for j in range(i, varNum):
            c = int(p.coefficient(vars[i]*vars[j]))
            bin = (bin << 1) | c
            p = p - c*vars[i]*vars[j]
    #Linear coefficients
    for i in range(varNum):
        c = int(p.coefficient(vars[i]))
        bin = (bin << 1) | c
    #Constant coefficient
    bin = (bin << 1) | int(p.constant_coefficient())
    return bin

def intToBin(num):
    bytes = []
    cont = 0
    while num > 0 and cont < 1000:
        bytes.append(num & 0xff)
        num = num >> 8
        cont+=1
    return bytes
    
def polToBin(p):
    return intToBin(polToInt(p))

