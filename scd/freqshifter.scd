(
SynthDef.new(\freqshifter, {
	arg in, out=0;
	var input,sig;
	var freqShif=VarLag.kr(\freqshift.kr(150!13),1/30);
	var phase=VarLag.kr(\phase.kr(3.14!13),1/30);

	input = In.ar(in, 13);

	sig=FreqShift.ar(input,freqShif,phase);
	Out.ar(out, sig);

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
