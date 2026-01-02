(
~synthCreator.value("Roar", {|n|
	// Define all variables at the beginning
	var sig, sigDry, sigWet, sigShaped, feed;
	var tone, toneFreq, toneComp, toneAmpLo, toneAmpHi, drive, bias, amount;
	var filterFunc, filterFreq, filterLoHi, filterBP, filterRes, filterBW, filterPre;
	var feedAmt, feedFreq, feedBW, feedDelay, feedGate;

	// Input signal from Oceanode
	sig = In.ar(OceanodeInput.kr(\in), n);

	// Parameter definitions with proper range values
	drive = OceanodeParameter.ar(\drive, 14, n, 0, 48, "vf").dbamp;
	tone = OceanodeParameter.ar(\tone, -0.4, n, -1, 1, "vf");
	toneFreq = OceanodeParameter.ar(\tonefreq, 5520, n, 20, 20000, "vf");
	toneComp = OceanodeParameter.ar(\tonecomp, 1, n, 0, 1, "vf");
	amount = OceanodeParameter.ar(\amount, 0.8, n, 0, 1, "vf");
	bias = OceanodeParameter.ar(\bias, 0, n, -1, 1, "vf");

	filterFreq = OceanodeParameter.ar(\filterfreq, 12800, n, 20, 20000, "vf");
	filterLoHi = OceanodeParameter.ar(\filterlohi, -1, n, -1, 1, "vf");
	filterBP = OceanodeParameter.ar(\filterbp, 0.2, n, 0, 1, "vf");
	filterRes = OceanodeParameter.ar(\filterres, 0.3, n, 0, 1, "vf");
	filterBW = OceanodeParameter.ar(\filterbw, 0.5, n, 0, 4, "vf");
	filterPre = OceanodeParameter.ar(\filterpre, 1, n, 0, 1, "vf");

	feedAmt = OceanodeParameter.ar(\feedamt, -14, n, -90, 12, "vf").dbamp;
	feedFreq = OceanodeParameter.ar(\feedfreq, 80, n, 20, 20000, "vf");
	feedBW = OceanodeParameter.ar(\feedbw, 0.1, n, 0, 4, "vf");
	feedDelay = OceanodeParameter.ar(\feeddelay, 1/6, n, 0, 4, "vf") - ControlDur.ir;
	feedGate = OceanodeParameter.ar(\feedgate, 0.1, n, 0.02, 0.3, "vf");

	// Calculate tone amp values
	toneAmpLo = tone.lincurve(-1.0, 1.0, 2.0, 0.0, -0);
	toneAmpHi = tone.lincurve(-1.0, 1.0, 0.0, 2.0, 0);

	// WET TONE
	sigWet = BLowShelf.ar(BHiShelf.ar(sig, toneFreq, 1, toneAmpHi.ampdb), toneFreq, 1, toneAmpLo.ampdb);

	// DRY TONE
	sigDry = BLowShelf.ar(BHiShelf.ar(sig, toneFreq, 1, 0), toneFreq, 1, 0);

	// Dry should be silent if tone = 0, else it should "make up" the attenuation
	sigDry = (sigDry - sigWet);

	// FEEDBACK
	feed = LocalIn.ar(n);
	feed = DelayC.ar(
		LeakDC.ar(
			BBandPass.ar(feed * feedAmt, feedFreq, feedBW)
		),
		4,
		feedDelay
	) * Amplitude.ar(sig, 0.01, feedGate);

	// FILTER
	// filterLoHi blends between a lowpass and highpass
	// filterBP blends between the lo-hi signal and a bandpass
	filterFunc = {|inputSig|
		var loHiMix = filterLoHi.linlin(-1, 1, 0, 1);
		var lpHpMix = (
			(BLowPass.ar(inputSig, filterFreq, filterRes) * (1 - loHiMix)) +
			(BHiPass.ar(inputSig, filterFreq, filterRes) * loHiMix)
		);

		(lpHpMix * (1 - filterBP)) + (BBandPass.ar(inputSig, filterFreq, filterBW) * filterBP);
	};

	// SHAPE: PRE-FILTER
	// filterPre blends between filtering before the shape stage, or after
	sigShaped = sigWet + feed;
	sigShaped = (sigShaped * (1 - filterPre)) + (filterFunc.(sigShaped) * filterPre);

	// SHAPE
	sigShaped = tanh((sigShaped * drive) + bias);

	// SHAPE: POST-FILTER
	sigShaped = (sigShaped * filterPre) + (filterFunc.(sigShaped) * (1 - filterPre));

	// Feedback loop
	LocalOut.ar(sigShaped);

	// Mix wet and dry signals
	sigWet = (sigWet * (1 - amount)) + (sigShaped * amount);
	sig = sigWet + (toneComp * sigDry);

	// Apply levels control with proper curve and output
	sig = sig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Dynamic distortion effect with feedback and filtering", category: "Effect/Distortion");
)