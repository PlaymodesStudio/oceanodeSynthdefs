// channelroutermatrix.scd - Channel Router Matrix with gain compensation and bypass
// Routes inputs to outputs with configurable gain matrix, automatic compensation, and bypass
var d, channelRouterMatrixDir;
if(thisProcess.nowExecutingPath.notNil) {
    d = thisProcess.nowExecutingPath.dirname +/+ "/CompiledSynthdefs";
} {
    d = Platform.userAppSupportDir +/+ "/SuperCollider/CompiledSynthdefs";
};
channelRouterMatrixDir = d +/+ "/channelroutermatrix";
File.mkdir(d);
File.mkdir(channelRouterMatrixDir);
[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,20,21,24,25,30].do({|numChannels|
    var synthName = ("channelRouterMatrix" ++ numChannels).asSymbol;
    var matrixSize = numChannels * numChannels;
    SynthDef(synthName, {
        arg in=0, out=0, compensation=1, bypass=0;
        var sig, matrix, output, numOverlaps, compensationFactor, finalOutput;
        // Input - read the specified number of channels
        sig = In.ar(in, numChannels);
        // Routing matrix - flattened array [in0_out0, in0_out1, ..., in1_out0, in1_out1, ...]
        // Each element is gain from input to output (0.0-1.0)
        matrix = NamedControl.kr(\matrix, Array.fill(matrixSize, {|i|
            var row = (i / numChannels).floor;
            var col = i % numChannels;
            // Default identity matrix
            if(row == col, {1.0}, {0.0});
        }));
        // Initialize output array
        output = Array.fill(numChannels, 0.0);
        // For each output channel
        numChannels.do({|outChan|
            var channelSum = 0.0;
            var activeInputCount = 0;
            var compFactor = 1.0;
            // First pass: count how many inputs are routed to this output
            numChannels.do({|inChan|
                var matrixIndex = (inChan * numChannels) + outChan;
                var gain = matrix.at(matrixIndex);
                // Count active inputs (gain > 0.0)
                activeInputCount = activeInputCount + (gain > 0.0).asInteger;
            });
            // Calculate compensation factor based on overlap count
            compFactor = Select.kr(compensation, [
                // 0 = 0dB: no compensation
                1.0,
                // 1 = -3dB per overlap: 1 / sqrt(numOverlaps)
                Select.kr(activeInputCount > 0, [
                    1.0,  // If no inputs, use 1.0
                    1.0 / activeInputCount.sqrt
                ]),
                // 2 = -6dB per overlap: 1 / numOverlaps
                Select.kr(activeInputCount > 0, [
                    1.0,  // If no inputs, use 1.0
                    1.0 / activeInputCount
                ])
            ]);
            // Second pass: sum all inputs with their gains and compensation
            numChannels.do({|inChan|
                var matrixIndex = (inChan * numChannels) + outChan;
                var gain = matrix.at(matrixIndex);
                // Apply compensation BEFORE user gain
                // finalGain = inputSignal * compensation * userGain
                channelSum = channelSum + (sig.at(inChan) * compFactor * gain);
            });
            output[outChan] = channelSum;
        });

        // Bypass: crossfade between processed output and dry input
        // When bypass=0: output processed signal
        // When bypass=1: output dry input (identity routing)
        finalOutput = Select.ar(bypass, [
            output,  // bypass=0: processed
            sig      // bypass=1: dry input
        ]);

        // Output the final signal
        Out.ar(out, finalOutput);
    }).writeDefFile(channelRouterMatrixDir);
    // Progress indication
    if([1, 2, 4, 8, 16].includes(numChannels)) {
        ("✅ Created: " ++ synthName ++ " (" ++ numChannels ++ " channels)").postln;
    };
});
("✅ Channel Router Matrix SynthDefs created successfully").postln;
("• Compensation modes: 0dB, -3dB, -6dB").postln;
("• Matrix format: row-major [in0_out0, in0_out1, ..., in1_out0, ...]").postln;
("• Compensation applied BEFORE user gain").postln;
("• Bypass: 0 = processed, 1 = dry pass-through").postln;