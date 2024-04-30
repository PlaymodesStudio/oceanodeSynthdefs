

(/// gain
SynthDef.new(\gain, {
	arg in = 0, out=0;
	var sig, ctl;
	ctl=\gainmult.kr(1!78);
	ctl=0.000031623*exp(10.36*ctl); //assumim 90db de rang dinamic
	//https://www.dr-lex.be/info-stuff/volumecontrols.html
	sig = In.ar(in, 78)*ctl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// gain
SynthDef.new(\gain13, {
	arg in = 0, out=0;
	var sig, ctl;
	ctl=\gainmult.kr(1!13);
	ctl=0.000031623*exp(10.36*ctl); //assumim 90db de rang dinamic
	//https://www.dr-lex.be/info-stuff/volumecontrols.html
	sig = In.ar(in, 13)*ctl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// linearGain
SynthDef.new(\lineargain, {
	arg in, out;
	var sig, ctl,pw;
	ctl=\gainmult.kr(1!78, 1/30, fixedLag:true);
	pw=\pow.kr(1!78);
	ctl=pow(ctl,pw);
	sig = In.ar(in, 78)*ctl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// linearGain
SynthDef.new(\lineargain48, {
	arg in, out;
	var sig, ctl,pw;
	ctl=\gainmult.kr(1!48, 1/30, fixedLag:true);
	pw=\pow.kr(1!48);
	ctl=pow(ctl,pw);
	sig = In.ar(in, 48)*ctl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// linearGain 13ch
SynthDef.new(\lineargain13, {
	arg in, out;
	var sig, ctl,pw;
	ctl=\gainmult.kr(1!13, 1/30, fixedLag:true);
	pw=\pow.kr(1!13);
	ctl=pow(ctl,pw);
	sig = In.ar(in, 13)*ctl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// linearGain 13ch
SynthDef.new(\lineargain6, {
	arg in, out;
	var sig, ctl,pw;
	ctl=\gainmult.kr(1!6, 1/30, fixedLag:true);
	pw=\pow.kr(1!6);
	ctl=pow(ctl,pw);
	sig = In.ar(in, 6)*ctl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// linearGain 13ch
SynthDef.new(\lineargainmono, {
	arg in, out;
	var sig, ctl,pw;
	ctl=\gainmult.kr(1!1, 1/30, fixedLag:true);
	pw=\pow.kr(1!1);
	ctl=pow(ctl,pw);
	sig = In.ar(in, 1)*ctl;
	Out.ar(out, sig);
}).writeDefFile(d);
)