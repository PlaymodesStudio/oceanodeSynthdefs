(
SynthDef(\bells13, {
	arg out=0;
	var pitch=\pitch.kr(30!13).midicps, t60=\t60.kr(6!13), pitchy=\pitchy.kr(1!13), amp=\levels.kr(0.25!13), gate=\gate.kr(1!13);
	var sig, exciter;
	exciter = WhiteNoise.ar() * 0.25;
	sig = DynKlank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60     // ring times
		],
		exciter,
		freqscale:pitch*pitchy);
	Out.ar(out, sig*0.25*amp);
}).play();
)

d = thisProcess.nowExecutingPath.dirname;
