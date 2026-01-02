(
~synthCreator.value("EchoHold", {|n|
	var sig, del, gate, muteSignal, delayedGate;
	var filters, fb, cut, res, selfilt, mx, dry, feedback, wet;
	var inputToEffect, inputGate, trigDelay, drySignalGate;

	// Parameters
	fb = OceanodeParameter.ar(\feed, 0.5, n, 0, 1, "vf");
	del = OceanodeParameterLag.ar(\delay, 0.2, n, 0.01, 2, "vf", 1/30, true);
	cut = OceanodeParameterLag.ar(\cutoff, 60, n, 12, 120, "vf", 1/30, true).midicps;
	res = OceanodeParameter.ar(\resonance, 0.2, n, 0, 1, "vf");
	selfilt = OceanodeParameterDropdown.kr(\filtertype, 0, n, "LowPass:HighPass:BandPass:PeakEQ");
	mx = 0.5;
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");

	// First, establish a clean trigger that fires when gate goes from 0 to 1
	trigDelay = Trig.ar(gate, SampleDur.ir);

	// Input signal to effect gate:
	// - When gate goes from 0 to 1, allow input to effect for exactly delay time
	// - Otherwise, no input to effect
	inputGate = Trig1.ar(trigDelay, del);
	inputGate = LPF.ar(inputGate,100);

	// Input signal
	dry = In.ar(OceanodeInput.kr(\in), n);

	// Create a delayed gate signal that goes high 'delay' seconds after gate goes high
	delayedGate = DelayN.ar(gate, 2, del);

	// Create mute signal:
	// - When gate is 0, muteSignal is 1 (unmuted)
	// - When gate goes to 1, muteSignal stays 1 for 'delay' seconds, then goes to 0 (muted)
	// - When gate returns to 0, muteSignal immediately returns to 1 (unmuted)
	muteSignal = 1.0 - (delayedGate * gate);
	muteSignal = LPF.ar(muteSignal,100);

	// Apply the mute to the signal
	dry = dry * muteSignal;

	// For dry signal gate (equivalent to muteSignal for this effect)
	drySignalGate = muteSignal;

	// Input processing
	feedback = LocalIn.ar(n);
	wet = LeakDC.ar(feedback * fb + (dry * inputGate));

	// Filter options
	filters = [
		RLPF.ar(wet, cut, 1-res),
		RHPF.ar(wet, cut, 1-res),
		BPF.ar(wet, cut, 1-res),
		BPeakEQ.ar(wet, cut, res*12)
	];

	// Select filter type
	wet = Select.ar(selfilt, filters);

	// Feedback loop
	LocalOut.ar(DelayC.ar(wet, 2, del));

	// Mix dry and wet signals (with dry gate applied)
	sig = XFade2.ar(dry, wet*(1-inputGate), mx*2-1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Mutes input signal after specified delay time when gate is triggered. Immediately unmutes when gate is off.", category: "Effect/Time/Delay");
)