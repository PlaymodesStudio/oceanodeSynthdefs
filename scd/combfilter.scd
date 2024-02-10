//comb filter
(
SynthDef.new(\comb, {
	arg in, out=0;
	var input,combed,sig,p,finalP,dec,drywet,vib,ing;
	ing=\inputgain.kr(1!78, 1/30, fixedLag:true);
	input = In.ar(in, 78);

	p=\pitch.kr(36!78);
	dec=\decay.kr(1!78);
	drywet=\mix.kr(0!78);
	vib=SinOsc.ar(\vibf.kr(0!78),0,\viba.kr(0!78),0);
	finalP=p+vib;
	finalP=finalP.midicps;

	combed=CombL.ar(input*ing,0.1,1/finalP,dec,1,0)/2;
	sig=(drywet*combed)+((1-drywet)*input);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef.new(\comb13, {
	arg in, out=0;
	var input,combed,sig,p,finalP,dec,drywet,vib,ing;
	ing=\inputgain.kr(1!13, 1/30, fixedLag:true);
	input = In.ar(in, 13);

	p=\pitch.kr(36!13);
	dec=\decay.kr(1!13);
	drywet=\mix.kr(0!13);
	vib=SinOsc.ar(\vibf.kr(0!13),0,\viba.kr(0!13),0);
	finalP=p+vib;
	finalP=finalP.midicps;

	combed=CombL.ar(input*ing,0.1,1/finalP,dec,1,0)/2;
	sig=(drywet*combed)+((1-drywet)*input);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef.new(\combmono, {
	arg in, out=0;
	var input,combed,sig,p,finalP,dec,drywet,vib,ing;
	ing=\inputgain.kr(1!1, 1/30, fixedLag:true);
	input = In.ar(in, 1);

	p=\pitch.kr(36!1);
	dec=\decay.kr(1!1);
	drywet=\mix.kr(0!1);
	vib=SinOsc.ar(\vibf.kr(0!1),0,\viba.kr(0!1),0);
	finalP=p+vib;
	finalP=finalP.midicps;

	combed=CombL.ar(input*ing,0.1,1/finalP,dec,1,0)/2;
	sig=(drywet*combed)+((1-drywet)*input);
	Out.ar(out, sig);
}).writeDefFile(d);
)