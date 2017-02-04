import numpy
import sys
polSet = eval(sys.argv[1])
print sorted(polSet, reverse=True)
print numpy.argsort(polSet)[::-1][:len(polSet)]
