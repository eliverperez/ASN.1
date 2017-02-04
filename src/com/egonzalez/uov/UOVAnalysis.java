package com.egonzalez.uov;

import java.util.List;
import java.util.Set;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

public class UOVAnalysis {

	BigInteger[] polSet;
	BigInteger[] polsChallenge;
	BigInteger[] reducedPols;
	List<Set<Integer>> reducedIdx;
	int[][] vecChallenge;
	int[] bitChallenge;

	public static void main(String[] args) {
		UOVAnalysis analysis = new UOVAnalysis();
		analysis.load("/home/edgar/Documents/UOV/pubKey30.txt", "/home/edgar/Documents/UOV/challenge.txt");
		// if (analysis.bruteForceLinearCombination())
		// System.out.println("Exitoso!!");
		int yBit = -1;
		for (int i = 0; i < analysis.polsChallenge.length; i++) {
			yBit = analysis.gaussSolveChallenge(analysis.vecChallenge[i], analysis.polsChallenge[i]);
			if (yBit != analysis.bitChallenge[i]) {
				System.out.println("Failed :(");
			} else {
				System.out.println("Success!!");
			}
		}
	}
	
	public void createKeyPair() {
		
	}

	public int bruteForceLinearCombination(int[] yBits, BigInteger polChallenge) {
		// Try to find out the used polynomials
		int m = polSet.length;
		int[] indices = null;
		for (int j = 1; j <= m; j++) {
			indices = new int[j];
			for (int k = 0; k < j; k++) {
				indices[k] = k;
			}
			int l = 1;
			while (indices[0] <= m - j) {
				if (checkIndices(indices, polChallenge))
					return computeBit(indices, yBits);
				while (indices[j - 1] < m - 1) {
					if (checkIndices(indices, polChallenge))
						return computeBit(indices, yBits);
				}
				while (j > l && indices[j - l] == m - l) {
					l++;
				}
				indices[j - l]++;
				while (l > 1) {
					indices[j - l + 1] = indices[j - l] + 1;
					l--;
				}
			}
		}
		return -1;
	}

	public boolean checkIndices(int[] idxSet, BigInteger polChallenge) {
		BigInteger tryPoly = BigInteger.ZERO;
		for (int idx : idxSet) {
			tryPoly = tryPoly.xor(polSet[idx]);
		}
		return (tryPoly.equals(polChallenge));
	}

	public boolean checkIndices(Set<Integer> idxSet, BigInteger polChallenge) {
		return checkIndices(intSetToArray(idxSet), polChallenge);
	}

	public int computeBit(int[] idxSet, int[] yBits) {
		int yBit = 0;
		for (int idx : idxSet) {
			yBit ^= yBits[idx];
		}
		return yBit;
	}

	public int computeBit(Set<Integer> idxSet, int[] yBits) {
		return computeBit(intSetToArray(idxSet), yBits);
	}

	private int[] intSetToArray(Set<Integer> set) {
		int[] idxSetArray = new int[set.size()];
		int i = 0;
		for (int n : set)
			idxSetArray[i++] = n;
		return idxSetArray;
	}

	public boolean selectiveLinearCombination() {
		BigInteger or = BigInteger.ZERO;
		int idx = 0;
		int minSetBits = Integer.MAX_VALUE;
		int minIdx = 0;
		for (int i = 0; i < polSet.length; i++) {
			or = or.or(polSet[i]);
		}
		int bitCount[] = new int[or.bitLength()];
		while (!or.equals(BigInteger.ZERO)) {
			idx = or.getLowestSetBit();
			for (int i = 0; i < polSet.length; i++) {
				if (polSet[i].testBit(idx)) {
					bitCount[idx]++;
				}
			}
			if (bitCount[idx] > 0 && bitCount[idx] < minSetBits) {
				minSetBits = bitCount[idx];
				minIdx = idx;
			}
			or = or.clearBit(idx);
		}
		System.out.println(Arrays.toString(bitCount));
		System.out.println("Min set bits: " + minSetBits + ", index: " + minIdx);
		return false;
	}

	public void load(String pubKeyPath, String challengePath) {
		BufferedReader br = null;
		// Read Public Key Polynomials
		try {
			br = new BufferedReader(new FileReader(new File(pubKeyPath)));
			int nPols = Integer.parseInt(br.readLine().trim());
			polSet = new BigInteger[nPols];
			for (int i = 0; i < nPols; i++) {
				polSet[i] = new BigInteger(br.readLine());
			}

			// Read Challenge Polynomials
			br = new BufferedReader(new FileReader(new File(challengePath)));
			String ln = null;
			int trials = Integer.parseInt(br.readLine().trim());
			String[] vecStr;
			int[] vecInt;
			vecChallenge = new int[trials][];
			bitChallenge = new int[trials];
			polsChallenge = new BigInteger[trials];
			for (int i = 0; i < trials; i++) {
				ln = br.readLine();
				// Read random vector
				ln = ln.substring(1, ln.trim().length() - 1);
				vecStr = ln.split(",");
				vecInt = new int[vecStr.length];
				for (int j = 0; j < vecStr.length; j++) {
					vecInt[j] = Integer.parseInt(vecStr[j].trim());
				}
				vecChallenge[i] = vecInt;
				bitChallenge[i] = Integer.parseInt((br.readLine()));
				polsChallenge[i] = new BigInteger(br.readLine());
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				br.close();
			} catch (IOException e) {
			}
		}
	}

	public int gaussSolveChallenge(int[] yBits, BigInteger polChallenge) {
		if (this.reducedIdx == null)
			gaussReductLinearCombination(this.polSet);

		// Given a challenge, we look for the linear combination in the
		// reduced set
		Set<Integer> idxSet = new HashSet<>();
		BigInteger auxBig = null;
		int lastIdx = 0;
		auxBig = polChallenge;
		while (!auxBig.equals(BigInteger.ZERO)) {
			for (int j = lastIdx; j < reducedPols.length; j++) {
				if (reducedPols[j].bitLength() == auxBig.bitLength()) {
					auxBig = auxBig.xor(reducedPols[j]);
					mixPolSet(idxSet, this.reducedIdx.get(j));
					break;
				}
			}
		}
		if (checkIndices(idxSet, polChallenge)) {
			return computeBit(idxSet, yBits);
		}
		return -1;
	}

	public void gaussReductLinearCombination(BigInteger[] polSet) {
		try {
			this.reducedPols = new BigInteger[polSet.length];
			String polStr, idxStr = "", auxStr = "";
			String[] polStrArray, idxStrArray;
			int[] sortedIdx = new int[polSet.length];
			this.reducedIdx = new ArrayList<>();

			System.out.println("python /home/edgar/Documents/UOV/uov_analysis.py " + Arrays.toString(polSet));
			Process p = Runtime.getRuntime()
					.exec("sage /home/edgar/Documents/UOV/uov_analysis.py " + Arrays.toString(polSet).replace(" ", ""));
			BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
			polStr = in.readLine();
			polStr = polStr.substring(1, polStr.length() - 1);
			polStrArray = polStr.split(",");
			while ((auxStr = in.readLine()) != null && auxStr.trim().length() > 0) {
				idxStr = idxStr + auxStr;
			}
			idxStr = idxStr.substring(1, idxStr.length() - 1);
			idxStrArray = idxStr.trim().split("\\s+");

			// Poynomials sorted from the rightmost set bit.
			// Keep the index of the original polynomial position
			for (int i = 0; i < polSet.length; i++) {
				auxStr = polStrArray[i].trim();
				reducedPols[i] = new BigInteger(auxStr.substring(0, auxStr.length() - 1));
				sortedIdx[i] = Integer.parseInt(idxStrArray[i].trim());
			}

			// Perform a Gauss reduction. We keep the set of indices used in the
			// reduction to keep track of the linear combination used
			for (int i = 0; i < polSet.length; i++) {
				this.reducedIdx.add(new HashSet<Integer>());
				this.reducedIdx.get(i).add(sortedIdx[i]);
			}

			System.out.println(Arrays.toString(reducedPols));
			for (int i = 0; i < polSet.length; i++) {
				for (int j = i + 1; j < polSet.length; j++) {
					if (reducedPols[j].testBit(reducedPols[i].bitLength() - 1)) {
						// if a polynomial exists in the previous set, then we
						// remove it since a sum of the same polynomial yields
						// the zero polynomial in char = 2
						mixPolSet(this.reducedIdx.get(j), this.reducedIdx.get(i));
						reducedPols[j] = reducedPols[j].xor(reducedPols[i]);
					}
				}
			}
			System.out.println(this.reducedIdx.toString());
			BigInteger test = BigInteger.ZERO;
			for (int idx : this.reducedIdx.get(29)) {
				test = test.xor(polSet[idx]);
			}

			// System.out.println(test.equals(reducedPols[29]));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void mixPolSet(Set<Integer> originalSet, Set<Integer> mixingSet) {
		Set<Integer> auxSet = new HashSet<>(mixingSet);

		// Add new elemments and remove duplicate
		auxSet.retainAll(originalSet);
		originalSet.addAll(mixingSet);
		originalSet.removeAll(auxSet);
	}
}
