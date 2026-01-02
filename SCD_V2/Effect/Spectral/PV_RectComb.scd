(
~synthCreator.value("PV_RectComb", {|n|
	var sig, chain, mix;
	var teeth, ph, pw;
	
	// Parameters with appropriate ranges from synthdefs.json
	teeth = OceanodeParameter.ar(\teeth, 8, n, 1, 512, "vi");
	ph = OceanodeParameter.ar(\phase, 0, n, -1, 1, "vf");
	pw = OceanodeParameter.ar(\width, 0.5, n, 0, 1, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	
	// Input signal
	sig = In.ar(OceanodeInput.kr(\in), n);
	
	// FFT processing
	chain = FFT(LocalBuf(2048.dup(n), 1), sig);
	chain = PV_RectComb(chain, teeth, ph, pw);
	chain = IFFT(chain);
	
	// Apply mix control
	sig = XFade2.ar(sig, chain, mix * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Spectral comb filter with adjustable teeth width and phase", category: "Effect/Spectral");
)