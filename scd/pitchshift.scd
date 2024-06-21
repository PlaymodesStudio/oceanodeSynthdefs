(
SynthDef.new(\pitchshifter, {
	arg in, out=0;
	var input,sig;
	var grainSize=0.1;
	var pitchShif=VarLag.kr(\pitchshift.kr(0!13),1/30).midiratio;
	var pitchDispersion=VarLag.kr(\pitchdisp.kr(0!13),1/30);
	var timeDispersion=VarLag.kr(\timedisp.kr(0.0001!13),1/30);
	//z = Blip.ar(800, 6, 0.1);

	input = In.ar(in, 13);

	sig=PitchShift.ar(input,grainSize,pitchShif,pitchDispersion,timeDispersion);
	Out.ar(out, sig);

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
