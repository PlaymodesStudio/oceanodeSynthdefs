(//sidechain
SynthDef.new(\sidechain13, {
	arg in=0, in2=0, out, peak;
	var sig, sig2, envf,envfamp,lagtime, att, rel;
	envfamp=\strength.kr(1!13);
	att=\attack.kr(0.001!13);
	rel=\release.kr(0.1!13);
	lagtime=\smooth.kr(0.01!13);

	sig = In.ar(in, 13); //to be sidechained
	sig2 = In.ar(in2, 13); //ctrl signal
	envf=Lag.kr(Amplitude.kr(sig2,att,rel), lagtime);
	envf=(envf*envfamp).clip(0,1);
	envf=1-envf;
	sig=sig*envf;
	Out.ar(out,sig);
}).writeDefFile(d);
)