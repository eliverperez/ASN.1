R.<X> = GF(2)[]
k.<x> = GF(2**5, GF(2)['X'].irreducible_element(5))
K = PolynomialRing(k, "x", 5, order='deglex')