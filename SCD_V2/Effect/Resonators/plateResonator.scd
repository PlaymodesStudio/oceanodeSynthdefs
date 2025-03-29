(
~synthCreator.value("PlateResonator", {|n|
	var freq, amp, rel, ratio, decCoef, xpos, ypos, thumpDec;
	var freqArray, ampArray, decArray, snd, input, send, mix;
	var chanInput, wet, processed;

	// Main parameters
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);

	// Sound shaping parameters
	rel = OceanodeParameter.ar(\rel, 2, n, 0.1, 10, "vf");
	ratio = OceanodeParameter.ar(\ratio, 1, n, 0.1, 5, "vf");
	decCoef = OceanodeParameter.ar(\deccoef, 0.31, n, 0, 1, "vf");

	// Position parameters
	xpos = OceanodeParameter.ar(\xpos, 0.5, n, 0, 1, "vf");
	ypos = OceanodeParameter.ar(\ypos, 0.5, n, 0, 1, "vf");
	thumpDec = OceanodeParameter.ar(\thumpdec, 0.75, n, 0, 1, "vf");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Input for excitation
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signals for each channel
	snd = n.collect({ |chan|
		chanInput = input[chan] * send[chan];
		
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

		// The Plate resonator using DynKlank
		wet = DynKlank.ar(
			specificationsArrayRef:
				Ref.new([freqArray.flatten, ampArray.flatten, decArray.flatten]),
			input: chanInput,
			freqscale: 1,
			decayscale: rel[chan]
		);

		// Mix down and apply amplitude
		processed = Mix.ar(wet/7) * amp[chan].lincurve(0, 1, 0, 1, 4);
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], processed, mix[chan] * 2 - 1);
	});

	// Output with limiter
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(snd));

}, description: "Plate resonator effect that applies metal plate resonances to input audio", category: "Effect/Resonators");
)