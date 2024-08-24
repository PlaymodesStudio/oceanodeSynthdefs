d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\flangersync13, {

	arg out=0, in=0;
	var dry,wet,snd;
	var numchans=13;
	var mx=\mix.kr(1!numchans, 1/30, fixedLag: true);
	var rate = \rate.kr(0.01!numchans);
	var minDelay = \mindel.kr(0.004!numchans);
	var maxDelay = \maxdel.kr(0.01!numchans);
	var decayTime = \decay.kr(1!numchans);
	var sig, sigA, sigB, lfoA, lfoB, combA, combB, delayTime;

	lfoA = LFSaw.ar(rate, 1, (maxDelay * 0.5) - minDelay, (maxDelay * 0.5) + minDelay); // initial phase of 0 radians
	lfoB = LFSaw.ar(rate, 0, (maxDelay * 0.5) - minDelay, (maxDelay * 0.5) + minDelay); // initial phase of pi radians

	dry = In.ar(in,13);

	combA = CombC.ar(dry, maxDelay, lfoA, decayTime);
	combB = CombC.ar(dry, maxDelay, lfoB, decayTime);

	wet = XFade2.ar(combA, combB, LFTri.kr(rate, 1)); // initial phase of pi radians

	snd = (dry * (1 - mx)) + (wet * mx);
	Out.ar(out, snd);

}).writeDefFile(d);
)

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