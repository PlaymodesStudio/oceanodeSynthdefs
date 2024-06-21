(
SynthDef(\karplushold6, {
	arg out=0;
	var env = \env.kr(1!6, 1/30, fixedLag: true);
	var sustain = \sustain.kr(1!6);
	var amp = \levels.kr(1!6, 1/30, fixedLag: true);
	var freq = \pitch.kr(36!6, 1/30, fixedLag: true).midicps;
	var accent = \accent.kr(0.75!6, 1/30, fixedLag: true);
	var brightness = \brightness.kr(0.15!6, 1/30, fixedLag: true);
	var damping = \damping.kr(0.25!6, 1/30, fixedLag: true);

    var sig = StringVoice.ar(1!6, structure: 0.5, infsustain: sustain, freq: freq, accent: accent, brightness: brightness, damping: damping);

    Out.ar(out, env*sig*amp)
}).writeDefFile(d);
)

(
SynthDef(\karpluspluck6, {
	arg out=0;
	var trig = \trig.kr(1!6, 1/30, fixedLag: true);
	var sustain = \sustain.kr(1!6);
	var dur=\pulsedur.kr(0.01!6, 1/30, fixedLag: true);
	var amp = \levels.kr(1!6, 1/30, fixedLag: true);
	var freq = \pitch.kr(36!6, 1/30, fixedLag: true).midicps;
	var accent = \accent.kr(0.75!6, 1/30, fixedLag: true);
	var brightness = \brightness.kr(0.15!6, 1/30, fixedLag: true);
	var damping = \damping.kr(0.25!6, 1/30, fixedLag: true);
	var env = Env.perc.kr(gate: trig, timeScale:dur);

    var sig = StringVoice.ar(env, structure: 0.5, infsustain: sustain, freq: freq, accent: accent, brightness: brightness, damping: damping);

    Out.ar(out, sig*amp)
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\rongsinator, {|out, amp=0.25, pan=0, sustainTime=0.01, f0=100.05, structure=0.5, brightness=0.5, damping=0.75, accent=0.9, harmonicstretch=0.5, position=0.15, loss=0.15|
    var trig = Trig.kr(1, dur: sustainTime);

    var modeNum=2, cosFreq=0.025;
    var sig = Rongs.ar(
        trigger:trig,
        sustain:trig,
        f0:f0,
        structure:structure,
        brightness:brightness,
        damping:damping,
        accent:accent,
        stretch:harmonicstretch,
        position:position,
        loss:loss,
        modeNum:modeNum,
        cosFreq:cosFreq
    );

    DetectSilence.ar(in: sig, amp: 0.0001, time: 0.1, doneAction: 2);
    sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
}).add;
)

