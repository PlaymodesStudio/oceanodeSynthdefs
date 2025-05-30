(
~synthCreator.value("PitchDelay", {|n|
	var filters, fb, del, cut, res, selfilt, sig, mx, dry, feedback, wet, ing;
	
	// Parameters
	fb = OceanodeParameter.ar(\feed, 0.5, n, 0, 1, "vf");
	del = OceanodeParameterLag.ar(\pitch, 36, n, 24, 96, "vf", 1/30, true).midicps.reciprocal;
	cut = OceanodeParameterLag.ar(\cutoff, 60, n, 20, 120, "vf", 1/30, true).midicps;
	res = OceanodeParameter.ar(\resonance, 0.2, n, 0, 1, "vf");
	selfilt = OceanodeParameterDropdown.kr(\filtertype, 0, n, "LowPass:HighPass:BandPass:PeakEQ");
	mx = OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf");
	ing = OceanodeParameterLag.ar(\inputgain, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Input processing
	dry = In.ar(OceanodeInput.kr(\in), n);
	feedback = LocalIn.ar(n);
	wet = LeakDC.ar(feedback * fb + (dry * ing));
	
	// Filter options
	filters = [
		RLPF.ar(wet, cut, 1-res),
		RHPF.ar(wet, cut, 1-res),
		BPF.ar(wet, cut, 1-res),
		BPeakEQ.ar(wet, cut, 1, res*12)
	];
	
	// Select filter type
	wet = Select.ar(selfilt, filters);
	
	// Feedback loop with delay time based on pitch
	LocalOut.ar(DelayC.ar(wet, 2, del));
	
	// Mix dry and wet signals
	sig = XFade2.ar(dry, wet, mx*2-1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Delay effect with delay time based on musical pitch", category: "Effect/Time/Delay", variables: [], variableDimensions: []);
)