

(//campaneitor
SynthDef.new(\campaneitorsignes, {
	arg in, out=0;
	var sig, spr=1,lvl=1,wdth=2,cnt=0,orient=0.5, pos;
	// spr=\spread.kr(1);
	lvl=\level.kr(1);
	wdth=\width.kr(2);
	// cnt=\center.kr(0.5);
	// pos=\position.kr(0.5!26);
	orient=\orientation.kr(0.5);
	sig = In.ar(in, 78);
	sig = sig.asArray.reshape(3,26);
	sig = Mix.ar(sig);

	pos = [0.0] ++ [0, 5.5/12].resamp1(12) ++ [6.5/12, 1].resamp1(12) ++ [1.0];
	sig = PanX.ar(13, sig, pos, lvl*sig.size.reciprocal.sqrt, wdth).flop.collect(Mix(_));
	// sig = PanX.ar(13, sig, [ cnt - spr, cnt + spr ].resamp1(78), lvl*sig.size.reciprocal.sqrt, wdth).flop.collect(Mix(_));
	// sig=SplayAz.ar(13,sig.asArray,spr,lvl,wdth,cnt,orient);
	Out.ar(out, sig);
}).writeDefFile(d);
)