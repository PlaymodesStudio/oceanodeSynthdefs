(
~synthCreator.value("Quantizer", { |n|
    var source;
    var flatQraw, qArr;
    var qSizeRaw, qSize, outSig, quant;
    var amountRaw, amtArr;
    var levelsRaw, lvlArr;
    var maxEntries = 32;

    // 1) Input audio (n channels)
    source = In.ar(OceanodeInput.kr(\in), n);

    // 2) Single quant-table: maxEntries channels (shared by all input channels)
    flatQraw = OceanodeParameter.ar(\qlist, 0, maxEntries, 0, 128, "vf");  // Changed range to 0-128
    qArr = flatQraw.asArray;

    // 3) Number of valid entries (same for all channels)
    qSizeRaw = OceanodeParameter.kr(\qsize, 1, 1, 1, maxEntries, "i");
    qSize = qSizeRaw;

    // 4) Quant amount & smoothed levels (audio-rate, per channel)
    amountRaw = OceanodeParameter.ar(\amount, 1, n, 0, 1, "vf");
    amtArr = amountRaw.asArray;


    // 5) Build each channel's quantizer (all using same qlist)
    outSig = n.collect({ |ch|
        var inS = source[ch];
        var minD = DC.ar(1e9);    // initial "huge" distance
        var closest = qArr[0];    // Initialize to first quantization value

        maxEntries.do({ |j|
            var qv = qArr[j];     // All channels use same qlist: qArr[0], qArr[1], etc.
            var dist = (inS - qv).abs;
            // mask out slots beyond qSize (add huge penalty if invalid)
            var validMask = (qSize > j).asFloat;
            var maskedDist = dist + ((1 - validMask) * DC.ar(1e5));
            var isCloser = maskedDist < minD;
            closest = Select.ar(isCloser, [closest, qv]);
            minD = Select.ar(isCloser, [minD, maskedDist]);
        });

        // mix original ↔ quantized, then apply level
        quant = LinSelectX.ar(amtArr[ch], [inS, closest]);
    });

    // 6) Write out all channels
    Out.ar(OceanodeOutput.kr(\out), outSig);
},
description: "Quantizes input signal to nearest values in qlist (all channels use same qlist)",
category: "Utilities/Math"
);
)