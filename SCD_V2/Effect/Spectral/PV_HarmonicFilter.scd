(
~synthCreator.value("PV_HarmonicFilter", {|n|
	var input, outputSignal, fftSize = 4096;
	var pitches, bandwidth, sensitivity, mix, levels, sinFreqs;

	// Parameters with appropriate ranges and defaults
	pitches = OceanodeParameter.ar(\pitches, 60!512, n, 0, 127, "vf");  // Default chord: C major
	bandwidth = OceanodeParameter.ar(\bandwidth, 0.1, n, 0.01, 1, "vf");
	sensitivity = OceanodeParameter.ar(\sensitivity, 0.5, n, 0, 1, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Safety check
	input = LeakDC.ar(input);

	// Convert MIDI pitches to frequencies for filtering - this handles arrays
	sinFreqs = pitches.midicps;

	// Perform FFT processing for each channel
	outputSignal = Array.fill(n, {|i|
		var localInput = input[i];
		var localBuffer = LocalBuf(fftSize);
		var maskBuffer = LocalBuf(fftSize);
		var fftChain, maskSignal, maskChain, maskedChain;

		// Create FFT chain for input signal
		fftChain = FFT(localBuffer, localInput);

		// Create a composite mask signal using oscillators at all MIDI pitches
		// We need to use a simple sine mix - can't use higher-level methods on UGens
		maskSignal = SinOsc.ar(sinFreqs) * sensitivity[i];

		// Apply some bandwidth control
		maskSignal = maskSignal * LFNoise1.ar(0.1).range(bandwidth[i] * 0.9, bandwidth[i] * 1.1);

		// Sum all the components
		maskSignal = Mix.ar(maskSignal);

		// FFT the mask signal
		maskChain = FFT(maskBuffer, maskSignal);

		// Multiply the magnitudes to filter only the desired frequencies
		maskedChain = PV_MagMul(fftChain, maskChain);

		// Convert back to time domain and apply mix/levels
		IFFT(maskedChain) * levels[i] * mix[i] + (localInput * (1 - mix[i]) * levels[i]);
	});

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), outputSignal);
}, description: "Spectral filter that passes only frequencies at specified pitches", category: "Effects/Spectral");
)