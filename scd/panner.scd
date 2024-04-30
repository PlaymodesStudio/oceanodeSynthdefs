(//Panner 13chan
SynthDef.new(\panner13, {
	arg in, out=0;
	var sig, pos=1,lvl=1,wdth=2,orient=0.5;
	pos=\position.kr(0, 1/30, fixedLag:true); //rang 0-26
	lvl=\level.kr(1);
	wdth=\width.kr(2);
	// orient=\orientation.kr(0.5);
	sig = In.ar(in, 1);
	sig=PanX.ar(13,sig,pos,lvl,wdth);
	Out.ar(out, sig);
}).writeDefFile(d);
)

PanAz