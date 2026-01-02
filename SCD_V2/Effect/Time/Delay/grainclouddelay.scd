(
~synthCreator.value("GrainCloudDelay", {|n|
	var bufferSize = 5;
	var amp, delayTime, trigRate, grainDur, rate, grainOffset, dryWet, send;
	var input, circularBuf, writePos, readPos;
	var granulation, delayedSig, outputSig;
	var bufFrames, grainTrig;
	
	// Parameters
	amp = OceanodeParameter.ar(\levels, 1, n, 0, 1, "vf");
	delayTime = OceanodeParameter.ar(\delay, 1, n, 0.1, 5, "vf");
	trigRate = OceanodeParameter.ar(\trigrate, 10, n, 1, 50, "vf");
	grainDur = OceanodeParameter.ar(\graindur, 0.35, n, 0.01, 1, "vf");
	rate = OceanodeParameter.ar(\pitch, 0, n, -24, 24, "vf").midiratio;
	grainOffset = OceanodeParameter.ar(\grainoffset, 0.1, n, 0, 1, "vf");
	dryWet = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	
	// Allocate buffer within the SynthDef
	circularBuf = LocalBuf(SampleRate.ir * bufferSize, 1).clear;
	bufFrames = BufFrames.kr(circularBuf);
	
	// Input
	input = In.ar(OceanodeInput.kr(\in), n);
	
	// Ensure mono processing for each channel
	input = n.collect { |i|
		var monoInput = input[i];
		var monoWritePos, monoReadPos, monoGrainTrig;
		var monoGranulation;
		
		// Write position and recording - apply send parameter here
		monoWritePos = Phasor.ar(0, 1, 0, bufFrames);
		BufWr.ar(monoInput * send[i], circularBuf, monoWritePos);
		
		// Read position
		monoReadPos = Wrap.ar(monoWritePos - (delayTime[i] * SampleRate.ir), 0, bufFrames);
		
		// Grain trigger
		monoGrainTrig = Dust.kr(trigRate[i]);
		
		// Granulation
		monoGranulation = GrainBuf.ar(
			numChannels: 1,
			trigger: monoGrainTrig,
			dur: grainDur[i],
			sndbuf: circularBuf,
			rate: rate[i],
			pos: (monoReadPos + TRand.ar(0, grainOffset[i] * SampleRate.ir, monoGrainTrig)) / bufFrames,
			interp: 2,
			pan: 0  // No panning needed for mono processing
		);
		
		// Mix dry and wet signals
		XFade2.ar(monoInput, monoGranulation * amp[i], dryWet[i] * 2 - 1);
	};
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), input);
}, description: "Granular cloud delay effect with variable grain parameters", category: "Effect/Time/Delay", variables: [], variableDimensions: []);
)