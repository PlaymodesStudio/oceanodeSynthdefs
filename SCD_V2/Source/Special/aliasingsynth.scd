(
~synthCreator.value("AliasingSynth", {|n|
	var b, writeSig, writePos, readPos;
	var aliased, filteredHP, filteredLP, inputLPfm, inputHPfm, finalsig, writef, readf;
	var levels, readratio, readfine, writeratio, writefine, transpose;
	var readlfofreq, writelfofreq, readlfoamp, writelfoamp;

	// Parameters
	levels = OceanodeParameter.ar(\levels, 1, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
	
	// Ratio parameters
	readratio = OceanodeParameter.ar(\readratio, 1, n, 0, 5, "vf");
	readfine = OceanodeParameter.ar(\readfine, 0.04, n, -0.5, 0.5, "vf");
	writeratio = OceanodeParameter.ar(\writeratio, 2, n, 0, 5, "vf");
	writefine = OceanodeParameter.ar(\writefine, 0.051, n, -0.5, 0.5, "vf");
	transpose = OceanodeParameter.ar(\transpose, 0, n, -2, 2, "vf");
	
	// LFO parameters
	readlfofreq = OceanodeParameter.ar(\readlfofreq, 0.01, n, 0, 1, "vf") * 12;
	writelfofreq = OceanodeParameter.ar(\writelfofreq, 0.0013, n, 0, 1, "vf") * 12;
	readlfoamp = OceanodeParameter.ar(\readlfoamp, 0.01, n, 0, 1, "vf");
	writelfoamp = OceanodeParameter.ar(\writelfoamp, 0.001, n, 0, 1, "vf");

	// Buffer for aliasing synthesis
	b = LocalBuf.new(1024, n);

	// Calculate write and read frequencies with LFO modulation
	writef = SinOsc.kr(writelfofreq, 0, writelfoamp) + writeratio + writefine + transpose;
	readf = SinOsc.kr(readlfofreq, 0, readlfoamp) + readratio + readfine + transpose;

	// Create write and read position phasors
	writePos = (Phasor.ar(0.0, writef, 0.0, BufFrames.kr(b)) * 2) - 1; // Write position header
	readPos = Phasor.ar(0.0, readf, 0.0, BufFrames.kr(b)); // Read position header
	
	// Write read position to buffer
	BufWr.ar(readPos, b, writePos); // In the original synth, writeSig=readPos
	
	// Read from buffer to create aliasing effect
	aliased = (BufRd.ar(n, b, readPos) * 2) - 1; // Aliasing synthesis result

	// Final signal conditioning
	finalsig = LeakDC.ar(aliased, 0.995); // DC correction
	finalsig = Limiter.ar(finalsig * 0.1); // Limiting
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), finalsig * levels);
}, description: "Aliasing synthesizer based on buffer read/write with modulated phasors", category: "Source/Special");
)