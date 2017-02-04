package com.egonzalez.matsumoto;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.security.Security;
import java.util.Arrays;

import org.bouncycastle.jcajce.provider.symmetric.AES;


public class MITest {

	public static void main(String[] args) {
		MITest test = new MITest();
		test.testFields();
	}

	public void loadPublic() {

	}

	public void testFields() {
		// Create 
		String resp = null; 
		Process p = Runtime.getRuntime()
				.exec("sage /home/edgar/Documents/UOV/uov_analysis.py " + Arrays.toString(polSet).replace(" ", ""));
		BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
		resp = in.readLine();
	}

}
