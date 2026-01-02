(
~synthCreator.value("InterferenceRhythm", {|n, variables|
	var pattern, durationMs, minFreq, maxFreq, reset, levels, seed;
	var freqs, phases, sinusoids, output;
	var resetTrig, stepDuration, fundamentalFreq;
	var freqRange, freqBase, numOscillators;
	var patternSum, targetPhases, harmonicSpacing;

	// Input parameters
	pattern = OceanodeParameter.ar(\pattern, [1, 0, 1, 0, 1, 1, 0, 1], 8, 0, 1, "vf"); // 8-step pattern
	durationMs = OceanodeParameter.ar(\durationms, 4000, n, 500, 32000, "vf"); // Pattern duration
	minFreq = OceanodeParameter.ar(\minfreq, 80, n, 20, 2000, "vf"); // Min frequency
	maxFreq = OceanodeParameter.ar(\maxfreq, 800, n, 50, 4000, "vf"); // Max frequency
	reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vf"); // Reset trigger
	seed = OceanodeParameter.ar(\seed, 1, n, 1, 10000, "vi"); // Random seed
	levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true); // Output level

	// Setup
	numOscillators = n;
	stepDuration = durationMs / 8000; // Convert to seconds for 8 steps
	fundamentalFreq = 1 / (stepDuration * 8); // Base frequency for pattern timing
	freqRange = maxFreq - minFreq;
	freqBase = minFreq;
	resetTrig = Trig1.kr(reset > 0.5, 0.01);

	// Calculate sum of pattern for normalization
	patternSum = pattern[0] + pattern[1] + pattern[2] + pattern[3] +
	            pattern[4] + pattern[5] + pattern[6] + pattern[7];

	// Generate frequencies using deterministic distribution
	freqs = numOscillators.collect({|i|
		var seedVal = (seed * 31 + i * 17 + i * i * 7) % 9973;
		var normalizedSeed = seedVal / 9973;
		var baseFreq = freqBase + (freqRange * normalizedSeed);

		// Add harmonic relationships to fundamental frequency
		var harmonicIndex = (i % 7) + 1;
		var harmonicComponent = fundamentalFreq * harmonicIndex * 0.1;

		// Slight frequency adjustment based on pattern energy
		var patternInfluence = (patternSum / 8) * 0.05;

		baseFreq + harmonicComponent + (baseFreq * patternInfluence);
	});

	// Calculate phases to create interference pattern
	phases = numOscillators.collect({|i|
		var seedPhase = ((seed + i * 23) * 1.618034) % 1;
		var basePhase = seedPhase * 2pi;

		// Calculate phase offset based on desired interference
		var stepIndex = i % 8;
		var stepValue = pattern[stepIndex];

		// For steps with value 1, align phases for constructive interference
		// For steps with value 0, offset phases for destructive interference
		var patternPhase = stepValue * pi;

		// Add harmonic phase relationships
		var harmonicPhase = (i / numOscillators) * 2pi;

		// Combine all phase components
		(basePhase + patternPhase + harmonicPhase) % (2pi);
	});

	// Create the sinusoids
	sinusoids = numOscillators.collect({|i|
		var freq = freqs[i];
		var initialPhase = phases[i];

		// Create oscillator with reset capability
		// When reset triggers, the phase jumps back to initial phase
		var resetPhase = Latch.kr(initialPhase, resetTrig + Impulse.kr(0));
		var runningPhase = Phasor.ar(resetTrig, freq * 2pi / SampleRate.ir, 0, 2pi, resetPhase);

		// Generate the sinusoid
		SinOsc.ar(0, runningPhase);
	});

	// Apply level control with natural curve
	output = sinusoids * levels;

	// Output each oscillator to its own channel
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "N independent sinusoids creating interference rhythm patterns", category: "Source/Special");
)