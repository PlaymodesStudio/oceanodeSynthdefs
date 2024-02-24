b = Buffer.alloc(s, 1024, 5);
b.free;

(
SynthDef.new(\aliasingSynth, {
	//Aliasing Synth. Based on a Reaktor Ensemble by Dietrich Pank.
	//https://www.native-instruments.com/es/reaktor-community/reaktor-user-library/entry/show/5241/:
	//Coded by Santi Vilanova (Playmodes) and Eric Sluyter, with the invaluable help of Thor_Madsen


	arg in=0,out=0;
	var b, writeSig, writePos, readPos;
	var aliased,filteredHP,filteredLP,inputLPfm,inputHPfm,finalsig,writef,readf;

	var readratio=\readratio.kr(1!5); //0-5
	var readfine=\readfine.kr(0.04!5); //-0.5 0.5
	var writeratio=\writeratio.kr(2!5); //0-5
	var writefine=\writefine.kr(0.051!5); //-0.5 0.5
	var transpose=\transpose.kr(0!5); //-2 2

	var readlfofreq=\readlfofreq.kr(0.01!5)*12; //normalized input
	var writelfofreq=\writelfofreq.kr(0.0013!5)*12;
	var readlfoamp=\readlfoamp.kr(0.01!5); //normalized input
	var writelfoamp=\writelfoamp.kr(0.001!5);

	var lppitch=\lppitch.kr(120).midicps; //0-130
	var lpres=\lpres.kr(0.7);
	var hppitch=\hppitch.kr(20).midicps;
	var hpres=\hpres.kr(0.7);
	var lpfm=\lpfm.kr(1000); //0-3000
	var hpfm=\hpfm.kr(0);
	var drive=\dbdrive.kr(10); //0-30db

	b = LocalBuf.new(1024,5);

	//aliasing synth (5 voices)
	writef=SinOsc.kr(writelfofreq,0,writelfoamp)+writeratio+writefine+transpose;
	readf=SinOsc.kr(readlfofreq,0,readlfoamp)+readratio+readfine+transpose;

	///////////////just for testing
	//writef=MouseX.kr(0,5)!5;
	//readf=MouseY.kr(0,5)!5;
	//////////////

	writePos = Phasor.ar(0.0, writef, 0.0, BufFrames.kr(b)); //write position header
	readPos = Phasor.ar(0.0, readf, 0.0, BufFrames.kr(b)); //read position header
	BufWr.ar(readPos, b, writePos); //in the original synth, writeSig=readPos
	aliased = Splay.ar(BufRd.ar(5, b, readPos)); //aliasing synthesis result, 5 voices spread across stereo


	//filter  (stereo)
	inputLPfm=aliased*lpfm; //we use the input also as an FM source
	inputHPfm=aliased*hpfm;

	filteredHP=BHiPass4.ar(aliased,hppitch+inputHPfm,hpres,drive.dbamp).tanh;//LP filter and saturation
	filteredLP=BLowPass4.ar(filteredHP,lppitch+aliased,lpres); //HP filtering in series

	//final signal conditioning
	finalsig=LeakDC.ar(filteredLP,0.995,drive.dbamp).tanh; //final saturation and dc correction
	finalsig=Limiter.ar(finalsig*0.1);
	Out.ar(out, finalsig);

}).play();
)


(
SynthDef.new(\aliasingsynth13, {
	//Aliasing Synth. Based on a Reaktor Ensemble by Dietrich Pank.
	//https://www.native-instruments.com/es/reaktor-community/reaktor-user-library/entry/show/5241/:
	//Coded by Santi Vilanova (Playmodes) and Eric Sluyter, with the invaluable help of Thor_Madsen


	arg in=0,out=0;
	var b, writeSig, writePos, readPos;
	var aliased,filteredHP,filteredLP,inputLPfm,inputHPfm,finalsig,writef,readf;

	var levels=\levels.kr(1!13);

	var readratio=\readratio.kr(1!13); //0-5
	var readfine=\readfine.kr(0.04!13); //-0.5 0.5
	var writeratio=\writeratio.kr(2!13); //0-5
	var writefine=\writefine.kr(0.051!13); //-0.5 0.5
	var transpose=\transpose.kr(0!13); //-2 2

	var readlfofreq=\readlfofreq.kr(0.01!13)*12; //normalized input
	var writelfofreq=\writelfofreq.kr(0.0013!13)*12;
	var readlfoamp=\readlfoamp.kr(0.01!13); //normalized input
	var writelfoamp=\writelfoamp.kr(0.001!13);

	b = LocalBuf.new(1024,13);

	//aliasing synth (5 voices)
	writef=SinOsc.kr(writelfofreq,0,writelfoamp)+writeratio+writefine+transpose;
	readf=SinOsc.kr(readlfofreq,0,readlfoamp)+readratio+readfine+transpose;

	writePos = Phasor.ar(0.0, writef, 0.0, BufFrames.kr(b)); //write position header
	readPos = Phasor.ar(0.0, readf, 0.0, BufFrames.kr(b)); //read position header
	BufWr.ar(readPos, b, writePos); //in the original synth, writeSig=readPos
	aliased = BufRd.ar(13, b, readPos); //aliasing synthesis result, 5 voices spread across stereo

	//final signal conditioning
	finalsig=LeakDC.ar(aliased,0.995); //final saturation and dc correction
	finalsig=Limiter.ar(finalsig*0.1);
	Out.ar(out, finalsig*levels);

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

