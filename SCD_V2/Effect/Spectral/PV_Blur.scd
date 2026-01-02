(
~synthCreator.value("PV_Blur", {|n|
	var sig, chain, mix;
	var blur;
	
	// Parameters with appropriate ranges from synthdefs.json
	blur = OceanodeParameter.ar(\blur, 0, n, 0, 1, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	
	// Input signal
	sig = In.ar(OceanodeInput.kr(\in), n);
	
	// FFT processing
	chain = FFT(LocalBuf(1024.dup(n), 1), sig);
	chain = PV_MagSmooth(chain, blur);
	chain = IFFT(chain);
	
	// Apply mix control
	sig = XFade2.ar(sig, chain, mix * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Spectral blur effect that smooths FFT bins over time", category: "Effect/Spectral");
)