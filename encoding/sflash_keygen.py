#reset() # Erase all previously defined variables

###################################################
#                  Initialization                 #
###################################################
from MPKC.MatsumotoImai.Sflash.sflash_encoder import SflashEncoder
from MPKC.MatsumotoImai.Sflash.sflash_generator import SflashKeyGenerator
from MPKC.Utils.asn1 import ASN1
import binascii
import sys
import os

if (len( sys.argv ) < 1 ):
	print("Out file required!\n")
	sys.exit(1)

dir = sys.argv[len(sys.argv) - 1]
if not os.path.isdir(dir):
	filePath = dir
	idx = dir[::-1].find("/")
	if idx > 0:
		dir = dir[0: len(dir) - idx - 1]
		if not os.path.isdir(dir):
			print("Out file required!\n")
			sys.exit(1)
else:
	filePath = dir + '/sflash'

encoder = SflashEncoder("BER")
#asn = encoder.getEncoder()
keygen = SflashKeyGenerator()
keyPair = keygen.generateKeyPair()

publicBin = encoder.encodePublic(keyPair.getPublic())
privateBin = encoder.encodePrivate(keyPair.getPrivate())

#print(binascii.hexlify(publicBin))
#print(binascii.hexlify(privateBin))
print(publicBin)
print(privateBin)

file = open(filePath + ".pub", "wb")
file.write(publicBin)
print("Public key has been store in " + file.name)
file.close()

file = open(filePath + ".priv", "wb")
file.write(privateBin)
print("Private key has been stored in " + file.name)
file.close()
