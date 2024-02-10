(/// sync saw
SynthDef(\syncsaw, {
	arg out;
	var f,sf,sig,lv;
	lv=\levels.kr(0!78, 1/30, fixedLag:true);
	f=\pitch.kr(24!78).midicps;
	sf=\synchz.kr(440!78, 0.1, fixedLag:true);
	sig=SyncSaw.ar(f,sf,lv,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// sync saw
SynthDef(\syncsaw13, {
	arg out;
	var f,sf,sig,lv;
	lv=\levels.kr(0!13, 1/30, fixedLag:true);
	f=\pitch.kr(24!13).midicps;
	sf=\synchz.kr(440!13, 0.1, fixedLag:true);
	sig=SyncSaw.ar(f,sf,lv,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(/// sync saw
SynthDef(\syncsawmono, {
	arg out;
	var f,sf,sig,lv;
	lv=\levels.kr(0!1, 1/30, fixedLag:true);
	f=\pitch.kr(24!1).midicps;
	sf=\synchz.kr(440!1, 0.1, fixedLag:true);
	sig=SyncSaw.ar(f,sf,lv,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)