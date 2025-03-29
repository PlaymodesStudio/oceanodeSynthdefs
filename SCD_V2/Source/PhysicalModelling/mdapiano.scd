(
~synthCreator.value("MDAPiano", {|n|
	var freq, gate, vel, decay, release, random;
	var sustain, hard, velhard, muffle, velmuff;
	var velcurve, tune, levels, signals;

	// Main parameters
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true).midicps;
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");

	// Amplitude and dynamic parameters
	vel = OceanodeParameter.ar(\vel, 80, n, 1, 127, "vf");
	levels = OceanodeParameterLag.ar(\levels, 0.1, n, 0, 1, "vf", 1/30, true);

	// Decay and release parameters
	decay = OceanodeParameter.ar(\decay, 0.8, n, 0.1, 1, "vf");
	release = OceanodeParameter.ar(\release, 0.8, n, 0.1, 1, "vf");

	// Sustain mode
	sustain = OceanodeParameter.ar(\sustain, 0, n, 0, 1, "vf");

	// Tone parameters
	random = OceanodeParameter.ar(\random, 0.1, n, 0, 1, "vf");
	tune = OceanodeParameter.ar(\tune, 0.5, n, 0, 1, "vf");

	// Touch response parameters
	hard = OceanodeParameter.ar(\hard, 0.8, n, 0, 1, "vf");
	velhard = OceanodeParameter.ar(\velhard, 0.8, n, 0, 1, "vf");
	muffle = OceanodeParameter.ar(\muffle, 0.8, n, 0, 1, "vf");
	velmuff = OceanodeParameter.ar(\velmuff, 0.8, n, 0, 1, "vf");
	velcurve = OceanodeParameter.ar(\velcurve, 0.8, n, 0, 1, "vf");

	// Create n independent piano voices
	signals = n.collect({ |chan|
		MdaPiano.ar(
			freq[chan],
			gate[chan],
			vel: vel[chan],
			hard: hard[chan],
			muffle: muffle[chan],
			velhard: velhard[chan],
			velmuff: velmuff[chan],
			velcurve: velcurve[chan],
			stereo: 0,  // mono output per channel
			tune: tune[chan],
			random: random[chan],
			sustain: sustain[chan],
			decay: decay[chan],
			release: release[chan]
		) * levels[chan].lincurve(0, 1, 0, 1, 4)
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), signals);

}, description: "MDA Piano model with adjustable touch response and tuning", category: "Source/PhysicalModelling");
)