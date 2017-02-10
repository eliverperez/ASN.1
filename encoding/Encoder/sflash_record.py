from .mi_record import *

class SflashPublicRecord(MIPublicRecord):
	def nada(self):
		return None

class SflashPrivateRecord(Record):
	componentType = namedtype.NamedTypes(namedtype.OptionalNamedType('primeField', univ.Integer()),
		namedtype.OptionalNamedType('baseField', univ.Integer()),
		namedtype.OptionalNamedType('extensionField', univ.Integer()),
		namedtype.OptionalNamedType('theta', univ.Integer()),
		namedtype.NamedType('mdim', univ.Integer()),
		namedtype.NamedType('affine1', univ.Integer()),
		namedtype.NamedType('ndim', univ.Integer()),
		namedtype.NamedType('affine2', univ.Integer()))

	def setPrimeField(self, p):
		self.setComponentByName('primeField', p)

	def setBaseField(self, baseField):
		self.setComponentByName('baseField', baseField)

	def setExtensionField(self, extField):
		self.setComponentByName('extensionField', extField)

	def setTheta(self, theta):
		self.setComponentByName('theta', theta)

	def setNdim(self, n):
		self.setComponentByName('ndim', n)

	def setAffine1(self, affine1):
		self.setComponentByName('affine1', affine1)

	def setAffine2(self, affine2):
		self.setComponentByName('affine2', affine2)

	def setMdim(self, m):
		self.setComponentByName('mdim', m)