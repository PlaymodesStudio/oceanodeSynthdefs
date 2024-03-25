(
SynthDef(\envelope13, {
	arg out = 0;
	var type=\type.kr(0!13);
	var gate=\trigger.kr(0!13);
	var att=\att.kr(10!13)/1000.0;
	var dec=\dec.kr(10!13)/1000.0;
	var sus=\sus.kr(1!13);
	var rel=\rel.kr(1000!13)/1000.0;
	var curv=\curve.kr(-4!13); //-8 a 8
	var lev=\level.kr(1!13);
	var sig, types;

	types=[
		EnvGen.ar(Env.adsr(att,dec,sus,rel,lev, curv),gate);
		EnvGen.ar(Env.perc(att,rel,lev,curv),gate);
	];

	sig =Select.ar(type,types);
	Out.ar(out,sig)
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
