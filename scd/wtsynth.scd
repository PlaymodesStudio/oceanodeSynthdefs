(
SynthDef(\wtsynth13_no_va,
	{
	arg out=0;
	var buf=0, freq, amp, sig, bufmod;
	buf=\bufnum.kr(0!13);
	amp=\levels.kr(1!13, 1/30, fixedLag: true);
	bufmod =\wtpos.kr(0!13, 1/30, fixedLag: true); //rang depen del numero de bufers
	freq =\pitch.kr(36!13, 1/30, fixedLag: true).midicps;
	sig = VOsc.ar(buf+bufmod, freq);
	sig = LeakDC.ar(sig);
	Out.ar(out, sig*amp);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


(
SynthDef(\wtsynth13,{
	arg out=0;
    var buf,gate=1,fq=5,sig1,sig2,sig3,sig4,sig5,sig6,sig7,sig8,mix,vib,signal,amp,pos;
	buf=\bufnum.kr(0!13, 1/30, fixedLag: true);
	pos=\wtpos.kr(0!13, 1/30, fixedLag: true);
	amp=\levels.kr(1!13, 1/30, fixedLag: true);
	fq=2.pow((\pitch.kr(36!13, 1/30, fixedLag: true)-38)/12);

	sig1=PlayBuf.ar(1,buf[0],fq,1,0,1);
	sig2=PlayBuf.ar(1,buf[1],fq,1,0,1);
	sig3=PlayBuf.ar(1,buf[2],fq,1,0,1);
	sig4=PlayBuf.ar(1,buf[3],fq,1,0,1);
	sig5=PlayBuf.ar(1,buf[4],fq,1,0,1);
	sig6=PlayBuf.ar(1,buf[5],fq,1,0,1);
	sig7=PlayBuf.ar(1,buf[6],fq,1,0,1);
	sig8=PlayBuf.ar(1,buf[7],fq,1,0,1);

	mix=SelectX.ar(pos,[sig1,sig2,sig3,sig4,sig5,sig6,sig7,sig8],1);

	Out.ar(out, mix*amp);
}).writeDefFile(d);
)



