(
~synthCreator.value("HarmonicExciter", {|n|
	var source, processed, finalSig, driven, normalizedInput, digital, analog, dry;

	// Get parameters
	var drive = OceanodeParameterLag.ar(\drive, 0.5, n, 0, 1, "vf", 1/30, true);
	var mix = OceanodeParameterLag.ar(\mix, 0.5, n, 0, 1, "vf", 1/30, true);
	var outputLevel = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true);
	var algorithmType = OceanodeParameterDropdown.kr(\type, 0, n, "Digital:Analog");
	var normType = OceanodeParameterDropdown.kr(\normalize, 1, n, "Raw:Norm01");

	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);

	// Store dry signal for mixing later
	dry = source;

	// Apply drive - increase gain before waveshaping
	driven = source * (1 + (drive * 5));

	// Waveshaping algorithms - choose whether to normalize to 0-1 range
	normalizedInput = Select.ar(normType, [
		driven,                 // Raw signal (not normalized)
		driven * 0.5 + 0.5      // Normalized to 0-1 range
	]);

	// Digital algorithm (original)
	digital = LeakDC.ar(((normalizedInput * 5 - 13) * normalizedInput + 3) / (normalizedInput * 2 + 3)).neg;

	// Analog-style algorithm (alternative)
	analog = LeakDC.ar(SinOsc.ar(0, normalizedInput * pi));

	// Select algorithm based on type
	processed = Select.ar(algorithmType, [digital, analog]);

	// Apply mix (dry/wet) using XFade2
	finalSig = XFade2.ar(dry, processed, mix * 2 - 1);

	// Apply output level
	finalSig = finalSig * outputLevel;

	// Send to output
	Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "Harmonic exciter for enhancing high frequency content", category: "Effect/Eq");
)