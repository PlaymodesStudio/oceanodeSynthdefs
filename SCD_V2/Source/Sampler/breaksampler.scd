(
~synthCreator.value("BreakSampler", {|n|
	var sig, bufDur, rate, bufFrames, portionDur;
	var startPos, endPos, trigger, loop, duration, levels, buffer;
	var phaseStart, phaseEnd, phase, phaseLoop;

	// Get buffer info
	buffer = OceanodeBuffer.kr(\buf);
	bufFrames = BufFrames.kr(buffer);
	bufDur = BufDur.kr(buffer);

	// Parameters with lag for smooth transitions
	levels = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	duration = OceanodeParameterLag.ar(\duration, 1000, n, 100, 10000, "vf", 1/30, true);

	// Position parameters
	startPos = OceanodeParameter.ar(\startpos, 0, n, 0, 1, "vf");
	endPos = OceanodeParameter.ar(\endpos, 1, n, 0, 1, "vf");

	// Other parameters
	loop = OceanodeParameter.kr(\loop, 0, n, 0, 1, "vi");
	trigger = OceanodeParameter.kr(\trigger, 0, n, 0, 1, "vi");

	// Calculate duration of selected portion in seconds
	portionDur = bufDur * (endPos - startPos);

	// Calculate rate: portion duration / target duration
	// When portionDur = 5s and duration = 4000ms, rate should be 5/(4/1000) = 1.25
	rate = portionDur / (duration / 1000);

	// Convert normalized positions to frames
	phaseStart = startPos * bufFrames;
	phaseEnd = endPos * bufFrames;

	// Create trigger signal
	trigger = Trig.kr(trigger, 0.001);

	// Create custom phase that loops between start and end points
	phase = Phasor.ar(
		trig: trigger,
		rate: rate * BufRateScale.kr(buffer),
		start: phaseStart,
		end: phaseEnd,
		resetPos: phaseStart
	);

	// Apply looping logic (if loop=0, stop at end position)
	phaseLoop = Select.ar(loop, [
		// No loop: phase stops at end
		phase.clip(phaseStart, phaseEnd),
		// Loop: phase wraps between start and end
		phase
	]);

	// Play the buffer with n channels using our custom phase
	sig = BufRd.ar(
		numChannels: n,
		bufnum: buffer,
		phase: phaseLoop,
		loop: 1,  // Let Phasor handle loop behavior
		interpolation: 4 // Cubic interpolation for best quality
	);

	// Apply gain and output
	sig = sig * levels;

	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Sample player for rhythm breaks with automatic duration adjustment", category: "Source/Sampler");
)