(
~maxChans = 24;

SynthDef(\mergeBufDynamic, {
	arg outBuf = 0, nChans = 2;

	var bufnums, sigs, sig, phase;

	// Create full-size arrays and slice later
	bufnums = Array.fill(~maxChans, { |i|
		OceanodeBuffer.kr(("inBufs" ++ i).asSymbol, 0)
	});

	phase = Phasor.ar(1, 1, 0, BufFrames.kr(outBuf));

	sigs = Array.fill(~maxChans, { |i|
		BufRd.ar(1, bufnums[i], phase)
	});

	// Now slice at runtime — this works correctly
	sig = sigs.copyRange(0, nChans - 1);

	BufWr.ar(sig, outBuf, phase);
}).writeDefFile("/your/defs/path");
)