from MPKC.MatsumotoImai.Sflash.sflash_record import *
from pyasn1.codec.ber import encoder
import base64 

def testSflashRecord():
	record = SflashPrivateRecord()
	record.setAffine1(2)
	record.setAffine2(2)
	record.setNdim(2)
	record.setMdim(2)
	record.setDelta(2)
	print(record.prettyPrint())
	print(base64.b64encode(encoder.encode(record)))

testSflashRecord()
