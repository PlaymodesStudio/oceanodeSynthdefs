(
SynthDef(\paramshaper13, {
    arg in=0, out=0;
	var amount = \amount.kr(0!13, 1/30, fixedLag:true);
	var k = 2 * amount / (1 - amount);
    var dry, wet, sig;
    var level = \level.kr(1!13);    // Range: 0 to 1. Adjusts output level of wet signal
    var mix = \mix.kr(1!13);        // Range: 0 to 1. 0 = dry, 1 = wet

    dry = In.ar(in, 13);
    wet = (1 + k) * dry / (1 + (k * dry.abs));
    sig = XFade2.ar(dry, wet, mix*2-1);

    Out.ar(out, sig*level);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\sigmoidshaper13, {
    arg in=0, out=0;
    var steep = \steep.kr(0.5!13, 1/30, fixedLag:true);  // Range: -1 to 1
    var inflec = \inflec.kr(0.5!13, 1/30, fixedLag:true);  // Range: -1 to 1
    var level = \level.kr(1!13);    // Range: 0 to 1. Adjusts output level of wet signal
    var mix = \mix.kr(1!13);        // Range: 0 to 1. 0 = dry, 1 = wet
    var dry, wet, sig;

    dry = In.ar(in, 13);

    wet = { |ph, steep, inflec|
        var y = (((inflec * (steep - 1) * ((ph / inflec) - 1)) /
                 ((4 * steep) * (ph - inflec).abs - steep - 1)) +
                 ((inflec * (steep - 1)) / ((4 * inflec * steep) - steep - 1))) /
                (((inflec * (steep - 1) * ((1 / inflec) - 1)) /
                 ((4 * steep) * (1 - inflec).abs - steep - 1)) +
                 ((inflec * (steep - 1)) / ((4 * inflec * steep) - steep - 1)));
        y.clip(0, 1)  // Ensure output is between 0 and 1
    }.value(dry, steep, inflec);

    sig = XFade2.ar(dry, wet, mix*2-1);
    Out.ar(out, sig * level);
}).add;
)