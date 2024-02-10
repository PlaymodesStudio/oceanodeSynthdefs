(//flanger
SynthDef(\flanger, {
	arg out=0, in=0;
	var input,effect,del,fb,sig,mx,wt;
	input=In.ar(in,78);
	wt=In.ar(in,78);
	input=input+LocalIn.ar(78);
	del=K2A.ar(\delay.kr(0.005!78, 0.1, fixedLag:true)); //param 1
	fb=\feedback.kr(0.5!78); //param 2
	mx=\mix.kr(0!78);
	effect= DelayN.ar(input,0.02,del);
	LocalOut.ar(fb*effect);
	sig=(wt*(1-mx))+(effect*mx);
	Out.ar(out,sig); //adds to bus 0 where original signal is already playing
}).writeDefFile(d);
)

(//flanger
SynthDef(\flanger13, {
	arg out=0, in=0;
	var input,effect,del,fb,sig,mx,wt;
	input=In.ar(in,13);
	wt=In.ar(in,13);
	input=input+LocalIn.ar(13);
	del=K2A.ar(\delay.kr(0.005!13, 0.1, fixedLag:true)); //param 1
	fb=\feedback.kr(0.5!13); //param 2
	mx=\mix.kr(0!13);
	effect= DelayN.ar(input,0.02,del);
	LocalOut.ar(fb*effect);
	sig=(wt*(1-mx))+(effect*mx);
	Out.ar(out,sig); //adds to bus 0 where original signal is already playing
}).writeDefFile(d);
)

(//flanger
SynthDef(\flangermono, {
	arg out=0, in=0;
	var input,effect,del,fb,sig,mx,wt;
	input=In.ar(in,1);
	wt=In.ar(in,1);
	input=input+LocalIn.ar(1);
	del=K2A.ar(\delay.kr(0.005!1, 0.1, fixedLag:true)); //param 1
	fb=\feedback.kr(0.5!1); //param 2
	mx=\mix.kr(0!1);
	effect= DelayN.ar(input,0.02,del);
	LocalOut.ar(fb*effect);
	sig=(wt*(1-mx))+(effect*mx);
	Out.ar(out,sig); //adds to bus 0 where original signal is already playing
}).writeDefFile(d);
)

(//flangerpitch
SynthDef(\flangerpitch, {
	arg out=0, in=0;
	var input,effect,del,fb,sig,mx,wt;
	input=In.ar(in,78);
	wt=In.ar(in,78);
	input=input+LocalIn.ar(78);
	del=K2A.ar(\pitch.kr(60!78, 0.1, fixedLag:true).midicps.reciprocal); //param 1
	fb=\feedback.kr(0.5!78); //param 2
	mx=\mix.kr(0!78);
	effect= DelayN.ar(input,0.2,del);
	LocalOut.ar(fb*effect);
	sig=(wt*(1-mx))+(effect*mx);
	Out.ar(out,sig); //adds to bus 0 where original signal is already playing
}).writeDefFile(d);
)

(//flangerpitch
SynthDef(\flangerpitch13, {
	arg out=0, in=0;
	var input,effect,del,fb,sig,mx,wt;
	input=In.ar(in,13);
	wt=In.ar(in,13);
	input=input+LocalIn.ar(13);
	del=K2A.ar(\pitch.kr(60!13, 0.1, fixedLag:true).midicps.reciprocal); //param 1
	fb=\feedback.kr(0.5!13); //param 2
	mx=\mix.kr(0!13);
	effect= DelayN.ar(input,0.2,del);
	LocalOut.ar(fb*effect);
	sig=(wt*(1-mx))+(effect*mx);
	Out.ar(out,sig); //adds to bus 0 where original signal is already playing
}).writeDefFile(d);
)

(//flangerpitch
SynthDef(\flangerpitchmono, {
	arg out=0, in=0;
	var input,effect,del,fb,sig,mx,wt;
	input=In.ar(in,1);
	wt=In.ar(in,1);
	input=input+LocalIn.ar(1);
	del=K2A.ar(\pitch.kr(60!1, 0.1, fixedLag:true).midicps.reciprocal); //param 1
	fb=\feedback.kr(0.5!1); //param 2
	mx=\mix.kr(0!1);
	effect= DelayN.ar(input,0.2,del);
	LocalOut.ar(fb*effect);
	sig=(wt*(1-mx))+(effect*mx);
	Out.ar(out,sig); //adds to bus 0 where original signal is already playing
}).writeDefFile(d);
)