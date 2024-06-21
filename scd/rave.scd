(
// loading
s.reboot.waitForBoot {
    NN.load(\perc, "/Users/santiagovilanova/Documents/RAVE_MODELS/percussion.ts");
};
)


// resynth live input
{ NN(\perc, \forward).ar(SoundIn.ar) }.play


(
SynthDef(\ravepercussion, {
	arg in = 0, out =0;
	var sig,amp;
	NN.load(\perc, "/Users/santiagovilanova/Documents/RAVE_MODELS/percussion.ts");

	amp=\levels.kr(1!2, 1/30, fixedLag: true);

	sig = SoundIn.ar(in, 1);
	sig=NN(\perc, \forward).ar(sig);
	Out.ar(out, sig*amp);

}).play();
)

d = thisProcess.nowExecutingPath.dirname;