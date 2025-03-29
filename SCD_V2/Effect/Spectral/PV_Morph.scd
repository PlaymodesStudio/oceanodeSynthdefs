(
~synthCreator.value("PV_Morph", {|n|
	var sigA, sigB, chainA, chainB, sig;
	var morph;
	
	// Parameters with appropriate ranges from synthdefs.json
	morph = OceanodeParameterLag.ar(\morph, 0, n, 0, 1, "vf", 0.05, true);
	
	// Input signals
	sigA = In.ar(OceanodeInput.kr(\in), n);
	sigB = In.ar(OceanodeInput.kr(\in2), n);
	
	// FFT processing
	chainA = FFT(LocalBuf(2048.dup(n), 1), sigA);
	chainB = FFT(LocalBuf(2048.dup(n), 1), sigB);
	sig = PV_Morph(chainA, chainB, morph);
	sig = IFFT(sig);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Spectral morphing between two input signals", category: "Effect/Spectral");
)