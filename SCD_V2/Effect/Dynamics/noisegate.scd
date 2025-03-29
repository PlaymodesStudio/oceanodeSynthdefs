(
~synthCreator.value("NoiseGate", {|n|
	var source, sig, thresh, attack, release, numchans, amp, gate, env, send;
	
	// All variables must be declared at the beginning
	numchans = n;
	
	// Parameters with appropriate ranges from synthdefs.json
	thresh = OceanodeParameter.ar(\threshdb, 60, n, 0, 60, "vf");
	attack = OceanodeParameter.ar(\attack, 0.01, n, 0, 1, "vf");
	release = OceanodeParameter.ar(\release, 0.01, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	
	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);
	
	// Apply send amount
	source = source * send;
	
	// Calculate amplitude and create gate
	amp = Amplitude.kr(source);
	gate = amp > thresh.neg.dbamp;
	
	// Create envelope from gate
	env = EnvGen.kr(Env.asr(attack, 1, release), gate);
	
	// Apply gate to signal
	sig = source * env;
	
	// Mix dry and wet signals
	sig = XFade2.ar(source, sig, OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf") * 2 - 1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
	
}, description: "Noise gate that silences signals below threshold", category: "Effect/Dynamics");
)