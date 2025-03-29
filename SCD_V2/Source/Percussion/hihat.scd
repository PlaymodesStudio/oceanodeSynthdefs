(
~synthCreator.value("Hihat", {|n|
	var noise, noiseAmp, snd, gate, rel, hi, lo, curve, amp;
	
	// Parameters with appropriate ranges
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	rel = OceanodeParameter.ar(\release, 0.8, n, 0.1, 2, "vf");
	hi = OceanodeParameter.kr(\hifreq, 9010, n, 5000, 15000, "vf");
	lo = OceanodeParameter.kr(\lofreq, 5100, n, 2000, 8000, "vf");
	curve = OceanodeParameter.kr(\curve, -8, n, -20, -1, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	
	// Envelope - now using multichannel expansion
	noiseAmp = EnvGen.ar(Env.perc(0.001, rel, curve: curve), gate);
	
	// Sound generation - filtered noise with multichannel expansion
	// Each channel gets its own independent noise source and filtering
	noise = BPF.ar(ClipNoise.ar, [hi, lo], [0.815, 0.56], [1.0, 0.6]);
	noise = Mix(noise) * 0.7 * noiseAmp;
	
	// Final signal with per-channel amplitude
	snd = noise * amp;
	
	// Output directly - no need for wrapExtend as multichannel expansion handles this
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Hihat with filtered noise and adjustable resonance", category: "Source/Percussion");
)