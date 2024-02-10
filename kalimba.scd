(
SynthDef(\kalimba13, {
    arg out = 0;

    // Named controls with multichannel expansion (13 channels)
    var pitch = \pitch.kr(60!13).midicps; // MIDI pitch to frequency conversion
    var gate = \gate.kr(1!13);            // Gate (trigger) for each channel
    var level = \level.kr(0.1!13);        // Amplitude level for each channel
    var lo = \lo.kr(0.8!13);              // Low EQ parameter for each channel
    var mid = \mid.kr(0.05!13);           // Mid EQ parameter for each channel
    var hi = \hi.kr(0.07!13);             // High EQ parameter for each channel
    var mix = \resomix.kr(0.1!13);        // Resonator mix for each channel

    var snd, resonators, resonatorFreqs, resonatorAmps, resonatorDecays;

    // Basic tone and resonator configuration for each channel
    snd = Array.fill(13, {|i|
        var basicTone, clickNoise, mixedSignal;

        // Basic tone
        basicTone = SinOsc.ar(pitch[i]) * EnvGen.ar(Env.perc(0.005, Rand(2.5, 3.5)), gate[i]);

        // Clicking sounds (resonators)
		clickNoise = PinkNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.01),gate[i]);
		resonatorFreqs = [(pitch[i]/2)*ExpRand(0.9, 1.1), (pitch[i]*5)*ExpRand(0.9, 1.1), (pitch[i]*8)*ExpRand(0.9, 1.1)];
        resonatorAmps = [-7.dbamp, 0.dbamp, 3.dbamp];
        resonatorDecays = [lo[i], mid[i], hi[i]];
        resonators = DynKlank.ar(`[resonatorFreqs, resonatorAmps, resonatorDecays], clickNoise);

        // Correct mix between basic tone and resonators
		mixedSignal = ((resonators*(1-mix))+(basicTone*mix))* level[i]*0.025;
    });

    // Output each channel separately
    Out.ar(out, snd);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;





