R.<X> = GF(2)[]
k.<x> = GF(2**1, GF(2)['X'].irreducible_element(1))
K = PolynomialRing(k, "x", 100, order='deglex')