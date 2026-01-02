(
~synthCreator.value("Rhodes", {| n|
    var pitch, vel, modIndex, mix, lfoSpeed, lfoDepth, gate, cutoff, rq;
    var env1, env2, env3, env4, envMaster;
    var osc1, osc2, osc3, osc4, snd, freq;
    var trigEnvs;
    var decay;

    // Parameter definitions
    pitch      = OceanodeParameterLag.ar(\pitch, 60, n, 12, 120, "vf", 1/30, true);
    vel        = OceanodeParameterLag.ar(\vel, 0.8, n, 0, 1, "vf", 1/30, true);
    modIndex   = OceanodeParameterLag.ar(\modindex, 0.2, n, 0, 1, "vf", 1/30, true);
    mix        = OceanodeParameterLag.ar(\mix, 0.2, n, 0, 1, "vf", 1/30, true);
    lfoSpeed   = OceanodeParameterLag.ar(\lfospeed, 0.4, n, 0, 1, "vf", 1/30, true);
    lfoDepth   = OceanodeParameterLag.ar(\lfodepth, 0.1, n, 0, 1, "vf", 1/30, true);
    gate       = OceanodeParameterLag.ar(\gate, 0, n, 0, 1, "vi", 1/30, true);
    cutoff     = OceanodeParameterLag.ar(\cutoff, 100, n, 20, 130, "vf", 1/30, true);
    rq         = OceanodeParameterLag.ar(\rq, 0.5, n, 0.1, 1, "vf", 1/30, true);

    // Decay parameter for both master and modulation envelopes
    decay      = OceanodeParameterLag.ar(\decay, 0.1, n, 0.001, 10, "vf", 1/30, true);

    // Convert pitch to frequency (×2 multiplier as in original)
    freq = pitch.midicps * 2;

    // Map LFO speed from 0–1 to 0–12
    lfoSpeed = lfoSpeed * 12;

    // Ensure multichannel expansion
    freq      = freq.asArray;
    vel       = vel.asArray;
    modIndex  = modIndex.asArray;
    mix       = mix.asArray;
    lfoSpeed  = lfoSpeed.asArray;
    lfoDepth  = lfoDepth.asArray;
    gate      = gate.asArray;
    cutoff    = cutoff.asArray;
    rq        = rq.asArray;

    // Convert cutoff from MIDI note to frequency
    cutoff = cutoff.midicps;

    // Create trigger signals from gate changes (assuming proper triggering)
    trigEnvs = Trig.ar(gate, 0.001);

    // Update modulation envelopes to use decay parameter
    env1 = EnvGen.ar(Env([0, 0, 1, 0], [0.001, 0.001, decay * 1.0], \lin), trigEnvs);
    env2 = EnvGen.ar(Env([0, 0, 1, 0], [0.001, 0.001, decay * 0.8], \lin), trigEnvs);
    env3 = EnvGen.ar(Env([0, 0, 1, 0], [0.001, 0.001, decay * 1.2], \lin), trigEnvs);
    env4 = EnvGen.ar(Env([0, 0, 1, 0], [0.001, 0.001, decay * 1.2], \lin), trigEnvs);

    // FM algorithm with multichannel expansion
    osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex * env4 * vel;
    osc3 = SinOsc.ar(freq, osc4) * env3 * vel;
    osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * env2 * vel;
    osc1 = SinOsc.ar(freq, osc2) * env1 * vel;

    // Mix oscillators
    snd = (osc3 * (1 - mix)) + (osc1 * mix);
    snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);

    // Master amplitude envelope with variable decay
    envMaster = EnvGen.ar(Env.perc(0.001, decay), trigEnvs);

    snd = snd * envMaster * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);
    snd = RLPF.ar(snd, cutoff, rq);
    snd = Sanitize.ar(snd);

    Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "FM-based Fender Rhodes electric piano emulation", category: "Source/PhysicalModelling");
)