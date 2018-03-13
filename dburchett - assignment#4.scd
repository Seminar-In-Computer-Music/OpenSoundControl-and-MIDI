// MIDI
(
s.boot;
Server.local.scope(2);
MIDIIn.connectAll
)

(
SynthDef("dusty", { arg dens = 5, rate = 440, bit = 0.5, amp = 1, gate = 1;
	var env;
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	Out.ar(0, Pan2.ar(Decimator.ar(Dust.ar(dens, 0.5), rate, bit, 0.5), 0, amp*env))}).add;

SynthDef("car", {arg chaos = 0.2, amp = 1, freq = 0.01, rq = 0.01, gate = 1;
	var sound, glitch, env;
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	sound = Crackle.ar(TRand.kr(freq, rq, Dust.kr(chaos)), 0.5);
	Out.ar(0, Pan2.ar(Limiter.ar(LeakDC.ar(sound), 0.5, 0.01), 0, amp*env))}).add;

SynthDef("feedy", {arg freq = 50000, amp = 1, fb = 0.2, gate = 1;
	var sound, env;
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	sound = SinOscFB.ar(freq, fb, 0.5);
	Out.ar(0, Pan2.ar(sound, 0, amp*env))}).add;

SynthDef("feedy2", {arg freq = 60000, amp = 1, fb = 0.2, gate = 1;
	var sound, env;
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	sound = SinOscFB.ar(freq, fb, 0.5);
	Out.ar(0, Pan2.ar(sound, 0, amp*env))}).add;

SynthDef("grainy", {arg dens = 5, dur = 1, mg = 512, amp = 1, gate = 1;
	var sound, env;
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	sound = GrainSin.ar(2, Dust.kr(dens), dur, 100000, 0, -1, mg, 0.5);
	Out.ar(0, Pan2.ar(sound, 0, amp*env))}).add;
)

(
~dusty = Synth(\dusty,[\dens,5,\amp,0,\rate,44100,\bit,24,\gate,1]);
~car = Synth(\car,[\chaos, 0.2, \amp, 0, \freq, 0.01, \rq, 0.01,\gate,1]);
~feedy = Synth(\feedy,[\freq, 120000, \amp, 0, \fb, 0.2,\gate,1]);
~feedy2 = Synth(\feedy,[\freq, 60000, \amp, 0, \fb, 0.2,\gate,1]);
~grainy = Synth(\grainy,[\dens,5,\amp,0,\dur,1,\mg,512,\gate,1]);
)

(
MIDIdef.cc(\dustCC,{arg val, num, chan;
	switch(num.postln,
		1,{~dusty.set(\dens,[0.1,25,\lin,0.1].asSpec.map(val/127)) },
		0,{~dusty.set(\amp,[0.01, 1.0, \lin, 0.1].asSpec.map(val/127)) },
		17,{~dusty.set(\rate,[0, 44100,\lin,0.1].asSpec.map(val/127)) },
		16,{~dusty.set(\bit,[0.1, 24,\lin,0.1].asSpec.map(val/127)) },
		43,{~dusty.set(\gate,[0, 1, \lin, 0.01].asSpec.map(val/127)) }
)});
MIDIdef.cc(\carCC,{arg val, num, chan;
	switch(num.postln,
		3,{~car.set(\chaos,[0.1,100,\lin,0.01].asSpec.map(val/127)) },
		2,{~car.set(\amp,\amp.asSpec.map(val/127)) },
		18,{~car.set(\freq,[0.01, 2.0, \lin, 0.01].asSpec.map(val/127)) },
		19,{~car.set(\rq,[0.01, 2.0, \lin, 0.01].asSpec.map(val/127)) },
		44,{~car.set(\gate,[0, 1, \lin, 0.01].asSpec.map(val/127)) }
)});
MIDIdef.cc(\feedyCC,{arg val, num, chan;
	switch(num.postln,
		6,{~feedy.set(\amp,\amp.asSpec.map(val/127)) },
		22,{~feedy.set(\fb,[0.01, 3.0, \lin, 0.01].asSpec.map(val/127)) },
		41,{~feedy.set(\gate,[0, 1, \lin, 0.01].asSpec.map(val/127)) }
)});
MIDIdef.cc(\feedy2CC,{arg val, num, chan;
	switch(num.postln,
		7,{~feedy2.set(\amp,\amp.asSpec.map(val/127)) },
		23,{~feedy2.set(\fb,[0.01, 3.0, \lin, 0.01].asSpec.map(val/127)) },
		45,{~feedy2.set(\gate,[0, 1, \lin, 0.01].asSpec.map(val/127)) }
)});
MIDIdef.cc(\grainyCC,{arg val, num, chan;
	switch(num.postln,
		5,{~grainy.set(\dens,[0.2,50,\lin,0.01].asSpec.map(val/127)) },
		4,{~grainy.set(\amp,\amp.asSpec.map(val/127)) },
		20,{~grainy.set(\dur,[0.01, 0.5, \lin, 0.01].asSpec.map(val/127)) },
		21,{~grainy.set(\mg,[0.01, 512.0, \lin, 0.01].asSpec.map(val/127)) },
		42,{~grainy.set(\gate,[0, 1, \lin, 0.01].asSpec.map(val/127)) }
)});
)

MIDIdef.freeAll;   // clear all MIDIdefs
