d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\solochannel13, {
    arg out=0, in=0;
	var soloch=\soloch.kr(0);
    var input, selectedChannel, output;

    // Input is 13 channels
    input = In.ar(in, 13);

    // Select the channel based on soloch parameter
    selectedChannel = Select.ar(soloch, input);

    // Duplicate the selected channel 13 times
    output = Array.fill(13, selectedChannel);

    // Output all 13 channels
    Out.ar(out, output);
}).writeDefFile(d);
)