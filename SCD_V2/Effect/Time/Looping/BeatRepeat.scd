(
~synthCreator.value("BeatRepeat", {|n|
	var input, buffer, output, loopOutput;
	var bufferSize, numChannels;
	var writePos, readPos, bufFrames, offsetSamples, loopSamples;
	var recording, declickEnv, gateEnv;
	var mix, play, wetGate, mixedOutput;
	var loopDur, adaptiveLoopDur, loopReset, loopPhase, gatePhase;
	var envtime, effectiveRate, loopCount, currentRate, basePitchShift;
	var combinedResetTrig, delayedOnoff, onoffTrig;
	var gatedDrySignal, gatedWetSignal, transitionOutput;
	var onoffDelay, transitionEnv, fadeEnv;
	var recordTrig, recordReset;
	var pitchCounter, accumulatedPitch;
	var baseRate, adaptedRate;

	// Parameters
	var onoff = OceanodeParameter.ar(\go, 0, n, 0, 1, "vi");
	var recms = OceanodeParameter.ar(\repms, 1000, n, 1, 3000, "vf");
	var adapt = OceanodeParameter.ar(\adaptlength, 0, n, 0, 1, "vi");
	var offset = OceanodeParameter.ar(\offset, 0, n, 0, 1000, "vf") / 1000.0;
	var gate = OceanodeParameter.ar(\gate, 1, n, 0, 1, "vf");
	var declick = OceanodeParameter.ar(\declick, 0.005, n, 0, 0.1, "vf");
	var rate = OceanodeParameter.ar(\rate, 1, n, 0, 4, "vf");
	var reverse = OceanodeParameter.ar(\reverse, 0, n, 0, 1, "vi");
	var pitchstep = OceanodeParameter.ar(\pitchstep, 0, n, -12, 12, "vf");
	var numsteps = OceanodeParameter.ar(\numpitchsteps, 12, n, 0, 24, "vi");
	var grainamp = OceanodeParameter.ar(\grainamp, 1, n, 0, 1, "vf");
	var reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	var drywet = OceanodeParameter.ar(\drywet, 1, n, 0, 1, "vf");
	var levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/50, true).lincurve(0, 1, 0, 1, 4);

	// Setup
	bufferSize = 8;
	numChannels = n;
	bufFrames = (bufferSize * SampleRate.ir).max(1);
	buffer = LocalBuf(bufFrames, numChannels).clear;
	input = In.ar(OceanodeInput.kr(\in), numChannels);

	// Calculate basic timing parameters
	loopDur = recms / 1000;

	// Initialize timing control signals
	onoffTrig = Trig.kr(onoff);
	onoffDelay = loopDur * onoff;
	delayedOnoff = DelayN.kr(onoff, loopDur, onoffDelay);

	// Reset trigger for combined operations
	combinedResetTrig = Trig1.ar(K2A.ar(delayedOnoff) + K2A.ar(reset), ControlDur.ir);

	// Recording logic
	recordTrig = 1 - onoff;
	recordReset = Trig.kr(onoff);
	recording = (1 - delayedOnoff) + Trig1.kr(recordTrig, loopDur);

	writePos = Phasor.ar(recordReset, BufRateScale.kr(buffer) * recording, 0, BufFrames.kr(buffer));
	BufWr.ar(input, buffer, writePos);

	// Phases for loop management
	loopPhase = Phasor.ar(combinedResetTrig, 1 / (SampleRate.ir * loopDur), 0, 1, 0);
	gatePhase = Phasor.ar(onoffTrig, 1 / (SampleRate.ir * loopDur), 0, 1, 0);

	loopReset = Trig1.ar((loopPhase - Delay1.ar(loopPhase)) > 0, ControlDur.ir);

	// Calculate pitch accumulation
	pitchCounter = PulseCount.ar(loopReset, combinedResetTrig);
	loopCount = pitchCounter % numsteps;

	// Calculate accumulated pitch shift
	accumulatedPitch = (loopCount * pitchstep) % (numsteps * pitchstep.abs.max(1));
	basePitchShift = 2 ** (accumulatedPitch / 12);

	// Calculate base and adapted rates
	baseRate = rate;
	currentRate = baseRate * basePitchShift;

	// Apply rate direction (reverse or forward)
	effectiveRate = currentRate * (1 - (reverse * 2));

	// Calculate adaptive loop duration
	adaptiveLoopDur = Select.kr(adapt, [
		loopDur,                   // When adapt=0: fixed loop duration
		loopDur / basePitchShift   // When adapt=1: duration adjusted for pitch
	]);

	loopSamples = (adaptiveLoopDur * SampleRate.ir).round(1).max(1);

	// Quantize parameters at loop reset points
	currentRate = Latch.kr(currentRate, loopReset);
	effectiveRate = Latch.kr(effectiveRate, loopReset);
	adaptiveLoopDur = Latch.kr(adaptiveLoopDur, loopReset);
	loopSamples = Latch.kr(loopSamples, loopReset);
	gate = Latch.kr(gate, loopReset);
	grainamp = Latch.kr(grainamp, loopReset);

	offsetSamples = Latch.kr((offset * SampleRate.ir).round(1), loopReset);

	// Create read position for buffer playback
	readPos = Phasor.ar(
		trig: loopReset,
		rate: BufRateScale.kr(buffer) * effectiveRate,
		start: reverse * loopSamples,
		end: (1 - reverse) * loopSamples,
		resetPos: reverse * loopSamples
	);
	readPos = writePos - offsetSamples - loopSamples + readPos;
	readPos = readPos.wrap(0, BufFrames.kr(buffer) - 1);

	mix = delayedOnoff;
	wetGate = delayedOnoff;
	play = delayedOnoff;

	// Create declicking envelope
	envtime = (adaptiveLoopDur - (2 * declick)).max(0);
	declickEnv = EnvGen.ar(
		Env(
			levels: [0, 1, 1, 0],
			times: [declick, envtime, declick],
			curve: [\sin, \step, \sin]
		),
		gate: loopReset
	);

	gateEnv = (gatePhase < gate).lag(declick.min(adaptiveLoopDur / 4));

	// Read from buffer and apply envelopes
	loopOutput = BufRd.ar(numChannels, buffer, readPos, loop: 1);
	loopOutput = loopOutput * play * declickEnv * grainamp;

	gatedDrySignal = input * gateEnv;
	gatedWetSignal = loopOutput * gateEnv;

	fadeEnv = EnvGen.ar(
		Env.asr(declick, 1, declick, 'sine'),
		gate: onoff
	);

	transitionEnv = EnvGen.ar(
		Env.asr(declick, 1, declick, 'sine'),
		gate: delayedOnoff
	);

	transitionOutput = XFade2.ar(
		gatedDrySignal,
		gatedWetSignal,
		transitionEnv * 2 - 1
	);

	// Final output with dry/wet control
	output = SelectX.ar(fadeEnv, [input, transitionOutput]);
	output = XFade2.ar(input, output, drywet * 2 - 1);

	Out.ar(OceanodeOutput.kr(\out), output * levels);

}, description: "Beat repeater effect with accumulative pitch shifting", category: "Effect/Time/Looping");
)