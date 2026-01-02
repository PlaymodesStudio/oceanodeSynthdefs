(
~synthCreator.value("Leslie", {|n|
	var source, distance, throb, sound1, sound2, wet;
	var leslie, lrate, lsize, lrateKr, lrateKr2, panMod;

	// Input
	source = In.ar(OceanodeInput.kr(\in), n);

	// Parameters with proper ranges based on original
	leslie = OceanodeParameterLag.ar(\leslie, 0.5, n, 0, 1, "vf", 1/30, true);
	lrate = OceanodeParameterLag.kr(\lrate, 6.7, n, 0.1, 20, "vf", 1/30, true);
	lsize = OceanodeParameterLag.ar(\lsize, 0.3, n, 0, 1, "vf", 1/30, true);

	// Convert rates to control rate with lag for modulation
	lrateKr = Lag.kr(lrate, 10);
	lrateKr2 = Lag.kr(lrate * 0.8, 20);

	// Leslie effect calculations - shared across all channels
	distance = SinOsc.ar(lrateKr, 0).range(0, lsize);
	throb = SinOsc.ar(lrateKr2, 0).range(0, lsize * 1.3);

	// Create channel-specific modulation for rotating effect
	panMod = Array.fill(n, { |i|
		var phase = (i / max(1, n-1)) * 2 * pi; // Distribute phases around circle
		SinOsc.kr(Lag.kr(lrate * 0.8, 4), phase).range(-0.3, 0.3);
	});

	// Split signal into low and high frequency components
	sound2 = HPF.ar(source, 800);
	sound1 = source - sound2;

	// Process low frequencies with tremolo and channel-specific modulation
	sound1 = leslie * (1.0 - throb) * sound1;
	sound1 = sound1 * (1 + (panMod * 0.5)); // Apply rotating modulation

	// Process high frequencies with delay (Doppler effect) and counter-modulation
	sound2 = DelayC.ar(sound2, 1, distance / 343);
	sound2 = leslie * (1.0 - distance) * sound2;
	sound2 = sound2 * (1 - (panMod * 0.3)); // Counter-rotating for highs

	// Combine processed signals
	wet = 1.2 * (sound1 + sound2);

	// Mix with dry signal using XFade2
	wet = XFade2.ar(source, wet, OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf") * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), wet);

}, description: "Rotating speaker cabinet effect with modulated delays and panning", category: "Spatial/Perceptual");
)