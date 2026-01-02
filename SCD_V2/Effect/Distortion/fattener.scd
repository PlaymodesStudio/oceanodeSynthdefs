(
~synthCreator.value("Fattener", {|n, variables|
	var in, signal, level;
	var fattness, color, inputGain;
	var threshold, ratio, outputGain, satThreshold, finalGain;
	var peakFreq, peakGain, peakQ;
	var preprocessed, gainReduction;

	// Parameters with OceanodeParameter
	fattness = OceanodeParameterLag.ar(\fattness, 0, n, 0, 100, "vf", 0.1, true) / 100; // 0-100% -> 0-1
	color = OceanodeParameterLag.ar(\color, 0, n, 0, 100, "vf", 0.1, true) / 100; // 0-100% -> 0-1
	inputGain = OceanodeParameter.ar(\gain, 0, n, -24, 24, "vf").dbamp; // Convert dB to amplitude

	// Calculate derived parameters
	threshold = (fattness * 34.0 + 1.0).neg.dbamp;
	ratio = 10; // 10:1 ratio (fixed in original)
	outputGain = (fattness * 39.0 + 1.0).dbamp;
	satThreshold = 0.1 * color + 0.9;
	finalGain = (-0.1).dbamp; // -0.1dB final gain (fixed in original)

	// Peak EQ parameters (derived from color parameter)
	peakFreq = (color.pow(3.219) * 6680.0 + 40.0).clip(40, SampleRate.ir * 0.5 - 100);
	peakGain = color * 8.0;
	peakQ = 0.71;

	// Get input signal
	in = In.ar(OceanodeInput.kr(\in), n);

	// Apply input gain
	signal = in * inputGain;

	// Pre-processing: high-pass filtering to remove unwanted low frequencies
	signal = HPF.ar(signal, 20); // First HP filter at 20Hz
	signal = HPF.ar(signal, 30); // Second HP filter at 30Hz

	// Apply peak EQ for color control
	signal = BPeakEQ.ar(signal, peakFreq, peakQ, peakGain);

	// Store preprocessed signal for later use
	preprocessed = signal;

	// Calculate signal level for compression (use max of all channels)
	level = Amplitude.ar(preprocessed, 0.00269, 0.0329);

	// Apply compression with threshold and ratio
	// Using smooth conditional transition instead of Select.ar
	gainReduction = (level / threshold).pow(1/ratio - 1);
	// Conditional logic with smooth transition between modes
	gainReduction = 1.0 + ((gainReduction - 1.0) * (level > threshold));

	// Apply compression and output gain
	signal = preprocessed * gainReduction * outputGain;

	// Apply soft-clipping/saturation
	// Simplified version using smoothed conditional logic rather than Select.ar
	signal = signal.sign * (
		// Below threshold: just use signal magnitude
		(signal.abs * (signal.abs <= satThreshold)) +
		// Above threshold: apply saturation
		(
			satThreshold +
			((signal.abs - satThreshold) / (1 - satThreshold)).tanh * (1 - satThreshold)
		) * (signal.abs > satThreshold)
	);

	// Apply final gain adjustment
	signal = signal * finalGain;

	// Ensure signal is clean with no DC offset
	signal = LeakDC.ar(signal);

	Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Adds warmth, distortion and fatness to audio signals", category: "Effect/Distortion");
)