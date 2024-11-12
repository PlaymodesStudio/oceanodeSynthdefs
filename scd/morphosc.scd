(
SynthDef(\morphosc2, {
    arg out=0;
    var nch=2;

    var freq=\pitch.kr(56!nch).midicps,
    amp=\levels.kr(0.5!nch),
    phaseOffset=\phase.kr(0!nch),
    pulseWidth=\pw.kr(0.5!nch),
    skew=\skew.kr(0!nch),
    roundness=\round.kr(0.5!nch),
    randomAdd=\rndmadd.kr(0!nch),
    scale=\scale.kr(1!nch),
    offset=\offset.kr(0!nch),
    pow=\pow.kr(0!nch),
    biPow=\bipow.kr(0!nch),
    quant=\quant.kr(0!nch),
    invert=\invert.kr(0!nch);
    var indexNormalized = 0;
    var phasor, linPhase, skewedLinPhase, w, val;

    phasor = Phasor.ar(0, (freq) * SampleDur.ir, 0, 1);
    linPhase = (phasor + indexNormalized + phaseOffset).wrap(0, 1);

    // Pulse Width
    linPhase = Select.ar(pulseWidth < 0.5, [
        linPhase,
        linPhase.linlin(0.5 - pulseWidth, 0.5 + pulseWidth, 0, 1)
    ]);

      // Corrected Skew implementation
    skewedLinPhase = Select.ar(skew < 0, [
        // Positive skew (unchanged)
        Select.ar(linPhase > ((1 - skew.abs) * 0.5), [
            linPhase.linlin(0, (1 - skew.abs) * 0.5, 0, 0.5),
            linPhase.linlin((1 - skew.abs) * 0.5, 1, 0.5, 1)
        ]),
        // Negative skew (corrected)
        Select.ar(linPhase < (0.5 + (skew.abs * 0.5)), [
            linPhase.linlin(0, 0.5 + (skew.abs * 0.5), 0, 0.5),
            linPhase.linlin(0.5 + (skew.abs * 0.5), 1, 0.5, 1)
        ]).flop.reverse.flop // This line corrects the negative skew behavior
    ]);
    linPhase = skewedLinPhase;


    w = linPhase * 2pi;

    // Roundness
     val = SelectX.ar(roundness * 2, [
        1 - (linPhase * -2 + 1).abs, // Triangle
        cos(w + pi).linlin(-1, 1, 0, 1), // Sine
		Select.ar((linPhase+0.75)%1 < 0.5,
            [DC.ar(0), DC.ar(1)]
        ) // Square
    ]);

    // Interpolate between shapes
    val = Select.ar(roundness < 0.5, [
        LinXFade2.ar(
            1 - (linPhase * -2 + 1).abs,
            cos(w + pi).linlin(-1, 1, 0, 1),
            roundness * 4 - 1
        ),
        cos(w + pi).linlin(-1, 1, 0, 1).pow(roundness * 2)
    ]);

    // Apply additional modifications
    val = (val + (randomAdd * WhiteNoise.ar())).clip(0, 1);
    val = val * scale + offset;
    val = val.clip(0, 1);
    val = Select.ar(pow != 0, [val, val.pow(pow.exp)]);
    val = Select.ar(biPow != 0, [
        val,
        ((val * 2 - 1).pow(biPow.exp) + 1) * 0.5
    ]);
    val = val.clip(0, 1);

    // Quantization
    val = Select.ar(quant > 1, [
        val,
        (val * (quant - 1)).round / (quant - 1)
    ]);
    val = val.clip(0, 1);
    val = Select.ar(invert > 0, [val, 1 - val]);

    // Convert the 0 to 1 range to -1 to 1 range
    val = (val * 2) - 1;

    // Apply amplitude
    val = val * amp;

    Out.ar(out, val);
}).add();
)

// Create a synth instance
x = Synth(\morphosc2);

// Open the scope window
s.scope;

(
// Make sure the SynthDef is already loaded

// Create a synth instance
x = Synth(\morphosc2);

// Open the scope window
s.scope;

// Create a window for our GUI
w = Window("MorphOsc2 Control", Rect(100, 100, 400, 300)).front;

// Create sliders for various parameters
StaticText(w, Rect(10, 10, 100, 20)).string_("Pitch");
EZSlider(w, Rect(10, 30, 380, 20), "pitch", ControlSpec(20, 100, \lin, 0.1, 56), {|ez| x.set(\pitch, ez.value)});

StaticText(w, Rect(10, 60, 100, 20)).string_("Roundness");
EZSlider(w, Rect(10, 80, 380, 20), "round", ControlSpec(0, 1, \lin, 0.01, 0.5), {|ez| x.set(\round, ez.value)});

StaticText(w, Rect(10, 110, 100, 20)).string_("Pulse Width");
EZSlider(w, Rect(10, 130, 380, 20), "pw", ControlSpec(0, 1, \lin, 0.01, 0.5), {|ez| x.set(\pw, ez.value)});

StaticText(w, Rect(10, 160, 100, 20)).string_("Skew");
EZSlider(w, Rect(10, 180, 380, 20), "skew", ControlSpec(-1, 1, \lin, 0.01, 0), {|ez| x.set(\skew, ez.value)});

StaticText(w, Rect(10, 210, 100, 20)).string_("FM Amount");
EZSlider(w, Rect(10, 230, 380, 20), "fmamp", ControlSpec(0, 1000, \exp, 0.1, 200), {|ez| x.set(\fmamp, ez.value)});

// Add a button to stop the synth
Button(w, Rect(150, 260, 100, 30))
    .states_([["Stop Synth", Color.black, Color.red]])
    .action_({ x.free; w.close; });

// Cleanup when window closes
w.onClose = { x.free; };
)