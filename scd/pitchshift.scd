(
SynthDef.new(\pitchshifter, {
	arg in, out=0;
	var input,sig;
	var grainSize=\grainsize.kr(0.1!13);
	var pitchShif=VarLag.kr(\pitchshift.kr(0!13),1/30).midiratio;
	var pitchDispersion=VarLag.kr(\pitchdisp.kr(0!13),1/30);
	var timeDispersion=VarLag.kr(\timedisp.kr(0.0001!13),1/30);
	//z = Blip.ar(800, 6, 0.1);

	input = In.ar(in, 13);

	sig=PitchShift.ar(input,grainSize,pitchShif,pitchDispersion,timeDispersion);
	Out.ar(out, sig);

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

tgrains


(
SynthDef(\grainpitchshift13, {
    arg in=0, out=0;
    var numChannels = 13;
    var input, wet, output;
    var pitchShift = \pitchshift.kr(1!numChannels).midiratio;
    var grainSpeed = \grainspeed.kr(50!numChannels);
    var grainPeriods = \grainperiods.kr(4!numChannels);
    var timeDispersion = \timedisp.kr(6!numChannels);
    var mix = \mix.kr(1!numChannels);
    var amp = \levels.kr(1!numChannels);

    input = In.ar(in, numChannels);

    // Apply PitchShiftPA to each channel
    wet = numChannels.collect({ |i|
        PitchShiftPA.ar(
            input[i],
            grainSpeed[i],    // granulation speed
            1,                // pitchRatio (not used, should be 1)
            pitchShift[i],    // formantRatio becomes actual pitch ratio
            10,               // minFreq
            20,               // maxFormantRatio becomes maximum pitch ratio
            grainPeriods[i],  // grainPeriods
            timeDispersion[i] // timeDispersion
        );
    });

    // Multichannel crossfade between dry and wet signals
    output = (input * (1 - mix)) + (wet * mix);
    Out.ar(out, output * amp);
}).writeDefFile(d);
)

(
SynthDef(\grainpitchshift2, {
    arg in=0, out=0;
    var numChannels = 2;
    var input, wet, output;
    var pitchShift = \pitchshift.kr(1!numChannels).midiratio;
    var grainSpeed = \grainspeed.kr(50!numChannels);
    var grainPeriods = \grainperiods.kr(4!numChannels);
    var timeDispersion = \timedisp.kr(6!numChannels);
    var mix = \mix.kr(1!numChannels);
    var amp = \levels.kr(1!numChannels);

    input = In.ar(in, numChannels);

    // Apply PitchShiftPA to each channel
    wet = numChannels.collect({ |i|
        PitchShiftPA.ar(
            input[i],
            grainSpeed[i],    // granulation speed
            1,                // pitchRatio (not used, should be 1)
            pitchShift[i],    // formantRatio becomes actual pitch ratio
            10,               // minFreq
            20,               // maxFormantRatio becomes maximum pitch ratio
            grainPeriods[i],  // grainPeriods
            timeDispersion[i] // timeDispersion
        );
    });

    // Multichannel crossfade between dry and wet signals
    output = (input * (1 - mix)) + (wet * mix);
    Out.ar(out, output * amp);
}).writeDefFile(d);
)