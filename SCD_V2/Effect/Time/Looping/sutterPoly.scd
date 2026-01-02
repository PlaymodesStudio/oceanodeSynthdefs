(
~synthCreator.value("StutterPoly", {|n|
	var input, buffers, output, loopOutputs;
	var bufferSize, numChannels;
	var writePoses, readPoses, bufFrames, offsetSamples, loopSamples;
	var recordings, declickEnvs, gateEnvs;
	var loopDurs, loopResets, loopPhases, gatePhases;
	var effectiveRates;
	var combinedResetTrigs, delayedOnoffs, onoffTrigs;
	var gatedDrySignals, gatedWetSignals, transitionOutputs;
	var fadeEnvs, transitionEnvs;
	var resetTrigs, processedInput;

	// Parameters
	var on = OceanodeParameter.ar(\on, 0, n, 0, 1, "vi");
	var pitch = OceanodeParameterLag.ar(\pitch, 12, n, 0, 128, "vf");
	var offset = OceanodeParameterLag.ar(\offset, 0, n, 0, 1000, "vf") / 1000.0;
	var gateWidth = OceanodeParameterLag.ar(\gatepw, 1, n, 0, 1, "vf");
	var declick = OceanodeParameterLag.ar(\declick, 0.005, n, 0, 0.1, "vf");
	var reverse = OceanodeParameter.ar(\reverse, 0, n, 0, 1, "vi");
	var reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
	var send = OceanodeParameterLag.ar(\send, 1, n, 0, 4, "vf", 1/30, true);
	var drywet = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");
	var levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/50, true);

	// Calculate loop duration from MIDI pitch
	loopDurs = pitch.midicps.reciprocal;

	// Setup
	bufferSize = 8; // 8 seconds buffer per channel
	numChannels = n;
	bufFrames = (bufferSize * SampleRate.ir).max(1);

	// Create separate buffers for each channel
	buffers = Array.fill(n, { LocalBuf(bufFrames, 1).clear });

	input = In.ar(OceanodeInput.kr(\in), numChannels);

	// Apply send gain to input before processing
	 processedInput = input * send;

	// Per-channel processing
	output = Array.fill(n, {|i|
		var chan_input = processedInput[i];
		var chan_on = on[i];
		var chan_pitch = pitch[i];
		var chan_offset = offset[i];
		var chan_gateWidth = gateWidth[i];
		var chan_declick = declick[i];
		var chan_reverse = reverse[i];
		var chan_reset = reset[i];
		var chan_drywet = drywet[i];
		var chan_loopDur = loopDurs[i];

		var chan_onoffTrig, chan_delayedOnoff, chan_resetTrig, chan_combinedResetTrig;
		var chan_recording, chan_writePos, chan_loopPhase, chan_gatePhase;
		var chan_loopReset, chan_effectiveRate, chan_loopSamples, chan_offsetSamples;
		var chan_readPos, chan_loopOutput, chan_declickEnv, chan_gateEnv;
		var chan_gatedDrySignal, chan_gatedWetSignal, chan_fadeEnv, chan_transitionEnv;
		var chan_transitionOutput, chan_output;

		// Initialize timing control signals for this channel
		chan_onoffTrig = Trig.kr(chan_on);
		chan_delayedOnoff = DelayN.kr(chan_on, chan_loopDur, chan_loopDur * chan_on);

		// Reset detection for this channel - Handle audio-rate pulses properly
		chan_resetTrig = Trig1.ar(chan_reset > 0.5, 0.01);
		chan_resetTrig = A2K.kr(chan_resetTrig);

		// Reset trigger for combined operations for this channel
		chan_combinedResetTrig = Trig1.ar(K2A.ar(chan_delayedOnoff) + K2A.ar(chan_resetTrig), ControlDur.ir);

		// Recording logic for this channel
		chan_recording = (1 - chan_delayedOnoff) + Trig1.kr(1 - chan_on, chan_loopDur) + chan_resetTrig;

		chan_writePos = Phasor.ar(chan_onoffTrig + chan_resetTrig, BufRateScale.kr(buffers[i]) * chan_recording, 0, BufFrames.kr(buffers[i]));
		BufWr.ar(chan_input, buffers[i], chan_writePos);

		// Phases for loop management for this channel
		chan_loopPhase = Phasor.ar(chan_combinedResetTrig, 1 / (SampleRate.ir * chan_loopDur), 0, 1, 0);
		chan_gatePhase = Phasor.ar(chan_onoffTrig, 1 / (SampleRate.ir * chan_loopDur), 0, 1, 0);

		chan_loopReset = Trig1.ar((chan_loopPhase - Delay1.ar(chan_loopPhase)) > 0, ControlDur.ir);

		// Calculate effective rate (normal or reverse) for this channel
		chan_effectiveRate = 1 * (1 - (chan_reverse * 2));

		chan_loopSamples = (chan_loopDur * SampleRate.ir).round(1).max(1);

		// Quantize parameters at loop reset points for this channel
		chan_gateWidth = Latch.kr(chan_gateWidth, chan_loopReset);
		chan_offsetSamples = Latch.kr((chan_offset * SampleRate.ir).round(1), chan_loopReset);

		// Create read position for buffer playback for this channel
		chan_readPos = Phasor.ar(
			trig: chan_loopReset,
			rate: BufRateScale.kr(buffers[i]) * chan_effectiveRate,
			start: chan_reverse * chan_loopSamples,
			end: (1 - chan_reverse) * chan_loopSamples,
			resetPos: chan_reverse * chan_loopSamples
		);
		chan_readPos = chan_writePos - chan_offsetSamples - chan_loopSamples + chan_readPos;
		chan_readPos = chan_readPos.wrap(0, BufFrames.kr(buffers[i]) - 1);

		// Create declicking envelope for this channel
		chan_declickEnv = EnvGen.ar(
			Env(
				levels: [0, 1, 1, 0],
				times: [chan_declick, (chan_loopDur - (2 * chan_declick)).max(0), chan_declick],
				curve: [\sin, \step, \sin]
			),
			gate: chan_loopReset
		);

		chan_gateEnv = (chan_gatePhase < chan_gateWidth).lag(chan_declick.min(chan_loopDur / 4));

		// Read from buffer and apply envelopes for this channel
		chan_loopOutput = BufRd.ar(1, buffers[i], chan_readPos, loop: 1);
		chan_loopOutput = chan_loopOutput * chan_delayedOnoff * chan_declickEnv;

		chan_gatedDrySignal = chan_input * chan_gateEnv;
		chan_gatedWetSignal = chan_loopOutput * chan_gateEnv;

		chan_fadeEnv = EnvGen.ar(
			Env.asr(chan_declick, 1, chan_declick, 'sine'),
			gate: chan_on
		);

		chan_transitionEnv = EnvGen.ar(
			Env.asr(chan_declick, 1, chan_declick, 'sine'),
			gate: chan_delayedOnoff
		);

		chan_transitionOutput = XFade2.ar(
			chan_gatedDrySignal,
			chan_gatedWetSignal,
			chan_transitionEnv * 2 - 1
		);

		// Final output with dry/wet control for this channel
		chan_output = SelectX.ar(chan_fadeEnv, [input[i], chan_transitionOutput]);
		chan_output = XFade2.ar(input[i], chan_output, chan_drywet * 2 - 1);

		chan_output;
	});

	Out.ar(OceanodeOutput.kr(\out), output * levels);

}, description: "Beat repeater effect with variable pitch control", category: "Effect/Time/Looping");
)