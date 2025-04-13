(
~synthCreator.value("Echo", {|n|
	var filters, fb, del, cut, res, selfilt, sig, mx, dry, feedback, wet, ing;

	// Parameters
	fb = OceanodeParameter.ar(\feed, 0.5, n, 0, 1, "vf");
	del = OceanodeParameterLag.ar(\delay, 0.2, n, 0.01, 2, "vf", 1/30, true);
	cut = OceanodeParameterLag.ar(\cutoff, 60, n, 12, 120, "vf", 1/30, true).midicps;
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

	// Feedback loop
	LocalOut.ar(DelayC.ar(wet, 2, del));

	// Mix dry and wet signals
	sig = XFade2.ar(dry, wet, mx*2-1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Echo effect with feedback and filtering options", category: "Effect/Time/Delay");
)