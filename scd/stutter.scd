(
SynthDef(\stutter13,{
	arg in=0, out=0;
    var sig, delayTime, increment, trigger;
	var reset=\reset.kr(0);
	var delayPitch=\pitch.kr(12);
	var offsetms=\offsetms.kr(0, 1/30, fixedLag: true)/1000;
	var strobe=\gatepw.kr(1);
	var on=\onoff.kr(0);
	var envGen, sustainTime;
	var atkTime=0.002, relTime=0.002;

	reset=reset*on;
    // Convert pitch to delay time in seconds
    delayTime = delayPitch.midicps.reciprocal;

    // Trigger for incrementing delay time
    trigger = Impulse.ar(delayTime.reciprocal);

	// Calculate sustain time to ensure envelope stays high for the chunk duration minus attack and release
    sustainTime = delayTime - (atkTime + relTime);

    // Ensure sustainTime is not negative
    sustainTime = max(sustainTime, 0)*strobe;

    // Increment delay time
    increment = Dseries(0, delayTime, inf)*on;
    increment = Demand.ar(trigger, reset, increment);

	// Generate an envelope to soften clicks
    envGen = EnvGen.ar(Env([0, 1, 1, 0], [atkTime, sustainTime, relTime], 'lin'), trigger);


    // Get input signal
    sig = In.ar(in, 13); // Assuming stereo input

    // Apply delay
    sig = DelayC.ar(sig, 24, increment+offsetms);

	// Apply envGen
	sig=sig*envGen;

    // Output
    Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


//eli fieldsteel solution
s.boot;

// using built-in sample as source sound
b = Buffer.read(s, Platform.resourceDir ++ "/sounds/a11wlk01.wav");

// empty 5 sec buffer for loop record/playback
~b = Buffer.alloc(s, s.sampleRate * 5, 1);

(
SynthDef(\stutter, {
	arg in=0, out=0;
	var b;
	var sig, insig, trigger, delayTime;
	var delayPitch = \pitch.kr(12!3);
	var buf = LocalBuf.new(44100,1);

	// source signal — can be replaced with In/SoundIn or whatever
	//insig = PlayBuf.ar(1, b, BufRateScale.ir(b), loop:1) * 0.2;
	insig = SoundIn.ar(0);

	// calculate delay times and trigger signal
	delayTime = delayPitch.midicps.reciprocal;
	trigger = Impulse.ar(delayTime.reciprocal);

	// record source to empty buffer
	RecordBuf.ar(insig, buf, loop: 0);

	// loop playback specific chunk of recorded audio
	sig = PlayBuf.ar(1, buf, 1, trigger, MouseX.kr(0,BufFrames.kr(buf)));

	// mix 12 channels down to 2 so all channels are audible
	sig = Splay.ar(sig);

	// output
	Out.ar(out, sig);
}).add;
)

x = Synth(\stutter, [pitch: [-10,2,4]]);

x.free;

/////

(
SynthDef(\stutter, {
	arg in=0, out=0;
	var sig, insig, trigger, delayTime;
	var delayPitch = \pitch.kr(12!3);
	var buf = LocalBuf.new(SampleRate.ir / 20, 1);

	insig = PinkNoise.ar(0.1);
	delayTime = delayPitch.midicps.reciprocal;
	trigger = Impulse.ar(delayTime.reciprocal);
	RecordBuf.ar(insig, buf, loop: 0);
	sig = PlayBuf.ar(1, buf, 1, MouseY.kr > 0.5, MouseX.kr(0, BufFrames.kr(buf)));
	sig = Splay.ar(sig);
	Out.ar(out, sig);
}).add;
)

x = Synth(\stutter, [pitch: [55, 65, 75]]);

x.set(\pitch, [53, 62, 70]);

x.free;