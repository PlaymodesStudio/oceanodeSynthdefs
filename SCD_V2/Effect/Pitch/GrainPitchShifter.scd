(
~synthCreator.value("GrainPitchShifter", {|n|
	var input, wet, output, pitchShift, grainSpeed, grainPeriods, timeDispersion, mix, amp;

	// Parameters with appropriate ranges
	pitchShift = OceanodeParameterLag.ar(\pitchshift, 0, n, -24, 24, "vf", 1/30, true).midiratio;
	grainSpeed = OceanodeParameter.ar(\grainspeed, 50, n, 10, 200, "vf");
	grainPeriods = OceanodeParameter.ar(\grainperiods, 4, n, 1, 10, "vf");
	timeDispersion = OceanodeParameter.ar(\timedisp, 6, n, 0, 20, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	amp = OceanodeParameter.ar(\amp, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Apply PitchShiftPA to each channel
	wet = n.collect({ |i|
		PitchShiftPA.ar(
			input[i],
			grainSpeed,       // granulation speed
			1,                // pitchRatio (not used, should be 1)
			pitchShift,       // formantRatio becomes actual pitch ratio
			10,               // minFreq
			20,               // maxFormantRatio becomes maximum pitch ratio
			grainPeriods,     // grainPeriods
			timeDispersion    // timeDispersion
		);
	});

	// Multichannel crossfade between dry and wet signals
	output = XFade2.ar(input, wet, mix.linlin(0, 1, -1, 1)) * amp;

	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Granular pitch shifter with independent grain control", category: "Effect/Pitch");
)