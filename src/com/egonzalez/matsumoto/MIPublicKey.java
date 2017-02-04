package com.egonzalez.matsumoto;

import java.security.PublicKey;

import org.bouncycastle.pqc.math.linearalgebra.GF2mField;

public class MIPublicKey implements PublicKey {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	GF2mField baseField;
	GF2mField extensionField;
	
	public MIPublicKey(GF2mField baseField, GF2mField extensionField) {
		this.baseField = baseField;
		this.extensionField = extensionField;
	}
	
	@Override
	public String getAlgorithm() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public byte[] getEncoded() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getFormat() {
		// TODO Auto-generated method stub
		return null;
	}
	
}
