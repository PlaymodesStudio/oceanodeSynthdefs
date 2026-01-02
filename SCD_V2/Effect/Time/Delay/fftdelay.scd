(
~synthCreator.value("FFTDelay", {|n, variables|
	var inAmp, delayTime, feed, threshAbove, threshBelow, smooth, smear;
	var swapIn, pingPong, stretch, freqHP, freqLP, qHP, qLP, pan, noise;
	var signalIn, chain, signal, sigOut, ampAdj, mix, send;
	var panPos, leftPos, rightPos;
	var i_fft = 11;  // FFT size parameter

	// Parameters
	delayTime = OceanodeParameter.ar(\delaytime, 0.1, n, 0, 1, "vf");
	feed = OceanodeParameter.ar(\feed, 0.4, n, 0, 0.99, "vf");
	threshAbove = OceanodeParameter.ar(\threshabove, 0, n, 0, 3, "vf");
	threshBelow = OceanodeParameter.ar(\threshbelow, 3, n, 0, 3, "vf");
	smooth = OceanodeParameter.ar(\smooth, 0.5, n, 0, 1, "vf");
	smear = OceanodeParameter.ar(\smear, 0, n, 0, 1, "vf");
	stretch = OceanodeParameter.ar(\stretch, 0, n, -1, 1, "vf");
	freqHP = OceanodeParameter.ar(\hp, 0, n, 0, 130, "vf").midicps;
	freqLP = OceanodeParameter.ar(\lp, 130, n, 0, 130, "vf").midicps;
	qHP = OceanodeParameter.ar(\qhp, 0, n, 0, 0.99, "vf");
	qLP = OceanodeParameter.ar(\qlp, 0, n, 0, 0.99, "vf");
	mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);

	// Fixed parameters
	inAmp = 0.5;
	swapIn = 0;
	pingPong = 0;
	pan = 0;
	noise = -2;

	// Input processing
	signalIn = In.ar(OceanodeInput.kr(\in), 2);
	
	// Calculate panning positions
	panPos = pan * 2;
	leftPos = (panPos-1).clip(-1,1);
	rightPos = (panPos+1).clip(-1,1);

	// Optional channel swapping
	signalIn = [
		LinSelectX.ar(swapIn, [signalIn[0], signalIn[1]]),
		LinSelectX.ar(swapIn, [signalIn[1], signalIn[0]])
	];

	// Threshold calculations
	threshAbove = threshAbove ** 2;
	threshBelow = threshBelow ** 2;
	ampAdj = 1 / ((threshBelow**0.8).clip(0.005, 1.5));

	// Feedback loop with FFT processing
	signal = FbL({|feedback|
		chain = FFT({ LocalBuf(2**i_fft) }!2, (signalIn * send * inAmp) + (feedback.tanh * feed));
		chain = PV_MagBelow(chain, threshBelow);
		chain = PV_MagAbove(chain, threshAbove);
		chain = PV_MagSmooth(chain, smooth);
		chain = PV_MagSmear(chain, smear);
		chain = PV_MagShift(chain, 2**stretch);
		sigOut = (IFFT(chain) * 2);  // stereo

		// Apply noise and filtering
		noise = 0.5 ** noise;
		sigOut = sigOut * ampAdj * noise;
		sigOut = DFM1.ar(sigOut, freqHP, qHP, 0.445, 1, 0);
		sigOut = DFM1.ar(sigOut, freqLP, qLP, 0.445, 0, 0);
		sigOut = sigOut / ampAdj / noise;

		// Optional ping-pong
		[
			LinSelectX.ar(pingPong, [sigOut[0], sigOut[1]]),
			LinSelectX.ar(pingPong, [sigOut[1], sigOut[0]])
		];
	}, 1, delayTime.lag, 2);

	// Apply panning
	signal = LinPan2.ar(signal[0], leftPos) + LinPan2.ar(signal[1], rightPos);

	// Mix dry and wet signals
	signal = XFade2.ar(signalIn, signal * ampAdj, mix*2-1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "FFT-based delay with spectral processing", category: "Effect/Time/Delay");
)