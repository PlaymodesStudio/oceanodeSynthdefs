(
~synthCreator.value("OteyPiano", {|n|
	var amp, gate, vel, sigmlen, env, sig, finalSig;



	// Envelope parameters
	var att = OceanodeParameter.ar(\att, 0.001, n, 0, 2, "vf");
	var dec = OceanodeParameter.ar(\dec, 0.001, n, 0, 2, "vf");
	var sus = OceanodeParameter.ar(\sus, 0.5, n, 0, 1, "vf");
	var rel = OceanodeParameter.ar(\rel, 5.5, n, 0, 10, "vf");
	var curve = OceanodeParameter.ar(\curve, -4, n, -10, 10, "vf");

	// Right side string parameters
	var rmin = OceanodeParameter.ar(\rmin, 0.35, n, 0, 1, "vf");
	var rmax = OceanodeParameter.ar(\rmax, 1, n, 0, 2, "vf");
	var rampl = OceanodeParameter.ar(\rampl, 4, n, 0, 10, "vf");
	var rampr = OceanodeParameter.ar(\rampr, 8, n, 0, 20, "vf");
	var rcore = OceanodeParameter.ar(\rcore, 1, n, 0, 2, "vf");

	// Left side string parameters
	var lmin = OceanodeParameter.ar(\lmin, 0.07, n, 0, 1, "vf");
	var lmax = OceanodeParameter.ar(\lmax, 0.9, n, 0, 2, "vf");

	// Physical model parameters
	var rho = OceanodeParameter.ar(\rho, 0.1, n, 0, 1, "vf");
	var e = OceanodeParameter.ar(\ee, 1, n, 0, 2, "vf");
	var zb = OceanodeParameter.ar(\zb, 0.3, n, 0, 1, "vf");
	var zh = OceanodeParameter.ar(\zh, 0, n, 0, 1, "vf");
	var mh = OceanodeParameter.ar(\mh, 1, n, 0, 2, "vf");
	var k = OceanodeParameter.ar(\kk, 0.05, n, 0, 0.5, "vf");
	var alpha = OceanodeParameter.ar(\alpha, 2, n, 0, 5, "vf");
	var p = OceanodeParameter.ar(\pp, 0.2, n, 0, 1, "vf");
	var hpos = OceanodeParameter.ar(\hpos, 0.3142, n, 0, 1, "vf");
	var loss = OceanodeParameter.ar(\loss, 10.1, n, 0, 20, "vf");
	var detune = OceanodeParameter.ar(\detune, 0.00003, n, 0, 0.1, "vf");
	var htype = OceanodeParameter.ar(\htype, 1, n, 0, 2, "vf");

	// Main parameters
	amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	vel = OceanodeParameter.ar(\vel, 0.5, n, 0, 1, "vf");

	// String length parameter
	sigmlen = OceanodeParameter.ar(\sigmlen, 8, n, 0, 20, "vf");

	// Generate signal for each channel
	sig = n.collect({ |chan|
		// Piano string model with all parameters
		var pianoSig = OteyPianoStrings.ar(
			\pitch.kr(60).midicps * (chan/n + 0.5).midiratio,
			vel[chan],
			gate[chan],
			rmin: rmin[chan],
			rmax: rmax[chan],
			rampl: rampl[chan],
			rampr: rampr[chan],
			rcore: rcore[chan],
			lmin: lmin[chan],
			lmax: lmax[chan],
			lampl: sigmlen[chan].neg,
			lampr: sigmlen[chan],
			rho: rho[chan],
			e: e[chan],
			zb: zb[chan],
			zh: zh[chan],
			mh: mh[chan],
			k: k[chan],
			alpha: alpha[chan],
			p: p[chan],
			hpos: hpos[chan],
			loss: loss[chan],
			detune: detune[chan],
			hammer_type: htype[chan]
		);

		// Create envelope with controllable parameters
		env = EnvGen.ar(
			Env([0, 0, sus[chan], 0], [att[chan], dec[chan], rel[chan]], curve[chan]),
			gate[chan]
		);

		// Apply envelope and amplitude curve
		 finalSig = pianoSig * env * amp[chan];

		// Safety processing - DC filtering and limiting
		finalSig = LeakDC.ar(finalSig);
		finalSig = Limiter.ar(finalSig, 0.9);

		// Replace NaN values with silence
		Select.ar(CheckBadValues.ar(finalSig, 0, 0) > 0, [finalSig, DC.ar(0)])
	});

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Physically modeled piano with adjustable string and hammer parameters", category: "Source/PhysicalModelling");
)