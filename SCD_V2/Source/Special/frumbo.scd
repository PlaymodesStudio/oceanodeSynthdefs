(
~synthCreator.value("Frumbo", {|n|
	var freq, amp, gate, attack, decay, sustain, release;
	var pitchStartMult, pitchEnvTime, filterStartFreq, filterEndFreq;
	var filterEnvTime, filterRes, fmp, fmStart, fmEnd, fmEnvTime, filterType;
	var clip, skew;
	var sig, env, fm, fmEnv, pitchEnv, filterEnv, filteredSig;

	// Basic parameters
	freq = OceanodeParameterLag.ar(\pitch, 24, n, 12, 96, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");

	// Amplitude envelope parameters
	attack = OceanodeParameter.ar(\attack, 0.01, n, 0.001, 1, "vf");
	decay = OceanodeParameter.ar(\ampdec, 0.2, n, 0.01, 2, "vf");
	sustain = OceanodeParameter.ar(\ampsus, 0.5, n, 0, 1, "vf");
	release = OceanodeParameter.ar(\amprel, 0.1, n, 0.01, 2, "vf");

	// Pitch envelope parameters
	pitchStartMult = OceanodeParameter.ar(\penvratio, 4, n, 1, 10, "vf");
	pitchEnvTime = OceanodeParameter.ar(\penvtime, 0.05, n, 0.001, 1, "vf");

	// Filter parameters
	filterStartFreq = OceanodeParameter.ar(\filtstart, 130, n, 20, 135, "vf").midicps;
	filterEndFreq = OceanodeParameter.ar(\filtend, 36, n, 20, 135, "vf").midicps;
	filterEnvTime = OceanodeParameter.ar(\filtenvtime, 0.1, n, 0.001, 1, "vf");
	filterRes = OceanodeParameter.ar(\filtres, 0.5, n, 0.01, 0.99, "vf");
	filterType = OceanodeParameterDropdown.kr(\filttype, 0, n, "LowPass:BandPass:HighPass");

	// FM parameters
	fmp = OceanodeParameterLag.ar(\fmpitch, 48, n, 12, 96, "vf", 1/30, true);
	fmStart = OceanodeParameterLag.ar(\fmstart, 100, n, 0, 1000, "vf", 1/30, true);
	fmEnd = OceanodeParameterLag.ar(\fmend, 100, n, 0, 1000, "vf", 1/30, true);
	fmEnvTime = OceanodeParameterLag.ar(\fmenvtime, 0.1, n, 0.001, 1, "vf", 1/30, true);

	// Oscillator parameters
	clip = OceanodeParameterLag.ar(\clip, 0, n, 0, 1, "vf", 1/30, true);
	skew = OceanodeParameterLag.ar(\skew, 1, n, 0.1, 10, "vf", 1/30, true);

	// Pitch envelope
	pitchEnv = EnvGen.kr(
		Env([0, freq * pitchStartMult, freq, freq], [0, pitchEnvTime, 0.01], \exp),
		gate
	);

	// Filter envelope
	filterEnv = EnvGen.kr(
		Env([0, filterStartFreq, filterEndFreq, filterEndFreq], [0, filterEnvTime, 0.01], \exp),
		gate
	);

	// FM envelope
	fmEnv = EnvGen.kr(
		Env([0, fmStart, fmEnd, 0], [0, fmEnvTime, 0.01], \exp),
		gate
	);

	// FM modulation
	fm = SinOsc.ar(fmp.midicps, 0) * fmEnv;

	// Amplitude envelope
	env = EnvGen.kr(
		Env([0, 0, 1, sustain, 0], [0, attack, decay, release], -4),
		gate
	);

	// Main oscillator (Squine is a square-sine hybrid oscillator)
	sig = Squine.ar(pitchEnv + fm, clip, skew);

	// Filter with envelope and type selection
	filteredSig = Select.ar(filterType,
		[
			RLPF.ar(sig, filterEnv, filterRes),  // Low Pass
			BPF.ar(sig, filterEnv, filterRes),   // Band Pass
			RHPF.ar(sig, filterEnv, filterRes)   // High Pass
		]
	);

	// Apply envelope and amplitude
	sig = filteredSig * env * amp;

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Complex synth with FM pitch and filter envelopes and Squine oscillator", category: "Source/Special");
)