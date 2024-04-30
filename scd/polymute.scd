(
SynthDef.new(\polymute13, {
    arg in=0, in2=0, in3=0, in4=0, in5=0, in6=0, in7=0, in8=0,
	out=0, out2=0, out3=0, out4=0, out5=0, out6=0, out7=0, out8=0;
    var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;

	var mute=\mute.kr(1!8); //8 inputs, un mute per input
    // Inputs
	sig1 = In.ar(in, 13)*mute[0];
	sig2 = In.ar(in2, 13)*mute[1];
	sig3 = In.ar(in3, 13)*mute[2];
	sig4 = In.ar(in4, 13)*mute[3];
	sig5 = In.ar(in5, 13)*mute[4];
	sig6 = In.ar(in6, 13)*mute[5];
	sig7 = In.ar(in7, 13)*mute[6];
	sig8 = In.ar(in8, 13)*mute[7];

    Out.ar(out, sig1);
	Out.ar(out2, sig2);
	Out.ar(out3, sig3);
	Out.ar(out4, sig4);
	Out.ar(out5, sig5);
	Out.ar(out6, sig6);
	Out.ar(out7, sig7);
	Out.ar(out8, sig8);

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
