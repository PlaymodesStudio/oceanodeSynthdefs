(
~synthCreator.value("Envelope", {|n|
    var type, gate, att, dec, sus, rel, curv, lev, sig, types;
    // Parameters using OceanodeParameter
    type = OceanodeParameterDropdown.kr(\type, 0, n, "ADSR:Perc");
    gate = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
    att = OceanodeParameterLag.ar(\att, 10, n, 0, 5000, "vf", 1/30, true) / 1000.0;
    dec = OceanodeParameterLag.ar(\dec, 10, n, 0, 5000, "vf", 1/30, true) / 1000.0;
    sus = OceanodeParameterLag.ar(\sus, 1, n, 0, 1, "vf", 1/30, true);
    rel = OceanodeParameterLag.ar(\rel, 1000, n, 0, 10000, "vf", 1/30, true) / 1000.0;
    curv = OceanodeParameter.ar(\curve, -4, n, -8, 8, "vf", 1/30, true);
    lev = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true);
    // Define envelope types
    types = [
        EnvGen.ar(Env.adsr(att, dec, sus, rel, lev, curv), gate),
        EnvGen.ar(Env.perc(att, rel, lev, curv), gate)
    ];
    // Select envelope type
    sig = Select.ar(type, types);
    // Output the signal
    Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Envelope generator with ADSR and Perc modes", category: "Modulation/Envelope");
)