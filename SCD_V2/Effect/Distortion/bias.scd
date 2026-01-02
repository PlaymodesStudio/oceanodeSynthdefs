(
~synthCreator.value("Bias", {|n|
	var input, output, sign, rectified, bias, minClipped, mix;

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Bias parameter scaled from 0-1 to 0-0.15
	bias = OceanodeParameterLag.ar(\bias, 0, n, 0, 1, "vf", 1/30, true) / 1.666666;

	// Wet/dry mix
	mix = OceanodeParameterLag.ar(\mix, 0, n, -1, 1, "vf", 1/30, true);

	// Extract sign and rectified value
	sign = input.sign;
	rectified = input.abs;

	// Core cell processing (bottom clipper)
	minClipped = rectified.clip(bias,2);

	// Apply sign back and combine with proper scaling
	output = (minClipped-bias) * sign * ((1-bias).reciprocal);

	// Mix dry/wet using XFade2 for equal power crossfade
	output = XFade2.ar(input, output, mix);

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Bias effect with bottom clipping", category: "Effect/Distortion");
)