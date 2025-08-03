File.mkdir(d ++ "/" ++ "convolution");

(1..~maxVoices).do({ arg n;
    var numChan = n;
    SynthDef.new(\convolution ++ numChan.asSymbol, {
        arg in, out, irspectrum, partsize = 1024, mix = 0, levels = 0.5;
        var input, convolved, output;

        input = In.ar(in, numChan);

        // Handle per-channel convolution with different buffers
        convolved = if(numChan == 1, {
            // Single channel case
            PartConv.ar(input, partsize, irspectrum, 0.1);
        }, {
            // Multichannel case - convert to array first
            input.asArray.collect { |chan, i|
                var bufferForThisChannel = irspectrum + i; // Use buffer array offset
                PartConv.ar(chan, partsize, bufferForThisChannel, 0.1);
            };
        });

        // Mix and apply gain
        output = (input * (1 - mix)) + (convolved * mix);
        output = output * levels;

        Out.ar(out, output);
    }).writeDefFile(d ++ "/convolution");
});