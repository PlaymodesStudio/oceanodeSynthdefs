(
~synthCreator.value("SubharmonicShaper", {|n|
	var input, output;
	var drive, mix, levels, sensitivity, lowpassFreq;
	var numDividers = 8;
	var dividerAmps;

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Parameters
	drive = OceanodeParameterLag.ar(\drive, 1, n, 0.1, 10, "vf", 1/30, true);
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	sensitivity = OceanodeParameterLag.ar(\sensitivity, 0.1, n, 0.01, 1, "vf", 1/30, true);
	lowpassFreq = OceanodeParameterLag.ar(\lowpass, 300, n, 50, 1000, "vf", 1/30, true);

	// Frequency divider amplitudes (1/2, 1/3, 1/4, 1/5, 1/6, 1/7, 1/8, 1/9)
	dividerAmps = OceanodeParameterLag.ar(\dividers_8, 0, numDividers, 0, 2, "vf", 1/30, true);

	// Process each channel individually
	output = Array.fill(n, { |chanNum|
		var chanInput = input[chanNum];
		var drivenInput, subharmonicSum, processedInput;
		var zeroCrossing, dividerTriggers, gates, gatedSignals;

		// Apply drive and light nonlinear distortion for difference frequencies
		drivenInput = (chanInput * drive[chanNum]).tanh;

		// Lowpass filter the input to focus on fundamental content
		processedInput = LPF.ar(drivenInput, lowpassFreq[chanNum]);

		// Detect zero crossings (positive going)
		zeroCrossing = Trig1.ar(
			(processedInput > 0) * (Delay1.ar(processedInput) <= 0),
			SampleDur.ir
		);

		// Create frequency dividers using counters
		dividerTriggers = Array.fill(numDividers, { |divIndex|
			var divider = divIndex + 2; // 2, 3, 4, 5, 6, 7, 8, 9
			var counter = PulseCount.ar(zeroCrossing) % divider;
			var counterIsZero = (counter |==| 0);  // Use |==| for audio-rate comparison
			var dividerTrig = Trig1.ar(counterIsZero, SampleDur.ir);
			dividerTrig;
		});

		// Create gates that open/close based on divider triggers
		// Each gate alternates between 0 and 1 on each trigger
		gates = Array.fill(numDividers, { |divIndex|
			var flipFlop = ToggleFF.ar(dividerTriggers[divIndex]);
			// Use sensitivity to control gate depth
			flipFlop * sensitivity[chanNum] + (1 - sensitivity[chanNum]);
		});

		// Apply gates to the processed input
		gatedSignals = Array.fill(numDividers, { |divIndex|
			var gatedSig = processedInput * gates[divIndex] * dividerAmps[divIndex];
			// Additional lowpass filtering to smooth the gated result
			LPF.ar(gatedSig, lowpassFreq[chanNum] * 0.5);
		});

		// Sum all the gated subharmonics
		subharmonicSum = gatedSignals.sum;

		// Apply soft saturation
		subharmonicSum = subharmonicSum.tanh;

		subharmonicSum;
	});

	// Apply dry/wet mix using XFade2
	output = Array.fill(n, { |i|
		XFade2.ar(input[i], output[i], mix[i].linlin(0, 1, -1, 1));
	});

	// Apply final level control
	output = output * levels;

	// Output the processed signal
	Out.ar(OceanodeOutput.kr(\out), output);

}, description: "True subharmonic generator using frequency division and gating", category: "Effect/Distortion");
)