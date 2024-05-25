(
SynthDef(\graindelay13, {
	arg in = 0, out =0;
	var cf, echoes;
	var del, dens, graindur, pan, amp;
	var sigin, sig, panctrl, drywet;

	panctrl=\pan.kr(0!13, 1/30, fixedLag: true); //-1 to 1
	amp=\levels.kr(1!13, 1/30, fixedLag: true);
	del=\delay.kr(0.25!13, 1/30, fixedLag: true);
	dens=\density.kr(30!13, 1/30, fixedLag: true);
	graindur=\graindur.kr(0.07!13, 1/30, fixedLag: true);
	echoes=\echoes.kr(12!13, 1/30, fixedLag: true);
	cf=\lowcut.kr(130!13, 1/30, fixedLag: true).midicps;
	drywet=\mix.kr(1!13, 1/30, fixedLag: true);

	sigin = In.ar(in, 13);

	sig = LPF.ar(sigin, cf);
	sig = CombL.ar(sig, del, del, del*echoes);
	sig = GrainIn.ar(13, Dust.kr(dens), graindur, sig, panctrl);
	sig = sig * amp;
	sig=(sigin*(1-drywet))+(sig*drywet);

	Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


SynthDef(\grainstretch, {
        arg
        bufnum,
        amp = 1,
        startPos = 0,        // within the source file, in seconds
        endPos = 60,         // within the source file, in seconds
        outputDur = 60,      // in seconds
        playbackSpeed = 1,   // relative to original speed
        samplerFreq	= 1,     // in Hz
        pitchSmear	= 1.001, // interval ratio.  Should be slightly >1 to avoid a mechanical sound
        out_bus;

        var
        numSamplers = 4096,
        pitchOffsets = Array.new,
        position,
        samplers = Array.new,
        samplerOffsets = Array.new,
        samplingPos,
        samplerEnvs = Array.new,        // envelopes for reducing clicks
        triggerFreq,
        triggers = Array.new,
        outSignal;

        triggerFreq = samplerFreq * playbackSpeed;
        samplingPos = Line.kr(startPos, endPos, outputDur);
        position = BufFrames.kr(bufnum) * samplingPos / BufDur.kr(bufnum);

        numSamplers.do {
            arg i;

            samplerEnvs = samplerEnvs.add(
                0.5 * SinOsc.kr(
                    triggerFreq,
                    (2 * pi) * i / numSamplers - (pi / 2), // phase offset in radians
                    1,
                    1
                );
            );

            // (2 * pi) * i / n spaces n envelopes evenly over one cycle,
            // each envelope in sync with a sample trigger (see below).
            // - ( pi/2 ) shifts each waveform so that it starts and ends
            // with 0 (silence)

            triggers = triggers.add(
                Impulse.kr(
                    triggerFreq,
                    i / numSamplers        	// phase offset between 0 and 1
                );
            );

            // pitch smear is an interval above and below a center frequency

            pitchOffsets = pitchOffsets.add(
                TExpRand.kr(
                    1 / pitchSmear,
                    pitchSmear,
                    triggers[i]
                )
            );

            samplers = samplers.add(
                PlayBuf.ar(
                	2,
                	bufnum,
                	BufRateScale.kr(bufnum) * playbackSpeed * pitchOffsets[i],
                	triggers[i],
                	position,
                	1
                ) * samplerEnvs[i]
        	)
        };
        outSignal = amp * Mix(samplers); // Mix an array of stereo arrays
        // down to a single stereo array
        Out.ar(
            out_bus,
        	outSignal
        );
    }
).writeDefFile;
/*
GrainFreeze.scd
prm
SynthDef for capturing and holding incoming audio as a drone
patrickryanmcminn@gmail.com
http://www.patrickmcminn.com/
*/

// execute within the parentheses:
(
SynthDef(\grainfreeze, {
  arg in = 0, out = 0;
	var amp = 1,
  trigRate = 60, grainDur = 0.35, pos = 0.3, rate = 1,
  attackTime = 0.5, decayTime = 0, sustainLevel = 1, releaseTime = 2, gate = 1,
  lowPassCutoff = 7000, highPassCutoff = 100, postDistCutoff = 18000, distAmt = 1;

  var input, record, localBuf;
  var grainTrig, granulation, env, lpf, hpf, dist, sig;

  // Record (into a 1 second, mono buffer)
  input = SoundIn.ar(in, 1);
  localBuf = LocalBuf.new(SampleRate.ir * 1, 1).clear;
  record = RecordBuf.ar(input, localBuf, loop: 0);

  //// Granulate:
  // Random distribution of triggers prevents amplitude modulation artifacts
  grainTrig = Dust.ar(trigRate);
  granulation = GrainBuf.ar(1, grainTrig, grainDur, localBuf, rate, pos);

  // Filter and distort
  lpf = LPF.ar(granulation, lowPassCutoff);
  hpf = HPF.ar(lpf, highPassCutoff);
  dist = (hpf * distAmt).distort;
  dist = LPF.ar(dist, postDistCutoff);

  // Envelope -- delays start until recording has finished
  env = EnvGen.kr(Env.dadsr(1, attackTime, decayTime, sustainLevel, releaseTime), gate, amp, doneAction: 2);
  sig = dist * env;

  // Output
  sig = Out.ar(out, sig);
}).play;
)

//// examples:

// execute this:
a = Bus.audio;
// then this:
b = { Out.ar(a, SoundIn.ar(0)) }.play;

// sing, whistle, or play a steady held note, then execute this line of code:
c = Synth(\prm_GrainFreeze, [\inBus, a, \outBus, 0, \attackTime, 4], addAction: \addToTail);


// play at half the speed, (one octave down):
c.set(\rate, 0.5);

// set lowpass cutoff:
c.set(\lowPassCutoff, 2500);

// set high pass cutoff:
c.set(\highPassCutoff, 1000);

// reset it:
c.set(\highPassCutoff, 20);

// set distortion (CAREFUL!! Gets loud):
(
c.set(\postDistCutoff, 1500);
c.set(\distAmt, 60.dbamp);
)

// increase release time and free:
(
c.set(\releaseTime, 10);
c.set(\gate, 0);
)