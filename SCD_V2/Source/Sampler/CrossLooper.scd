(
~synthCreator.value("CrossLooper", {|n|
	var buf, xfadeTime, trig, levels, pitch, start, loopDur, rate;
	var bufDur, startPos, xfadeSeconds, signals;

	// Input parameters with appropriate range values
	trig = OceanodeParameter.ar(\trig, 0, n, 0, 1, "vi");
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	pitch = OceanodeParameter.ar(\pitch, 0, n, -24, 24, "vf");
	start = OceanodeParameter.ar(\start, 0, n, 0, 1, "vf");
	loopDur = OceanodeParameter.ar(\loopdur, 0.5, n, 0.01, 10, "vf"); // Now in seconds, with appropriate range
	xfadeTime = OceanodeParameter.ar(\xfadetime, 0.1, n, 0, 1, "vf");
	buf = OceanodeParameter.ar(\bufnum, 0, n, 0, 1000, "vi");

	// Convert semitones to playback rate
	rate = pitch.midiratio;

	// Get buffer duration
	bufDur = BufDur.kr(buf);

	// Calculate positions
	startPos = start * bufDur;

	// Calculate crossfade time in seconds
	xfadeSeconds = xfadeTime * loopDur;

	// Generate signals
	signals = XPlayBuf.ar(
		numChannels: 1,
		bufnum: buf,
		rate: rate,
		trigger: trig,
		startPos: startPos,
		loopDur: loopDur, // Now directly in seconds, no need to multiply by bufDur
		loop: 1,
		fadeTime: 0.001,
		xFadeTime: xfadeSeconds
	) * levels;

	// Output signals
	Out.ar(OceanodeOutput.kr(\out), signals*LPF.ar(trig,20));

}, description: "Buffer looper with crossfade and variable duration", category: "Source/Sampler");
)