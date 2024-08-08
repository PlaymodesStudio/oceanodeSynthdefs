SynthDef(\beatrepeat13, {
    arg in=0, out=0;
    var insig, gatedInsig, delayedSig, finalSig, delayTime, increment, trigger;
    var reset = \reset.kr(0);
    var delayMs = \delay.kr(100!13);  // New parameter for delay time in milliseconds
    var offsetms = \offsetms.kr(0);
    var gatepw = \gatepw.kr(1);
    var on = \onoff.kr(0);
    var envGen, sustainTime;
    var atkTime = 0.002, relTime = 0.002;

    reset = reset * on;

    // Convert milliseconds to seconds
    delayTime = delayMs / 1000;

    // Trigger for incrementing delay time and envelope
    trigger = Impulse.ar(delayTime.reciprocal);

    // Calculate sustain time to ensure envelope stays high for the chunk duration minus attack and release
    sustainTime = delayTime - (atkTime + relTime);

    // Ensure sustainTime is not negative
    sustainTime = max(sustainTime, 0) * gatepw;

    // Generate an envelope to soften clicks
    envGen = EnvGen.ar(Env([0, 1, 1, 0], [atkTime, sustainTime, relTime], 'lin'), trigger);

    // Get input signal
    insig = In.ar(in, 13); // Assuming 13-channel input

    // Apply gate to input signal
    gatedInsig = insig * envGen;

    // Increment delay time
    increment = Dseries(0, delayTime, inf) * on;
    increment = (Demand.ar(trigger, reset, increment))!13;

    // Apply delay to gated input signal (note: offsetms is now in milliseconds)
    delayedSig = DelayC.ar(gatedInsig, 24, increment + (offsetms/1000));

    // Mix the gated input and delayed gated signal based on the 'on' parameter
    finalSig = (delayedSig * on) + (insig * (1 - on));

    // Output
    Out.ar(out, finalSig);
}).writeDefFile(d);

d = thisProcess.nowExecutingPath.dirname;
