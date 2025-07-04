(
~synthCreator.value("PhasorCycleTrigger", {|n|
	var input, output, prevSample, cycleTrigger;

	// Get the input phasor signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Detect cycle completion by looking for falling edge (wrap from high to low)
	// We compare current sample with previous sample delayed by one sample
	prevSample = Delay1.ar(input);

	// Trigger when phasor wraps around (previous sample > current sample)
	// This detects the discontinuity where phasor resets from ~1 to 0
	cycleTrigger = prevSample > input;

	// Convert to proper trigger pulse
	output = Trig.ar(cycleTrigger, 0.001);

	// Output the trigger signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Outputs trigger when input phasor completes a cycle (falling edge)", category: "Utilities/Control");
)