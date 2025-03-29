(
~synthCreator.value("CompressorC", {|n|
	var in, t, o, r, c, e, lookahead, dry, wet;
	var kneelag, bias;
	var attack, release;

	// Input from bus
	in = In.ar(OceanodeInput.kr(\in), n);

	// Keep dry signal for mix later
	dry = in;

	// Gain parameters
	attack = OceanodeParameterLag.ar(\attack, 0.01, n, 0.0000001, 0.1, "vf", 1/30, true);
	release = OceanodeParameterLag.ar(\release, 0.1, n, 0.0000001, 0.4, "vf", 1/30, true);
	t = OceanodeParameterLag.ar(\threshold, -20, n, -80, 0, "vf", 1/30, true);

	// Apply input trim
	in = in * OceanodeParameterLag.ar(\trim, 0, n, 0, 60, "vf", 1/30, true).dbamp;

	// Calculate envelope - mean for stereo inputs, or just use the signal for mono
	e = if(n > 1, { in.mean }, { in });

	// High-pass filter the detector signal to avoid bass-pumping
	e = HPF.ar(e, OceanodeParameterLag.ar(\hpf, 50, n, 10, 1000, "vf", 1/30, true));

	// Envelope detection - smooth the signal
	e = EnvDetect.ar(e, attack, release);

	// Calculate how much we are over threshold (in dB)
	o = e.ampdb.excess(t);

	// Scale the excess value by ratio
	r = OceanodeParameterLag.ar(\ratio, 4, n, 1, 20, "vf", 1/30, true);
	c = (max(o, 0.0)) * (r.reciprocal - 1);

	// Apply knee smoothing
	kneelag = attack * OceanodeParameterLag.ar(\knee, 0, n, 0, 10, "vf", 1/30, true);
	c = c.lag(kneelag);

	// Convert back to amplitude
	c = c.dbamp;

	// Apply lookahead if needed
	lookahead = OceanodeParameterLag.ar(\lookahead, 0, n, 0, 1, "vf", 1/30, true);
	in = DelayC.ar(in, 0.5, (attack + release + kneelag * lookahead).lag(0.4));

	// Apply compression
	in = in * c;

	// Apply makeup gain
	in = in * OceanodeParameterLag.ar(\gain, 0, n, 0, 60, "vf", 1/30, true).dbamp;

	// Apply saturation if enabled
	bias = K2A.ar(OceanodeParameterLag.ar(\bias, 0, n, 0, 0.5, "vf", 1/30, true));
	in = Select.ar(OceanodeParameterDropdown.kr(\saturate, 1, n, "Off:On"), [in, (in + bias).softclip - bias]);

	// Remove DC offset
	in = LeakDC.ar(in);

	// Mix dry/wet using XFade2
	wet = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);

	// Output the signal with dry/wet mix using XFade2 (centered at 0 = dry, 1 = wet)
	wet = XFade2.ar(dry, in, (wet * 2) - 1);

	// Apply final level
	wet = wet * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Send to output bus
	Out.ar(OceanodeOutput.kr(\out), wet);

}, description: "Dynamic range compressor with threshold ratio and makeup gain", category: "Effect/Dynamics");
)