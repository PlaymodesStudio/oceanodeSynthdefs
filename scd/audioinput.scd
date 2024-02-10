(
SynthDef.new(\audioinput, {
    arg out=0;
	var inChan;
    var inputSignal;
	inChan=\chan.kr(1);
    inputSignal = AudioIn.ar(inChan);
    Out.ar(out, inputSignal);
}).writeDefFile(d);
)