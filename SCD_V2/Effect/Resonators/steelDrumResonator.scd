(
~synthCreator.value("SteelDrumResonator", {|n|
	var freq, amp, dec, curve, filterHarmonic;
	var resFreqArray, resAmpArray, resDecArray, snd;
	var input, send, mix, chanInput, wet;

	// Parameters
	freq = OceanodeParameter.ar(\pitch, 60, n, 24, 96, "vf").midicps;
	amp = OceanodeParameter.ar(\amp, 0.1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	dec = OceanodeParameter.ar(\dec, 1.5, n, 0.1, 5, "vf");
	curve = OceanodeParameter.ar(\curve, -6, n, -10, 0, "vf");
	filterHarmonic = OceanodeParameter.ar(\harmonic, 6, n, 1, 20, "vf");
	
	// Mix and send parameters
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Arrays for the bank of resonators, mostly harmonics near 5ths and 9ths, and random amplitudes
	resFreqArray = [2, 2.98, 4.75, 6.21, 9, 9.15, 11.87];
	resAmpArray = [0.35, 0.23, 0.10, 0.06, 0.07, 0.05, 0.01];
	resDecArray = [0.86, 0.72, 0.37, 0.55, 0.32, 0.21, 0.16];

	// Input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Generate signal for each channel
	snd = n.collect({ |chan|
		chanInput = input[chan] * send[chan];
		
		// Fundamental and octave up resonances
		wet = SinOsc.ar(freq: freq[chan], mul: 0.2) * chanInput;
		wet = wet + SinOsc.ar(freq: freq[chan] * 2.015, mul: 0.1) * chanInput;
		
		// Bank of enharmonic resonators
		wet = wet + DynKlank.ar(
			specificationsArrayRef:
				Ref.new([
					resFreqArray * freq[chan],
					resAmpArray,
					resDecArray * dec[chan]
				]),
			input: LPF.ar(HPF.ar(chanInput, freq[chan] * 2), freq[chan] * filterHarmonic[chan])
		);

		// Output stages with a tiny bit of compression to smooth things out
		wet = Limiter.ar(wet * amp[chan], amp[chan]);
		
		// Mix dry and wet signals
		XFade2.ar(input[chan], wet, mix[chan] * 2 - 1);
	});

	// Output
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Steel drum resonator effect that applies steel drum-like resonances to input audio", category: "Effect/Resonators");
)