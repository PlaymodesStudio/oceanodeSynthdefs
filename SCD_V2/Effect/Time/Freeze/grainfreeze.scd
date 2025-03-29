~synthCreator.value("GrainFreeze", {|n|
	var source, sig, bufnum, point, pitch, glide, gate, wsize, playMode, rate, mix, numchans;
	var pointVal, wetSignal, drySignal, crossfade, attackTime, releaseTime;

	// All variables must be declared at the beginning
	numchans = n;

	// Parameters with appropriate ranges from synthdefs.json
	point = OceanodeParameter.ar(\point, 0, n, 0, 1, "vf");
	pitch = OceanodeParameter.ar(\pitch, 0, n, -36, 36, "vf");
	glide = OceanodeParameter.kr(\glide, 0, n, 0, 2, "vf");
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	wsize = OceanodeParameter.ar(\wsize, 0.45, n, 0.01, 1, "vf");
	// Convert playMode to use dropdown instead of numeric value
	playMode = OceanodeParameterDropdown.kr(\playmode, 0, n, "PointGlide:Saw:Sine:Triangle:Noise");
	rate = OceanodeParameter.ar(\rate, 0.1, n, 0.01, 2, "vf");

	// A) Add mix parameter (0 = dry only, 1 = wet only)
	mix = OceanodeParameter.kr(\mix, 0.5, n, 0, 1, "vf");

	// B) Add attack and release parameters for smooth crossfade
	attackTime = OceanodeParameter.ar(\attack, 0.1, n, 0.01, 2, "vf");
	releaseTime = OceanodeParameter.ar(\release, 0.1, n, 0.01, 2, "vf");

	// Input signal
	source = In.ar(OceanodeInput.kr(\in), 2); // Stereo input


	// Store dry signal for later mixing
	drySignal = source;

	// Create buffer for recording
	bufnum = LocalBuf(SampleRate.ir * 2, 2); // 2 seconds stereo buffer

	// Create a smooth crossfade envelope for gate transitions
	crossfade = EnvGen.kr(
		Env.asr(attackTime, 1, releaseTime, \sine),
		gate
	);

	// Record to buffer when gate is on with smooth crossfade
	RecordBuf.ar(source, bufnum, 0, 1, 0, (1-crossfade), 1, crossfade);

	// Create different position sources based on playback mode
	pointVal = Select.ar(playMode, [
		Lag.ar(point, glide),     // Manual
		LFSaw.ar(rate).abs,       // Saw
		SinOsc.ar(rate).abs,      // Sine
		LFTri.ar(rate).abs,       // Triangle
		LFNoise1.ar(rate, 0.5, 0.5) // Noise
	]);

	// Apply granular processing
	wetSignal = Warp1.ar(
		2,                  // Number of channels
		bufnum,             // Buffer
		pointVal,           // Position
		pitch.midiratio,    // Pitch ratio
		wsize,              // Window size
		-1,                 // Window randomization
		8,                  // Number of overlaps
		0.1,                // Window randomization
		2                   // Interpolation
	);

	// Use the mix parameter with XFade2 for smooth transitions between dry and wet
	// XFade2 expects a range of -1 to 1, where -1 is fully dry and 1 is fully wet
	// Convert our 0-1 mix range to -1 to 1
	sig = XFade2.ar(
		drySignal,
		wetSignal,
		mix.linlin(0, 1, -1, 1)
	);

	// Apply gate envelope for smooth transitions between normal and frozen states
	sig = XFade2.ar(
		drySignal,
		sig,
		crossfade.linlin(0, 1, -1, 1)
	);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Granular freeze effect with position pitch control and smooth crossfading", category: "Effect/Time/Freeze");