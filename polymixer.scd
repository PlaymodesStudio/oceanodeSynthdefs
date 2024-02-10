(//// polymixer
SynthDef.new(\polymixer, {
	arg in=0, in2=0, in3=0, in4=0, in5=0, in6=0, in7=0, in8=0, out=0;
	var sig1, sig2, sig3,sig4,sig5,sig6,sig7,sig8, finalsig;
	sig1 = In.ar(in, 78)*\levels1.kr(0.5!78, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 78)*\levels2.kr(0.5!78, 1/30, fixedLag:true);
	sig3 = In.ar(in3, 78)*\levels3.kr(0.5!78, 1/30, fixedLag:true);
	sig4 = In.ar(in4, 78)*\levels4.kr(0.5!78, 1/30, fixedLag:true);
	sig5 = In.ar(in5, 78)*\levels5.kr(0.5!78, 1/30, fixedLag:true);
	sig6 = In.ar(in6, 78)*\levels6.kr(0.5!78, 1/30, fixedLag:true);
	sig7 = In.ar(in7, 78)*\levels7.kr(0.5!78, 1/30, fixedLag:true);
	sig8 = In.ar(in8, 78)*\levels8.kr(0.5!78, 1/30, fixedLag:true);
	finalsig=sig1+sig2+sig3+sig4+sig5+sig6+sig7+sig8;
	finalsig=finalsig*\masterlevel.kr(1!78, 1/30, fixedLag:true);
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

(//// polymixer
SynthDef.new(\polymixer13, {
	arg in=0, in2=0, in3=0, in4=0, in5=0, in6=0, in7=0, in8=0, out=0;
	var sig1, sig2, sig3,sig4,sig5,sig6,sig7,sig8, finalsig;
	sig1 = In.ar(in, 13)*\levels1.kr(0.5!13, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 13)*\levels2.kr(0.5!13, 1/30, fixedLag:true);
	sig3 = In.ar(in3, 13)*\levels3.kr(0.5!13, 1/30, fixedLag:true);
	sig4 = In.ar(in4, 13)*\levels4.kr(0.5!13, 1/30, fixedLag:true);
	sig5 = In.ar(in5, 13)*\levels5.kr(0.5!13, 1/30, fixedLag:true);
	sig6 = In.ar(in6, 13)*\levels6.kr(0.5!13, 1/30, fixedLag:true);
	sig7 = In.ar(in7, 13)*\levels7.kr(0.5!13, 1/30, fixedLag:true);
	sig8 = In.ar(in8, 13)*\levels8.kr(0.5!13, 1/30, fixedLag:true);
	finalsig=sig1+sig2+sig3+sig4+sig5+sig6+sig7+sig8;
	finalsig=finalsig*\masterlevel.kr(1!13, 1/30, fixedLag:true);
	Out.ar(out, finalsig);
}).writeDefFile(d);
)

(//// polymixer
SynthDef.new(\polymixermono, {
	arg in=0, in2=0, in3=0, in4=0, in5=0, in6=0, in7=0, in8=0, out=0;
	var sig1, sig2, sig3,sig4,sig5,sig6,sig7,sig8, finalsig;
	sig1 = In.ar(in, 1)*\levels1.kr(0.5!1, 1/30, fixedLag:true);
	sig2 = In.ar(in2, 1)*\levels2.kr(0.5!1, 1/30, fixedLag:true);
	sig3 = In.ar(in3, 1)*\levels3.kr(0.5!1, 1/30, fixedLag:true);
	sig4 = In.ar(in4, 1)*\levels4.kr(0.5!1, 1/30, fixedLag:true);
	sig5 = In.ar(in5, 1)*\levels5.kr(0.5!1, 1/30, fixedLag:true);
	sig6 = In.ar(in6, 1)*\levels6.kr(0.5!1, 1/30, fixedLag:true);
	sig7 = In.ar(in7, 1)*\levels7.kr(0.5!1, 1/30, fixedLag:true);
	sig8 = In.ar(in8, 1)*\levels8.kr(0.5!1, 1/30, fixedLag:true);
	finalsig=sig1+sig2+sig3+sig4+sig5+sig6+sig7+sig8;
	finalsig=finalsig*\masterlevel.kr(1!1, 1/30, fixedLag:true);
	Out.ar(out, finalsig);
}).writeDefFile(d);
)