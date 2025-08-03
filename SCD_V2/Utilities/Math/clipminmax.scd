(
~synthCreator.value("ClipMinMax", {|n|
	var input, output, minVal, maxVal;

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Parameters
	minVal = OceanodeParameter.ar(\min, -1, n, -130, 130, "vf");
	maxVal = OceanodeParameter.ar(\max, 1, n, -130, 130, "vf");

	// Ensure min is always less than or equal to max
	minVal = min(minVal, maxVal - 0.001);

	// Clip the signal between min and max values
	output = input.clip(minVal, maxVal);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "Clips input signal between min and max values", category: "Utilities/Math");
)