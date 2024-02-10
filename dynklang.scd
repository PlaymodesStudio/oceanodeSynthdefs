(// dynklang
SynthDef(\dynklang, {
	//VarLag.kr(\levels.kr(1!8), 1/30)
	arg out=0;
	var partials = 16;
	var chans = 78;
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = SinOsc.ar(freqs, mul: amps);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)

(// dynklang
SynthDef(\dynklang13, {
	//VarLag.kr(\levels.kr(1!8), 1/30)
	arg out=0;
	var partials = 16;
	var chans = 13;
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = SinOsc.ar(freqs, mul: amps);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)

(// dynklang
SynthDef(\dynklangmono, {
	//VarLag.kr(\levels.kr(1!8), 1/30)
	arg out=0;
	var partials = 16;
	var chans = 1;
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = SinOsc.ar(freqs, mul: amps);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)