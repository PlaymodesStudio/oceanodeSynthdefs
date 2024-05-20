(
SynthDef(\hardsync13, {
	arg out=0;
	var freq, syncFreqRatio, masterOsc, slaveOsc, sync, amp;
	freq=\pitch.kr(36!13, 1/30, fixedLag: true).midicps;
	syncFreqRatio=\ratio.kr(1!13, 1/30, fixedLag: true);
	amp=\levels.kr(1!13, 1/30, fixedLag: true);
    masterOsc = Pulse.ar(freq, 0.5);
    slaveOsc = Saw.ar(freq * syncFreqRatio);
    sync = slaveOsc * (masterOsc < 0);
    Out.ar(out, sync*amp);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
