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
