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
	*kr {arg name;
		^name.asSymbol.kr(0, spec: ControlSpec(units: "buffer"));
	}
}

OceanodeInternalBuffer{
	*kr {arg name;
		^name.asSymbol.kr(0, spec: ControlSpec(units: "internalbuffer"));
	}
}
*/

//Default params
d = thisProcess.nowExecutingPath.dirname +/+ "../../Supercollider/Synthdefs"
~maxVoices = 100;

//Default synths
//Infos synths
(
File.mkdir(d ++ "/" ++ "info");
(1..~maxVoices).do({arg n;
	var numChan = n;
	SynthDef.new(\info ++ (numChan).asSymbol, {
		arg in, amp, peak, lagTime = 0.2, decay = 0.99;
		var sig;
		sig = In.ar(in, numChan);
		Out.kr(amp, Lag.kr(Amplitude.kr(sig), lagTime));
		Out.kr(peak, PeakFollower.kr(sig, decay));
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

//Helper funtion to create synths
(
~synthCreator = {|name, func, description = "", category = "", variables, variableDimensions|
	var createSynths, variableNames, variableDimensionString, placeholderArgs;
	("Writing Synth " ++ name ++ " --------------------------").postln;
	File.mkdir(d ++ "/" ++ name);
	description = description.replace(" ", "_");
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