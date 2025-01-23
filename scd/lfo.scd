d = thisProcess.nowExecutingPath.dirname;


(
SynthDef.new(\lfo13, {
	arg out;
	var p, ph, waves, pulsew, finalSig, poww, bipow;
	var k1, k2, k3;

	ph=\phoff.kr(0!13, 1/30, fixedLag: true);
	p = \hz.kr(1!13, 1/30, fixedLag: true);
	pulsew = \pw.kr(0!13, 1/30, fixedLag: true);
	poww = \pow.kr(1!13, 1/30, fixedLag: true);
	bipow = \bipow.kr(0!13, 1/30, fixedLag: true);

	waves = [
		(((((LFSaw.ar(p)+1)/2)+ph)%1)*2)-1,
		SinOsc.ar(p, ph),
		LFTri.ar(p, ph),
		LFPulse.ar(p, ph, (pulsew + 0.5) % 1),
		LFDNoise3.ar(p)
	];

	finalSig = SelectX.ar(\shape.kr(0!13, 1/30, fixedLag: true), waves);
	finalSig = (finalSig + 1) / 2; // Normalizing the signal range [0, 1]
	finalSig = finalSig.pow(poww);
	// Implementing the bipow transformation as specified
	finalSig = (finalSig * 2) - 1; // Convert to bipolar range [-1, 1]
	k1 = 2 * bipow * 0.99999;
	k2 = k1 / ((bipow * -1 * 0.999999) + 1);
	k3 = k2 * abs(finalSig) + 1;
	finalSig = finalSig * (k2 + 1) / k3; // Apply the non-linear transformation
	finalSig = (finalSig + 1) * 0.5; // Convert back to unipolar range [0, 1]
	finalSig = 1 - (finalSig * \levels.kr(0!13, 1/30, fixedLag: true)); // Scaling with levels control
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

(
SynthDef(\lfosync13, {
    arg out=0;
    var numChannels = 13;
    var reset, phase, lfo;
    var getTriangle, getSine, getTrapezoid, getMultiLFO;

    // Function definitions
    getTriangle = { |phase, skew|
        phase = phase.linlin(0, 1, skew.neg, 1 - skew);
        phase.bilin(0, skew.neg, 1 - skew, 1, 0, 0);
    };

    getSine = { |phase|
        1 - cos(phase * pi) / 2;
    };

    getTrapezoid = { |phase, duty, shape, skew|
        var offset = phase - (1 - duty);
        var steepness = 1 / (1 - shape);
        var trapezoid = (offset * steepness + (1 - duty)).clip(0, 1);
        var pulse = offset > 0;
        Select.ar(shape |==| 1, [trapezoid, pulse]);
    };

    getMultiLFO = { |phase, skew, width, shape, mix|
        var triangle = getTriangle.(phase, skew);
        var trapezoid = getTrapezoid.(triangle, width, shape);
        var sine = getSine.(trapezoid);
        trapezoid * (1 - mix) + (sine * mix);
    };

    // Control parameters with multichannel expansion
    reset = \reset.tr(0!numChannels);
    phase = Phasor.ar(reset, \freq.kr(1!numChannels, 1/30, fixedLag: true) * SampleDur.ir);
    // Add phase offset
    phase = (phase + \phoff.kr(0!numChannels, 1/30, fixedLag: true)) % 1;

    lfo = getMultiLFO.(
        phase,
        \skew.kr(0.0!numChannels, 1/30, fixedLag: true),
        \width.kr(0.5!numChannels, 1/30, fixedLag: true),
        \shape.kr(0!numChannels, 1/30, fixedLag: true),
        \mix.kr(0!numChannels, 1/30, fixedLag: true)
    );

    Out.ar(out, lfo);
}).writeDefFile(d);
)



(
var getTriangle = { |phase, skew|
    phase = phase.linlin(0, 1, skew.neg, 1 - skew);
    phase.bilin(0, skew.neg, 1 - skew, 1, 0, 0);
};
var getSine = { |phase|
    1 - cos(phase * pi) / 2;
};
var getTrapezoid = { |phase, duty, shape, skew|
    var offset = phase - (1 - duty);
    var steepness = 1 / (1 - shape);
    var trapezoid = (offset * steepness + (1 - duty)).clip(0, 1);
    var pulse = offset > 0;
    Select.ar(shape |==| 1, [trapezoid, pulse]);
};
var getMultiLFO = { |phase, skew, width, shape, mix|
    var triangle = getTriangle.(phase, skew);
    var trapezoid = getTrapezoid.(triangle, width, shape);
    var sine = getSine.(trapezoid);
    trapezoid * (1 - mix) + (sine * mix);
};
{
    var reset = \reset.tr(0);
    var phase = Phasor.ar(reset, 100 * SampleDur.ir);
    var lfo = getMultiLFO.(phase, \skew.kr(0.0), \width.kr(0.5), \shape.kr(0), \mix.kr(0));
    [phase, lfo];
}.plot(0.02);
)



(
SynthDef.new(\lfo6, {
	arg out;
	var p, ph, waves, pulsew, finalSig, poww, bipow;
	var k1, k2, k3;

	ph=\phoff.kr(0!6, 1/30, fixedLag: true);
	p = \hz.kr(1!6, 1/30, fixedLag: true);
	pulsew = \pw.kr(0!6, 1/30, fixedLag: true);
	poww = \pow.kr(1!6, 1/30, fixedLag: true);
	bipow = \bipow.kr(0!6, 1/30, fixedLag: true);

	waves = [
		(((((LFSaw.ar(p)+1)/2)+ph)%1)*2)-1,
		SinOsc.ar(p, ph),
		LFTri.ar(p, ph),
		LFPulse.ar(p, ph, (pulsew + 0.5) % 1),
		LFDNoise3.ar(p)
	];

	finalSig = SelectX.ar(\shape.kr(0!6, 1/30, fixedLag: true), waves);
	finalSig = (finalSig + 1) / 2; // Normalizing the signal range [0, 1]
	finalSig = finalSig.pow(poww);
	// Implementing the bipow transformation as specified
	finalSig = (finalSig * 2) - 1; // Convert to bipolar range [-1, 1]
	k1 = 2 * bipow * 0.99999;
	k2 = k1 / ((bipow * -1 * 0.999999) + 1);
	k3 = k2 * abs(finalSig) + 1;
	finalSig = finalSig * (k2 + 1) / k3; // Apply the non-linear transformation
	finalSig = (finalSig + 1) * 0.5; // Convert back to unipolar range [0, 1]
	finalSig = 1 - (finalSig * \levels.kr(0!6, 1/30, fixedLag: true)); // Scaling with levels control
	Out.ar(out, finalSig);
}).writeDefFile(d);
)
