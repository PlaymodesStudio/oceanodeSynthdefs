(
SynthDef(\pluck, {
	arg out=0;
	var signal, finalSig;

	// Amplitude for multiple voices - expecting 78 amplitudes
	var amp = \amp.kr(0.1!78);

	// Coefficient for multiple voices - expecting 78 coefficients
	var coef = \coef.kr(0.85!78);

	// Velocity for multiple voices - expecting 78 velocities
	var vel = \vel.kr(0.1!78);

	// Duration for multiple voices - expecting 78 durations
	var dur = \dur.kr(1!78);

	// External trigger for multiple voices - expecting 78 triggers
	var go = \trigger.kr(0!78);

	// Envelope for the pluck sound
	var env = Env.perc(0.01, dur, amp, -4);

	// Pitch for multiple voices - expecting 78 pitches
	var p = \pitch.kr(42!78).midicps;

	// Synthesis - Plucked string sound using Karplus-Strong algorithm
	signal = Pluck.ar(
		WhiteNoise.ar(amp),  // Exciter
		go,  // Trigger
		p.reciprocal,  // Period of one cycle
		coef
	);

	// Apply the envelope to the signal
	signal = signal * EnvGen.ar(env, go, vel*0.5, 0, 1, 2);

	// Final signal - applying amplitude control
	finalSig = signal * \levels.kr(0.5!78);

	// Output - 78 channels
	Out.ar(out, finalSig);
}).add();
)

d = thisProcess.nowExecutingPath.dirname;

x = Synth(\pluck, [\trigger, 1, \pitch, 60, \amp, 0.5, \coef, 0.9, \vel, 0.8, \dur, 1, \levels, 0.7]);

