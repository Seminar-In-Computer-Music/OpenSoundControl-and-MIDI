(

//////////////////////////SYNTHS

SynthDef(\filtered,
	{arg freq = 100,fmult = 6,
		amount= 1,amp = 0.5,envlen = 0.071,effBus = 16,eff1Amp = 0,eff2Amp = 0,eff3Amp = 0,eff4Amp = 0,
		gate=1;
		var sound=HPF.ar(LPF.ar(Saw.ar((freq*fmult) +SinOsc.ar(20, 0, amount), (EnvGen.ar(Env([0, 1, 1, 0], [0.8, 0.5, 0.7]), gate, 1, 0, envlen, 2))), 16900), 50);
		Out.ar([0, 1], Limiter.ar(sound*amp, 0.5));
		Out.ar(effBus, [sound*eff1Amp, sound*eff2Amp, sound*eff3Amp, sound*eff4Amp]);
}).store;

	SynthDef("playbuf1",   //plays the recording of the synth bus with the below Pbind and also sends some of its signal back into the effects
	{ arg
		buffer,
		rate=1,
		trigger=1,
		startPos=0,
		loop=1,
		envlen =1,
		pan = 0,
		amp = 1,
		lpf = 6600,
		effBus,
		eff1Amp = 0,eff2Amp = 0,eff3Amp = 0,eff4Amp = 0,
		fftBus,
		fft1Amp = 0,fft2Amp = 0,fft3Amp = 0,fft4Amp = 0;
		var sound =
		HPF.ar(LPF.ar(Pan2.ar(
				PlayBuf.ar(1,buffer, BufRateScale.kr(buffer)*rate,trigger,
					BufFrames.ir(buffer)*startPos, loop),0.0, amp*(EnvGen.ar(Env([0, 1, 0], [0.5, 0.5]), 1, 1, 0, envlen, 2))), lpf, 1), 0050, 1);      Out.ar(effBus, [sound*eff1Amp, sound*eff2Amp, sound*eff3Amp, sound*eff4Amp]);
		Out.ar(fftBus, [sound*fft1Amp, sound*fft2Amp, sound*fft3Amp, sound*fft4Amp]);
		Out.ar(21, Limiter.ar(sound*amp));
		Out.ar(0, Limiter.ar(sound*amp));
		}).store;

	SynthDef("playbuf2",   //plays the recording of the synth bus with the below Pbind and also sending siglad ONLY to effects has to be received by somthing to be heard
	{ arg
		buffer,
		rate=1,
		trigger=1,
		startPos=0,
		loop=1,
		envlen =1,
		pan = 0,
		amp = 1,
		lpf = 6600,
		effBus,
		eff1Amp = 0,eff2Amp = 0,eff3Amp = 0,eff4Amp = 0,
		fftBus,
		fft1Amp = 0,fft2Amp = 0,fft3Amp = 0,fft4Amp = 0;
		var sound =
		HPF.ar(LPF.ar(Pan2.ar(
				PlayBuf.ar(1,buffer, BufRateScale.kr(buffer)*rate,trigger,
					BufFrames.ir(buffer)*startPos, loop),0.0, amp*(EnvGen.ar(Env([0, 1, 0], [0.5, 0.5]), 1, 1, 0, envlen, 2))), lpf, 1), 0050, 1);      Out.ar(effBus, [sound*eff1Amp, sound*eff2Amp, sound*eff3Amp, sound*eff4Amp]);
		Out.ar(fftBus, [sound*fft1Amp, sound*fft2Amp, sound*fft3Amp, sound*fft4Amp]);
		}).store;



/////////////////////////FXXX

/*SynthDef(\dev,{arg
	inBus=16,
	delay=0.02,
	decay=1.5,
	amp=1;
	Out.ar([0], CombN.ar(In.ar(inBus,1),1.0,delay,decay).dup,amp)
}).store;
*/

SynthDef(\freeze, {arg      // cant get this to work with out being VERY LOUD
		inBus=16,
	amp= 1,
	fre;
    var in, chain;
    in = In.ar(inBus,1);
    chain = FFT(LocalBuf(2048), in);
    chain = PV_MagFreeze(chain, fre);
	    Out.ar([0], 0.1*IFFT(chain).dup);
}).store;

SynthDef(\reverb,{arg
	inBus=16,
	size=1,
	damp=0.2,
	eout,
	amp=1,
	ampALL = 1;
	Out.ar(20,Limiter.ar(ampALL*FreeVerb.ar(In.ar(inBus,1),1,SinOsc.kr(0.5, 0, 200, 200)*size,damp,amp)));
	Out.ar(0,  Limiter.ar(ampALL*FreeVerb.ar(In.ar(inBus,1),1,SinOsc.kr(0.5, 0, 200, 200)*size,damp,amp)).dup);
}).store;

SynthDef("mafs",
	{arg threshold= 2,
		amp=0.5,
		inBus,
		wipe = 0,
		width = 0.2;
	var chain;
		chain = FFT(LocalBuf(2048), In.ar(inBus), 0.01);
		chain = PV_BinScramble(chain, SinOsc.ar(0.2, 0, 0.5, 0.5), SinOsc.ar(0.35, 0, 0.5, 0.5), Dust.ar(0.2));
	IFFT(chain);
		Out.ar([0, 1], Limiter.ar(IFFT(chain), 0.6))}).play;

SynthDef("randWipe", { arg amp = 1,
	inbus1 = ~fftBus[\fft2].index,
	inbus2 = ~effBus[\fft1].index;
    var inA, chainA, inB, chainB, chain;
	    inA = In.ar(inbus1);
    inB = In.ar(inbus2);
    chainA = FFT(LocalBuf(2048), inA);
    chainB = FFT(LocalBuf(2048), inB);
	    chain = PV_RandWipe(chainA, chainB, SinOsc.kr(0.353, 0, 0.5, 0.5), Dust.ar(0.5));
	Out.ar(0, amp*0.5 * Limiter.ar(IFFT(chain), 0.7));}).play;


/////////////////////////ORDERING

~effGroup = Group.tail(1);
~effBus = (r1: Bus.audio(s,1), fre2: Bus.audio(s,1), ps3: Bus.audio(s,1));

~fftGroup = Group.tail(1);
~fftBus = (fft1: Bus.audio(s,1), fft2: Bus.audio(s,1), fft3: Bus.audio(s,1));

/////////////////////////Buffers

r = Buffer.alloc(s,s.sampleRate*15.0, 1);
k = Buffer.alloc(s,s.sampleRate*15.0,1);
b = Buffer.read(s, "/Users/jesstambellini/Desktop/sounds/ADVORCHT19.wav");


SynthDef(\recSoundIn, {RecordBuf.ar(In.ar(20), r, loop: 2)}).add;
SynthDef(\recSoundIna, {RecordBuf.ar(In.ar(21), k,loop: 2)}).add;



Synth.tail(~effGroup, \recSoundIn);
Synth.tail(~effGroup, \recSoundIna);


 )
/////////////////////////Midi stuff


(
MIDIIn.connectAll;

MIDIdef.cc(\test1,{ arg ... args;
	var fromMIDIarray, e = args*145;
	fromMIDIarray = e.at(0);
	{SinGrain.ar(1, 0.14, fromMIDIarray, 0.3*EnvGen.ar(Env.perc, doneAction: 2))}.play;
}, 8, 7);

MIDIdef.cc(\test2,{ arg ... args;
	var fromMIDIarray, e = args*15;
	fromMIDIarray = e.at(0);
	{SinGrain.ar(1, 0.14, fromMIDIarray, 0.3*EnvGen.ar(Env.perc, doneAction: 2))}.play;
}, 9, 7);

MIDIdef.cc(\tes3t,{ arg ... args;
	var fromMIDIarray, e = args*115;
	fromMIDIarray = e.at(0);
	{SinGrain.ar(1, 0.14, fromMIDIarray, 0.3*EnvGen.ar(Env.perc, doneAction: 2))}.play;
}, 10, 7);

MIDIdef.cc(\test4,{ arg ... args;
	var fromMIDIarray, e = args*165;
	fromMIDIarray = e.at(0);
	{SinGrain.ar(1, 0.4, fromMIDIarray, 0.3*EnvGen.ar(Env.perc, doneAction: 2))}.play;
}, 11, 7);

MIDIdef.cc(\test5,{ arg ... args;
	var fromMIDIarray, e = args*2555;
	fromMIDIarray = e.at(0);
	{SinGrain.ar(1, 0.4, fromMIDIarray, 0.3*EnvGen.ar(Env.perc, doneAction: 2))}.play;
}, 12, 7);


MIDIdef.cc(\test6,{ arg ... args;
	var fromMIDIarray, e = args*245;
	fromMIDIarray = e.at(0);
	{SinGrain.ar(1, 0.664, fromMIDIarray, 0.3*EnvGen.ar(Env.perc, doneAction: 2))}.play;
}, 13, 7);

MIDIdef.cc(\test7,{ arg ... args;
	var fromMIDIarray, e = args*225;
	fromMIDIarray = e.at(0);
	{SinGrain.ar(1, 1.4, fromMIDIarray, 0.3*EnvGen.ar(Env.perc, doneAction: 2)).dup}.play;
}, 14, 7);

MIDIdef.cc(\test8,{ arg ... args;
	var fromMIDIarray, e = args*335;
	fromMIDIarray = e.at(0);
	{SinGrain.ar(1, 2.4, fromMIDIarray, 0.3*EnvGen.ar(Env.perc, 1, 1, 0, 4, doneAction: 2))}.play;
}, 15, 7);

///////////////////////////////

Pdef(\121).fadeTime = 0;    /// not sure if these are doing anything
Pdef(\121).quant = 0;

~cc0 = 1; ~cc1 = 1; ~cc2 = 1; ~cc3 = 1; ~cc4 = 1; ~cc5 = 1; ~cc6 = 1; ~cc7 = 1;

MIDIdef.cc(\button1filtered,{ arg cc, midinumber, channel, deviceID; var
	cc0, cc1, cc2, cc3, cc4,cc5,cc6,  cc7, b = [cc,  midinumber, channel, deviceID];
	    if(b.at(1)==0, {~cc0 = cc}, {~cc0});
     	if(b.at(1)==1, {~cc1 = cc}, {~cc1});
		if(b.at(1)==2, {~cc2 = cc}, {~cc2});
		if(b.at(1)==3, {~cc3 = cc}, {~cc3});
		if(b.at(1)==4, {~cc4 = cc}, {~cc4});
		if(b.at(1)==5, {~cc5 = cc}, {~cc5});
		if(b.at(1)==6, {~cc6 = cc}, {~cc6});
		if(b.at(1)==7, {~cc7 = cc}, {~cc7});
	Pdef(\121, Pbindef(\this, \instrument,\filtered,
		\amp, Pfunc({LinLin.kr(~cc0, 0, 128, 0, 1.4)}),
		\freq,Pwhite(Pfunc({~cc1}), Pfunc({LinLin.kr(~cc2, 0, 127, 127, 2000)})),
				\dur, Pfunc({LinLin.kr(~cc3, 0, 127, 0.01, 0.3)}),
                \group, 1,
		\envlen, (Pfunc({(LinLin.kr(~cc4, 0, 127, 0.0001, 1))})),
				\fmult, Pfunc({LinLin.kr(~cc5, 0, 127, 0.01, 10)}),
		\amount, Pfunc({LinLin.kr(~cc6, 0, 127, 1, 200)}),
		\eff1Amp, 1.1,
		        \eff2Amp, 0.6,
			\eff3Amp, 0.3).play)});


// need to give this a gate to turn on and off right now i just turn it off by turning it down.....

///////////////////////////////


Pdef(\playthatbrass).fadeTime = 0;
Pdef(\playthatbrass).quant = 0;

~cca0 = 0.0001; ~cca1 = 1; ~cca2 = 1; ~cca3 = 1; ~cca4 = 1; ~cca5 = 1; ~cca6 = 1; ~cca7 = 1;

MIDIdef.cc(\button3playbufbrass,{ arg cca, midinumbera, channela, deviceIDa; var
	c = [cca,  midinumbera, channela, deviceIDa];
	c.postln;
	    if(c.at(1)==16, {~cca0 = cca}, {~cca0});
     	if(c.at(1)==17, {~cca1 = cca}, {~cca1});
		if(c.at(1)==18, {~cca2 = cca}, {~cca2});
		if(c.at(1)==19, {~cca3 = cca}, {~cca3});
		if(c.at(1)==20, {~cca4 = cca}, {~cca4});
		if(c.at(1)==21, {~cca5 = cca}, {~cca5});
		if(c.at(1)==22, {~cca6 = cca}, {~cca6});
		if(c.at(1)==23, {~cca7 = cca}, {~cca7});
Pdef(\playthatbrass, Pbind(\instrument, \playbuf1,
	\amp, Pfunc({LinLin.kr(~cca0, 0, 127, 0, 20)}),
			\rate, Pfunc({LinLin.kr(~cca1, 0, 127, 0.002, 222.5)}),
				\lpf, Pfunc({LinLin.kr(~cca2, 0, 127, 0, 6000)}),
	\buffer, b,
\fftBus, ~fftBus[\fft1].index,
	     \fft2Amp, 0,
	 \fft1Amp, 0.20,                        //thow much to send plaubuf1
			\fft3Amp, 0.1,
	\startPos, Pseq([660.rand*44100.poll, 660.rand*44100], 1),
	\dur, Pwhite(0.1, 0.7, inf),
		\envlen, Pfunc({LinLin.kr(~cca4, 0, 127, 0.02, 2)})

).play;)}, [16, 17, 18, 19, 20, 21, 22, 23])

//need to figure out a way that this wont trigger everytime i turn a knob....
)




