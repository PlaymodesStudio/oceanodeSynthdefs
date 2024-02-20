(
SynthDef(\stutter,{
	arg in=0, out=0;
    var sig, delayTime, increment, trigger;
	var reset=\reset.kr(0);
	var delayPitch=\pitch.kr(12);
	var offsetms=\offsetms.kr(0)/1000;
	var strobe=\strobe.kr(1);
	var envGen, sustainTime;
	var atkTime=0.002, relTime=0.002;

    // Convert pitch to delay time in seconds
    delayTime = delayPitch.midicps.reciprocal;

    // Trigger for incrementing delay time
    trigger = Impulse.ar(delayTime.reciprocal);

	// Calculate sustain time to ensure envelope stays high for the chunk duration minus attack and release
    sustainTime = delayTime - (atkTime + relTime);

    // Ensure sustainTime is not negative
    sustainTime = max(sustainTime, 0)*strobe;

    // Increment delay time
    increment = Dseries(0, delayTime, inf);
    increment = Demand.ar(trigger, reset, increment);

	// Generate an envelope to soften clicks
    envGen = EnvGen.ar(Env([0, 1, 1, 0], [atkTime, sustainTime, relTime], 'lin'), trigger);


    // Get input signal
    sig = In.ar(in, 1); // Assuming stereo input

    // Apply delay
    sig = DelayC.ar(sig, 24, increment+offsetms);

	// Apply envGen
	sig=sig*envGen;

    // Output
    Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\stutter13,{
	arg in=0, out=0;
    var sig, delayTime, increment, trigger;
	var reset=\reset.kr(0!13);
	var delayPitch=\pitch.kr(12!13);
	var offsetms=\offsetms.kr(0!13)/1000;
	var strobe=\strobe.kr(1!13);
	var envGen, sustainTime;
	var atkTime=0.001!13, relTime=0.001!13;

    // Convert pitch to delay time in seconds
    delayTime = delayPitch.midicps.reciprocal;

    // Trigger for incrementing delay time
    trigger = Impulse.ar(delayTime.reciprocal);

	// Calculate sustain time to ensure envelope stays high for the chunk duration minus attack and release
    sustainTime = delayTime - (atkTime + relTime);

    // Ensure sustainTime is not negative
    sustainTime = max(sustainTime, 0)*strobe;

    // Increment delay time
    increment = delayTime.collect { |dt, i|
		Dseries(0, dt, inf).asStream
	};

    increment = Demand.ar(trigger, reset, increment);

	// Generate an envelope to soften clicks
    envGen = EnvGen.ar(Env([0!13, 1, 1, 0], [atkTime, sustainTime, relTime], 'lin'), trigger);


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

