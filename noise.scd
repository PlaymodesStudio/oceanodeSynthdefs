
(//noise oscillators
SynthDef.new(\noise, {
	arg out;
	var d,waves,finalSig,p;
	d=\density.kr(1!78);

	waves=[
		WhiteNoise.ar({1}!78,0), //pow?
		PinkNoise.ar({1}!78,0), //pow?
		Crackle.ar(d*2,1,0),
		Dust2.ar(d*8,1,0)*2
	];

	finalSig=Select.ar(\type.kr(0!78),waves);
	finalSig=finalSig*\levels.kr(0!78, 1/30, fixedLag:true);
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

(//noise oscillators
SynthDef.new(\noise13, {
	arg out;
	var d,waves,finalSig,p;
	d=\density.kr(1!13);

	waves=[
		WhiteNoise.ar({1}!13,0), //pow?
		PinkNoise.ar({1}!13,0), //pow?
		Crackle.ar(d*2,1,0),
		Dust2.ar(d*8,1,0)*2
	];

	finalSig=Select.ar(\type.kr(0!13),waves);
	finalSig=finalSig*\levels.kr(0!13, 1/30, fixedLag:true);
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

(//noise oscillators
SynthDef.new(\noisemono, {
	arg out;
	var d,waves,finalSig,p;
	d=\density.kr(1!1);

	waves=[
		WhiteNoise.ar({1}!1,0), //pow?
		PinkNoise.ar({1}!1,0), //pow?
		Crackle.ar(d*2,1,0),
		Dust2.ar(d*8,1,0)*2
	];

	finalSig=Select.ar(\type.kr(0!1),waves);
	finalSig=finalSig*\levels.kr(0!1, 1/30, fixedLag:true);
	Out.ar(out, finalSig);
}).writeDefFile(d);
)