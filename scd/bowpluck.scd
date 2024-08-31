d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\bow13, {
	arg out=0;
	var nch=13;
	var freq=\pitch.kr(36!nch, 1/30,fixedLag:true).midicps,
	amp=\amp.kr(1!nch, 1/30, fixedLag:true), //0-1
	force=\force.kr(0.13!nch, 1/30, fixedLag:true), //0-1
	pos=\pos.kr(0.8!nch, 1/30, fixedLag:true),//0-1
	c1=\invdec.kr(0.25!nch, 1/30, fixedLag:true), //0-10
	c3=\highloss.kr(31!nch, 1/30, fixedLag:true), //0-8000
	impz=\impedance.kr(0.55!nch, 1/30, fixedLag:true), //0.001-32
	fb=\inharm.kr(2!nch, 1/30, fixedLag:true), //0-2000
	lpf=\lpf.kr(90!nch, 1/30, fixedLag:true).midicps,
	vibr=\vibamp.kr(0.003!nch, 1/30, fixedLag:true); //0-999

	var levels=\levels.kr(1!nch, 1/30, fixedLag:true);
    var vib = Gendy1.kr(1,1,1,1,0.1,4,mul:vibr,add:1!nch);
    var son = DWGBowed.ar(freq*vib, amp,force,1,pos,0.1,c1,c3, impz,fb);
    son = DWGSoundBoard.ar(son);
	son = BPF.ar(son,118,1)+son;
    son = BPF.ar(son,430,1)+son;
    son = BPF.ar(son,490,1)+son;
    son = LPF.ar(son,lpf);
	son=LeakDC.ar(son);
	son=Limiter.ar(son);

    Out.ar(out, son*levels);
}).writeDefFile(d);
)

(
SynthDef(\pluck13, {
    arg out=0;
    var nch=13;
    var freq=\pitch.kr(36!nch, 1/30, fixedLag:true).midicps,
    amp=\amp.kr(1!nch, 1/30, fixedLag:true), //0-1
    trig=\trigg.tr(0!nch),
    pos=\pos.kr(0.1!nch, 1/30, fixedLag:true),//0-1
    c1=\invdec.kr(1!nch, 1/30, fixedLag:true), //0-10
    c3=\highloss.kr(3000!nch, 1/30, fixedLag:true), //0-3000
	rel=1000!nch, //si no, s'allibera el sinte
    fB = \inharm.kr(80!nch, 1/30, fixedLag:true), //0-1000
	prelpf=\prelpf.kr(80!nch, 1/30, fixedLag:true).midicps,
	lpf=\lpf.kr(90!nch, 1/30, fixedLag:true).midicps,
	att=\att.kr(0.001/nch, 1/30, fixedLag:true),
	release=\rel.kr(0.0005!nch, 1/30, fixedLag:true);

    var levels=\levels.kr(1!nch, 1/30, fixedLag:true);
    var env = Env.new([0,1, 1, 0],[att,0.006, release],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(prelpf) * EnvGen.ar(env, trig, doneAction:0);
    var son = DWGPluckedStiff.ar(freq, amp, trig, pos, c1, c3, inp, rel, fB);
	son = LPF.ar(son,lpf);
    Out.ar(out, son * levels * 0.2);
}).writeDefFile(d);
)

(
SynthDef(\pluck_in13, {
    arg out=0, in=0;
    var nch=13;
    var freq=\pitch.kr(36!nch, 1/30, fixedLag:true).midicps,
	amp=\amp.kr(1!nch, 1/30, fixedLag:true), //0-1
    pos=\pos.kr(0.1!nch, 1/30, fixedLag:true),//0-1
	trig=\trigg.tr(0!nch),
    c1=\invdec.kr(1!nch, 1/30, fixedLag:true), //0-10
    c3=\highloss.kr(3000!nch, 1/30, fixedLag:true), //0-3000
	rel=1000!nch, //si no, s'allibera el sinte
    fB = \inharm.kr(80!nch, 1/30, fixedLag:true), //0-1000
	prelpf=\prelpf.kr(80!nch, 1/30, fixedLag:true).midicps,
	lpf=\lpf.kr(90!nch, 1/30, fixedLag:true).midicps;

    var levels=\levels.kr(1!nch, 1/30, fixedLag:true);
	var inp = LPF.ar(In.ar(in,nch),prelpf);
    var son = DWGPluckedStiff.ar(freq, amp, trig, pos, c1, c3, inp, rel, fB);
	son = LPF.ar(son,lpf);
    Out.ar(out, son * levels * 0.2);
}).writeDefFile(d);
)

// Create a synth instance
x = Synth(\pluck13);

// Trigger a note
x.set(\trigg, 1, \pitch, 34);

// Release the note
x.set(\trigg, 0);

// Trigger another note
x.set(\trigg, 1, \pitch, 72);

(
SynthDef(\help_dwgplucked, { |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0|
    var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPlucked.ar(freq, amp, gate,0.1,1,c3,inp);
    DetectSilence.ar(son, 0.001, doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;
)

(
SynthDef(\help_dwgplucked, { |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0|
    var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPlucked2.ar(freq, amp, gate,0.1,1,c3,inp);
    DetectSilence.ar(son, 0.001, doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;
)

