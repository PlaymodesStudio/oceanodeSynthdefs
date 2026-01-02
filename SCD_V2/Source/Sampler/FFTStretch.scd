(
~synthCreator.value("FFTStretch", {|n, variables|
	var buf, overlaps, fftSize, chains, pos, transpose, rate, levels;

	// Inputs (unchanged)
	buf       = OceanodeParameter.kr(\bufnum, 0, n, 0, 1000, "vi");
	overlaps  = 4;        // try 2 or 4
	fftSize   = 16384;
	transpose = OceanodeParameterLag.ar(\transpose, 0, n, -24, 24, "vf", 1/30, true);
	pos       = OceanodeParameterLag.ar(\pos, 0, n, 0, 1, "vf", 1/30, true);
	levels    = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	rate      = transpose.midiratio;

	chains = Array.fill(n, { |i|
		var chanBuf   = buf.asArray[i];
		var chanPos   = pos.asArray[i] * BufFrames.kr(chanBuf);
		var chanRate  = rate.asArray[i] * BufRateScale.kr(chanBuf);
		var chanLevel = levels.asArray[i];

		var fftBuf  = LocalBuf(fftSize ! overlaps);
		var idx     = (0 .. (overlaps - 1));    // <-- FIXED: drive all overlap streams
		var chain, sig;

		chain = BufFFTTrigger(fftBuf, 1/overlaps, idx, overlaps);
		chain = BufFFT_BufCopy(chain, chanBuf, chanPos, chanRate);
		chain = BufFFT(chain);
		chain = PV_Diffuser(chain, 1);          // kept exactly as you had

		// Use BufIFFT2 for 2× (Hann), BufIFFT for >2× (Sine at 4×)
		if (overlaps == 2) {
			// Hann (1) pairs well at 2×, reduces AM the most
			sig = BufIFFT2(chain[0], chain[1], 1, 0);
		} {
			// At 4×, Sine (0) is the safer choice than Hann for flatter OLA
			sig = Mix.ar(BufIFFT(chain, 0));
		};

		sig * 0.8 * chanLevel;
	});

	Out.ar(OceanodeOutput.kr(\out), chains);
}, description: "FFT stretch with correct trigger indices; BufIFFT2@2× (Hann) / BufIFFT@4× (Sine)", category: "Source/Sampler");
)
