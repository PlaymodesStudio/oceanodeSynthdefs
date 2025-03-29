(
~synthCreator.value("MultibandSineShaper", {|n|
	var dryWet, lowFreq, highFreq, masterLevel, signals, low, mid, high;
	var shapedLow, shapedMid, shapedHigh, mixedSignal, finalSignal, drySignal;
	var lowDrive, midDrive, highDrive, lowGain, midGain, highGain;

	// Parameters
	lowFreq = OceanodeParameter.ar(\lowfreq, 300, n, 20, 2000, "vf");
	highFreq = OceanodeParameter.ar(\highfreq, 3200, n, 1000, 10000, "vf");
	
	// Drive controls
	lowDrive = OceanodeParameter.ar(\lowdrive, 1, n, 0, 10, "vf");
	midDrive = OceanodeParameter.ar(\middrive, 1, n, 0, 10, "vf");
	highDrive = OceanodeParameter.ar(\highdrive, 1, n, 0, 10, "vf");
	
	// Gain controls
	lowGain = OceanodeParameter.ar(\lowgain, 1, n, 0, 2, "vf");
	midGain = OceanodeParameter.ar(\midgain, 1, n, 0, 2, "vf");
	highGain = OceanodeParameter.ar(\highgain, 1, n, 0, 2, "vf");
	
	// Mix and level
	dryWet = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	masterLevel = OceanodeParameter.ar(\level, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);

	// Input signal
	signals = In.ar(OceanodeInput.kr(\in), n);
	drySignal = signals;

	// Splitting the signal into three bands using nested LPF for steeper rolloff
	low = LPF.ar(LPF.ar(signals, lowFreq), lowFreq);
	mid = LPF.ar(LPF.ar(signals - low, highFreq), highFreq);
	high = signals - low - mid;

	// Apply sine shaping distortion to each band
	shapedLow = (low * lowDrive).sin;
	shapedMid = (mid * midDrive).sin;
	shapedHigh = (high * highDrive).sin;

	// Apply gain correction to each band
	shapedLow = shapedLow * lowGain;
	shapedMid = shapedMid * midGain;
	shapedHigh = shapedHigh * highGain;

	// Mix all shaped signals
	mixedSignal = Mix.new([shapedLow, shapedMid, shapedHigh]);

	// Dry/Wet Mix using XFade2
	finalSignal = XFade2.ar(drySignal, mixedSignal, dryWet * 2 - 1);

	// Apply master level
	finalSignal = finalSignal * masterLevel;

	// Output
	Out.ar(OceanodeOutput.kr(\out), finalSignal);
}, description: "Multiband sine shaper distortion effect", category: "Effect/Distortion");
)