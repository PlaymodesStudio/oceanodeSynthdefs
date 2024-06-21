(
SynthDef(\simplereverb6, {
		arg in=0, out=0;
	var dec=\decay.kr(4!6), lpf=\lpf.kr(1500!6), hpf=\hpf.kr(100!6), mix=\mix.kr(1!6);
		var sig, sigin;
	var ch=6;

		sigin = In.ar(in, ch);

		sig = DelayN.ar(sigin, 0.03, 0.03);
		sig = CombN.ar(sig, 0.1, {Rand(0.01,0.099)}!32, dec);
		sig = LPF.ar(sig, lpf);
	sig = HPF.ar(sig, hpf);
		5.do{sig = AllpassN.ar(sig, 0.1, {Rand(0.01,0.099)}!ch, 3)};
		sig = LPF.ar(sig, lpf);
		sig = LeakDC.ar(sig);
	sig=(sig*mix)+(sigin*(1-mix));
		Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
