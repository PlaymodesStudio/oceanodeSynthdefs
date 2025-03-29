(
~synthCreator.value("Kickdrumb", {|n|
	var body, bodyfreq, bodyamp, gate, pitch, curvp, curva, pdec, adec, tune, harm, amp;
	
	// Parameters with appropriate ranges
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	pitch = OceanodeParameterLag.ar(\pitch, 36, n, 24, 60, "vf", 1/30, true).midicps;
	curvp = OceanodeParameter.kr(\pitchcurve, -4, n, -20, 0, "vf");
	curva = OceanodeParameter.kr(\ampcurve, -4, n, -20, 0, "vf");
	pdec = OceanodeParameter.ar(\pitchdecay, 4, n, 0.1, 8, "vf");
	adec = OceanodeParameter.ar(\ampdecay, 4, n, 0.1, 8, "vf");
	tune = OceanodeParameter.kr(\hitune, 300, n, 100, 5000, "vf");
	harm = OceanodeParameter.ar(\harmonics, 40, n, 1, 100, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	
	// Frequency and amplitude envelopes - using multichannel expansion
	bodyfreq = (EnvGen.ar(Env.perc(0.01, pdec, 1, curvp), gate) * tune) + pitch;
	bodyamp = EnvGen.ar(Env.perc(0.01, adec, 1, curva), gate) * harm;
	
	// Sound generation with multichannel expansion
	body = LFTri.ar(bodyfreq, 0, bodyamp);
	body = body.tanh * amp;
	
	// Output directly - no need for wrapExtend as multichannel expansion handles this
	Out.ar(OceanodeOutput.kr(\out), body);
}, description: "Kick drum with triangle oscillator and additive pitch envelope", category: "Source/Percussion");
)