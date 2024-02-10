(
SynthDef.new(\decimator, {
	arg in, out=0;
	var input,sig;
	var rate=VarLag.kr(\samplerate.kr(44100!13),1/30);
	var bits=VarLag.kr(\bitdepth.kr(24!13),1/30);

	input = In.ar(in, 13);

	sig=Decimator.ar(input,rate,bits);
	Out.ar(out, sig);

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
