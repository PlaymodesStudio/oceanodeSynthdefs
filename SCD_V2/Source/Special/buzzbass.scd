(
~synthCreator.value("BuzzBass", {|n|
	var snd, buzz, freq, noisef, hif, levels, distortion;

	// Parameters
	freq = OceanodeParameterLag.ar(\pitch, 28, n, 24, 60, "vf", 1/30, true).midicps;
	noisef = OceanodeParameterLag.ar(\noise, 8210, n, 100, 15000, "vf", 1/30, true);
	hif = OceanodeParameterLag.ar(\hif, 800, n, 100, 5000, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);
	distortion = OceanodeParameter.ar(\distortion, 5, n, 0, 20, "vf");

	// Basic sine oscillator
	snd = SinOsc.ar(freq);

	// Create buzz component
	buzz = snd;

	// Add filtered noise
	buzz = buzz + (BPF.ar({ WhiteNoise.ar }, noisef, 0.3) * -20.dbamp);

	// Waveshaping
	buzz = (buzz + 0.3).sign - buzz;

	// Add subtle modulated delay for stereo width
	buzz = buzz + DelayC.ar(buzz, 0.2, SinOsc.ar(0.3, [0, pi]).linlin(-1, 1, 0, 1) * 1e-3);

	// Combine sine with distortion and high-passed buzz
	snd = (snd * distortion).tanh + (HPF.ar(buzz, hif) * -10.dbamp);

	// Apply level control
	snd = snd * levels * -15.dbamp;

	// Output
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Buzzy bass synth with noise and distortion", category: "Source/Special");
)