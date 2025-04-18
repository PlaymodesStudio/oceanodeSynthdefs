(
~synthCreator.value("PV_BinShift", {|n|
	var sig, chain, drywet;
	var shift, stretch;
	
	// Parameters with appropriate ranges from synthdefs.json
	stretch = OceanodeParameter.ar(\stretch, 1, n, 0.25, 4, "vf");
	shift = OceanodeParameter.ar(\shift, 0, n, -128, 128, "vf");
	drywet = OceanodeParameter.ar(\drywet, 1, n, 0, 1, "vf");
	
	// Input signal
	sig = In.ar(OceanodeInput.kr(\in), n);
	
	// FFT processing
	chain = FFT(LocalBuf(2048.dup(n), 1), sig);
	chain = PV_BinShift(chain, stretch, shift, 1);
	chain = IFFT(chain);
	
	// Apply dry/wet control
	sig = XFade2.ar(sig, chain, drywet * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Spectral bin shifter with stretch and shift controls", category: "Effect/Spectral");
)