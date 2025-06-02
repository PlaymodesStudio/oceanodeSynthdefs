(
~synthCreator.value("FFTStretch", {|n, variables|
	var buf, overlaps, fftSize, chains, pos, transpose, rate, levels, sigArray;

	// Input parameters
	buf = OceanodeBuffer.kr(\bufnum);
	overlaps = 2;
	fftSize = 16384;
	transpose = OceanodeParameterLag.ar(\transpose, 0, n, -24, 24, "vf", 1/30, true);
	pos = OceanodeParameterLag.ar(\pos, 0, n, 0, 1, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Convert semitone transpose to rate multiplier
	rate = transpose.midiratio; // 2.midiratio = 1.122, -2.midiratio = 0.891, etc.

	// Calculate position in frames
	pos = pos * BufFrames.kr(buf);

	// Create FFT chains for each channel
	chains = Array.fill(n, { |i|
		var fftBuf = LocalBuf(fftSize!overlaps);
		var chain = BufFFTTrigger(fftBuf, 1/overlaps, [0,1], overlaps);
		chain = BufFFT_BufCopy(chain, buf, pos.asArray[i], rate.asArray[i] * BufRateScale.kr(buf));
		chain = BufFFT(chain);
		chain = PV_Diffuser(chain, 1);
		chain = BufIFFT(chain, 0);
		Mix.ar(chain) * 0.8 * levels.asArray[i];
	});

	// Output
	Out.ar(OceanodeOutput.kr(\out), chains);
}, description: "Spectral stretching of audio file with pitch control", category: "Source/Sampler");
)
