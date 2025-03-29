(
~synthCreator.value("MarimbaResonator", {|n|
	var freq, amp, rel, decCoef, position, ampSlope;
	var snd, input, send, mix;
	var freqs, amps, decs, chanInput, wet, thisFreq;

	// Common parameters with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 78, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 1, n, 0, 1, "vf", 1/30, true);

	// Material parameters
	rel = OceanodeParameter.ar(\rel, 0.395, n, 0, 1, "vf");
	decCoef = OceanodeParameter.ar(\deccoef, 0.84, n, 0, 1, "vf");
	position = OceanodeParameter.ar(\position, 0.414, n, 0, 1, "vf");
	ampSlope = OceanodeParameter.ar(\ampslope, 3, n, 0, 6, "vf");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signal for each channel
	snd = n.collect({ |chan|
		chanInput = input[chan] * send[chan] * 0.1;

		// Calculate frequency ratios for marimba sound (30 partials)
		freqs = Array.fill(30, { |i|
			var ratio = if(i <= 1) {
				Select.kr(i, [1.50561873, 2.49975267])
			} {
				i + 1.5
			} / 1.50561873;
			ratio * freq[chan];
		});

		// Calculate amplitudes based on strike position and frequency scaling
		amps = Array.fill(30, { |i|
			thisFreq = freqs[i];
			Select.kr(
				thisFreq <= 20000,
				[
					0,
					sin(((i + 1) * pi) * position[chan]) *
					(ampSlope[chan] * (thisFreq/freq[chan]).log2).dbamp
				]
			);
		});

		// Calculate decay times with material coefficient
		decs = Array.fill(30, { |i|
			exp(-1 * i * decCoef[chan]) * rel[chan]
		});

		// Use DynKlank for dynamic resonator bank
		wet = DynKlank.ar(
			specificationsArrayRef: Ref.new([
				freqs,    // frequencies
				amps,     // amplitudes
				decs      // decay times
			]),
			input: chanInput
		) * amp[chan].lincurve(0, 1, 0, 1, 4);
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
	});

	// Output with limiter for safety
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(snd, 0.95, 0.01));

}, description: "Marimba resonator effect that applies marimba-like resonances to input audio", category: "Effect/Resonators");
)