(
SynthDef(\additive13, {
	arg out=0;
    var partialAmps, ratios, pitch, partialNum = 320, amp = 0.2, sigArray, freqsArray, amps, levels;

	partialAmps=\partialamps.kr(0.5!320, 1/30, fixedLag: true);
	pitch=\pitch.kr(36!13, 1/30, fixedLag: true);
	levels=\levels.kr(1!13, 1/30, fixedLag: true);
	ratios=\ratios.kr(Array.fill(partialNum, { |j| (j + 1) }), 1/30, fixedLag: true);

    sigArray = Array.fill(pitch.size, { |i|

        var baseFreq = pitch[i].midicps;
		freqsArray = Array.fill(partialNum, { |j| baseFreq * ratios[j] });
        amps = partialAmps[0 .. (partialNum - 1)];

        Mix(SinOsc.ar(freqsArray, 0, amps)) * amp
    });

    Out.ar(out, sigArray*levels)
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

freeverb

