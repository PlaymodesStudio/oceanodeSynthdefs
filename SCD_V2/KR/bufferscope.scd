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