(
~synthCreator.value("SignalDestroyer", {|n|
	var sig, input, inputGain, bitDepth, sampleRate, foldLevel, rectMix, bitMix, srMix, foldMix, chaosMix;

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Parameters with lag for smooth transitions
	inputGain = OceanodeParameterLag.ar(\drive, 1, n, 0, 20, "vf", 1/30, true);

	// Apply input gain
	sig = input * inputGain;

	// Individual parameter controls for each distortion type
	rectMix = OceanodeParameterLag.ar(\rectmix, 0.5, n, 0, 1, "vf", 1/30, true);
	bitDepth = OceanodeParameterLag.ar(\bits, 4, n, 1, 16, "vf", 1/30, true);
	bitMix = OceanodeParameterLag.ar(\bitmix, 0.5, n, 0, 1, "vf", 1/30, true);
	sampleRate = OceanodeParameterLag.ar(\srate, 1000, n, 20, 44100, "vf", 1/30, true);
	srMix = OceanodeParameterLag.ar(\srmix, 0.5, n, 0, 1, "vf", 1/30, true);
	foldLevel = OceanodeParameterLag.ar(\fold, 0.5, n, 0.01, 1, "vf", 1/30, true);
	foldMix = OceanodeParameterLag.ar(\foldmix, 0.5, n, 0, 1, "vf", 1/30, true);
	chaosMix = OceanodeParameterLag.ar(\chaosmix, 0.5, n, 0, 1, "vf", 1/30, true);

	// Apply all distortion types in series with mix controls

	// 1. Rectification (blend of full and half-wave)
	sig = (sig * (1-rectMix)) + (sig.abs * rectMix);

	// 2. Bit crushing
	sig = (sig * (1-bitMix)) + (sig.round(2.pow(bitDepth.reciprocal)) * bitMix);

	// 3. Sample rate decimation
	sig = (sig * (1-srMix)) + (Latch.ar(sig, Impulse.ar(sampleRate)) * srMix);

	// 4. Fold back distortion
	sig = (sig * (1-foldMix)) + (Fold.ar(sig, foldLevel.neg, foldLevel) * foldMix);

	// 5. Chaotic distortion
	sig = (sig * (1-chaosMix)) + (SinOsc.ar(0, sig * 100).wrap2(foldLevel) * chaosMix);


	// Dry/wet mix
	sig = (input * (1 - OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf"))) +
	      (sig * OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf"));

	// Output levels with proper dB scaling
	sig = sig * OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Send to output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Chain of extreme distortions applied in series with separate mix controls", category: "Effect/Distortion");
)