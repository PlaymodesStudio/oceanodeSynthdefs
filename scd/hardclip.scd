(
SynthDef(\hardclip13, {
    arg in=0, out=0;
    var dry, dcCorrected, wet, sig;
    var drive = \drive.kr(10!13);   // Range: 1 to 100+. Higher values = more distortion
    var clip = \clip.kr(0.8!13);    // Range: 0.01 to 1. Lower values = more aggressive clipping
    var level = \level.kr(1!13);    // Range: 0 to 1. Adjusts output level of wet signal
    var mix = \mix.kr(1!13);        // Range: 0 to 1. 0 = dry, 1 = wet

    // Get input signal
    dry = In.ar(in, 13);

    // Apply DC correction
    dcCorrected = LeakDC.ar(dry);

    // Apply extreme hard clip distortion for each channel
    wet = (dcCorrected * drive).clip2(clip);

    // Apply level control and limiting for each channel
    wet = wet * level;
    wet = Limiter.ar(wet, 0.99);

    // Mix dry and wet signals for each channel
    sig = XFade2.ar(dry, wet, mix*2-1);

    // Final safety limiter
    sig = Limiter.ar(sig, 0.99);

    // Output
    Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\tanh13, {
    arg in=0, out=0;
    var dry, dcCorrected, wet, sig;
    var drive = \drive.kr(10!13);   // Range: 1 to 100+. Higher values = more distortion
    var clip = \clip.kr(0.8!13);    // Range: 0.01 to 1. Lower values = more aggressive clipping
    var level = \level.kr(1!13);    // Range: 0 to 1. Adjusts output level of wet signal
    var mix = \mix.kr(1!13);        // Range: 0 to 1. 0 = dry, 1 = wet

    // Get input signal
    dry = In.ar(in, 13);

    // Apply DC correction
    dcCorrected = LeakDC.ar(dry);

    // Apply extreme hard clip distortion for each channel
    wet = (dcCorrected * drive).tanh(clip);

    // Apply level control and limiting for each channel
    wet = wet * level;
    wet = Limiter.ar(wet, 0.99);

    // Mix dry and wet signals for each channel
    sig = XFade2.ar(dry, wet, mix*2-1);

    // Final safety limiter
    sig = Limiter.ar(sig, 0.99);

    // Output
    Out.ar(out, sig);
}).writeDefFile(d);
)