(
~synthCreator.value("Kick808", {|n|
	var gate, midinote, decay, amp, att, tri;
	var freq, fenv, env, trienv, sig, sub, punch, pfenv, rel;
	
	// Control parameters with appropriate ranges
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");  // Changed from trigger to gate
	midinote = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true);
	decay = OceanodeParameterLag.kr(\decay, 1.5, n, 0.0001, 10, "vf", 1/30, true);
	att = OceanodeParameterLag.kr(\attack, 0.1, n, 0.0001, 1, "vf", 1/30, true);
	rel = OceanodeParameterLag.kr(\release, 0.1, n, 0.001, 1, "vf", 1/30, true);  // Added release parameter
	tri = OceanodeParameterLag.kr(\tri, 0.6, n, 0, 100, "vf", 1/30, true);
	
	// Calculate frequency from MIDI note
	freq = midinote.midicps;
	
	// Create envelopes with proper release stage
	// Using Env.asr instead of Env.perc to have a proper release stage
	env = EnvGen.ar(
		Env.asr(att, 1, rel, -4),
		gate,
		doneAction: 0
	);
	
	trienv = EnvGen.ar(
		Env.asr(att, tri, rel, -4),
		gate,
		doneAction: 0
	);
	
	// Frequency envelopes with proper release
	// Using gate instead of trigger and adding a release stage
	fenv = Select.ar(
		gate,
		[
			// When gate is 0, use the current frequency
			DC.ar(freq),
			// When gate is 1, use the frequency envelope
			EnvGen.ar(
				Env([freq * 7, freq * 1.35, freq], [0.05, 0.6], -14),
				Trig.ar(gate, 0.001),
				doneAction: 0
			)
		]
	);
	
	pfenv = Select.ar(
		gate,
		[
			// When gate is 0, use the current frequency
			DC.ar(freq),
			// When gate is 1, use the frequency envelope
			EnvGen.ar(
				Env([freq * 7, freq * 1.35, freq], [0.03, 0.6], -10),
				Trig.ar(gate, 0.001),
				doneAction: 0
			)
		]
	);
	
	// Create the kick components
	sig = SinOsc.ar(fenv) * env;
	sub = LFTri.ar(fenv) * trienv * 0.05;
	punch = SinOsc.ar(pfenv) * env * 2;
	punch = HPF.ar(punch, 350);
	
	// Mix components and process
	sig = sig + sub + punch;
	sig = LeakDC.ar(sig);
	sig = Limiter.ar(sig, 0.5) * 2;
	
	// Apply level control with proper dB scaling
	sig = sig * OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	
	// Output directly - no need for wrapExtend as multichannel expansion handles this
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "808 style kick drum with tone control", category: "Source/Percussion/808");
)