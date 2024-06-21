d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\loopfadesampler2, {
	arg buf, out;
	var freq=220
	,sampleStart=\samplestart.kr(0.03)
	,loopStart=\loopstart.kr(0.03)
	,loopLen=\looplen.kr(0.225)
	,fadeLen=\fadelen.kr(0.25)
	,gate=\gate.kr(1)
	,attack=\attack.kr(0.01)
	,sustain=\sustain.kr(1)
	,release=\release.kr(0.01)
	,amp=\levels.kr(1,1/30,fixedLag:true)
	,f0=220;

	var rate = freq / f0;
	var sr = rate*BufSampleRate.kr(buf);
	var loopEnd = loopLen*(BufFrames.kr(buf) - loopStart) + loopStart;
	var loopFrames = loopEnd - loopStart + 1;
	var fadeFrames = fadeLen*loopFrames;
	var loopTime = (loopFrames - fadeFrames)/sr;
	var startUpTime = (loopStart - sampleStart)/sr;

	var gateChanged = HPZ1.kr(gate) > 0;
	var resetTrig = Impulse.ar(gateChanged);

	var trigLoop = TDuty.ar(Dseq([startUpTime + loopTime, Dseq([loopTime], inf)]), resetTrig, gapFirst:1);


	//var trigLoop = TDuty.ar(Dseq([startUpTime + loopTime, Dseq([loopTime], inf)]), gapFirst:1);

	var phaseA = Phasor.ar(trigLoop, rate, sampleStart, inf, loopStart);
	var phaseB = Phasor.ar(trigLoop, rate, loopEnd - fadeFrames, inf, loopEnd - fadeFrames);

	var srcA = BufRd.ar(buf.numChannels, buf, phaseA);
	var srcB = BufRd.ar(buf.numChannels, buf, phaseB);

	var startLoop = SetResetFF.ar(trigLoop);
	var loopPan = Phasor.ar(trigLoop, 2/fadeFrames * rate, -1, inf, -1).clip(-1,1);

	var sig = Select.ar(startLoop, [srcA, LinXFade2.ar(srcB, srcA, pan:loopPan)]);
	var env = EnvGen.ar(Env.asr(attack, sustain, release, 1), gate);

	Out.ar(out, Splay.ar(sig) * env * amp);
}).writeDefFile(d);
)


~buf = Buffer.read(s, "/Users/santiagovilanova/Desktop/GEN_DAW/lacrimosa/lacrimosa.wav");