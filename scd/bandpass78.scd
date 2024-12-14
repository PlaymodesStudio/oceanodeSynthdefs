(
SynthDef.new(\bandpass78, {
	arg in, out=0;
	var input, freq, res, bpf1, bpf2;
	input = In.ar(in, 78);
	freq = \pitch.kr(128!78, 0.05, fixedLag: true).midicps; // Control rate array for frequency
	res = \q.kr(1!78); // Control rate array for resonance

	// First 2-pole BPF
	bpf1 = BPF.ar(input, freq, res, 1, 0);

	// Second 2-pole BPF cascaded to make it 4-pole
	bpf2 = BPF.ar(bpf1, freq, res, 1, 0);

	Out.ar(out, bpf2);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


(
SynthDef(\bandpass1080, {
    arg in=0, out=0;
    var input, bands, freqs, qs, amps, output, pans;
    var numBands = 1080;
    var scaling = 1/numBands.sqrt;  // Compensate for band summation

    input = In.ar(in,1);

    freqs = \pitcharray.kr(60!numBands).midicps;
    qs = \qarray.kr(1!numBands, 1/30, fixedLag:true);
    amps = \amparray.kr(1!numBands, 1/30, fixedLag:true);
    pans = \panarray.kr(0!numBands, 1/30, fixedLag:true);

    bands = Array.fill(numBands, { |i|
        var bpf1 = BPF.ar(input, freqs[i], qs[i]);
        Pan2.ar(bpf1 * amps[i], pans[i])
    });

    output = Mix(bands) * scaling;

    Out.ar(out, output);
}).writeDefFile(d);
)


// If you hear noise, our routing is working. Then we can add the full processing:
(
SynthDef(\bandpass256, {
    arg in=0, out=0;
    var input, bands, freqs, qs, amps, output, pans;
    var numBands = 256;
    var scaling = 1/numBands.sqrt;  // Compensate for band summation

    input = In.ar(in,1);

    freqs = \pitcharray.kr(60!numBands).midicps;
    qs = \qarray.kr(1!numBands, 1/30, fixedLag:true);
    amps = \amparray.kr(1!numBands, 1/30, fixedLag:true);
    pans = \panarray.kr(0!numBands, 1/30, fixedLag:true);

    bands = Array.fill(numBands, { |i|
        var bpf1 = BPF.ar(input, freqs[i], qs[i]);
        var bpf2 = BPF.ar(bpf1, freqs[i], qs[i]);
        Pan2.ar(bpf2 * amps[i], pans[i])
    });

    output = Mix(bands) * scaling;

    Out.ar(out, output);
}).writeDefFile(d);
)

(
SynthDef(\bandpass32_13, {
    arg in=0, out=0;
    var input, bands, freqs, qs, amps, output, levels;
    var numBands = 32;
    var numChannels = 13;
    var scaling = 1/numBands.sqrt;

    input = In.ar(in, numChannels);

    freqs = \pitcharray.kr(60!numBands).midicps;
    qs = \qarray.kr(1!numBands, 1/30, fixedLag:true);
    amps = \amparray.kr(1!numBands, 1/30, fixedLag:true);
	levels = \levels.kr(1!numChannels, 1/30, fixedLag:true);

    output = Array.fill(numChannels, { |chanNum|
        var chanInput = input[chanNum];
        var chanBands = Array.fill(numBands, { |i|
            var bpf1 = BPF.ar(chanInput, freqs[i], qs[i]);
            var bpf2 = BPF.ar(bpf1, freqs[i], qs[i]);
            bpf2 * amps[i]
        });
        Mix(chanBands) * scaling
    });

    Out.ar(out, output*levels);
}).writeDefFile(d);
)

(
SynthDef(\bandpass256_13, {
    arg in=0, out=0;
    var input, bands, freqs, qs, amps, output, pans,nch,levels;
    var numBands = 256;
    var scaling = 1/numBands.sqrt;  // Compensate for band summation
	nch=13;
    input = In.ar(in,1); //mono input

    freqs = \pitcharray.kr(60!numBands).midicps;
    qs = \qarray.kr(1!numBands, 1/30, fixedLag:true);
    amps = \amparray.kr(1!numBands, 1/30, fixedLag:true);
    pans = \panarray.kr(0!numBands, 1/30, fixedLag:true);
	levels = \levels.kr(1!nch, 1/30, fixedLag:true);

    bands = Array.fill(numBands, { |i|
        var bpf1 = BPF.ar(input, freqs[i], qs[i]);
        var bpf2 = BPF.ar(bpf1, freqs[i], qs[i]);
        PanAz.ar(nch, bpf2 * amps[i], pans[i])
    });

    output = Mix(bands) * scaling;

    Out.ar(out, output*levels);
}).writeDefFile(d);
)
