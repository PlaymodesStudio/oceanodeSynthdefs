

(///// eq
SynthDef(\eq, {
	arg in, out=0;
	var lofreq=80, midlofreq=300, midfreq=800, midhifreq=2000, hifreq=4000, band1=0, band2=0, band3=0,band4=0,band5=0;
	var dry, wet;

	lofreq=\lowf.kr(80!78);
	midlofreq=\midlowf.kr(300!78);
	midfreq=\midf.kr(800!78);
	midhifreq=\midhighf.kr(2000!78);
	hifreq=\highf.kr(4000!78);

	band1=\lowdb.kr(0!78);
	band2=\midlowdb.kr(0!78);
	band3=\middb.kr(0!78);
	band4=\midhighdb.kr(0!78);
	band5=\highdb.kr(0!78);

	dry = In.ar(in, 78);

	wet = BLowShelf.ar(dry, lofreq, 1, band1);
	wet = BPeakEQ.ar(wet, midlofreq, 1, band2);
	wet = BPeakEQ.ar(wet, midfreq, 1, band3);
	wet = BPeakEQ.ar(wet, midhifreq, 1, band4);
	wet = BHiShelf.ar(wet, hifreq, 1, band5);
	wet.tanh;
	Out.ar(out, wet);
}).writeDefFile(d);
)

(///// eq
SynthDef(\eq13, {
	arg in, out=0;
	var lofreq=80, midlofreq=300, midfreq=800, midhifreq=2000, hifreq=4000, band1=0, band2=0, band3=0,band4=0,band5=0;
	var dry, wet;

	lofreq=\lowf.kr(80!13);
	midlofreq=\midlowf.kr(300!13);
	midfreq=\midf.kr(800!13);
	midhifreq=\midhighf.kr(2000!13);
	hifreq=\highf.kr(4000!13);

	band1=\lowdb.kr(0!13);
	band2=\midlowdb.kr(0!13);
	band3=\middb.kr(0!13);
	band4=\midhighdb.kr(0!13);
	band5=\highdb.kr(0!13);

	dry = In.ar(in, 13);

	wet = BLowShelf.ar(dry, lofreq, 1, band1);
	wet = BPeakEQ.ar(wet, midlofreq, 1, band2);
	wet = BPeakEQ.ar(wet, midfreq, 1, band3);
	wet = BPeakEQ.ar(wet, midhifreq, 1, band4);
	wet = BHiShelf.ar(wet, hifreq, 1, band5);
	wet.tanh;
	Out.ar(out, wet);
}).writeDefFile(d);
)

(///// eq
SynthDef(\eqmono, {
	arg in, out=0;
	var lofreq=80, midlofreq=300, midfreq=800, midhifreq=2000, hifreq=4000, band1=0, band2=0, band3=0,band4=0,band5=0;
	var dry, wet;

	lofreq=\lowf.kr(80!1);
	midlofreq=\midlowf.kr(300!1);
	midfreq=\midf.kr(800!1);
	midhifreq=\midhighf.kr(2000!1);
	hifreq=\highf.kr(4000!1);

	band1=\lowdb.kr(0!1);
	band2=\midlowdb.kr(0!1);
	band3=\middb.kr(0!1);
	band4=\midhighdb.kr(0!1);
	band5=\highdb.kr(0!1);

	dry = In.ar(in, 1);

	wet = BLowShelf.ar(dry, lofreq, 1, band1);
	wet = BPeakEQ.ar(wet, midlofreq, 1, band2);
	wet = BPeakEQ.ar(wet, midfreq, 1, band3);
	wet = BPeakEQ.ar(wet, midhifreq, 1, band4);
	wet = BHiShelf.ar(wet, hifreq, 1, band5);
	wet.tanh;
	Out.ar(out, wet);
}).writeDefFile(d);
)