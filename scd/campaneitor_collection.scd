(//campaneitor auditori
SynthDef.new(\campaneitorsignes, {
	arg in, out=0;
	var sig, spr=1,lvl=1,wdth=2,cnt=0,orient=0.5, pos;
	lvl=\level.kr(1);
	wdth=\width.kr(2);
	orient=\orientation.kr(0.5);

	sig = In.ar(in, 27);
	sig = sig.asArray.reshape(3,9);
	sig = Mix.ar(sig);

	pos = [0.0] ++ [0, 1].resamp1(7) ++ [1.0]; //per que 7?
	sig = PanX.ar(4, sig, pos, lvl*sig.size.reciprocal.sqrt, wdth).flop.collect(Mix(_));

	Out.ar(out, sig);
}).writeDefFile(d);
)

(//campaneitor unna
SynthDef.new(\campaneitorsignes, {
	arg in, out=0;
	var sig, spr=1,lvl=1,wdth=2,cnt=0,orient=0.5, pos;
	lvl=\level.kr(1);
	wdth=\width.kr(2);
	orient=\orientation.kr(0.5);

	sig = In.ar(in, 48);
	sig = sig.asArray.reshape(4,12);
	sig = Mix.ar(sig);

	pos = [0.0] ++ [0, 1].resamp1(10) ++ [1.0];
	sig = PanX.ar(6, sig, pos, lvl*sig.size.reciprocal.sqrt, wdth).flop.collect(Mix(_));

	Out.ar(out, sig);
}).writeDefFile(d);
)