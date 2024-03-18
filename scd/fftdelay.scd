// FFT Delay //
(
SynthDef.new(\fftdelay, {
	arg in=0, out=0, i_fft=11;
	var inAmp=0.5,
	delayTime = \delaytime.kr(0.1),
	feed = \feed.kr(0.4),
	threshAbove = \threshabove.kr(0),
	threshBelow = \threshbelow.kr(3),
	smooth = \smooth.kr(0.5),
	smear=\smear.kr(0),
	swapIn=0,
	pingPong=0,
	stretch = \stretch.kr(0),
	freqHP=\hp.kr(0).midicps,
	freqLP=\lp.kr(130).midicps,
	qHP = \qhp.kr(0),
	qLP = \qlp.kr(0),
	pan=0,
	noise= -2;
	var signalIn = In.ar(in, 2) * inAmp;
	var chain, signal, sigOut, ampAdj;
	var panPos   = pan * 2;
	var leftPos  = (panPos-1).clip(-1,1);
	var rightPos = (panPos+1).clip(-1,1);
	signalIn = [ LinSelectX.ar(swapIn, [signalIn[0],signalIn[1]]),
	             LinSelectX.ar(swapIn, [signalIn[1],signalIn[0]])];
	threshAbove = threshAbove ** 2;
	threshBelow = threshBelow ** 2;
	ampAdj      = 1 / ((threshBelow**0.8).clip(0.005,1.5));
	signal      = FbL({|feedback|
		chain  = FFT({ LocalBuf(2**i_fft) }!2, signalIn+(feedback.tanh*feed));
		chain  = PV_MagBelow (chain, threshBelow);
		chain  = PV_MagAbove (chain, threshAbove);
		chain  = PV_MagSmooth(chain, smooth);
		chain  = PV_MagSmear (chain, smear);
		chain  = PV_MagShift (chain, 2**stretch);
		sigOut = (IFFT(chain)*2);  // stereo
		noise  = 0.5 ** noise;
		sigOut = sigOut * ampAdj * noise;
		sigOut = DFM1.ar(sigOut,freqHP, qHP ,0.445,1,0);
		sigOut = DFM1.ar(sigOut,freqLP, qLP, 0.445,0,0);
		sigOut = sigOut / ampAdj / noise;
		[ LinSelectX.ar(pingPong, [sigOut[0],sigOut[1]]),
		  LinSelectX.ar(pingPong, [sigOut[1],sigOut[0]])];
	},1,delayTime.lag,2);
	signal = LinPan2.ar(signal[0], leftPos) + LinPan2.ar(signal[1], rightPos);
	Out.ar(out, signal * ampAdj);
},
).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


(
SynthDef("PlayBuf", {| out = 0, bufnum = 0 |
	Out.ar(out, PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop:1) )
}).send;
)

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav"); // remember to free the buffer later.

f = Synth("fftdelay",[\in,4,\out,0,\i_fft,11]); // set fft size here 7-13
Synth("PlayBuf",[\out, 4, \bufnum, b]);
f.set(\delayTime, 0.1666);
f.set(\feed, 0.55);
f.set(\smooth, 0.93);
f.set(\smooth, 0.4);
f.set(\smear, 3);
f.set(\smear, 0);
f.set(\stretch, 0.1);
f.set(\stretch, -0.2);
f.set(\stretch, 0);
f.set(\threshAbove, 0.3);
f.set(\threshAbove, 0.7);
f.set(\threshAbove, 0);
f.set(\threshBelow, 1);
f.set(\threshBelow, 0.7);
f.set(\threshBelow, 3);
f.set(\freqLP, 6000);
f.set(\qLP, 0.25);
f.set(\freqHP, 200);
f.set(\qHP, 0.4);
f.set(\delayTime, 0.166);
f.set(\smooth, 0.8);
f.set(\pingPong, 0); // stereo
Synth("PlayBuf",[\out, 5, \bufnum, b]);
f.set(\pingPong, 0.5); // mono
f.set(\pingPong, 1); // ping pong
f.set(\swapIn,0.5); // input is mono
f.set(\swapIn,1); // swap L & R in