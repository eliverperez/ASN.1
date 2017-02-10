R.<X> = GF(2)[]
k.<x> = GF(2**3, GF(2)['X'].irreducible_element(3))
K = PolynomialRing(k, "x", 10, order='deglex')