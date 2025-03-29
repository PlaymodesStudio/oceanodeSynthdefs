(
~synthCreator.value("Kalimba", {|n|
    var pitch, gate, level, lo, mid, hi, resoMix;
    var sig;
	var snd, resonators, resonatorFreqs, resonatorAmps, resonatorDecays, mix;

    // Parameters with lag for smooth transitions
    pitch = OceanodeParameter.kr(\pitch, 60, n, 0, 130, "vf").midicps;
    gate = OceanodeParameter.kr(\gate, 0, n, 0, 1, "vi");
    level = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    lo = OceanodeParameter.kr(\lo, 0.8, n, 0, 1, "vf");
    mid = OceanodeParameter.kr(\mid, 0.05, n, 0, 1, "vf");
    hi = OceanodeParameter.kr(\hi, 0.07, n, 0, 1, "vf");
    resoMix = OceanodeParameter.kr(\resomix, 0.1, n, 0, 1, "vf");

     snd = Array.fill(n, {|i|
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
		mixedSignal = ((resonators*(1-resoMix[i]))+(basicTone*resoMix[i]))* level[i]*0.2;    });

    // Output the signal
    Out.ar(OceanodeOutput.kr(\out), snd);

}, description: "Kalimba physical model with adjustable tonal characteristics", category: "Source/PhysicalModelling");
)
