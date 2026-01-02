(
~synthCreator.value("PV_Brickwall", {|n|
	var sig, chain, mix;
	var cutoff;
	
	// Parameters with appropriate ranges from synthdefs.json
	cutoff = OceanodeParameter.ar(\cutoff, 0, n, -1, 1, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	
	// Input signal
	sig = In.ar(OceanodeInput.kr(\in), n);
	
	// FFT processing
	chain = FFT(LocalBuf(2048.dup(n), 1), sig);
	chain = PV_BrickWall(chain, cutoff);
	chain = IFFT(chain);
	
	// Apply mix control
	sig = XFade2.ar(sig, chain, mix * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Spectral brick wall filter with adjustable cutoff threshold", category: "Effect/Spectral");
)