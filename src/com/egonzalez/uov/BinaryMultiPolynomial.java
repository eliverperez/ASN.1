package com.egonzalez.uov;

import java.math.BigInteger;

public class BinaryMultiPolynomial {
	private BigInteger coefficients;
	private int nVars;
	private String varName;
	
	BinaryMultiPolynomial(BigInteger coefficients, int nVars, String varName) {
		this.coefficients = coefficients;
		this.nVars = nVars;
		this.varName = varName;			
	}
	
	public String toString() {
		BigInteger auxCoef = coefficients;
		int lowBit = auxCoef.getLowestSetBit();
		String polStr = lowBit == 0 ? " + 1" : "";
		String linStr = "";
		String quadStr = "";
		auxCoef = auxCoef.clearBit(0);
		while ((lowBit = auxCoef.getLowestSetBit()) <= this.nVars && lowBit != -1) {
			linStr = varName + (this.nVars - lowBit) + " + " + linStr;
			auxCoef = auxCoef.clearBit(lowBit);
		}
		int i = 1;
		int j = 0;
		int j1 = 1;
		int j2 = 0;
		int k = 0;
		while (lowBit != -1) {
			k = lowBit - this.nVars;
		    j1 = (i * (i + 1)) / 2;
		    while (k > j1) {
		    	i++;
				j2 = j1;
				j1 = (i*(i+1)/2);
		    }
		    j = k - j2;
		    if (i == j)
		    	quadStr = this.varName + (this.nVars - i) + "^2 + " + quadStr;
		    else
		    	quadStr = this.varName + (this.nVars - i) + "*" + this.varName + (this.nVars - j) + " + " + quadStr;			
			auxCoef = auxCoef.clearBit(lowBit);
			lowBit = auxCoef.getLowestSetBit();
		}		
		return quadStr.substring(0, quadStr.length() - 3) +
				(linStr.equals("") ? "" : " + " + linStr.substring(0, linStr.length() - 3)) + polStr;
	}
	
	public static void main(String[] args) {
		BigInteger bigIntPol = new BigInteger("23287181769614310490849843211458596836248429038155797469972429021057167233909355326834694461038123511986859080174134454963874310267613575725706803957362383613760856106972696417835852802661367181367151193435900577840466140583443067638999793947914910593286354764664818117237211154538541300060247567218837315425437613324272127601");
		System.out.println(bigIntPol.bitCount());
		BinaryMultiPolynomial pol = new BinaryMultiPolynomial(bigIntPol, 45, "x");
		System.out.println(pol.toString());
	}
}