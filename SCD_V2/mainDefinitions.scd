//Make shure you have OceanodeParameter pseudo-Ugen in user extensions folder
Platform.userExtensionDir;
//You should have a class containing the file oceanodeParameter.sc with the following contents:

/*
OceanodeParameter {
	*ar {arg name, default, size, min, max, units;
		^Select.ar(
			(name ++ "_sel").asSymbol.kr(0),
			[
				K2A.ar(name.asSymbol.kr(default!size, spec: ControlSpec(min, max, default: default, units: "a"++units))),
				(name ++ "_ar").asSymbol.ar(default!size);
			]
		)
	}

	*kr {arg name, default, size, min, max, units;
		^name.asSymbol.kr(default!size, spec: ControlSpec(min, max, default: default, units: units));
	}
}

OceanodeParameterLag {
	*ar {arg name, default, size, min, max, units, lagtime = 0, fixedLag = false;
		^Select.ar(
			(name ++ "_sel").asSymbol.kr(0),
			[
				K2A.ar(name.asSymbol.kr(default!size, lag: lagtime, fixedLag: fixedLag, spec: ControlSpec(min, max, default: default, units: "a"++units))),
				(name ++ "_ar").asSymbol.ar(default!size);
			]
		)
	}

	*kr {arg name, default, size, min, max, units, lagtime = 0, fixedLag = false;
		^name.asSymbol.kr(default!size, lag: lagtime, fixedLag: fixedLag, spec: ControlSpec(min, max, default: default, units: units));
	}
}

OceanodeParameterDropdown {
	*ar {arg name, default, size, options;
		^Select.ar(
			(name ++ "_sel").asSymbol.kr(0),
			[
				K2A.ar(name.asSymbol.kr(default!size, spec: ControlSpec(default: default, units: "ad:"++options))),
				(name ++ "_ar").asSymbol.ar(default!size);
			]
		)
	}
	*kr {arg name, default, size, options;
		^name.asSymbol.kr(default!size, spec: ControlSpec(default: default, units: "d:"++options));
	}
}

OceanodeParameterFloatDropdown {
	*ar {arg name, default, size, options;
		^Select.ar(
			(name ++ "_sel").asSymbol.kr(0),
			[
				K2A.ar(name.asSymbol.kr(default!size, spec: ControlSpec(default: default, units: "adf:"++options))),
				(name ++ "_ar").asSymbol.ar(default!size);
			]
		)
	}
	*kr {arg name, default, size, options;
		^name.asSymbol.kr(default!size, spec: ControlSpec(default: default, units: "df:"++options));
	}
}


OceanodeInput{
	*kr {arg name;
		^name.asSymbol.kr(0, spec: ControlSpec(units: "input"));
	}
}

OceanodeOutput{
	*kr {arg name;
		^name.asSymbol.kr(0, spec: ControlSpec(units: "output"));
	}
}

OceanodeBuffer{
  *kr {arg name, default = -1;
    ^name.asSymbol.kr(default, spec: ControlSpec(units: "buffer"));
  }
}

OceanodeInternalBuffer{
	*kr {arg name;
		^name.asSymbol.kr(0, spec: ControlSpec(units: "internalbuffer"));
	}
}
*/

//Default params
d = thisProcess.nowExecutingPath.dirname +/+ "/CompiledSynthdefs"
~maxVoices = 24;

//Default synths
//Infos synths
(
File.mkdir(d ++ "/" ++ "info");
(1..~maxVoices).do({arg n;
	var numChan = n;
	SynthDef.new(\info ++ (numChan).asSymbol, {
		arg in, amp, peak, value, lagTime = 0.2, decay = 0.99;
		var sig;
		sig = In.ar(in, numChan);
		Out.kr(amp, Lag.kr(Amplitude.kr(sig), lagTime));
		Out.kr(peak, PeakFollower.kr(sig, decay));
		Out.kr(value, A2K.kr(sig));
	}).writeDefFile(d ++ "/info");
})
)


//Output Synth
(
SynthDef.new(\output, {
	arg in = 0, out=0;
	var sig;
	sig = In.ar(in, ~maxVoices);
	sig=LeakDC.ar(sig);
	sig=Sanitize.ar(sig);
	sig = DelayN.ar(sig, 5, \delay.kr(0));
	ReplaceOut.ar(out, sig.tanh * \levels.kr(0));
}).writeDefFile(d);
)


// recbufSynthdefs.scd
(
File.mkdir(d ++ "/" ++ "recbuf");

(1..24).do { |nCh|
    var name = ("recbuf" ++ nCh).asSymbol;
    SynthDef(name, {
        arg in, buf, record = 0;
        var sig = In.ar(in, nCh);
        var phase = Phasor.ar(record, 1, 0, BufFrames.kr(buf)); // avança només si record=1
        BufWr.ar(sig, buf, phase, loop: 0);
        // res a enviar a la sortida
    }).writeDefFile(d ++ "/recbuf");
    name.postln;
};

"✓ recbuf SynthDefs escrits".postln;
)

(
File.mkdir(d ++ "/bufalloc");

// Hybrid bufalloc: supports both fragment and circular modes
SynthDef(\bufalloc, {
    arg in = 0, buf = 0, record = 0, loop = 0;
    var sig = In.ar(in, 1);
    var shouldRecord = record > 0;
    var phase = Phasor.ar(shouldRecord, shouldRecord, 0, BufFrames.kr(buf), 0);
    BufWr.ar(sig, buf, phase, loop: loop > 0);
}).writeDefFile(d ++ "/bufalloc");

"✓ hybrid bufalloc SynthDef written".postln;
)


(
~maxChans = 24;

SynthDef(\mergeBufDynamic, {
	arg outBuf = 0, nChans = 2;

	var bufnums, sigs, sig, phase;

	// Create full-size arrays and slice later
	bufnums = Array.fill(~maxChans, { |i|
		OceanodeBuffer.kr(("inBufs" ++ i).asSymbol, 0)
	});

	phase = Phasor.ar(1, 1, 0, BufFrames.kr(outBuf));

	sigs = Array.fill(~maxChans, { |i|
		BufRd.ar(1, bufnums[i], phase)
	});

	// Now slice at runtime — this works correctly
	sig = sigs.copyRange(0, nChans - 1);

	BufWr.ar(sig, outBuf, phase);
}).writeDefFile("/your/defs/path");
)











(
File.mkdir(d ++ "/" ++ "bufferscope");
// funció generadora mono
~makeSpread = { |nSamp|
    SynthDef(("bufferscopeSpread1_" ++ nSamp).asSymbol, { |buf=0, out=0|
        var idx = (Array.series(nSamp, 0, 1) / nSamp) * BufFrames.kr(buf);
        Out.kr(out, BufRd.kr(1, buf, idx))
    }).writeDefFile(d);
};

// crea variants per 32..512
[32,64,128,256,512,1024,2048,4096].do(~makeSpread);

"✓ bufferscopeSpread SynthDefs escrits a ".postln; d.postln;
)







(
File.mkdir(d ++ "/" ++ "wavescope");

// Create SynthDefs for different sample sizes - NO DYNAMIC PARAMETERS
[32, 64, 128, 256, 512].do({|numSamples|
	(1..24).do({|numChannels|
		var synthName = ("wavescope" ++ numChannels ++ "_" ++ numSamples).asSymbol;

		SynthDef(synthName, {
			arg in, out, timewindow = 1;  // ONLY these 3 parameters
			var sig, bufferSize, writePhase;
			var sampleRate, samplesForTimeWindow;
			var outputSamples;
			var localBufs;

			sampleRate = SampleRate.ir;
			bufferSize = 10 * sampleRate;
			sig = In.ar(in, numChannels);

			// Create buffers
			localBufs = Array.fill(numChannels, { LocalBuf(bufferSize, 1) });
			writePhase = Phasor.ar(0, 1, 0, bufferSize);

			// Record
			numChannels.do({|i|
				RecordBuf.ar(sig[i], localBufs[i], writePhase, loop: 1);
			});

			samplesForTimeWindow = timewindow * sampleRate;

			// Generate output - numSamples is compile-time constant
			outputSamples = [];
			numChannels.do({|ch|
				numSamples.do({|sampleIdx|
					var readOffset = samplesForTimeWindow * (1 - (sampleIdx / (numSamples - 1)));
					var readPos = (writePhase - readOffset) % bufferSize;
					var sample = BufRd.kr(1, localBufs[ch], readPos, loop: 1, interpolation: 1);
					outputSamples = outputSamples.add(sample);
				});
			});

			Out.kr(out, outputSamples);

		}).writeDefFile(d ++ "/wavescope");

		// Progress indicator
		if((numChannels == 1) && ((numSamples == 32) || (numSamples == 128) || (numSamples == 512))) {
			("Creating: " ++ synthName).postln;
		};
	});
});

"✓ Clean wavescope SynthDefs created successfully".postln;
)

//Helper funtion to create at once a number of synths from 1 to maxVoices
(
~synthCreator = {|name, func, description = "", category = "", variables, variableDimensions|
	var createSynths, variableNames, variableDimensionString, placeholderArgs;
	("Writing Synth " ++ name ++ " --------------------------").postln;
	File.mkdir(d ++ "/" ++ name);
	description = description.replace(" ", "_");
	description = description.replace(",", "|");
	if(variables.size == 0){
		variableNames = "";
		variableDimensionString = "";
	}{
		variableNames = variables.join(":");
		variableDimensionString = variableDimensions.collect(_.asString).join(":");
	};
	//Create first synth for metadata.
	(1..variables.size).do{
		placeholderArgs = placeholderArgs.add(1);
	};
	SynthDef.new(name, {
			var sig = SynthDef.wrap(func, prependArgs: [1, placeholderArgs]);
	}, metadata: (name: name, type: "source", description: description, category: category, variables: variableNames, variableDimensions: variableDimensionString)).writeDefFile(d ++ "/" ++ name);

	 // Recursive function to handle variable number of variables
    createSynths = { |n, vars, varDim, args|
		var synthdefName = name ++ (n).asSymbol;
        if (args.size == vars.size) {
            // Base case: No more variables to process
			if(args.size > 0){
				(1..args.size).do{|a|
					synthdefName = synthdefName ++ "_" ++ (args[a-1]).asSymbol;
				};
			}{};
		    synthdefName.postln;
            SynthDef.new(synthdefName, {
                var sig = SynthDef.wrap(func, prependArgs: [n, args]);
            }).writeDefFile(d ++ "/" ++ name, mdPlugin: AbstractMDPlugin); //AbstractMDPlugin to disable metadata
			args = [];
		}{
            // Recursive case: Process current variable and call next
			args = args.add(1);
			(1..varDim[args.size-1]).do { |varValue|
                // Recurse to handle the next variable
				args[args.size-1] = varValue;
				createSynths.(n, vars, varDim, args);
            };
			args = args.removeAt(args.size-1);
        };
    };

    // Create synths for each voice number
    (1..~maxVoices).do { |n|
        createSynths.(n, variables, variableDimensions);
    };
	"Writing finished".postln;
};
)


~maxVoices = 1;
// Helper function to create a single synth with maxVoices
(
~synthCreator = {|name, func, description = "", category = "", variables, variableDimensions|
    var createSynth, variableNames, variableDimensionString, placeholderArgs;

    ("Writing Single Synth " ++ name ++ " with " ++ ~maxVoices ++ " voices --------------------------").postln;
    File.mkdir(d ++ "/" ++ name);

    description = description.replace(" ", "_");
    description = description.replace(",", "|");

    if(variables.size == 0){
        variableNames = "";
        variableDimensionString = "";
    }{
        variableNames = variables.join(":");
        variableDimensionString = variableDimensions.collect(_.asString).join(":");
    };

    // Create placeholder args for metadata
    (1..variables.size).do{
        placeholderArgs = placeholderArgs.add(1);
    };

    // Create metadata synth
    SynthDef.new(name, {
        var sig = SynthDef.wrap(func, prependArgs: [~maxVoices, placeholderArgs]);
    }, metadata: (
        name: name,
        type: "source",
        description: description,
        category: category,
        variables: variableNames,
        variableDimensions: variableDimensionString
    )).writeDefFile(d ++ "/" ++ name);

    // Function to create a single synth with variable combinations
    createSynth = { |n, vars, varDim, args|
        var synthdefName = name ++ (n).asSymbol;

        if (args.size == vars.size) {
            // Base case: No more variables to process
            if(args.size > 0){
                (1..args.size).do{|a|
                    synthdefName = synthdefName ++ "_" ++ (args[a-1]).asSymbol;
                };
            };

            synthdefName.postln;
            SynthDef.new(synthdefName, {
                var sig = SynthDef.wrap(func, prependArgs: [n, args]);
            }).writeDefFile(d ++ "/" ++ name, mdPlugin: AbstractMDPlugin); // AbstractMDPlugin to disable metadata
            args = [];
        }{
            // Recursive case: Process current variable and call next
            args = args.add(1);
            (1..varDim[args.size-1]).do { |varValue|
                // Recurse to handle the next variable
                args[args.size-1] = varValue;
                createSynth.(n, vars, varDim, args);
            };
            args = args.removeAt(args.size-1);
        };
    };

    // Create only one synth with the specified number of voices from global maxVoices
    createSynth.(~maxVoices, variables, variableDimensions);

    "Writing finished".postln;
};
)
