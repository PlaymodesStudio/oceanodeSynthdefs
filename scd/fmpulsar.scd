(
SynthDef(\fmpulsar13, {
    arg out=0;
    var a, d, f;
    var t, overlap, carfreq, modfreq, mInd, amp, levels;
    var nch=13;

    // Base frequency from pitch
    f = \pitch.kr(36!nch, 1/30, fixedLag: true).midicps;

    // Amplitude and levels
    amp = \preamp.kr(0.6!nch, 1/30, fixedLag: true).clip(0, 1.0);  // Clip amp to prevent overload
    levels = \levels.kr(0.15!nch, 1/30, fixedLag: true);

    // FM parameters
    carfreq = f * \carrier.kr(8/7!nch, 1/30, fixedLag: true);
    modfreq = carfreq * \modulator.kr(4/3!nch, 1/30, fixedLag: true);

    // Generate triggers for each channel
    t = Impulse.ar(f);

    // Calculate modulation index and overlap per channel - adjusted scaling
	mInd = amp.pow(3.5) * \modindex.kr(0.15!nch, 1/30, fixedLag: true);  // Reduced default modindex
    overlap = 1.15 - amp.pow(0.55) * \overlap.kr(1!nch, 1/30, fixedLag: true);
    d = overlap/f;

    // Generate and mix the sound for all channels with proper scaling
    a = (SinOsc.ar(f) * 0.5) +
        (GrainFM.ar(nch, t, d, carfreq, modfreq, mInd) * 0.5);  // Equal mix at half amplitude

    // Process each channel
    a = LeakDC.ar(a * amp);
    a = BLowPass4.ar(a, 1350!nch, 1.0);

    Out.ar(out, a * levels);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
