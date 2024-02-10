s.boot;
s.meter;
s.options.maxLogins=3;
s.plotTree;
s.options.numAudioBusChannels;
s.options.memSize=2048576;
s.options.numWireBufs=8192;
s.options.numOutputBusChannels=32;
s.options.numInputBusChannels;

/// Synthdefs

//Analog oscillators

d = thisProcess.nowExecutingPath.dirname +/+ "../SC_DEBUG/data/Synthdefs"

(
SynthDef.new(\analog, {
	arg out;
	var p,vib,trem,finalP,x,waves,pulsew,finalSig,fm,fmp,fma;
	p=\pitch.kr(36!78);
	pulsew=\pw.kr(0!78);
	vib=SinOsc.ar(\vibf.kr(0!78),0,\viba.kr(0!78),0);
	trem=1-((SinOsc.ar(\tremf.kr(0!78),0,1,1)/2)*\trema.kr(0!78));
	finalP=p+vib;
	fmp=\fmpitch.kr(48!78);
	fma=\fmamp.kr(0!78);
	fm=SinOsc.ar(fmp.midicps,0)*fma;

	waves=[
		Saw.ar(finalP.midicps+fm,1,0),
		LFTri.ar(finalP.midicps+fm,0),
		Pulse.ar(finalP.midicps+fm,(pulsew+0.5)%1,1),
		SinOsc.ar(finalP.midicps+fm,0)
	];

	finalSig=Select.ar(\type.kr(0!78),waves);
	finalSig=finalSig*(\levels.kr(0!78, 1/30, fixedLag:true))*trem;
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

(
SynthDef.new(\analog13, {
	arg out;
	var p,vib,trem,finalP,x,waves,pulsew,finalSig,fm,fmp,fma;
	p=\pitch.kr(36!13);
	pulsew=\pw.kr(0!13);
	vib=SinOsc.ar(\vibf.kr(0!13),0,\viba.kr(0!13),0);
	trem=1-((SinOsc.ar(\tremf.kr(0!13),0,1,1)/2)*\trema.kr(0!13));
	finalP=p+vib;
	fmp=\fmpitch.kr(48!13);
	fma=\fmamp.kr(0!13);
	fm=SinOsc.ar(fmp.midicps,0)*fma;

	waves=[
		Saw.ar(finalP.midicps+fm,1,0),
		LFTri.ar(finalP.midicps+fm,0),
		Pulse.ar(finalP.midicps+fm,(pulsew+0.5)%1,1),
		SinOsc.ar(finalP.midicps+fm,0)
	];

	finalSig=Select.ar(\type.kr(0!13),waves);
	finalSig=finalSig*(\levels.kr(0!13, 1/30, fixedLag:true))*trem;
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

(
SynthDef.new(\analogmono, {
	arg out;
	var p,vib,trem,finalP,x,waves,pulsew,finalSig,fm,fmp,fma;
	p=\pitch.kr(36!1);
	pulsew=\pw.kr(0!1);
	vib=SinOsc.ar(\vibf.kr(0!1),0,\viba.kr(0!1),0);
	trem=1-((SinOsc.ar(\tremf.kr(0!1),0,1,1)/2)*\trema.kr(0!1));
	finalP=p+vib;
	fmp=\fmpitch.kr(48!1);
	fma=\fmamp.kr(0!1);
	fm=SinOsc.ar(fmp.midicps,0)*fma;

	waves=[
		Saw.ar(finalP.midicps+fm,1,0),
		LFTri.ar(finalP.midicps+fm,0),
		Pulse.ar(finalP.midicps+fm,(pulsew+0.5)%1,1),
		SinOsc.ar(finalP.midicps+fm,0)
	];

	finalSig=Select.ar(\type.kr(0!1),waves);
	finalSig=finalSig*(\levels.kr(0!1, 1/30, fixedLag:true))*trem;
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

(
SynthDef(\ikedabass, {

	arg out = 0;
	var freq = 0, amp = 1, harmonic = 8, iphase = pi/3;
	var env, snd;

	freq=\pitch.kr(36!78).midicps;
	amp=\levels.kr(0!78, 1/30, fixedLag:true);
	harmonic=\harm.kr(8!78);
	snd = SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq) + iphase).wrap(-pi, pi))+SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq * harmonic) + iphase).wrap(-pi, pi));
snd=snd*amp;
	snd = (snd/2).tanh;
	snd = LeakDC.ar(snd);
	snd = snd ;
    Out.ar(out, snd);

}).writeDefFile(d);
)

(
SynthDef(\ikedabass13, {

	arg out = 0;
	var freq = 0, amp = 1, harmonic = 8, iphase = pi/3;
	var env, snd;

	freq=\pitch.kr(36!13).midicps;
	amp=\levels.kr(0!13, 1/30, fixedLag:true);
	harmonic=\harm.kr(8!13);

	snd = SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq) + iphase).wrap(-pi, pi))+SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq * harmonic) + iphase).wrap(-pi, pi));
snd=snd*amp;
	snd = (snd/2).tanh;
	snd = LeakDC.ar(snd);
	snd = snd ;
    Out.ar(out, snd);
}).writeDefFile(d);
)

(
SynthDef(\ikedabassmono, {

	arg out = 0;
	var freq = 0, amp = 1, harmonic = 8, iphase = pi/3;
	var env, snd;

	freq=\pitch.kr(36!1).midicps;
	amp=\levels.kr(0!1, 1/30, fixedLag:true);
	harmonic=\harm.kr(8!1);

	snd = SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq) + iphase).wrap(-pi, pi))+SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq * harmonic) + iphase).wrap(-pi, pi));
	snd=snd*amp;
	snd = (snd/2).tanh;
	snd = LeakDC.ar(snd);
	snd = snd ;
    Out.ar(out, snd);
}).writeDefFile(d);
)

(
 SynthDef.new(\tb303, {
	arg  out=0, freq=440, wave=0, ctf=100, res=0.2, sus=0, dec=1.0, env=1000, gate=0, vol=0.2;
	var  filEnv, volEnv, waves, sig;

	freq=\pitch.kr(36!78).midicps;
	wave=\wavetype.kr(0!78);
	ctf=\cutoff.kr(48!78).midicps;
	res=\resonance.kr(0.2!78);
	sus=\sustain.kr(0!78);
	dec=\decay.kr(1!78);
	env=\envelope.kr(1000!78);
	gate=\trigger.kr(0!78);
	vol=\level.kr(0!78);

	volEnv =  EnvGen.ar( Env .new([10e-10, 1, 1, 10e-10], [0.01, sus, dec],  'exp' ), gate);
	filEnv =  EnvGen.ar( Env .new([10e-10, 1, 10e-10], [0.01, dec],  'exp' ), gate);

	waves = [ Saw.ar(freq, volEnv),  Pulse.ar(freq, 0.5, volEnv)];
	sig=RLPF.ar(Select.ar(wave, waves), ctf + (filEnv * env), res) * vol;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(
 SynthDef.new(\tb30313, {
	arg  out=0, freq=440, wave=0, ctf=100, res=0.2, sus=0, dec=1.0, env=1000, gate=0, vol=0.2;
	var  filEnv, volEnv, waves, sig;

	freq=\pitch.kr(36!13).midicps;
	wave=\wavetype.kr(0!13);
	ctf=\cutoff.kr(48!13).midicps;
	res=\resonance.kr(0.2!13);
	sus=\sustain.kr(0!13);
	dec=\decay.kr(1!13);
	env=\envelope.kr(1000!13);
	gate=\trigger.kr(0!13);
	vol=\level.kr(0!13);

	volEnv =  EnvGen.ar( Env .new([10e-10, 1, 1, 10e-10], [0.01, sus, dec],  'exp' ), gate);
	filEnv =  EnvGen.ar( Env .new([10e-10, 1, 10e-10], [0.01, dec],  'exp' ), gate);

	waves = [ Saw.ar(freq, volEnv), Pulse.ar(freq, 0.5, volEnv)];
	sig=RLPF.ar(Select.ar(wave, waves), ctf + (filEnv * env), res) * vol;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(
 SynthDef.new(\tb303mono, {
	arg  out=0, freq=440, wave=0, ctf=100, res=0.2, sus=0, dec=1.0, env=1000, gate=0, vol=0.2;
	var  filEnv, volEnv, waves, sig;

	freq=\pitch.kr(36!1).midicps;
	wave=\wavetype.kr(0!1);
	ctf=\cutoff.kr(48!1).midicps;
	res=\resonance.kr(0.2!1);
	sus=\sustain.kr(0!1);
	dec=\decay.kr(1!1);
	env=\envelope.kr(1000!1);
	gate=\trigger.kr(0!1);
	vol=\level.kr(0!1);

	volEnv =  EnvGen.ar( Env .new([10e-10, 1, 1, 10e-10], [0.01, sus, dec],  'exp' ), gate);
	filEnv =  EnvGen.ar( Env .new([10e-10, 1, 10e-10], [0.01, dec],  'exp' ), gate);

	waves = [ Saw.ar(freq, volEnv), Pulse.ar(freq, 0.5, volEnv)];
	sig=RLPF.ar(Select.ar(wave, waves), ctf + (filEnv * env), res) * vol;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(///fm synth
SynthDef(\fm, {
	arg p, mR,mRf, cR,cRf, idx=1, amp, out=0;
	var car, mod, fb,sig;
	p=\pitch.kr(36!78).midicps; //param1
	amp=\levels.kr(0!78, 1/30, fixedLag:true); //param2
	mR=\mratio.kr(1!78)+\mratiofine.kr(0!78);//param3
	cR=\cratio.kr(1!78)+\cratiofine.kr(0!78);//param4
	idx=\index.kr(1!78);//param5
	fb=\mfeedback.kr(0!78);
	mod = SinOscFB.ar(p * mR, fb, mul:p * mR * idx);
	car=[
		SinOsc.ar(p * cR + mod) * amp,
		Saw.ar(p * cR + mod) * amp,
		LFTri.ar(p * cR + mod) * amp,
		Pulse.ar(p * cR + mod) * amp
	];
	sig=Select.ar(\mwave.kr(0!78),car);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(///fm synth
SynthDef(\fm13, {
	arg p, mR,mRf, cR,cRf, idx=1, amp, out=0;
	var car, mod, fb,sig;
	p=\pitch.kr(36!13).midicps; //param1
	amp=\levels.kr(0!13, 1/30, fixedLag:true); //param2
	mR=\mratio.kr(1!13)+\mratiofine.kr(0!13);//param3
	cR=\cratio.kr(1!13)+\cratiofine.kr(0!13);//param4
	idx=\index.kr(1!13);//param5
	fb=\mfeedback.kr(0!13);
	mod = SinOscFB.ar(p * mR, fb, mul:p * mR * idx);
	car=[
		SinOsc.ar(p * cR + mod) * amp,
		Saw.ar(p * cR + mod) * amp,
		LFTri.ar(p * cR + mod) * amp,
		Pulse.ar(p * cR + mod) * amp
	];
	sig=Select.ar(\mwave.kr(0!13),car);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(///fm synth
SynthDef(\fmmono, {
	arg p, mR,mRf, cR,cRf, idx=1, amp, out=0;
	var car, mod, fb,sig;
	p=\pitch.kr(36!1).midicps; //param1
	amp=\levels.kr(0!1, 1/30, fixedLag:true); //param2
	mR=\mratio.kr(1!1)+\mratiofine.kr(0!1);//param3
	cR=\cratio.kr(1!1)+\cratiofine.kr(0!1);//param4
	idx=\index.kr(1!1);//param5
	fb=\mfeedback.kr(0!1);
	mod = SinOscFB.ar(p * mR, fb, mul:p * mR * idx);
	car=[
		SinOsc.ar(p * cR + mod) * amp,
		Saw.ar(p * cR + mod) * amp,
		LFTri.ar(p * cR + mod) * amp,
		Pulse.ar(p * cR + mod) * amp
	];
	sig=Select.ar(\mwave.kr(0!1),car);
	Out.ar(out, sig);
}).writeDefFile(d);
)



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

(//// phmod synth
SynthDef(\phmod, {
	arg out;
	var carfreq,modfreq,pmidx,sig,lv;
	carfreq=\carp.kr(48!78).midicps;
	modfreq=\modp.kr(60!78).midicps;
	pmidx=\pmindex.kr(0!78);
	sig=PMOsc.ar(carfreq,modfreq,pmidx,0,\levels.kr(0!78, 1/30, fixedLag:true),0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// phmod synth
SynthDef(\phmod13, {
	arg out;
	var carfreq,modfreq,pmidx,sig,lv;
	carfreq=\carp.kr(48!13).midicps;
	modfreq=\modp.kr(60!13).midicps;
	pmidx=\pmindex.kr(0!13);
	sig=PMOsc.ar(carfreq,modfreq,pmidx,0,\levels.kr(0!13, 1/30, fixedLag:true),0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// phmod synth
SynthDef(\phmodmono, {
	arg out;
	var carfreq,modfreq,pmidx,sig,lv;
	carfreq=\carp.kr(48!1).midicps;
	modfreq=\modp.kr(60!1).midicps;
	pmidx=\pmindex.kr(0!1);
	sig=PMOsc.ar(carfreq,modfreq,pmidx,0,\levels.kr(0!1, 1/30, fixedLag:true),0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// click oscillator
SynthDef(\click, {
	arg out, go;
	var env, click;
	go=\trigger.kr(0!78);
	env = EnvGen.ar(Env(#[0, 0, 1], [0, 1], 0), go);
	click = Changed.ar(ceil(env));
	Out.ar(out, click);
}).writeDefFile(d);
)

(//// click oscillator
SynthDef(\click13, {
	arg out, go;
	var env, click;
	go=\trigger.kr(0!13);
	env = EnvGen.ar(Env(#[0, 0, 1], [0, 1], 0), go);
	click = Changed.ar(ceil(env));
	Out.ar(out, click);
}).writeDefFile(d);
)

(//// click oscillator
SynthDef(\clickmono, {
	arg out, go;
	var env, click;
	go=\trigger.kr(0!1);
	env = EnvGen.ar(Env(#[0, 0, 1], [0, 1], 0), go);
	click = Changed.ar(ceil(env));
	Out.ar(out, click);
}).writeDefFile(d);
)

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

(// miniklang
SynthDef(\miniklang, {
	arg out=0;
	var partials = 32;
	var chans = 2;
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = SinOsc.ar(freqs, mul: amps);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)

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

(/// sync saw
SynthDef(\syncsaw, {
	arg out;
	var f,sf,sig,lv;
	lv=\levels.kr(0!78, 1/30, fixedLag:true);
	f=\pitch.kr(24!78).midicps;
	sf=\synchz.kr(440!78, 0.1, fixedLag:true);
	sig=SyncSaw.ar(f,sf,lv,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// sync saw
SynthDef(\syncsaw13, {
	arg out;
	var f,sf,sig,lv;
	lv=\levels.kr(0!13, 1/30, fixedLag:true);
	f=\pitch.kr(24!13).midicps;
	sf=\synchz.kr(440!13, 0.1, fixedLag:true);
	sig=SyncSaw.ar(f,sf,lv,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// sync saw
SynthDef(\syncsawmono, {
	arg out;
	var f,sf,sig,lv;
	lv=\levels.kr(0!1, 1/30, fixedLag:true);
	f=\pitch.kr(24!1).midicps;
	sf=\synchz.kr(440!1, 0.1, fixedLag:true);
	sig=SyncSaw.ar(f,sf,lv,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//kickdrum
SynthDef(\kickdrum, {
	arg out = 0, pan = 0, amp = 1;
	var body, bodyFreq, bodyAmp;
	var waves;
	var go=\trigger.kr(0!78);
	var hi=\hifreq.kr(18000!78);
	var lo=\lopitch.kr(36!78).midicps;
	var time1=\freq1time.kr(0.035!78);
	var time2=\freq2time.kr(0.8!78);
	var curv=\freqcurve.kr(-8!78);
	var a=\attack.kr(0!78);
	var s=\sustain.kr(0.1!78);
	var r=\release.kr(0.3!78);
	var pmp=\pmpitch.kr(0!78).midicps;
	var pmidx=\pmindex.kr(0!78);
	bodyFreq = EnvGen.ar(Env([hi,hi,lo,lo], [0,time1,time2,time2], curve: curv), go);
	bodyAmp = EnvGen.ar(Env.linen(a, s, r, curve: 'cubed'), go);
	waves=[
		PMOsc.ar(bodyFreq,bodyFreq-pmp,pmidx) * bodyAmp;,
		Pulse.ar(bodyFreq)*bodyAmp
	];
	body =Select.ar(\wavetype.kr(0!78),waves);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)

(//kickdrum
SynthDef(\kickdrum13, {
	arg out = 0, pan = 0, amp = 1;
	var body, bodyFreq, bodyAmp;
	var waves;
	var go=\trigger.kr(0!13);
	var hi=\hifreq.kr(18000!13);
	var lo=\lopitch.kr(36!78).midicps;
	var time1=\freq1time.kr(0.035!13);
	var time2=\freq2time.kr(0.8!13);
	var curv=\freqcurve.kr(-8!13);
	var a=\attack.kr(0!13);
	var s=\sustain.kr(0.1!13);
	var r=\release.kr(0.3!13);
	var pmp=\pmpitch.kr(0!13).midicps;
	var pmidx=\pmindex.kr(0!13);
	bodyFreq = EnvGen.ar(Env([hi,hi,lo,lo], [0,time1,time2,time2], curve: curv), go);
	bodyAmp = EnvGen.ar(Env.linen(a, s, r, curve: 'cubed'), go);
	waves=[
		PMOsc.ar(bodyFreq,bodyFreq-pmp,pmidx) * bodyAmp;,
		Pulse.ar(bodyFreq)*bodyAmp
	];
	body =Select.ar(\wavetype.kr(0!13),waves);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)

(//kickdrum
SynthDef(\kickdrummono, {
	arg out = 0, pan = 0, amp = 1;
	var body, bodyFreq, bodyAmp;
	var waves;
	var go=\trigger.kr(0!1);
	var hi=\hifreq.kr(18000!1);
	var lo=\lopitch.kr(36!78).midicps;
	var time1=\freq1time.kr(0.035!1);
	var time2=\freq2time.kr(0.8!1);
	var curv=\freqcurve.kr(-8!1);
	var a=\attack.kr(0!1);
	var s=\sustain.kr(0.1!1);
	var r=\release.kr(0.3!1);
	var pmp=\pmpitch.kr(0!1).midicps;
	var pmidx=\pmindex.kr(0!1);
	bodyFreq = EnvGen.ar(Env([hi,hi,lo,lo], [0,time1,time2,time2], curve: curv), go);
	bodyAmp = EnvGen.ar(Env.linen(a, s, r, curve: 'cubed'), go);
	waves=[
		PMOsc.ar(bodyFreq,bodyFreq-pmp,pmidx) * bodyAmp;,
		Pulse.ar(bodyFreq)*bodyAmp
	];
	body =Select.ar(\wavetype.kr(0!1),waves);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)

(//kickdrum
SynthDef(\kickdrumb, {
	arg out=0;
	var body, bodyfreq, bodyamp;
	var go=\trigger.kr(0!78);
	var p=\pitch.kr(36!78).midicps;
	var curvp=\pitchcurve.kr(-4!78);
	var curva=\ampcurve.kr(-4!78);
	var pdec=\pitchdecay.kr(4!78);
	var adec=\ampdecay.kr(4!78);
	var tune=\hitune.kr(300!78);
	var harm=\harmonics.kr(40!78);

	bodyfreq=(EnvGen.ar(Env.perc(0.01, pdec, 1,curvp), go)*tune)+p;
	bodyamp=EnvGen.ar(Env.perc(0.01, adec, 1,curva), go)*harm;
	body=LFTri.ar(bodyfreq,0,bodyamp);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)

(//kickdrum
SynthDef(\kickdrumb13, {
	arg out=0;
	var body, bodyfreq, bodyamp;
	var go=\trigger.kr(0!13);
	var p=\pitch.kr(36!13).midicps;
	var curvp=\pitchcurve.kr(-4!13);
	var curva=\ampcurve.kr(-4!13);
	var pdec=\pitchdecay.kr(4!13);
	var adec=\ampdecay.kr(4!13);
	var tune=\hitune.kr(300!13);
	var harm=\harmonics.kr(40!13);

	bodyfreq=(EnvGen.ar(Env.perc(0.01, pdec, 1,curvp), go)*tune)+p;
	bodyamp=EnvGen.ar(Env.perc(0.01, adec, 1,curva), go)*harm;
	body=LFTri.ar(bodyfreq,0,bodyamp);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)

(//kickdrum
SynthDef(\kickdrumbmono, {
	arg out=0;
	var body, bodyfreq, bodyamp;
	var go=\trigger.kr(0!1);
	var p=\pitch.kr(36!1).midicps;
	var curvp=\pitchcurve.kr(-4!1);
	var curva=\ampcurve.kr(-4!1);
	var pdec=\pitchdecay.kr(4!1);
	var adec=\ampdecay.kr(4!1);
	var tune=\hitune.kr(300!1);
	var harm=\harmonics.kr(40!1);

	bodyfreq=(EnvGen.ar(Env.perc(0.01, pdec, 1,curvp), go)*tune)+p;
	bodyamp=EnvGen.ar(Env.perc(0.01, adec, 1,curva), go)*harm;
	body=LFTri.ar(bodyfreq,0,bodyamp);
	body=body.tanh;
	Out.ar(out, body);
}).writeDefFile(d);
)


(// samples
SynthDef(\sampler,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain;
		t=\trigger.kr(0!78);
		gain=\levels.kr(0!78, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!78);
		spd=\speed.kr(1!78);
		bucle=\loop.kr(0!78);
		start=\startpos.kr(0!78)*BufFrames.kr(buf);
		signal=PlayBuf.ar(1, buf, spd, t, start,bucle)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(// samples
SynthDef(\sampler13,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain;
		t=\trigger.kr(0!13);
		gain=\levels.kr(0!13, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!13);
		spd=\speed.kr(1!13);
		bucle=\loop.kr(0!13);
		start=\startpos.kr(0!13)*BufFrames.kr(buf);
		signal=PlayBuf.ar(1, buf, spd, t, start,bucle)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(// samples
SynthDef(\samplermono,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain;
		t=\trigger.kr(0!1);
		gain=\levels.kr(0!1, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!1);
		spd=\speed.kr(1!1);
		bucle=\loop.kr(0!1);
		start=\startpos.kr(0!1)*BufFrames.kr(buf);
		signal=PlayBuf.ar(1, buf, spd, t, start,bucle)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(///// GranularSampler
SynthDef(\grainsampler,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain,dur;
		t=\trigger.kr(0!78);
		gain=\levels.kr(0!78, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!78);
		spd=\speed.kr(1!78);
		start=\startpos.kr(0!78);
		dur=\grainsize.kr(0.1!78);
		signal=GrainBuf.ar(1, t, dur, buf, spd, start,2,0,-1,1024)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(///// GranularSampler
SynthDef(\grainsampler13,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain,dur;
		t=\trigger.kr(0!13);
		gain=\levels.kr(0!13, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!13);
		spd=\speed.kr(1!13);
		start=\startpos.kr(0!13);
		dur=\grainsize.kr(0.1!13);
		signal=GrainBuf.ar(1, t, dur, buf, spd, start,2,0,-1,1024)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(///// GranularSampler
SynthDef(\grainsamplermono,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain,dur;
		t=\trigger.kr(0!1);
		gain=\levels.kr(0!1, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!1);
		spd=\speed.kr(1!1);
		start=\startpos.kr(0!1);
		dur=\grainsize.kr(0.1!1);
		signal=GrainBuf.ar(1, t, dur, buf, spd, start,2,0,-1,1024)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

/////////////////////////////////////////////////////////////////////////////////////////////

//// dynklank
(
SynthDef(\dynklank, {
	arg out=0, in=0;
	var partials = 16;
	var chans = 78;
	var sig = In.ar(in, 78);
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var decays = \decayarray.kr(0.5.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = Ringz.ar(sig,freqs,decays,amps,0);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)

(
SynthDef(\dynklank13, {
	arg out=0, in=0;
	var partials = 16;
	var chans = 13;
	var sig = In.ar(in, 13);
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var decays = \decayarray.kr(0.5.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = Ringz.ar(sig,freqs,decays,amps,0);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)

(
SynthDef(\dynklankmono, {
	arg out=0, in=0;
	var partials = 16;
	var chans = 1;
	var sig = In.ar(in, 1);
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var decays = \decayarray.kr(0.5.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = Ringz.ar(sig,freqs,decays,amps,0);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)




//multimode filter
(
SynthDef.new(\filter, {
	arg in,out=0;
	var input,filters,filtered,freq,res,type;
	input = In.ar(in, 78);
	freq=\pitch.kr(128!78, 0.05, fixedLag:true).midicps;
	res=\q.kr(1!78);

	filters=[
		RLPF.ar(input,freq,res,1,0),
		RHPF.ar(input,freq,res,1,0),
		BPF.ar(input,freq,res,1,0),
		BRF.ar(input,freq,res,1,0),
		BPeakEQ.ar(input,freq,1,res*12,1,0)
	];

	filtered=Select.ar(\type.kr(0!78),filters);
	Out.ar(out, filtered);
}).writeDefFile(d);
)

(
SynthDef.new(\filter13, {
	arg in,out=0;
	var input,filters,filtered,freq,res,type;
	input = In.ar(in, 13);
	freq=\pitch.kr(128!13, 0.05, fixedLag:true).midicps;
	res=\q.kr(1!13);

	filters=[
		RLPF.ar(input,freq,res,1,0),
		RHPF.ar(input,freq,res,1,0),
		BPF.ar(input,freq,res,1,0),
		BRF.ar(input,freq,res,1,0),
		BPeakEQ.ar(input,freq,1,res*12,1,0)
	];

	filtered=Select.ar(\type.kr(0!13),filters);
	Out.ar(out, filtered);
}).writeDefFile(d);
)

(
SynthDef.new(\filtermono, {
	arg in,out=0;
	var input,filters,filtered,freq,res,type;
	input = In.ar(in, 1);
	freq=\pitch.kr(128!1, 0.05, fixedLag:true).midicps;
	res=\q.kr(1!1);

	filters=[
		RLPF.ar(input,freq,res,1,0),
		RHPF.ar(input,freq,res,1,0),
		BPF.ar(input,freq,res,1,0),
		BRF.ar(input,freq,res,1,0),
		BPeakEQ.ar(input,freq,1,res*12,1,0)
	];

	filtered=Select.ar(\type.kr(0!1),filters);
	Out.ar(out, filtered);
}).writeDefFile(d);
)


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


(//distortion
SynthDef.new(\distort, {
	arg in, out=0;
	var input,distort,distortions,type,sig,wet,dry,distamp,tp;
	input = In.ar(in, 78);

	distamp=(\pregain.kr(0.2!78, 0.1, fixedLag:true).pow(2)*80); //param1 preGain

	distortions=[
		(input*distamp).distort,
		(input*distamp).softclip,
		(input*distamp).clip2,
		(input*distamp).fold2,
		(input*distamp).wrap2,
		(1 + (2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1)))) * input / (1 + ((2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1))) * input.abs));
	];

	tp=\type.kr(0!78); //param2 Type
	distort=Select.ar(tp,distortions);

	wet=\mix.kr(0!78, 0.1, fixedLag:true); //param3 Mix
	dry=1-wet;
	sig=(input*dry)+(distort*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//distortion
SynthDef.new(\distort13, {
	arg in, out=0;
	var input,distort,distortions,type,sig,wet,dry,distamp,tp;
	input = In.ar(in, 13);

	distamp=(\pregain.kr(0.2!13, 0.1, fixedLag:true).pow(2)*80); //param1 preGain

	distortions=[
		(input*distamp).distort,
		(input*distamp).softclip,
		(input*distamp).clip2,
		(input*distamp).fold2,
		(input*distamp).wrap2,
		(1 + (2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1)))) * input / (1 + ((2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1))) * input.abs));
	];

	tp=\type.kr(0!13); //param2 Type
	distort=Select.ar(tp,distortions);

	wet=\mix.kr(0!13, 0.1, fixedLag:true); //param3 Mix
	dry=1-wet;
	sig=(input*dry)+(distort*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//distortion
SynthDef.new(\distortmono, {
	arg in, out=0;
	var input,distort,distortions,type,sig,wet,dry,distamp,tp;
	input = In.ar(in, 1);

	distamp=(\pregain.kr(0.2!1, 0.1, fixedLag:true).pow(2)*80); //param1 preGain

	distortions=[
		(input*distamp).distort,
		(input*distamp).softclip,
		(input*distamp).clip2,
		(input*distamp).fold2,
		(input*distamp).wrap2,
		(1 + (2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1)))) * input / (1 + ((2 * (((distamp/80)*2)-1) / (1 - (((distamp/80)*2)-1))) * input.abs));
	];

	tp=\type.kr(0!1); //param2 Type
	distort=Select.ar(tp,distortions);

	wet=\mix.kr(0!1, 0.1, fixedLag:true); //param3 Mix
	dry=1-wet;
	sig=(input*dry)+(distort*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// compressor
SynthDef.new(\compressor, {
	arg in, out=0;
	var thresh=0.5,slopeb=1,slopea=1,att=0.01,rel=0.1,make=1;
	var input,sig;
	thresh=\threshold.kr(0.5!78);
	slopeb=\slopebelow.kr(1!78);
	slopea=\slopeabove.kr(1!78);
	att=\attack.kr(0.005!78);
	rel=\release.kr(0.01!78);
	make=\makeup.kr(1!78);
	input = In.ar(in, 78);
	sig=Compander.ar(input,input,thresh,slopeb,slopea,att,rel,1,0)*make;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// compressor 13ch
SynthDef.new(\compressor13, {
	arg in, out=0;
	var thresh=0.5,slopeb=1,slopea=1,att=0.01,rel=0.1,make=1;
	var input,sig;
	thresh=\threshold.kr(0.5!13);
	slopeb=\slopebelow.kr(1!13);
	slopea=\slopeabove.kr(1!13);
	att=\attack.kr(0.005!13);
	rel=\release.kr(0.01!13);
	make=\makeup.kr(1!13);
	input = In.ar(in, 13);
	sig=Compander.ar(input,input,thresh,slopeb,slopea,att,rel,1,0)*make;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// compressor 1ch
SynthDef.new(\compressormono, {
	arg in, out=0;
	var thresh=0.5,slopeb=1,slopea=1,att=0.01,rel=0.1,make=1;
	var input,sig;
	thresh=\threshold.kr(0.5!1);
	slopeb=\slopebelow.kr(1!1);
	slopea=\slopeabove.kr(1!1);
	att=\attack.kr(0.005!1);
	rel=\release.kr(0.01!1);
	make=\makeup.kr(1!1);
	input = In.ar(in, 1);
	sig=Compander.ar(input,input,thresh,slopeb,slopea,att,rel,1,0)*make;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// Limiter
SynthDef.new(\limiter, {
	arg in, out=0,level=1;
	var input,sig;
	input = In.ar(in, 78);
	sig=Limiter.ar(input,level,0.01)*level.reciprocal;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// Limiter 13ch
SynthDef.new(\limiter13, {
	arg in, out=0,level=1;
	var input,sig;
	input = In.ar(in, 13);
	sig=Limiter.ar(input,level,0.01)*level.reciprocal;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// Limiter 1ch
SynthDef.new(\limitermono, {
	arg in, out=0,level=1;
	var input,sig;
	input = In.ar(in, 1);
	sig=Limiter.ar(input,level,0.01)*level.reciprocal;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// sine shaper
SynthDef.new(\sineshaper, {
	arg in, out=0;
	var input,shaped,sig,wet,dry;
	input = In.ar(in, 78);
	shaped=(input*\level.kr(1!78, 0.1, fixedLag:true)).sin;
	wet=\mix.kr(0!78, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(shaped*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// sine shaper
SynthDef.new(\sineshaper13, {
	arg in, out=0;
	var input,shaped,sig,wet,dry;
	input = In.ar(in, 13);
	shaped=(input*\levels.kr(0!13, 0.1, fixedLag:true)).sin;
	wet=\mix.kr(0!13, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(shaped*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// sine shaper
SynthDef.new(\sineshapermono, {
	arg in, out=0;
	var input,shaped,sig,wet,dry;
	input = In.ar(in, 1);
	shaped=(input*\level.kr(1!1, 0.1, fixedLag:true)).sin;
	wet=\mix.kr(0!1, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(shaped*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// ringmod
SynthDef.new(\ringmod, {
	arg in, out=0;
	var input,modulated,sig,wet,dry,p,amt;
	input = In.ar(in, 78);
	amt=\strength.kr(1!78);
	p=(\pitch.kr(48!78, 0.1, fixedLag:true)).midicps;
	modulated=input*(SinOsc.ar(p,0,1,0)*amt);
	modulated=modulated.tanh;
	wet=\mix.kr(0!78, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(modulated*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// ringmod
SynthDef.new(\ringmod13, {
	arg in, out=0;
	var input,modulated,sig,wet,dry,p,amt;
	input = In.ar(in, 13);
	amt=\strength.kr(1!13);
	p=(\pitch.kr(48!13, 0.1, fixedLag:true)).midicps;
	modulated=input*(SinOsc.ar(p,0,1,0)*amt);
	modulated=modulated.tanh;
	wet=\mix.kr(0!13, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(modulated*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// ringmod
SynthDef.new(\ringmodmono, {
	arg in, out=0;
	var input,modulated,sig,wet,dry,p,amt;
	input = In.ar(in, 1);
	amt=\strength.kr(1!1);
	p=(\pitch.kr(48!1, 0.1, fixedLag:true)).midicps;
	modulated=input*(SinOsc.ar(p,0,1,0)*amt);
	modulated=modulated.tanh;
	wet=\mix.kr(0!1, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(modulated*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// ampmod
SynthDef.new(\ampmod, {
	arg in, out=0;
	var input,modulated,sig,wet,dry,p,amt;
	input = In.ar(in, 78);
	amt=\strength.kr(1!78);
	p=(\pitch.kr(48!78, 0.1, fixedLag:true)).midicps;
	modulated=input*(((SinOsc.ar(p,0,1,0)+1)/2)*amt);
	modulated=modulated.tanh;
	wet=\mix.kr(0!78, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(modulated*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// ampmod
SynthDef.new(\ampmod13, {
	arg in, out=0;
	var input,modulated,sig,wet,dry,p,amt;
	input = In.ar(in, 13);
	amt=\strength.kr(1!13);
	p=(\pitch.kr(48!13, 0.1, fixedLag:true)).midicps;
	modulated=input*(((SinOsc.ar(p,0,1,0)+1)/2)*amt);
	modulated=modulated.tanh;
	wet=\mix.kr(0!13, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(modulated*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//// ampmod
SynthDef.new(\ampmodmono, {
	arg in, out=0;
	var input,modulated,sig,wet,dry,p,amt;
	input = In.ar(in, 1);
	amt=\strength.kr(1!1);
	p=(\pitch.kr(48!1, 0.1, fixedLag:true)).midicps;
	modulated=input*(((SinOsc.ar(p,0,1,0)+1)/2)*amt);
	modulated=modulated.tanh;
	wet=\mix.kr(0!1, 0.1, fixedLag:true);
	dry=1-wet;
	sig=(input*dry)+(modulated*wet);
	Out.ar(out, sig);
}).writeDefFile(d);
)


(//reverb 2
SynthDef(\reverb2, {
	arg in, out=0;
	var predel,revtime,lpf,hpf,mx,amp=1,dry,wet,temp,sig;
	predel=\predelay.kr(1!78);
	revtime=\time.kr(4!78);
	lpf=\lowpass.kr(100!78).midicps;
	hpf=\hipass.kr(12!78).midicps;
	mx=\mix.kr(0!78);

	dry = In.ar(in, 78);
	temp= In.ar(in, 78);

	wet=0;
	temp=DelayN.ar(temp, 1!78, predel);
	32.do {temp=AllpassL.ar(temp, 0.05!78, {Rand(0.001,0.05)}!78,revtime);
		temp=LPF.ar(temp,lpf);
		temp=HPF.ar(temp,hpf);
		wet=wet+temp;
	};
	sig=(dry*(1-mx))+(wet*mx);
	Out.ar(out,sig);
}).writeDefFile(d);
)

(//reverb 13ch
SynthDef(\reverb13, {
	arg in, out=0;
	var predel,revtime,lpf,hpf,mx,amp=1,dry,wet,temp,sig;
	predel=\predelay.kr(1!13);
	revtime=\time.kr(4!13);
	lpf=\lowpass.kr(100!13).midicps;
	hpf=\hipass.kr(12!13).midicps;
	mx=\mix.kr(0!13);

	dry = In.ar(in, 13);
	temp= In.ar(in, 13);

	wet=0;
	temp=DelayN.ar(temp, 1!13, predel);
	32.do {temp=AllpassL.ar(temp, 0.05!13, {Rand(0.001,0.05)}!13,revtime);
		temp=LPF.ar(temp,lpf);
		temp=HPF.ar(temp,hpf);
		wet=wet+temp;
	};
	sig=(dry*(1-mx))+(wet*mx);
	Out.ar(out,sig);
}).writeDefFile(d);
)

(//reverb 13ch
SynthDef(\reverbmono, {
	arg in, out=0;
	var predel,revtime,lpf,hpf,mx,amp=1,dry,wet,temp,sig;
	predel=\predelay.kr(1!1);
	revtime=\time.kr(4!1);
	lpf=\lowpass.kr(100!1).midicps;
	hpf=\hipass.kr(12!1).midicps;
	mx=\mix.kr(0!1);

	dry = In.ar(in, 1);
	temp= In.ar(in, 1);

	wet=0;
	temp=DelayN.ar(temp, 1!1, predel);
	32.do {temp=AllpassL.ar(temp, 0.05!1, {Rand(0.001,0.05)}!1,revtime);
		temp=LPF.ar(temp,lpf);
		temp=HPF.ar(temp,hpf);
		wet=wet+temp;
	};
	sig=(dry*(1-mx))+(wet*mx);
	Out.ar(out,sig);
}).writeDefFile(d);
)

(// echofeed
SynthDef(\echo,{
	arg in=0, out=0;
	var filters=0,fb,del,cut,res,selfilt,sig,mx,dry,feedback,wet,ing;
	fb=\feed.kr(0.5!78);
	del=\delay.kr(0.2!78, 1/30, fixedLag:true);
	cut=\cutoff.kr(60!78).midicps;
	res=\resonance.kr(0.2!78);
	selfilt=\filtertype.kr(0!78);
	mx=\mix.kr(0!78);
	ing=\inputgain.kr(1!78);

	dry = In.ar(in, 78);
	feedback = LocalIn.ar(78);
	wet = LeakDC.ar(feedback*fb + (dry*ing));

	filters=[
		RLPF.ar(wet,cut,1-res,1,0),
		RHPF.ar(wet,cut,1-res,1,0),
		BPF.ar(wet,cut,1-res,1,0),
		BPeakEQ.ar(wet,cut,1,res*12,1,0)
	];

	wet=Select.ar(selfilt,filters);
	LocalOut.ar(DelayC.ar(wet, 2, del));

	sig=XFade2.ar(dry,wet,mx*2-1,1!78);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// echofeed 13ch
SynthDef(\echo13,{
	arg in=0, out=0;
	var filters=0,fb,del,cut,res,selfilt,sig,mx,dry,feedback,wet,ing;
	fb=\feed.kr(0.5!13);
	del=\delay.kr(0.2!13, 1/30, fixedLag:true);
	cut=\cutoff.kr(60!13, 1/30, fixedLag:true).midicps;
	res=\resonance.kr(0.2!13);
	selfilt=\filtertype.kr(0!13);
	mx=\mix.kr(0!13);
	ing=\inputgain.kr(1!13, 1/30, fixedLag:true);

	dry = In.ar(in, 13);
	feedback = LocalIn.ar(13);
	wet = LeakDC.ar(feedback*fb + (dry*ing));

	filters=[
		RLPF.ar(wet,cut,1-res,1,0),
		RHPF.ar(wet,cut,1-res,1,0),
		BPF.ar(wet,cut,1-res,1,0),
		BPeakEQ.ar(wet,cut,1,res*12,1,0)
	];

	wet=Select.ar(selfilt,filters);
	LocalOut.ar(DelayC.ar(wet, 2, del));

	sig=XFade2.ar(dry,wet,mx*2-1,1!13);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(// echofeed 1ch
SynthDef(\echomono,{
	arg in=0, out=0;
	var filters=0,fb,del,cut,res,selfilt,sig,mx,dry,feedback,wet,ing;
	fb=\feed.kr(0.5!1);
	del=\delay.kr(0.2!1, 1/30, fixedLag:true);
	cut=\cutoff.kr(60!1, 1/30, fixedLag:true).midicps;
	res=\resonance.kr(0.2!1);
	selfilt=\filtertype.kr(0!1);
	mx=\mix.kr(0!1);
	ing=\inputgain.kr(1!1, 1/30, fixedLag:true);

	dry = In.ar(in, 1);
	feedback = LocalIn.ar(1);
	wet = LeakDC.ar(feedback*fb + (dry*ing));

	filters=[
		RLPF.ar(wet,cut,1-res,1,0),
		RHPF.ar(wet,cut,1-res,1,0),
		BPF.ar(wet,cut,1-res,1,0),
		BPeakEQ.ar(wet,cut,1,res*12,1,0)
	];

	wet=Select.ar(selfilt,filters);
	LocalOut.ar(DelayC.ar(wet, 2, del));

	sig=XFade2.ar(dry,wet,mx*2-1,1!1);
	Out.ar(out, sig);
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

(//phaser
SynthDef(\phaser, {
	arg out=0, in=0;
	var input,dsig, sig,freq,mx;
	freq=\frequency.kr(2!78);
	mx=\mix.kr(0!78);
	input = In.ar(in, 78);
	dsig = AllpassL.ar(input, 4, SinOsc.ar(freq, 0, 0.005, 0.005), 0);
	sig=(input*(1-mx))+(dsig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//phaser
SynthDef(\phaser13, {
	arg out=0, in=0;
	var input,dsig, sig,freq,mx;
	freq=\frequency.kr(2!13);
	mx=\mix.kr(0!13);
	input = In.ar(in, 13);
	dsig = AllpassL.ar(input, 4, SinOsc.ar(freq, 0, 0.005, 0.005), 0);
	sig=(input*(1-mx))+(dsig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//phaser
SynthDef(\phasermono, {
	arg out=0, in=0;
	var input,dsig, sig,freq,mx;
	freq=\frequency.kr(2!1);
	mx=\mix.kr(0!1);
	input = In.ar(in, 1);
	dsig = AllpassL.ar(input, 4, SinOsc.ar(freq, 0, 0.005, 0.005), 0);
	sig=(input*(1-mx))+(dsig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//chorus
SynthDef(\chorus, {
	arg out, in, amp = 1, loDelay = 0.001, hiDelay = 0.005,
	maxDelayTime = 0.1, mx;
	var sig, dry, freq, inSig;

	inSig = In.ar(in, 78);
	dry=In.ar(in, 78);
	mx=\mix.kr(0!78);
	freq=\frequency.kr(1!78);
	inSig = Mix.fill(10, { |i|
		DelayL.ar(inSig, maxDelayTime, LFDNoise3.ar(freq).range(loDelay, hiDelay))
	});
	inSig=inSig/2;
	sig=(dry*(1-mx))+(inSig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//chorus
SynthDef(\chorus13, {
	arg out, in, amp = 1, loDelay = 0.001, hiDelay = 0.005,
	maxDelayTime = 0.1, mx;
	var sig, dry, freq, inSig;

	inSig = In.ar(in, 13);
	dry=In.ar(in, 13);
	mx=\mix.kr(0!13);
	freq=\frequency.kr(1!13);
	inSig = Mix.fill(10, { |i|
		DelayL.ar(inSig, maxDelayTime, LFDNoise3.ar(freq).range(loDelay, hiDelay))
	});
	inSig=inSig/2;
	sig=(dry*(1-mx))+(inSig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//chorus
SynthDef(\chorusmono, {
	arg out, in, amp = 1, loDelay = 0.001, hiDelay = 0.005,
	maxDelayTime = 0.1, mx;
	var sig, dry, freq, inSig;

	inSig = In.ar(in, 1);
	dry=In.ar(in, 1);
	mx=\mix.kr(0!1);
	freq=\frequency.kr(1!1);
	inSig = Mix.fill(10, { |i|
		DelayL.ar(inSig, maxDelayTime, LFDNoise3.ar(freq).range(loDelay, hiDelay))
	});
	inSig=inSig/2;
	sig=(dry*(1-mx))+(inSig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(///// eq
SynthDef(\eq, {
	arg in, out=0;
	var lofreq=80, midlofreq=300, midfreq=800, midhifreq=2000, hifreq=4000, band1=0, band2=0, band3=0,band4=0,band5=0;
	var dry, wet;

	lofreq=\lowf.kr(80!78);
	midlofreq=\midlowf.kr(300!78);
	midfreq=\midf.kr(800!78);
	midhifreq=\midhighf.kr(2000!78);
	hifreq=\highf.kr(4000!78);

	band1=\lowdb.kr(0!78);
	band2=\midlowdb.kr(0!78);
	band3=\middb.kr(0!78);
	band4=\midhighdb.kr(0!78);
	band5=\highdb.kr(0!78);

	dry = In.ar(in, 78);

	wet = BLowShelf.ar(dry, lofreq, 1, band1);
	wet = BPeakEQ.ar(wet, midlofreq, 1, band2);
	wet = BPeakEQ.ar(wet, midfreq, 1, band3);
	wet = BPeakEQ.ar(wet, midhifreq, 1, band4);
	wet = BHiShelf.ar(wet, hifreq, 1, band5);
	wet.tanh;
	Out.ar(out, wet);
}).writeDefFile(d);
)

(///// eq
SynthDef(\eq13, {
	arg in, out=0;
	var lofreq=80, midlofreq=300, midfreq=800, midhifreq=2000, hifreq=4000, band1=0, band2=0, band3=0,band4=0,band5=0;
	var dry, wet;

	lofreq=\lowf.kr(80!13);
	midlofreq=\midlowf.kr(300!13);
	midfreq=\midf.kr(800!13);
	midhifreq=\midhighf.kr(2000!13);
	hifreq=\highf.kr(4000!13);

	band1=\lowdb.kr(0!13);
	band2=\midlowdb.kr(0!13);
	band3=\middb.kr(0!13);
	band4=\midhighdb.kr(0!13);
	band5=\highdb.kr(0!13);

	dry = In.ar(in, 13);

	wet = BLowShelf.ar(dry, lofreq, 1, band1);
	wet = BPeakEQ.ar(wet, midlofreq, 1, band2);
	wet = BPeakEQ.ar(wet, midfreq, 1, band3);
	wet = BPeakEQ.ar(wet, midhifreq, 1, band4);
	wet = BHiShelf.ar(wet, hifreq, 1, band5);
	wet.tanh;
	Out.ar(out, wet);
}).writeDefFile(d);
)

(///// eq
SynthDef(\eqmono, {
	arg in, out=0;
	var lofreq=80, midlofreq=300, midfreq=800, midhifreq=2000, hifreq=4000, band1=0, band2=0, band3=0,band4=0,band5=0;
	var dry, wet;

	lofreq=\lowf.kr(80!1);
	midlofreq=\midlowf.kr(300!1);
	midfreq=\midf.kr(800!1);
	midhifreq=\midhighf.kr(2000!1);
	hifreq=\highf.kr(4000!1);

	band1=\lowdb.kr(0!1);
	band2=\midlowdb.kr(0!1);
	band3=\middb.kr(0!1);
	band4=\midhighdb.kr(0!1);
	band5=\highdb.kr(0!1);

	dry = In.ar(in, 1);

	wet = BLowShelf.ar(dry, lofreq, 1, band1);
	wet = BPeakEQ.ar(wet, midlofreq, 1, band2);
	wet = BPeakEQ.ar(wet, midfreq, 1, band3);
	wet = BPeakEQ.ar(wet, midhifreq, 1, band4);
	wet = BHiShelf.ar(wet, hifreq, 1, band5);
	wet.tanh;
	Out.ar(out, wet);
}).writeDefFile(d);
)

(/// multiplier
SynthDef.new(\multiplier, {
	arg in, out=0;
	var input,mult1,mult2,mult3,mult4,sig;
	input = In.ar(in, 78);
	mult1=\mul1.kr(1!78, 1/30, fixedLag:true);
	mult2=\mul2.kr(1!78, 1/30, fixedLag:true);
	mult3=\mul3.kr(1!78, 1/30, fixedLag:true);
	mult4=\mul4.kr(1!78, 1/30, fixedLag:true);
	sig=input*mult1*mult2*mult3*mult4;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// multiplier
SynthDef.new(\multiplier13, {
	arg in, out=0;
	var input,mult1,mult2,mult3,mult4,sig;
	input = In.ar(in, 13);
	mult1=\mul1.kr(1!13, 1/30, fixedLag:true);
	mult2=\mul2.kr(1!13, 1/30, fixedLag:true);
	mult3=\mul3.kr(1!13, 1/30, fixedLag:true);
	mult4=\mul4.kr(1!13, 1/30, fixedLag:true);
	sig=input*mult1*mult2*mult3*mult4;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// multiplier
SynthDef.new(\multipliermono, {
	arg in, out=0;
	var input,mult1,mult2,mult3,mult4,sig;
	input = In.ar(in, 1);
	mult1=\mul1.kr(1!1, 1/30, fixedLag:true);
	mult2=\mul2.kr(1!1, 1/30, fixedLag:true);
	mult3=\mul3.kr(1!1, 1/30, fixedLag:true);
	mult4=\mul4.kr(1!1, 1/30, fixedLag:true);
	sig=input*mult1*mult2*mult3*mult4;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//stereo downmixer
SynthDef.new(\stereomix, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 78);
	sig=Splay.ar(sig,1,1,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//stereo downmixer
SynthDef.new(\stereomix13, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 13);
	sig=Splay.ar(sig,1,1,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// output generator
SynthDef.new(\output, {
	arg in = 0, out=0;
	var sig;
	sig = In.ar(in, 13);
	sig=LeakDC.ar(sig);
	sig=Sanitize.ar(sig);
	sig = DelayN.ar(sig, 5, \delay.kr(0));
	Out.ar(out, sig.tanh * \levels.kr(0));
}).writeDefFile(d);
)

(//// mixer
SynthDef.new(\mixer, {
	arg in=0, in2=0, out=0;
	var sig1, sig2, finalsig;
	sig1 = In.ar(in, 78)*\levels1.kr(0.5!78, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 78)*\levels2.kr(0.5!78, 1/30, fixedLag:true);
	finalsig=sig1+sig2;
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

(//// mixer
SynthDef.new(\mixer13, {
	arg in=0, in2=0, out=0;
	var sig1, sig2, finalsig;
	sig1 = In.ar(in, 13)*\levels1.kr(0.5!13, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 13)*\levels2.kr(0.5!13, 1/30, fixedLag:true);
	finalsig=sig1+sig2;
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

(//// mixer
SynthDef.new(\mixermono, {
	arg in=0, in2=0, out=0;
	var sig1, sig2, finalsig;
	sig1 = In.ar(in, 1)*\levels1.kr(0.5!1, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 1)*\levels2.kr(0.5!1, 1/30, fixedLag:true);
	finalsig=sig1+sig2;
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

(//// polymixer
SynthDef.new(\polymixer, {
	arg in=0, in2=0, in3=0, in4=0, in5=0, in6=0, in7=0, in8=0, out=0;
	var sig1, sig2, sig3,sig4,sig5,sig6,sig7,sig8, finalsig;
	sig1 = In.ar(in, 78)*\levels1.kr(0.5!78, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 78)*\levels2.kr(0.5!78, 1/30, fixedLag:true);
	sig3 = In.ar(in3, 78)*\levels3.kr(0.5!78, 1/30, fixedLag:true);
	sig4 = In.ar(in4, 78)*\levels4.kr(0.5!78, 1/30, fixedLag:true);
	sig5 = In.ar(in5, 78)*\levels5.kr(0.5!78, 1/30, fixedLag:true);
	sig6 = In.ar(in6, 78)*\levels6.kr(0.5!78, 1/30, fixedLag:true);
	sig7 = In.ar(in7, 78)*\levels7.kr(0.5!78, 1/30, fixedLag:true);
	sig8 = In.ar(in8, 78)*\levels8.kr(0.5!78, 1/30, fixedLag:true);
	finalsig=sig1+sig2+sig3+sig4+sig5+sig6+sig7+sig8;
	finalsig=finalsig*\masterlevel.kr(1!78, 1/30, fixedLag:true);
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

(//// polymixer
SynthDef.new(\polymixer13, {
	arg in=0, in2=0, in3=0, in4=0, in5=0, in6=0, in7=0, in8=0, out=0;
	var sig1, sig2, sig3,sig4,sig5,sig6,sig7,sig8, finalsig;
	sig1 = In.ar(in, 13)*\levels1.kr(0.5!13, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 13)*\levels2.kr(0.5!13, 1/30, fixedLag:true);
	sig3 = In.ar(in3, 13)*\levels3.kr(0.5!13, 1/30, fixedLag:true);
	sig4 = In.ar(in4, 13)*\levels4.kr(0.5!13, 1/30, fixedLag:true);
	sig5 = In.ar(in5, 13)*\levels5.kr(0.5!13, 1/30, fixedLag:true);
	sig6 = In.ar(in6, 13)*\levels6.kr(0.5!13, 1/30, fixedLag:true);
	sig7 = In.ar(in7, 13)*\levels7.kr(0.5!13, 1/30, fixedLag:true);
	sig8 = In.ar(in8, 13)*\levels8.kr(0.5!13, 1/30, fixedLag:true);
	finalsig=sig1+sig2+sig3+sig4+sig5+sig6+sig7+sig8;
	finalsig=finalsig*\masterlevel.kr(1!13, 1/30, fixedLag:true);
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

(//// polymixer
SynthDef.new(\polymixermono, {
	arg in=0, in2=0, in3=0, in4=0, in5=0, in6=0, in7=0, in8=0, out=0;
	var sig1, sig2, sig3,sig4,sig5,sig6,sig7,sig8, finalsig;
	sig1 = In.ar(in, 1)*\levels1.kr(0.5!1, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 1)*\levels2.kr(0.5!1, 1/30, fixedLag:true);
	sig3 = In.ar(in3, 1)*\levels3.kr(0.5!1, 1/30, fixedLag:true);
	sig4 = In.ar(in4, 1)*\levels4.kr(0.5!1, 1/30, fixedLag:true);
	sig5 = In.ar(in5, 1)*\levels5.kr(0.5!1, 1/30, fixedLag:true);
	sig6 = In.ar(in6, 1)*\levels6.kr(0.5!1, 1/30, fixedLag:true);
	sig7 = In.ar(in7, 1)*\levels7.kr(0.5!1, 1/30, fixedLag:true);
	sig8 = In.ar(in8, 1)*\levels8.kr(0.5!1, 1/30, fixedLag:true);
	finalsig=sig1+sig2+sig3+sig4+sig5+sig6+sig7+sig8;
	finalsig=finalsig*\masterlevel.kr(1!1, 1/30, fixedLag:true);
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

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

(//campaneitor
SynthDef.new(\campaneitorsignes, {
	arg in, out=0;
	var sig, spr=1,lvl=1,wdth=2,cnt=0,orient=0.5, pos;
	// spr=\spread.kr(1);
	lvl=\level.kr(1);
	wdth=\width.kr(2);
	// cnt=\center.kr(0.5);
	// pos=\position.kr(0.5!26);
	orient=\orientation.kr(0.5);
	sig = In.ar(in, 78);
	sig = sig.asArray.reshape(3,26);
	sig = Mix.ar(sig);

	pos = [0.0] ++ [0, 5.5/12].resamp1(12) ++ [6.5/12, 1].resamp1(12) ++ [1.0];
	sig = PanX.ar(13, sig, pos, lvl*sig.size.reciprocal.sqrt, wdth).flop.collect(Mix(_));
	// sig = PanX.ar(13, sig, [ cnt - spr, cnt + spr ].resamp1(78), lvl*sig.size.reciprocal.sqrt, wdth).flop.collect(Mix(_));
	// sig=SplayAz.ar(13,sig.asArray,spr,lvl,wdth,cnt,orient);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//Panner 13chan
SynthDef.new(\panner13, {
	arg in, out=0;
	var sig, pos=1,lvl=1,wdth=2,orient=0.5;
	pos=\position.kr(0, 1/30, fixedLag:true); //rang 0-26
	lvl=\level.kr(1);
	wdth=\width.kr(2);
	// orient=\orientation.kr(0.5);
	sig = In.ar(in, 1);
	sig=PanX.ar(13,sig,pos,lvl,wdth);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//monoto78
SynthDef.new(\monoto78, {
	arg in, out=0;
	var sig,lvl=1;
	lvl=\level.kr(1!78);
	sig = In.ar(in, 1);
	sig=(sig.dup(78))*lvl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//monoto13
SynthDef.new(\monoto13, {
	arg in, out=0;
	var sig,lvl=1;
	lvl=\level.kr(1!13);
	sig = In.ar(in, 1);
	sig=(sig.dup(13))*lvl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//monoize78
SynthDef.new(\monoize78, {
	arg in, out=0;
	var sig,lvl=1;
	lvl=\level.kr(1, 1/30, fixedLag:true);
	sig = In.ar(in, 78)/78;
	sig=Mix.ar(sig)*lvl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//monoize13
SynthDef.new(\monoize13, {
	arg in, out=0;
	var sig,lvl=1;
	lvl=\level.kr(1, 1/30, fixedLag:true);
	sig = In.ar(in, 13)/13;
	sig=Mix.ar(sig)*lvl;
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//sidechain
SynthDef.new(\sidechain13, {
	arg in=0, in2=0, out, peak;
	var sig, sig2, envf,envfamp,lagtime, att, rel;
	envfamp=\strength.kr(1!13);
	att=\attack.kr(0.001!13);
	rel=\release.kr(0.1!13);
	lagtime=\smooth.kr(0.01!13);

	sig = In.ar(in, 13); //to be sidechained
	sig2 = In.ar(in2, 13); //ctrl signal
	envf=Lag.kr(Amplitude.kr(sig2,att,rel), lagtime);
	envf=(envf*envfamp).clip(0,1);
	envf=1-envf;
	sig=sig*envf;
	Out.ar(out,sig);
}).writeDefFile(d);
)



(
SynthDef.new(\info2, {
	arg in, amp, peak, lagTime = 0.2, decay = 0.99;
	var sig;
	sig = In.ar(in, 2);
	//SendReply.kr(Impulse.kr(3), '/amp', [40, 41, 42, 43], 2);
	//SendReply.kr(Impulse.kr(3), \peak, PeakFollower.kr(sig));
	Out.kr(amp, Lag.kr(Amplitude.kr(sig), lagTime));
	Out.kr(peak, PeakFollower.kr(sig, decay));
}).writeDefFile(d);
)


(
SynthDef.new(\info13, {
	arg in, amp, peak, lagTime = 0.2, decay = 0.99;
	var sig;
	sig = In.ar(in, 13);
	//SendReply.kr(Impulse.kr(3), '/amp', [40, 41, 42, 43], 2);
	//SendReply.kr(Impulse.kr(3), \peak, PeakFollower.kr(sig));
	Out.kr(amp, Lag.kr(Amplitude.kr(sig), lagTime));
	Out.kr(peak, PeakFollower.kr(sig, decay));
}).writeDefFile(d);
)


(
SynthDef.new(\info78, {
	arg in, amp, peak, lagTime = 0.2, decay = 0.99;
	var sig;
	sig = In.ar(in, 78);
	//SendReply.kr(Impulse.kr(3), '/amp', [40, 41, 42, 43], 2);
	//SendReply.kr(Impulse.kr(3), \peak, PeakFollower.kr(sig));
	Out.kr(amp, Lag.kr(Amplitude.kr(sig), lagTime));
	Out.kr(peak, PeakFollower.kr(sig, decay));
}).writeDefFile(d);
)

thisProcess.openPorts()

(// delay
SynthDef(\delay,{
	arg in=0, out=0;
	var sig,del,dry;
	del=\delay.kr(1!2, 1/30, fixedLag:true);
	dry = In.ar(in, 2);
	sig=DelayC.ar(dry,24,del);
	Out.ar(out, sig);
}).writeDefFile(d);
)
/////// pendent

FreqShift
PitchShift




