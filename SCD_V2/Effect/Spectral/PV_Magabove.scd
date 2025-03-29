(
~synthCreator.value("PV_Magabove", {|n|
	var sig, chain, drywet;
	var mag;
	
	// Parameters with appropriate ranges from synthdefs.json
	mag = OceanodeParameter.ar(\magabove, 1, n, 0, 500, "vi");
	drywet = OceanodeParameter.ar(\drywet, 1, n, 0, 1, "vf");
	
	// Input signal
	sig = In.ar(OceanodeInput.kr(\in), n);
	
	// FFT processing
	chain = FFT(LocalBuf(2048.dup(n), 1), sig);
	chain = PV_MagAbove(chain, mag);
	chain = IFFT(chain);
	
	// Apply dry/wet control
	sig = XFade2.ar(sig, chain, drywet * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Spectral filter that passes frequencies with magnitudes above threshold", category: "Effect/Spectral");
)