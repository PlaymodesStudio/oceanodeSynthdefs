(
~synthCreator.value("VowelFilter", {|n|
	var source, vowelType, rq, mix, level, signal, wetSignal;
	var freq1, freq2, freq3;
	var firstFormant, secondFormant, thirdFormant;
	var vowelIndex, interp;
	var bp1, bp2, bp3;

	// Define vowel frequencies arrays for the three bands
	// Format: [a, e, i, o, u, er]
	firstFormant = [270, 300, 400, 530, 640, 660];   // First formant frequencies
	secondFormant = [2300, 870, 2000, 1850, 1200, 1700]; // Second formant frequencies
	thirdFormant = [3000, 2250, 2550, 2500, 2400, 2400];  // Third formant frequencies

	// Input parameters
	source = In.ar(OceanodeInput.kr(\in), n);
	vowelType = OceanodeParameterLag.ar(\vowel, 0, n, 0, 5, "vf", 1/30, true); // 0=a, 1=e, 2=i, 3=o, 4=u, 5=er
	rq = OceanodeParameterLag.ar(\rq, 0.1, n, 0.01, 1, "vf", 1/30, true); // RQ (reciprocal of Q) properly ranged 0.01-1
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true); // 0=dry, 1=wet
	level = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Create integer index and interpolation factor
	vowelIndex = vowelType.floor.clip(0, 5);
	interp = vowelType - vowelIndex;

	// Calculate frequencies using Select and linear interpolation
	freq1 = (Select.kr(vowelIndex, firstFormant.asArray) * (1 - interp)) +
	       (Select.kr((vowelIndex + 1).clip(0, 5), firstFormant.asArray) * interp);

	freq2 = (Select.kr(vowelIndex, secondFormant.asArray) * (1 - interp)) +
	       (Select.kr((vowelIndex + 1).clip(0, 5), secondFormant.asArray) * interp);

	freq3 = (Select.kr(vowelIndex, thirdFormant.asArray) * (1 - interp)) +
	       (Select.kr((vowelIndex + 1).clip(0, 5), thirdFormant.asArray) * interp);

	// Apply the three bandpass filters in parallel (not series) and sum them
	bp1 = BPF.ar(source, freq1, rq);
	bp2 = BPF.ar(source, freq2, rq);
	bp3 = BPF.ar(source, freq3, rq);

	// Sum the bandpass filtered signals
	wetSignal = (bp1 + bp2 + bp3) / 3; // Normalize by dividing by 3

	// Mix with original signal using XFade2
	signal = XFade2.ar(source, wetSignal, mix.linlin(0, 1, -1, 1));

	// Apply level control
	signal = signal * level;

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Vocal formant filter with 6 vowel types", category: "Effect/Filter");
)