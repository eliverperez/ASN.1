from pyasn1.codec.ber import encoder, decoder
from pyasn1.type import univ, namedtype
import base64
from Encoder.mi_record import MIPublicRecord

base64String = "MEoCAQICAQECAQUCPwTv9DeyNuwyeFys1AT3LXjQnnVUTxwLllrrmG8P0Nyd1scKzves7QJSNV8mrdPNG39H7pXRchmWU1Gakzdi5A=="

recovered = base64.b64decode(base64String)

decoded = decoder.decode(recovered)

p = int(decoded[0][0].prettyPrint())
baseField = int(decoded[0][1].prettyPrint())
n = int(decoded[0][2].prettyPrint())
polySize = ((n+1)*(n+2)*baseField / 2)
polynomials = Integer(decoded[0][3].prettyPrint()).binary()

print polynomials

res = polySize - (len(polynomials) % polySize)

if(res != polySize):
	for i in range(res):
		polynomials = "0" + polynomials

print "\n\n"

print polynomials