(
~synthCreator.value("TriggeredGrainDelay", {|n|
	var bufferSize = 8;
	var input, output;
	// Parameters - all are per-channel vectors
	var delayTime = OceanodeParameterLag.ar(\delay, 0.25, n, 0.01, 2, "vf", 1/30, true);
	var grainDur = OceanodeParameterLag.ar(\dur, 0.1, n, 0.01, 0.5, "vf", 1/30, true);
	var durJitter = OceanodeParameterLag.ar(\durjitter, 0, n, 0, 1, "vf", 1/30, true);
	var grainTrigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
	var grainPitch = OceanodeParameterLag.ar(\pitch, 0, n, -24, 24, "vf", 1/30, true);
	var pitchJitter = OceanodeParameterLag.ar(\pitchjitter, 0, n, 0, 12, "vf", 1/30, true);
	var lowCutFreq = OceanodeParameterLag.ar(\lowcut, 130, n, 0, 130, "vf", 1/30, true);
	var lowCutJitter = OceanodeParameterLag.ar(\lowcutjitter, 0, n, 0, 24, "vf", 1/30, true);
	var dryWet = OceanodeParameterLag.ar(\mix, 0.5, n, 0, 1, "vf", 1/30, true);
	var grainAmp = OceanodeParameterLag.ar(\grainamp, 1, n, 0, 1, "vf", 1/30, true);
	var grainAmpJitter = OceanodeParameterLag.ar(\grainampjitter, 0, n, 0, 1, "vf", 1/30, true);
	var outputAmp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	var spreadAmount = OceanodeParameterLag.ar(\delayjitter, 0, n, 0, 0.5, "vf", 1/30, true);
	var envBuf = OceanodeBuffer.kr(\envbuf);

	// Input
	input = In.ar(OceanodeInput.kr(\in), n);

	// Process each channel independently
	output = n.collect { |i|
		var monoInput = input[i];
		var monoCircularBuf = LocalBuf(SampleRate.ir * bufferSize, 1).clear;
		var bufFrames = BufFrames.kr(monoCircularBuf);
		var filteredInput, drySignal, wetSignal;
		var monoWritePos, monoReadPos;
		var grainTrig;

		// Create trigger and ensure it only fires on rising edge
		grainTrig = Trig.ar(grainTrigger[i], 0.001);

		// Write to buffer continuously
		monoWritePos = Phasor.ar(0, 1, 0, bufFrames);

		// Filter input - apply random jitter to cutoff within the grain itself
		filteredInput = LPF.ar(
			monoInput,
			lowCutFreq[i].midicps *
			(2 ** (TRand.ar(lowCutJitter[i].neg, lowCutJitter[i], grainTrig) / 12))
		);
		BufWr.ar(filteredInput, monoCircularBuf, monoWritePos);

		// Calculate read position with jitter
		monoReadPos = monoWritePos - (delayTime[i] * SampleRate.ir);
		monoReadPos = monoReadPos + (TRand.ar(spreadAmount[i].neg, spreadAmount[i], grainTrig) * SampleRate.ir);
		monoReadPos = Wrap.ar(monoReadPos, 0, bufFrames);

		// Use GrainBuf for granular processing with all jitter applied directly
		wetSignal = GrainBuf.ar(
			numChannels: 1,
			trigger: grainTrig,
			dur: grainDur[i] * (1 + TRand.ar(durJitter[i].neg, durJitter[i], grainTrig)),
			sndbuf: monoCircularBuf,
			rate: (2 ** (grainPitch[i] / 12)) *
			      (2 ** (TRand.ar(pitchJitter[i].neg, pitchJitter[i], grainTrig) / 12)),
			pos: monoReadPos / bufFrames,
			interp: 4,
			pan: 0,
			envbufnum: envBuf
		);

		// Apply amplitude with jitter
		wetSignal = wetSignal *
		            grainAmp[i].lincurve(0, 1, 0, 1, 4) *
		            (1 + TRand.ar(grainAmpJitter[i].neg, grainAmpJitter[i], grainTrig));

		// Mix dry and wet signals
		drySignal = monoInput * (1 - dryWet[i]);
		wetSignal = wetSignal * dryWet[i];

		// Return the mixed signal with output amplitude
		(drySignal + wetSignal) * outputAmp[i];
	};

	// Output each channel to its corresponding output
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "Triggered granular delay with complete grain playback", category: "Effect/Time/Delay");
)