(
~synthCreator.value("Celesta", {|n|
    var pitch, brightness, strike, hardness, resonance, levels, gate;
    var sig, beamRatios, amps, decays;

    // Parameters
    pitch = OceanodeParameterLag.ar(\pitch, 60, n, 0, 127, "vf", 1/30, true);
    brightness = OceanodeParameter.ar(\brightness, 0.5, n, 0, 1, "vf");
    strike = OceanodeParameter.ar(\strike, 0.25, n, 0, 1, "vf");
    hardness = OceanodeParameter.ar(\hardness, 0.6, n, 0, 1, "vf");
    resonance = OceanodeParameter.ar(\resonance, 0.7, n, 0, 1, "vf");
    gate = OceanodeParameter.ar(\gate, 0, n, 0, 1, "vi");
    levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

    // Simplified modal ratios
    beamRatios = [1.0, 2.76, 5.4, 8.93, 13.34, 18.64];

    // Simple amplitude distribution
    amps = [1.0, 0.4, 0.15, 0.08, 0.04, 0.02];

    // Decay times
    decays = [3.0, 2.5, 2.0, 1.5, 1.0, 0.8];

    // Generate signal for each channel
    sig = n.collect({ |chan|
        var chanPitch = pitch[chan].midicps;
        var chanGate = gate[chan];
        var chanStrike = strike[chan];
        var chanBrightness = brightness[chan];
        var chanResonance = resonance[chan];
        var chanHardness = hardness[chan];

        // Simple but reliable excitation
        var exciter = WhiteNoise.ar() * EnvGen.ar(
            Env.perc(0.001, 0.01),
            chanGate,
            doneAction: 0
        );

        // Adjust amplitudes based on strike position
        var strikeAmps = amps.collect({ |amp, i|
            var modeNum = i + 1;
            var strikeEffect = sin(pi * modeNum * chanStrike).abs.max(0.1);
            amp * strikeEffect * chanBrightness.linlin(0, 1, 0.5, 1)
        });

        // Adjust decays based on resonance
        var resoDecays = decays * chanResonance.linlin(0, 1, 0.5, 2.0);

        // Modal resonator
        var modalSig = DynKlank.ar(
            `[
                beamRatios,
                strikeAmps * chanHardness.linlin(0, 1, 0.5, 1.5),
                resoDecays
            ],
            exciter,
            freqscale: chanPitch
        );

        // Simple filtering
        modalSig = LPF.ar(modalSig, 8000);

        modalSig * levels[chan]
    });

    // Simple output
    Out.ar(OceanodeOutput.kr(\out), sig * 0.3);

}, description: "Realistic celesta using modal synthesis", category: "Source/PhysicalModelling");
)