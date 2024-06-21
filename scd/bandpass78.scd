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
SynthDef.new(\bandpass1080, {
	arg in=0, out=0;
	var pitchArray=#[440], ampArray=#[1], panArray=#[0], qArray=#[1];
    var source, bands, freqs, amps, pans, qs, panSignals, stereoOutput;
    var numBands = 1080;

    // Read the mono input
    source = In.ar(in);

    // Arrays for storing filter parameters
	freqs = \pitcharray.kr(36!1080).midicps;
	amps = \amparray.kr(1!1080, 1/30, fixedLag:true);
	pans = \panarray.kr(0!1080, 1/30, fixedLag:true);
	qs = \qarray.kr(1!1080, 1/30, fixedLag: true);

    // Process each band
    bands = Array.fill(numBands, { |i|
        var band = BPF.ar(source, freqs[i], freqs[i] / qs[i]);
        band = band * amps[i];  // Apply amplitude
        Pan2.ar(band, pans[i])  // Apply panning
    });

    // Sum all the bands
    stereoOutput = Mix(bands);

    // Output the final stereo signal
    Out.ar(out, stereoOutput/300);
}).writeDefFile(d);
)


