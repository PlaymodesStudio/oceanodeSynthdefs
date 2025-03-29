(
~synthCreator.value("MultibandHardClip", {|n|
	var highFreq, lowFreq, masterLevel, dryWet, signals, drySignal, low, mid, high;
	var distortedLow, distortedMid, distortedHigh, mixedSignal, finalSignal;
	var lowDrive, midDrive, highDrive, lowClip, midClip, highClip, lowGain, midGain, highGain;

	// Frequency parameters
	lowFreq = OceanodeParameter.ar(\lowfreq, 300, n, 20, 2000, "vf");
	highFreq = OceanodeParameter.ar(\highfreq, 3200, n, 1000, 10000, "vf");
	
	// Drive controls
	lowDrive = OceanodeParameter.ar(\lowdrive, 1, n, 0, 10, "vf");
	midDrive = OceanodeParameter.ar(\middrive, 1, n, 0, 10, "vf");
	highDrive = OceanodeParameter.ar(\highdrive, 1, n, 0, 10, "vf");
	
	// Clip threshold controls
	lowClip = OceanodeParameter.ar(\lowclip, 0.8, n, 0.01, 1, "vf");
	midClip = OceanodeParameter.ar(\midclip, 0.8, n, 0.01, 1, "vf");
	highClip = OceanodeParameter.ar(\highclip, 0.8, n, 0.01, 1, "vf");
	
	// Gain controls
	lowGain = OceanodeParameter.ar(\lowgain, 1, n, 0, 2, "vf");
	midGain = OceanodeParameter.ar(\midgain, 1, n, 0, 2, "vf");
	highGain = OceanodeParameter.ar(\highgain, 1, n, 0, 2, "vf");
	
	// Mix and level
	dryWet = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	masterLevel = OceanodeParameter.ar(\level, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);

	// Input signal
	signals = In.ar(OceanodeInput.kr(\in), n);
	signals = LeakDC.ar(signals);
	drySignal = signals;

	// Splitting the signal into three bands
	low = LPF.ar(LPF.ar(signals, lowFreq), lowFreq);
	signals = signals - low;  // Remove the low frequencies
	mid = LPF.ar(LPF.ar(signals, highFreq), highFreq);
	high = signals - mid;  // What remains are the high frequencies

	// Apply hard clip distortion to each band
	distortedLow = (low * lowDrive).clip2(lowClip);
	distortedMid = (mid * midDrive).clip2(midClip);
	distortedHigh = (high * highDrive).clip2(highClip);

	// Apply gain correction to each band
	distortedLow = distortedLow * lowGain;
	distortedMid = distortedMid * midGain;
	distortedHigh = distortedHigh * highGain;

	// Mix all distorted signals
	mixedSignal = Mix.new([distortedLow, distortedMid, distortedHigh]);

	// Dry/Wet Mix using XFade2
	finalSignal = XFade2.ar(drySignal, mixedSignal, dryWet * 2 - 1);

	// Apply master level
	finalSignal = finalSignal * masterLevel;

	// Output
	Out.ar(OceanodeOutput.kr(\out), finalSignal);
}, description: "Multiband hard clipping distortion effect with separate controls for each band", category: "Effect/Distortion");
)