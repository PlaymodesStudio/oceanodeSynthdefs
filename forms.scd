(// FORMS
SynthDef(\forms, {
	//VarLag.kr(\levels.kr(1!8), 1/30)
	arg out=0;
	var partials = 1080;
	var chans = 1;
	var freqs = \freqarray.kr(220.dup(partials));
	var amps = \amparray.kr(0.0.dup(partials), 1/30, fixedLag:true);
	var largeSig = SinOsc.ar(freqs, {Rand(-25,25)}!partials, amps);
	var flat = (Mix.ar(largeSig)/100);
	Out.ar(out, flat);
}).writeDefFile(d);
)