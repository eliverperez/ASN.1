from pyasn1.codec.ber import encoder, decoder
from pyasn1.type import univ, namedtype
import base64
from Encoder.mi_record import MIPublicRecord

base64String = "MIHmAgECAgEFAgEFAoHaHGaBCeCy6PjwG0vDVfFujA3eoOfIMaWGPf1wrXPbJIfeaIcSS2266wvBjKLscR3HvMy4GnQ03L/DHXdULWjBW9ztvwRYE9Rop4c2mBwKR948U2QYNJTVzxI9JWqtj/1RBKrNMWL6+i/5ct0MeTLflOj8wCpiJJVD6Z/iueELGmC0JIobYhXPAyLswejAy8M7BrZO0ftMVrSMZ50LRDanUcoxH8kB9LEbqcmXZVvFdDajhxagOvZKSsLb1cwJZfTSo16bM7FCFY7uyGqY3zIywX9UoJIsHAbcfS8="

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