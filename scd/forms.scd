(// FORMS
SynthDef(\forms, {
	//VarLag.kr(\levels.kr(1!8), 1/30)
	arg out=0;
	var partials = 1080;
	var chans = 1;
	var freqs = \freqarray.kr(220!partials);
	var amps = \amparray.kr(0.0!partials, 1/30, fixedLag:true);
	var largeSig = SinOsc.ar(freqs, {Rand(-25,25)}!partials, amps);
	var flat = (Mix.ar(largeSig)/100);
	Out.ar(out, flat);
}).writeDefFile(d);
)

(
SynthDef(\forms2, {
    arg out=0;
    var partials = 1080;
    var chans = 2;
    var freqs = \freqarray.kr(220!partials);
    var pitch = \pitcharray.kr(36!partials).midicps;
    var amps = \amparray.kr(0.0!partials, 1/30, fixedLag:true);
    var pans = \panarray.kr(0.0!partials, 1/30, fixedLag:true);
    var levels = \stereoamp.kr(1!2, 1/30, fixedLag:true);
    var usedpartials = \partials.kr(1080);

    var sigArray = Array.fill(partials, { |i|
        var baseFreq = freqs[i] + pitch[i];
        var amp = amps[i] * (i < usedpartials);  // Multiply amplitude by 0 if index >= usedpartials
        var pan = pans[i];
        Pan2.ar(SinOsc.ar(baseFreq, Rand(-25, 25), amp), pan);
    });

    var leftSig = Mix.new(sigArray.collect { |sig| sig[0] }) * levels[0];
    var rightSig = Mix.new(sigArray.collect { |sig| sig[1] }) * levels[1];

    Out.ar(out, [leftSig, rightSig] / 100);
}).writeDefFile(d);
)

(
SynthDef(\forms2160, {
    arg out=0;
    var partials = 2160;
    var chans = 2;
    var freqs = \freqarray.kr(220!partials);
    var pitch = \pitcharray.kr(36!partials).midicps;
    var amps = \amparray.kr(0.0!partials, 1/30, fixedLag:true);
    var pans = \panarray.kr(0.0!partials, 1/30, fixedLag:true);
    var levels = \stereoamp.kr(1!2, 1/30, fixedLag:true);
    var usedpartials = \partials.kr(partials);

    var sigArray = Array.fill(partials, { |i|
        var baseFreq = freqs[i] + pitch[i];
        var amp = amps[i] * (i < usedpartials);  // Multiply amplitude by 0 if index >= usedpartials
        var pan = pans[i];
        Pan2.ar(SinOsc.ar(baseFreq, Rand(-25, 25), amp), pan);
    });

    var leftSig = Mix.new(sigArray.collect { |sig| sig[0] }) * levels[0];
    var rightSig = Mix.new(sigArray.collect { |sig| sig[1] }) * levels[1];

    Out.ar(out, [leftSig, rightSig] / 100);
}).writeDefFile(d);
)

(
SynthDef(\forms3400, {
    arg out=0;
    var partials = 3400;
    var chans = 2;
    var freqs = \freqarray.kr(220!partials);
    var pitch = \pitcharray.kr(36!partials).midicps;
    var amps = \amparray.kr(0.0!partials, 1/30, fixedLag:true);
    var pans = \panarray.kr(0.0!partials, 1/30, fixedLag:true);
    var levels = \stereoamp.kr(1!2, 1/30, fixedLag:true);
    var usedpartials = \partials.kr(partials);

    var sigArray = Array.fill(partials, { |i|
        var baseFreq = freqs[i] + pitch[i];
        var amp = amps[i] * (i < usedpartials);  // Multiply amplitude by 0 if index >= usedpartials
        var pan = pans[i];
        Pan2.ar(SinOsc.ar(baseFreq, Rand(-25, 25), amp), pan);
    });

    var leftSig = Mix.new(sigArray.collect { |sig| sig[0] }) * levels[0];
    var rightSig = Mix.new(sigArray.collect { |sig| sig[1] }) * levels[1];

    Out.ar(out, [leftSig, rightSig] / 100);
}).writeDefFile(d);
)

(
SynthDef(\forms1700, {
    arg out=0;
    var partials = 1700;
    var chans = 2;
    var freqs = \freqarray.kr(220!partials);
    var pitch = \pitcharray.kr(36!partials).midicps;
    var amps = \amparray.kr(0.0!partials, 1/30, fixedLag:true);
    var pans = \panarray.kr(0.0!partials, 1/30, fixedLag:true);
    var levels = \stereoamp.kr(1!2, 1/30, fixedLag:true);
    var usedpartials = \partials.kr(partials);

    var sigArray = Array.fill(partials, { |i|
        var baseFreq = freqs[i] + pitch[i];
        var amp = amps[i] * (i < usedpartials);  // Multiply amplitude by 0 if index >= usedpartials
        var pan = pans[i];
        Pan2.ar(SinOsc.ar(baseFreq, Rand(-25, 25), amp), pan);
    });

    var leftSig = Mix.new(sigArray.collect { |sig| sig[0] }) * levels[0];
    var rightSig = Mix.new(sigArray.collect { |sig| sig[1] }) * levels[1];

    Out.ar(out, [leftSig, rightSig] / 100);
}).writeDefFile(d);
)

(
SynthDef(\forms2400, {
    arg out=0;
    var partials = 2400;
    var chans = 2;
    var freqs = \freqarray.kr(220!partials);
    var pitch = \pitcharray.kr(36!partials).midicps;
    var amps = \amparray.kr(0.0!partials, 1/30, fixedLag:true);
    var pans = \panarray.kr(0.0!partials, 1/30, fixedLag:true);
    var levels = \stereoamp.kr(1!2, 1/30, fixedLag:true);
    var usedpartials = \partials.kr(partials);

    var sigArray = Array.fill(partials, { |i|
        var baseFreq = freqs[i] + pitch[i];
        var amp = amps[i] * (i < usedpartials);  // Multiply amplitude by 0 if index >= usedpartials
        var pan = pans[i];
        Pan2.ar(SinOsc.ar(baseFreq, Rand(-25, 25), amp), pan);
    });

    var leftSig = Mix.new(sigArray.collect { |sig| sig[0] }) * levels[0];
    var rightSig = Mix.new(sigArray.collect { |sig| sig[1] }) * levels[1];

    Out.ar(out, [leftSig, rightSig] / 100);
}).writeDefFile(d);
)

(
SynthDef(\forms6, {
    arg out=0;
    var partials = 1080;
    var chans = 6;  // Number of output channels
    var freqs = \freqarray.kr(220!partials);
    var pitch = \pitcharray.kr(36!partials).midicps;
    var amps = \amparray.kr(0.0!partials, 1/30, fixedLag:true);
    var pans = \panarray.kr(0.0!partials, 1/30, fixedLag:true);
    var levels = \levels.kr(1!chans, 1/30, fixedLag:true);
    var usedpartials = \partials.kr(1080);

    var sigArray = Array.fill(partials, { |i|
        var baseFreq = freqs[i] + pitch[i];
        var amp = amps[i] * (i < usedpartials);  // Multiply amplitude by 0 if index >= usedpartials
        var pan = pans[i];
        PanAz.ar(chans, SinOsc.ar(baseFreq, Rand(-25, 25), amp), pan);
    });

    var mixedSig = Array.fill(chans, { |chan|
        Mix.new(sigArray.collect { |sig| sig[chan] }) * levels[chan];
    });

    Out.ar(out, mixedSig/100);
}).writeDefFile(d);
)

(
SynthDef(\forms13, {
    arg out=0;
    var partials = 1080;
    var chans = 13;  // Number of output channels
    var freqs = \freqarray.kr(220!partials);
    var pitch = \pitcharray.kr(36!partials).midicps;
    var amps = \amparray.kr(0.0!partials, 1/30, fixedLag:true);
    var pans = \panarray.kr(0.0!partials, 1/30, fixedLag:true);
    var levels = \levels.kr(1!chans, 1/30, fixedLag:true);
    var usedpartials = \partials.kr(1080);

    var sigArray = Array.fill(partials, { |i|
        var baseFreq = freqs[i] + pitch[i];
        var amp = amps[i] * (i < usedpartials);  // Multiply amplitude by 0 if index >= usedpartials
        var pan = pans[i];
        PanAz.ar(chans, SinOsc.ar(baseFreq, Rand(-25, 25), amp), pan);
    });

    var mixedSig = Array.fill(chans, { |chan|
        Mix.new(sigArray.collect { |sig| sig[chan] }) * levels[chan];
    });

    Out.ar(out, mixedSig/100);
}).writeDefFile(d);
)


d = thisProcess.nowExecutingPath.dirname;

