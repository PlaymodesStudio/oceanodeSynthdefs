(
SynthDef.new(\audioinput, {
    arg out=0;
	var inChan;
    var inputSignal;
	inChan=\inchan.kr(1);
    inputSignal = AudioIn.ar(inChan);
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
    Out.ar(out, inputSignal);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

