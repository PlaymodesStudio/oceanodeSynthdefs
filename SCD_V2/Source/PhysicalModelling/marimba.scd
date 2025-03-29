(
~synthCreator.value("Marimba", {|n|
	var mode, freq, amp, att, dec, rel, decCoef, position, ampSlope;
	var trig, excite, snd, input, mallet, trigSignal;

	// Mode selector as a dropdown parameter
	mode = OceanodeParameterDropdown.kr(\mode, 0, n, "Trigger:Drone:Input");

	// Common parameters with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 78, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 1, n, 0, 1, "vf", 1/30, true);

	// Material and excitation parameters
	att = OceanodeParameter.ar(\att, 0.001, n, 0.001, 1, "vf");
	dec = OceanodeParameter.ar(\dec, 0.01, n, 0, 1, "vf");
	rel = OceanodeParameter.ar(\rel, 0.395, n, 0, 1, "vf");
	decCoef = OceanodeParameter.ar(\deccoef, 0.84, n, 0, 1, "vf");
	position = OceanodeParameter.ar(\position, 0.414, n, 0, 1, "vf");
	ampSlope = OceanodeParameter.ar(\ampslope, 3, n, 0, 6, "vf");

	// Mode-specific parameters
	trig = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
	excite = OceanodeParameter.ar(\excite, 0.2, n, 0, 1, "vf");

	// Input signal for the input-driven mode
	input = In.ar(OceanodeInput.kr(\in), n);

	// Fix for trigger issue: Only trigger on rising edge (0->1)
	trigSignal = n.collect({ |chan|
		var current = K2A.ar(trig[chan]);
		var prev = DelayN.ar(current, 0.01, 0.005);
		(current > 0.5) * (prev <= 0.5); // Rising edge detection
	});

	// Generate signal for each channel
	snd = n.collect({ |chan|
		var freqs, amps, decs;

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
			var thisFreq = freqs[i];
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

		// Different excitation mechanisms based on mode
		mallet = Select.ar(mode[chan], [
			// Mode 0: Triggered mallet hit (now with proper edge detection)
			Decay2.ar(trigSignal[chan], att[chan], dec[chan], 0.1),

			// Mode 1: Continuous excitation (drone)
			WhiteNoise.ar() * 0.02 * excite[chan],

			// Mode 2: Input-driven
			input[chan] * 0.1
		]);

		// Use DynKlank for dynamic resonator bank
		DynKlank.ar(
			specificationsArrayRef: Ref.new([
				freqs,    // frequencies
				amps,     // amplitudes
				decs      // decay times
			]),
			input: mallet
		) * amp[chan].lincurve(0, 1, 0, 1, 4)
	});

	// Output with limiter for safety
	Out.ar(OceanodeOutput.kr(\out), Limiter.ar(snd, 0.95, 0.01));

}, description: "Modal synthesis marimba with triggering drone and input modes", category: "Source/PhysicalModelling");
)