(
~synthCreator.value("TimeBlur", {|n|
    var signal, drysignal, wetsignal, outsignal, frameSize, frameRate, frameTime, kernel;

    // Blur parameters
    var blur = OceanodeParameter.ar(\blur, 0.5, n, 0, 1, "vf");
    var blurq = OceanodeParameter.ar(\blurq, 3, n, 0.1, 10, "vf");
    var blurm = OceanodeParameter.ar(\blurm, 1, n, 0.1, 4, "vf");

    // Output parameters
    var level = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    var mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");

	   // Input signal
    signal = In.ar(OceanodeInput.kr(\in), n);
    drysignal = signal;

    // Frame calculations
    frameSize = 2048;
    frameRate = SampleRate.ir/frameSize;
    frameTime = frameRate.reciprocal;

    // Kernel generation with proper blur control
    RandSeed.kr(Impulse.kr(frameRate * blurm), blur * 1000); // blur parameter affects seed
    kernel = WhiteNoise.ar() * LFGauss.ar(frameTime, 1/blurq);

    // Apply convolution
    wetsignal = Convolution.ar(signal, kernel, frameSize);

    // Mix dry and wet signals
    outsignal = XFade2.ar(drysignal, wetsignal, mix * 2 - 1);

    // Apply level control
    outsignal = outsignal * level;

    Out.ar(OceanodeOutput.kr(\out), outsignal);
}, description: "Spectral blur using convolution", category: "Effect/Spectral");
)