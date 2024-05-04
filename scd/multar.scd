( SynthDef(\multar,
	{ arg in=0, in2=0, out=0;
		var sig, siga, sigb;
		siga = In.ar(0, 13);
		sigb = In.ar(0, 13);
		sig = siga*sigb;
		Out.ar(out, sig);
}).writeDefFile(d);
)

( SynthDef(\rectify,
	{ arg in=0, in2=0, out=0;
		var sig, siga, sigb,pw;
		pw=\pow.kr(1!13);
		siga = In.ar(0, 13);
		siga=(siga+1)/2;
		siga=siga.pow(pw);

		Out.ar(out, siga);

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\solo13, {
	arg inp=0, out=0;
	var in1, in2, in3, in4, in5, in6, in7, in8, mix, sig;
	var solo = \solo.kr(0);
	var arrayofinputs, selected;

	// Inputs
	in1 = In.ar(inp, 13);
	in2 = In.ar(inp, 13);
	in3 = In.ar(inp, 13);
	in4 = In.ar(inp, 13);
	in5 = In.ar(inp, 13);
	in6 = In.ar(inp, 13);
	in7 = In.ar(inp, 13);
	in8 = In.ar(inp, 13);
	mix = in1 + in2 + in3 + in4 + in5 + in6 + in7 + in8;

	// Pack inputs and mix into an array of arrays
	arrayofinputs = [in1, in2, in3, in4, in5, in6, in7, in8, mix];

	// Since Select.ar doesn't work directly with arrays of arrays,
	// we must individually select the correct input for each channel.
	selected = Array.fill(13, {|i|
		// For each channel, decide which input to take based on the `solo` control
		Select.ar(solo, arrayofinputs.collect{|input| input[i]})
	});

	// Output the selected signals
	Out.ar(out, selected);
}).writeDefFile(d);
)

(
SynthDef.new(\solo13, {
    arg in=0, in2=0, in3=0, in4=0, in5=0, in6=0, in7=0, in8=0, out=0, soloindex=0;
    var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
    var inputs, mixedInput, soloedInput, finalSig;

    // Inputs
    sig1 = In.ar(in, 13);
    sig2 = In.ar(in2, 13);
    sig3 = In.ar(in3, 13);
    sig4 = In.ar(in4, 13);
    sig5 = In.ar(in5, 13);
    sig6 = In.ar(in6, 13);
    sig7 = In.ar(in7, 13);
    sig8 = In.ar(in8, 13);

    // Combine all signals into an array
    inputs = [sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8];

    // Mix inputs channel-wise to maintain multi-channel structure
    mixedInput = Array.fill(13, {|chan|
        inputs.collect {|input| input[chan]}.sum
    });

    // Adjust the soloindex to range from 0 to 8, where 0 is the mixed signal
    soloindex = \solo.kr(0); // 0 for mix, 1-8 for solo inputs

    // Construct an array for Select.ar to choose from, placing mixedInput at index 0
    // This ensures that soloindex directly corresponds to the user's choice
    soloedInput = Select.ar(soloindex, [mixedInput] ++ inputs);

    // Output the final signal
    Out.ar(out, soloedInput);
}).writeDefFile(d);
)

(
SynthDef.new(\polymixer13, {
    arg in=0, in2=0, in3=0, in4=0, in5=0, in6=0, in7=0, in8=0, out=0, soloindex=0;
    var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
    var inputs, mixedInput, soloedInput, finalsig;
	var mute=\mute.kr(1!8);
    // Inputs
	sig1 = In.ar(in, 13)*\levels1.kr(0.5!13, 1/30, fixedLag:true)*mute[0];
	sig2 = In.ar(in2, 13)*\levels2.kr(0.5!13, 1/30, fixedLag:true)*mute[1];
	sig3 = In.ar(in3, 13)*\levels3.kr(0.5!13, 1/30, fixedLag:true)*mute[2];
	sig4 = In.ar(in4, 13)*\levels4.kr(0.5!13, 1/30, fixedLag:true)*mute[3];
	sig5 = In.ar(in5, 13)*\levels5.kr(0.5!13, 1/30, fixedLag:true)*mute[4];
	sig6 = In.ar(in6, 13)*\levels6.kr(0.5!13, 1/30, fixedLag:true)*mute[5];
	sig7 = In.ar(in7, 13)*\levels7.kr(0.5!13, 1/30, fixedLag:true)*mute[6];
	sig8 = In.ar(in8, 13)*\levels8.kr(0.5!13, 1/30, fixedLag:true)*mute[7];

    // Combine all signals into an array
    inputs = [sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8];

    // Mix inputs channel-wise to maintain multi-channel structure
    mixedInput = Array.fill(13, {|chan|
        inputs.collect {|input| input[chan]}.sum
    });

    // Adjust the soloindex to range from 0 to 8, where 0 is the mixed signal
    soloindex = \solo.kr(0); // 0 for mix, 1-8 for solo inputs

    // Construct an array for Select.ar to choose from, placing mixedInput at index 0
    // This ensures that soloindex directly corresponds to the user's choice
    soloedInput = Select.ar(soloindex, [mixedInput] ++ inputs);
	finalsig=soloedInput*\masterlevel.kr(1!13, 1/30, fixedLag:true);

    // Output the final signal
    Out.ar(out, finalsig);
}).writeDefFile(d);
)

