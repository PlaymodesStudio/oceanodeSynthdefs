(
SynthDef.new(\audioinput, {
    arg out=0;
	var inChan;
    var inputSignal;
	inChan=\inchan.kr(1);
    inputSignal = SoundIn.ar(inChan);
	inputSignal=LeakDC.ar(Limiter.ar((Sanitize.ar(inputSignal))));
    Out.ar(out, inputSignal);
}).writeDefFile(d);
)

(
SynthDef.new(\audioinput2, {
    arg out=0;
	var startChan;
    var inputSignal;
	startChan=\inchan.kr(0);
	inputSignal = SoundIn.ar([startChan, startChan+1]);
	inputSignal=LeakDC.ar(Limiter.ar((Sanitize.ar(inputSignal))));
    Out.ar(out, inputSignal);
}).writeDefFile(d);
)

(
SynthDef.new(\audioinput6, {
    arg out=0;
	var startChan;
    var inputSignal;
	startChan=\inchan.kr(0);
	inputSignal = SoundIn.ar([startChan, startChan+1,startChan+2,startChan+3,startChan+4,startChan+5]);
	inputSignal=LeakDC.ar(Limiter.ar((Sanitize.ar(inputSignal))));
    Out.ar(out, inputSignal);
}).writeDefFile(d);
)

(
SynthDef.new(\audioinput13, {
    arg out=0;
	var startChan;
    var inputSignal;
	startChan=\inchan.kr(0);
	inputSignal = SoundIn.ar([startChan, startChan+1,startChan+2,startChan+3,startChan+4,startChan+5, startChan+6, startChan+7, startChan+8, startChan+9, startChan+10, startChan+11, startChan+12]);
	inputSignal=LeakDC.ar(Limiter.ar((Sanitize.ar(inputSignal))));
	Out.ar(out, inputSignal);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

