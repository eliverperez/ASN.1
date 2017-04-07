R.<X> = GF(2)[]
k.<x> = GF(2**7, GF(2)['X'].irreducible_element(7))
K = PolynomialRing(k, "x", 100, order='deglex')