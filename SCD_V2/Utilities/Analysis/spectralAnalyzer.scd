(
~synthCreator.value("SpectralAnalyzer", {|n|
	var signal, outputSignals;
	var numBands = 100;

	// Parameters
	var lpfFreq = OceanodeParameterLag.kr(\smoothing, 10, 1, 0.1, 100, "vf", 1/30, true);
	var sensitivity = OceanodeParameterLag.kr(\sensitivity, 2, 1, 0.5, 8, "vf", 1/30, true);
	var rq = OceanodeParameterLag.kr(\bandwidth, 0.5, 1, 0.1, 2, "vf", 1/30, true);

	// Input signal - mix all channels together
	signal = In.ar(OceanodeInput.kr(\in), n);
	signal = Mix.new(signal) / max(n, 1);  // Mix and normalize

	// Create 100 bandpass filters and analyze each band
	outputSignals = Array.fill(numBands, {|bandIdx|
		var centerFreq, filteredSignal, amplitude;

		// Calculate logarithmically spaced center frequency for this band
		// from 20Hz to 20kHz
		centerFreq = 20 * pow(20000/20, bandIdx/numBands);

		// Apply bandpass filter
		filteredSignal = BPF.ar(signal, centerFreq, rq / centerFreq);

		// Get amplitude of the filtered signal
		amplitude = Amplitude.kr(
			filteredSignal,
			attackTime: 0.01,   // Fast attack to capture transients
			releaseTime: 0.1    // Slower release for smoother decay
		);

		// Apply sensitivity scaling and response curve
		amplitude = amplitude.lincurve(0, 0.05/sensitivity, 0, 1, 3);

		// Apply smoothing with LPF
		amplitude = LPF.kr(amplitude, lpfFreq);

		// Convert to audio rate signal
		K2A.ar(amplitude);
	});

	// Output all bands
	Out.ar(OceanodeOutput.kr(\out), outputSignals);

}, description: "Divides the spectrum into 100 frequency bands", category: "Utilities/Analysis");
)