(
~synthCreator.value("SampleAndHold", {|n|
	var input, gate, output, held, trigger;

	// Get the input signal to be sampled and held
	input = In.ar(OceanodeInput.kr(\in), n);

	// Gate parameter for triggering sample and hold
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	trigger = Trig.ar(gate, 0.001);

	// Sample and hold: captures input value when gate rises from 0 to 1
	held = Latch.ar(input, trigger);

	// Output the held signal
	output = held;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Samples and holds input value when gate parameter rises", category: "Utilities/Other");
)