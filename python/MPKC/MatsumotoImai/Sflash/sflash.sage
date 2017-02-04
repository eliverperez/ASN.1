reset() # Erase all previously defined variables

load('asn1.sage')
load('sflash_encoder.sage')
###################################################
#                  Initialization                 #
###################################################

if (len( sys.argv ) < 1):
	print "Operation required\n"
	sys.exit(1)

encoder = asn1("BER")
keyEncoder = SflashEncoder()
import binascii

op = sys.argv[1]
print(op)
if op == '--gen':
	print 'Generating'
	load('sflash_keygen.sage')
if op == '--text':
	key = sys.argv[2]
	dir = sys.argv[3]
	if key == 'pub':
		print 'Reading Public Key'
		f = open(dir, 'rb')
		pubBer = encoder.decode(binascii.hexlify(f.read()), 'hex')
		print('*** Public Key ***\n')		
		print('nvars = ' + str(binToInt(pubBer[0][1])))
		print('Public System:')
		print(binascii.hexlify(pubBer[1][1]))
		f.close()
	elif key == 'priv':
		print 'Reading Private Key'
		f = open(dir, 'rb')
		privBer = encoder.decode(binascii.hexlify(f.read()), 'hex')
		print('*** Private Key ***\n')
		print('delta = ' + binascii.hexlify(privBer[0][1]))
		print('m = ' + str(binToInt(privBer[1][1])))
		print('S :\n' + binascii.hexlify(privBer[2][1]))
		print('n = ' + str(binToInt(privBer[3][1])))
		print('T :\n' + binascii.hexlify(privBer[4][1]))
		f.close()
if op == '--sign':
	print 'Signing'
	dir = sys.argv[2]
	f = open(dir, 'rb')
	pubKey = keyEncoder.decodePrivate(bytearray.fromhex(binascii.hexlify(f.read())), 'hex')
	#Generate a signature from stored private key
	ValueError('Not IMplemented')
	
