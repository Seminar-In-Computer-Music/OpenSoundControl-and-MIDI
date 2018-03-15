MIDIIn.connectAll

(
SynthDef(\hi,{|amp=0.5, freq=1000.0|
	var jj, pan;
	jj = LFSaw.ar(freq)*Pulse.ar(1000)*EnvGen.kr(Env.perc(0.01, 0.6), doneAction:2);
	pan = Pan2.ar(jj, -0.3);
	Out.ar(0, pan*amp);
}).add;



SynthDef(\rorange,{|amp=0.4, freq=100, dur=1.0, ind=5.0, sinin=0.2, ppan= 0|
	var index, sig, pan;
	index = SinOsc.ar(sinin, 0, 10)*ind;
	sig = LFPulse.ar(LFSaw.ar(freq, 0, SinOsc.ar(50), freq*index, 440), 10, 0.5, SinOsc.ar(50))*EnvGen.kr(Env.new([0.0, 0.5, 0.5, 0.0],[0.02, 0.2, 0.06]), doneAction: 2);
	pan = Pan2.ar(sig, ppan);
	Out.ar(0, pan*amp*0.2)
}).add;



SynthDef(\bell,{|amp=0.2, freq=500.0|
	var jj, pan;
	jj = SinOsc.ar(freq)*LFTri.ar(60)*EnvGen.kr(Env.perc(0.01, 2.0), doneAction:2);
	pan = Pan2.ar(jj);
	Out.ar(0, pan*amp*0.4);
}).add;



SynthDef(\lo,{|amp=0.5, freq=40.0|
	var jj, pan;
	jj = SinOsc.ar(freq)*LFSaw.ar(100, 0, 0.1)*EnvGen.kr(Env.perc(0.01, 2.0), doneAction:2);
	pan = Pan2.ar(jj);
	Out.ar(0, pan*amp);
}).add;


SynthDef(\bass,{|amp=0.5, freq=40.0|
	var jj, pan;
	jj = SinOsc.ar(freq)*EnvGen.kr(Env.perc(0.01, 2.0), doneAction:2);
	pan = Pan2.ar(jj);
	Out.ar(0, pan*amp*1.5);
}).add;

SynthDef(\snare,{|amp=0.5, freq=700.0|
	var jj, pan;
	jj = PinkNoise.ar(1)*Pulse.ar(freq)*EnvGen.kr(Env.perc(0.01, 0.3), doneAction:2);
	pan = Pan2.ar(jj, -0.3);
	Out.ar(0, pan*amp*0.5);
}).add;


SynthDef(\wood,{|amp=0.5, freq=700.0|
	var jj, pan;
	jj = PinkNoise.ar(0.5)*EnvGen.kr(Env.perc(0.00,0.05))+SinOsc.ar(500)*SinOsc.ar(freq)*EnvGen.kr(Env.perc(0.00, 0.3), doneAction:2);
	pan = Pan2.ar(jj, -0.3);
	Out.ar(0, pan*amp*0.5);
}).add;

SynthDef(\click,{|amp=0.5, freq=1500.0|
	var jj, pan;
	jj = Blip.ar(freq)*Blip.ar(1300)*EnvGen.kr(Env.perc(0.01, 0.2), doneAction:2);
	pan = Pan2.ar(jj, -0.3);
	Out.ar(0, pan*amp*0.5);
}).add;

MIDIdef.noteOn(\testOn,{ arg vel,note;
	~synths = Array.fill(128,{nil});  // store records of Synth started by every note
	if (note == 52, {~synth = Synth(\rorange,[\amp,vel/127])});
	if (note == 53, {~synth = Synth(\hi,[\amp,vel/127])});
	if (note == 54, {~synth = Synth(\bell,[\amp,vel/127])});
	if (note == 55, {~synth = Synth(\lo,[\amp,vel/127])});
	if (note == 56, {~synth = Synth(\bass,[\amp,vel/127])});
	if (note == 57, {~synth = Synth(\snare,[\amp,vel/127])});
	if (note == 58, {~synth = Synth(\wood,[\amp,vel/127])});
	if (note == 59, {~synth = Synth(\click,[\amp,vel/127])});
},nil,0).fix(true);

MIDIdef.noteOff(\testOff,{ arg vel,note;
	if(~synths[note].notNil,{ ~synths[note].release; ~synths.put(note,nil) })
},nil,0); // al
)



MIDIdef.freeAll;