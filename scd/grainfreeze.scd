d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\grainfreeze,{
	arg out= 0, in=0;
	var point= \point.kr(0);
	var pitch= \pitch.kr(0).midiratio;
	var glide= \glide.kr(0.3);
	var gate= \gate.kr(0);
	var wSize= \wsize.kr(0.1);
	var playback=\play.kr(0);
	var rate= \rate.kr(0.1);
	var bufnum, signal, input, mix;

	input= In.ar(in,2);
	bufnum= LocalBuf(44100*2, 2); // recording 2 seconds
	RecordBuf.ar(input, bufnum, 0, 1, 0, (gate-1).abs, 1, gate);
	point = [Lag.kr(point, glide), LFSaw.kr(rate).abs, SinOsc.kr(rate).abs, LFTri.kr(rate).abs, LFNoise1.kr(rate, 1, 1)/2];
	signal = Warp1.ar(2, bufnum, Select.kr(playback, point), pitch, wSize, -1, 8, 0.1, 2);
	mix= gate.linlin(0, 1, -1, 1);
	ReplaceOut.ar(out, XFade2.ar(input, signal, mix)) ;
}).writeDefFile(d);
)

