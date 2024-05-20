(
SynthDef.new(\tremolo13, {
	arg in=0, out=0;
	var trem, signals;

	signals = In.ar(in,13);
	trem=1-((SinOsc.ar(\hz.kr(0!13),0,1,1)/2).pow(\pow.kr(1!13))*\amp.kr(0!13));
	signals=signals*trem;
	Out.ar(out, signals);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
