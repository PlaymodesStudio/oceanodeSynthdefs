(
~synthCreator.value("BasicSampler", {|n|
    // Variables declarations
    var trig, k_trig, trigEdge, buf, spd, bucle, startPos, gain, latchSpd;
    var latchedBuf, latchedSpd, latchedStart, finalSpd, signal;

    // 1) Get trigger as audio rate, but convert to control rate for edge detection
    trig = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
    k_trig = K2A.ar(A2K.kr(trig)); // Convert to control rate for processing, then back to audio
    trigEdge = Trig.kr(A2K.kr(trig), 0.001); // Edge detector at control rate

    // 2) Read input values
    buf = OceanodeBuffer.kr(\bufnum);
    spd = OceanodeParameter.kr(\speed, 1, n, -32, 32, "vf");
    latchSpd = OceanodeParameter.kr(\latchspeed, 1, n, 0, 1, "vi"); // 0=false, 1=true
    bucle = OceanodeParameter.kr(\loop, 0, n, 0, 1, "vi");
    startPos = OceanodeParameter.kr(\startpos, 0, n, 0, 1, "vf");
    gain = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

    // 3) Latch values (only updates on the 0→1 edge)
    // Use the current frame's values for latching to ensure proper timing
    latchedBuf = Latch.kr(buf, trigEdge);
    latchedSpd = Latch.kr(spd, trigEdge);
    latchedStart = Latch.kr(startPos, trigEdge) * BufFrames.kr(latchedBuf);

    // 4) Decide whether to use latched speed or current speed based on latchSpd parameter
    finalSpd = Select.kr(latchSpd, [spd, latchedSpd]);

    // 5) PlayBuf with edge as trigger parameter
    signal = PlayBuf.ar(
        numChannels: 1,
        bufnum: latchedBuf,
        rate: finalSpd,
        trigger: trigEdge,
        startPos: latchedStart,
        loop: bucle
    ) * gain;

    // Output
    Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Basic sample player with optional speed latching", category: "Source/Sampler");
)