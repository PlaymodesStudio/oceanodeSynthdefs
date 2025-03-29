(
~synthCreator.value("PV_Blur", {|n|
	var sig, chain, drywet;
	var blur;
	
	// Parameters with appropriate ranges from synthdefs.json
	blur = OceanodeParameter.ar(\blur, 0, n, 0, 1, "vf");
	drywet = OceanodeParameter.ar(\drywet, 1, n, 0, 1, "vf");
	
	// Input signal
	sig = In.ar(OceanodeInput.kr(\in), n);
	
	// FFT processing
	chain = FFT(LocalBuf(1024.dup(n), 1), sig);
	chain = PV_MagSmooth(chain, blur);
	chain = IFFT(chain);
	
	// Apply dry/wet control
	sig = XFade2.ar(sig, chain, drywet * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Spectral blur effect that smooths FFT bins over time", category: "Effect/Spectral");
)