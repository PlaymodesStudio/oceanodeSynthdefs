(// compressor
SynthDef.new(\compressor, {
	arg in, out=0;
	var thresh=0.5,slopeb=1,slopea=1,att=0.01,rel=0.1,make=1;
	var input,sig;
	thresh=\threshold.kr(0.5!78);
	slopeb=\slopebelow.kr(1!78);
	slopea=\slopeabove.kr(1!78);
	att=\attack.kr(0.005!78);
	rel=\release.kr(0.01!78);
	make=\makeup.kr(1!78);
	input = In.ar(in, 78);
	sig=Compander.ar(input,input,thresh,slopeb,slopea,att,rel,1,0)*make;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// compressor 13ch
SynthDef.new(\compressor13, {
	arg in, out=0;
	var thresh=0.5,slopeb=1,slopea=1,att=0.01,rel=0.1,make=1;
	var input,sig;
	thresh=\threshold.kr(0.5!13);
	slopeb=\slopebelow.kr(1!13);
	slopea=\slopeabove.kr(1!13);
	att=\attack.kr(0.005!13);
	rel=\release.kr(0.01!13);
	make=\makeup.kr(1!13);
	input = In.ar(in, 13);
	sig=Compander.ar(input,input,thresh,slopeb,slopea,att,rel,1,0)*make;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// compressor 1ch
SynthDef.new(\compressormono, {
	arg in, out=0;
	var thresh=0.5,slopeb=1,slopea=1,att=0.01,rel=0.1,make=1;
	var input,sig;
	thresh=\threshold.kr(0.5!1);
	slopeb=\slopebelow.kr(1!1);
	slopea=\slopeabove.kr(1!1);
	att=\attack.kr(0.005!1);
	rel=\release.kr(0.01!1);
	make=\makeup.kr(1!1);
	input = In.ar(in, 1);
	sig=Compander.ar(input,input,thresh,slopeb,slopea,att,rel,1,0)*make;
	Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

//compressor good nathan
(
SynthDef(\compressorb13, {
	arg in, out;
	var snd, attack=0, release=0.1, threshold= -6, ratio=4, make;
	var amplitudeDb, gainDb;
	attack=\attack.kr(0.005!13);
	release=\release.kr(0.01!13);
	threshold=\threshold.kr(-6!13);
	ratio=\ratio.kr(4!13);
	make=\makeup.kr(1!13);
	snd=In.ar(in, 13);
	amplitudeDb = Amplitude.ar(snd, attack, release).ampdb;
	gainDb = ((amplitudeDb - threshold) * (1 / ratio - 1)).min(0);
	Out.ar(out, snd * gainDb.dbamp * make);
}).writeDefFile(d);
)