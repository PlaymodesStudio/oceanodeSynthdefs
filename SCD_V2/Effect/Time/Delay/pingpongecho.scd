(
~synthCreator.value("PingPongEcho", {|n, variables|
	var filters, fb, del, cut, res, selfilt, sig, mx, dry, feedbackL, feedbackR, wetL, wetR, send, spread;
	
	// Parameters
	fb = OceanodeParameter.ar(\feed, 0.5, n, 0, 1, "vf");
	del = OceanodeParameterLag.ar(\delay, 0.2, n, 0.01, 2, "vf", 1/30, true);
	cut = OceanodeParameterLag.ar(\cutoff, 60, n, 12, 120, "vf", 1/30, true).midicps;
	res = OceanodeParameter.ar(\resonance, 0.2, n, 0, 1, "vf");
	selfilt = OceanodeParameterDropdown.kr(\filtertype, 0, n, "LowPass:HighPass:BandPass:PeakEQ");
	mx = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	spread = OceanodeParameterLag.ar(\spread, 1, n, 0, 1, "vf", 1/30, true);
	
	// This synth requires exactly 2 channels
	n = min(n, 2);
	
	// Input processing
	dry = In.ar(OceanodeInput.kr(\in), n);
	
	// Ensure stereo operation
	dry = if(dry.size < 2, [dry[0], dry[0]], dry);
	
	// Feedback loop
	#feedbackL, feedbackR = LocalIn.ar(2);
	
	// Cross-feedback (ping-pong effect)
	wetL = LeakDC.ar(feedbackR * fb + (dry[0] * send));
	wetR = LeakDC.ar(feedbackL * fb + (dry[1] * send));
	
	// Filter options
	filters = [
		RLPF.ar([wetL, wetR], cut, 1-res),
		RHPF.ar([wetL, wetR], cut, 1-res),
		BPF.ar([wetL, wetR], cut, 1-res),
		BPeakEQ.ar([wetL, wetR], cut, 1, res*12)
	];
	
	// Select filter type
	#wetL, wetR = Select.ar(selfilt, filters);
	
	// Apply stereo spread
	wetL = Balance2.ar(wetL, wetL, spread.neg);
	wetR = Balance2.ar(wetR, wetR, spread);
	
	// Feedback loop
	LocalOut.ar([
		DelayC.ar(wetL[0] + wetL[1], 2, del),
		DelayC.ar(wetR[0] + wetR[1], 2, del)
	]);
	
	// Mix dry and wet signals
	sig = XFade2.ar(dry, [wetL[0] + wetL[1], wetR[0] + wetR[1]], mx*2-1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Ping-pong echo effect that alternates between left and right channels", category: "Effect/Time/Delay", variables: [], variableDimensions: []);
)