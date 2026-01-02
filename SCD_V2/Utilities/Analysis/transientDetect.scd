~synthCreator.value("TransientDetect", {|n|
	var input, threshold, minInterval, slope, delayedInput, trig, gatedTrig;

	// Audio input
	input = In.ar(OceanodeInput.kr(\in), n);

	// Threshold for slope detection (how fast signal must rise)
	threshold = OceanodeParameter.ar(\threshold, 0.1, n, 0.001, 1, "vf");

	// Minimum interval between triggers in milliseconds
	minInterval = OceanodeParameter.ar(\interval, 10, n, 1, 1000, "vf");

	// Calculate slope (current - previous sample)
	delayedInput = Delay1.ar(input);
	slope = input - delayedInput;

	// Trigger when slope exceeds threshold (rising edge detected)
	trig = (slope > threshold);

	// Gate the triggers to enforce minimum interval
	// Trig1 creates a gate that stays high for minInterval duration
	// During this time, new triggers are blocked
	gatedTrig = trig * (1 - Trig1.ar(trig, minInterval * 0.001));

	// Output impulses
	Out.ar(OceanodeOutput.kr(\out), gatedTrig);
},
description: "Detects rising edges/transients in audio and outputs impulses",
category: "Utilities/Analysis");