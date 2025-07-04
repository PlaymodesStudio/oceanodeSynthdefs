(
~synthCreator.value("Tabla", {|n|
	var sig, membrane, edge, syahi, strike, pos, hardness, pitch;
	var membraneFreq, edgeFreq, syahiFreq;
	var excitation, membraneExcite, edgeExcite, syahiExcite;
	var coupling, membraneOut, edgeOut, syahiOut;
	var envelope, attack, decay, release, curve, gate, velocity;
	var bendFreq, bendAmount, shimmer, shimmerRate;
	var brightness, presence, levels;
	var prevGate, trigger;
	var headDamping, edgeDamping, syahiDamping;

	// Control parameters
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	pitch = OceanodeParameterLag.ar(\pitch, 48, n, 24, 96, "vf", 1/30, true);
	velocity = OceanodeParameterLag.ar(\velocity, 0.8, n, 0, 1, "vf", 1/30, true);
	pos = OceanodeParameter.ar(\strikepos, 0.3, n, 0, 1, "vf");
	hardness = OceanodeParameter.ar(\hardness, 0.5, n, 0, 1, "vf");

	// Envelope controls - now properly connected
	attack = OceanodeParameterLag.ar(\attack, 0.001, n, 0.001, 0.1, "vf", 1/30, true);
	decay = OceanodeParameterLag.ar(\decay, 2, n, 0.1, 8, "vf", 1/30, true);
	release = OceanodeParameterLag.ar(\release, 1, n, 0.1, 4, "vf", 1/30, true);
	curve = OceanodeParameter.ar(\curve, -4, n, -8, 8, "vf");

	// Physical modeling parameters - now properly connected
	coupling = OceanodeParameter.ar(\coupling, 0.15, n, 0, 1, "vf");
	headDamping = OceanodeParameter.ar(\headdamp, 0.3, n, 0, 1, "vf");
	edgeDamping = OceanodeParameter.ar(\edgedamp, 0.6, n, 0, 1, "vf");
	syahiDamping = OceanodeParameter.ar(\syahidamp, 0.2, n, 0, 1, "vf");

	// Pitch bending and modulation - now properly connected
	bendAmount = OceanodeParameter.ar(\bendamt, 0, n, 0, 2, "vf");
	shimmer = OceanodeParameter.ar(\shimmer, 0.1, n, 0, 1, "vf");
	shimmerRate = OceanodeParameter.ar(\shimmerrate, 3, n, 0.1, 10, "vf");

	// Tone shaping
	brightness = OceanodeParameter.ar(\brightness, 0.7, n, 0, 1, "vf");
	presence = OceanodeParameter.ar(\presence, 0.5, n, 0, 1, "vf");

	// Output controls - much higher default level
	levels = OceanodeParameterLag.ar(\levels, 1.0, n, 0, 1, "vf", 1/30, true);

	// Convert pitch to frequency
	membraneFreq = pitch.midicps;

	// Calculate resonant frequencies
	edgeFreq = membraneFreq * (1.593 + (pos * 0.2));
	syahiFreq = membraneFreq * (0.765 + (hardness * 0.1));

	// Proper trigger detection
	prevGate = Delay1.ar(gate);
	trigger = (gate - prevGate).max(0);

	// Pitch bending modulation - now properly applied
	bendFreq = SinOsc.ar(shimmerRate, 0, bendAmount * membraneFreq * 0.02);
	membraneFreq = membraneFreq + bendFreq;
	edgeFreq = edgeFreq + (bendFreq * 0.7);
	syahiFreq = syahiFreq + (bendFreq * 1.3);

	// Create envelope with all parameters properly connected
	envelope = EnvGen.ar(
		Env([0, 1, 0], [attack, decay + release], [curve, curve]),
		gate: trigger,
		doneAction: 0
	);

	// Much stronger excitation signal
	excitation = (
		// Strong initial impulse - much louder
		Impulse.ar(0) * trigger * velocity * 100 +
		// Brief burst of filtered noise
		(BPF.ar(WhiteNoise.ar(1), membraneFreq * (2 + hardness), 0.5) *
			EnvGen.ar(Env.perc(0.001, 0.02), trigger) * hardness * 10)
	);

	// Position-dependent excitation
	membraneExcite = excitation * sin(pi * (1 - pos));
	edgeExcite = excitation * sin(pi * pos) * (0.5 + hardness);
	syahiExcite = excitation * sin(pi * 0.5 * (1 - (pos - 0.5).abs)) * (0.3 + hardness * 0.4);

	// Main membrane with proper damping control
	membrane = DynKlank.ar(
		`[
			[1, 1.593, 2.136, 2.296, 2.653, 3.598],
			[1, 0.3, 0.15, 0.1, 0.08, 0.05] * (1 + velocity * 2),
			[1, 0.8, 0.6, 0.4, 0.3, 0.2] * decay * (1 / (headDamping * 10 + 0.1))
		],
		membraneExcite,
		freqscale: membraneFreq,
		freqoffset: 0,
		decayscale: 1
	);

	// Edge modes with proper damping control
	edge = DynKlank.ar(
		`[
			[1, 1.8, 2.4],
			[0.6, 0.2, 0.1] * (0.5 + hardness) * (1 + velocity),
			[0.5, 0.3, 0.2] * decay * (1 / (edgeDamping * 10 + 0.1))
		],
		edgeExcite,
		freqscale: edgeFreq,
		freqoffset: 0,
		decayscale: 1
	);

	// Syahi with proper damping control
	syahi = DynKlank.ar(
		`[
			[1, 0.85, 1.3],
			[0.8, 0.4, 0.2] * (0.7 + hardness * 0.3) * (1 + velocity),
			[1.5, 1.2, 0.8] * decay * (1 / (syahiDamping * 5 + 0.1))
		],
		syahiExcite,
		freqscale: syahiFreq,
		freqoffset: 0,
		decayscale: 1
	);

	// Cross-coupling - now properly controlled by coupling parameter
	membraneOut = membrane + (edge * coupling * 0.5) + (syahi * coupling * 0.8);
	edgeOut = edge + (membrane * coupling * 0.3) + (syahi * coupling * 0.2);
	syahiOut = syahi + (membrane * coupling * 0.6) + (edge * coupling * 0.3);

	// Mix the three components
	sig = (membraneOut * 0.5) + (edgeOut * 0.2) + (syahiOut * 0.4);

	// Apply shimmer modulation - now properly controlled
	sig = sig * (1 + (shimmer * SinOsc.ar(shimmerRate, 0, 0.2)));

	// Tone shaping with proper parameter control
	sig = sig + HPF.ar(sig, membraneFreq * (1 + brightness * 2), 0.5) * brightness * 0.3;
	sig = sig + LPF.ar(sig, membraneFreq * 3) * (1 - brightness * 0.7) * 0.4;
	sig = sig + BPF.ar(sig, membraneFreq * (2 + presence), 1.5) * presence * 0.2;

	// Subtle controlled distortion
	sig = sig + (sig.softclip * hardness * 0.05);

	// Apply envelope and controls with much higher overall gain
	sig = sig * envelope * levels * (velocity + 0.5) * 5; // Added big gain boost here

	// DC removal
	sig = LeakDC.ar(sig);

	// Safety limiter
	sig = Limiter.ar(sig, 0.95);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Realistic tabla physical modeling synthesizer", category: "Source/PhysicalModelling");
)