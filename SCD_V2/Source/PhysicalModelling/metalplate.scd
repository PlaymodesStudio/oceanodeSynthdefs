(
~synthCreator.value("MetalPlate", {|n|
	var t_gate, freq, amp, rel, crv, ratio, decCoef, xpos, ypos, thumpDec;
	var exciter, freqArray, ampArray, decArray, snd, env, input, exmode;

	// Main parameters
	t_gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);

	// Sound shaping parameters
	rel = OceanodeParameter.ar(\rel, 2, n, 0.1, 10, "vf");
	crv = OceanodeParameter.ar(\crv, 0, n, -8, 8, "vf");
	ratio = OceanodeParameter.ar(\ratio, 1, n, 0.1, 5, "vf");
	decCoef = OceanodeParameter.ar(\deccoef, 0.31, n, 0, 1, "vf");

	// Position parameters
	xpos = OceanodeParameter.ar(\xpos, 0.5, n, 0, 1, "vf");
	ypos = OceanodeParameter.ar(\ypos, 0.5, n, 0, 1, "vf");
	thumpDec = OceanodeParameter.ar(\thumpdec, 0.75, n, 0, 1, "vf");

	// Excitation mode selector as dropdown (added)
	exmode = OceanodeParameterDropdown.kr(\exmode, 0, n, "Internal:External");

	// Input for external excitation (added)
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signals for each channel
	snd = n.collect({ |chan|
		// Envelope for gating - only used in internal mode
		env = EnvGen.kr(Env.asr(0.01, 1, rel[chan], crv[chan]), gate: t_gate[chan]);

		// Frequencies - 2D array of harmonics
		freqArray = Array.fill2D(16, 16, {
			arg i, j;
			(i + 1).pow(2) + (ratio[chan] * (j + 1)).pow(2)
		});
		freqArray = freqArray/(freqArray[0][1]);
		freqArray = freqArray * freq[chan];

		// Amplitudes - based on position and frequency
		ampArray = Array.fill2D(16, 16, {
			arg i, j;
			((1 - ((freqArray[i][j] - 19000)/1000).tanh)/2) *
			sin(((i + 1) * pi) * xpos[chan]) *
			sin(((j + 1) * pi) * ypos[chan])
		});

		// Decay Times - dependent on position in the array
		decArray = Array.fill2D(16, 16, {
			arg i, j;
			(
				if (j == 0)
					{ thumpDec[chan] }
					{ 1 }
			) *
			exp(-1 * (i + j) * decCoef[chan])
		});

		// Select excitation source based on mode
		exciter = Select.ar(exmode[chan], [
			// Internal exciter - triggered
			T2A.ar(t_gate[chan]),

			// External input
			input[chan]
		]);

		// The Plate resonator using DynKlank
		snd = DynKlank.ar(
			specificationsArrayRef:
				Ref.new([freqArray.flatten, ampArray.flatten, decArray.flatten]),
			input: exciter,
			freqscale: 1,
			decayscale: rel[chan]
		);

		// Mix down and apply amplitude curve with conditional envelope
		Mix.ar(snd/7) * amp[chan].lincurve(0, 1, 0, 1, 4) *
		Select.kr(exmode[chan], [
			// For internal mode: apply envelope
			env,

			// For external mode: no envelope
			1.0
		])
	});

	// Output with limiter
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(snd));

}, description: "Metal plate simulation with adjustable position and decay characteristics", category: "Source/PhysicalModelling");
)