/*Loui */




(
MIDIdef.noteOn(\test,{ arg ... args; args.postln });
MIDIIn.connectAll
)

MIDIdef.freeAll;   // clear all MIDIdefs

//synth

(
SynthDef(\realRingMod, { arg modFreq=2500, carFreq=200, index=5000,gate=1;

	var modded= SinOsc.ar(carFreq * (index*SinOsc.ar(modFreq)),0,0.25);
	var env = EnvGen.kr(Env.asr(0.001,1,0.2),gate,doneAction: 2);
	Out.ar(0, modded*env.dup);
}).add;
)

(
~cmRatio=1; ~index1=1; ~cmRatio2=1; ~index2=1;
~synths = Array.fill(128,{nil});  // store records of Synth started by every note
MIDIdef.noteOn(\testOn,{ arg vel,note;
	~synths.put(note,Synth(\realRingMod,[
		\carFreq,note.midicps,\amp,vel/127,
		\cmRatio1,~cmRatio1, \index1,~index1,
		\cmRatio2,~cmRatio2, \index2, ~index2]));
},nil,0).fix(true);  // only on channel 1

MIDIdef.noteOff(\testOff,{ arg vel,note;
	if(~synths[note].notNil,{ ~synths[note].release; ~synths.put(note,nil) })
},nil,0) // also specify note, chan
.fix(true);

MIDIdef.cc(\testCC,{ arg val, num, chan;  // this is the vector for controller events
	var synthsOn;
	switch(num.postln,	// save cmratios and indexes
		32,{ ~cmRatio1=([0.1,20,\lin,0.1].asSpec.map(val/127));
			~ynthsOn= ~synths.select({|num| ~synths[num].notNil });
			if(~synths[num].notNil,{~synths[num].set(\cmRatio1,~cmRatio1)})
		},
		33,{ ~index1=([0.1,20,\lin,0.1].asSpec.map(val/127)) },
		34,{ ~cmRatio2=([0.1,20,\lin,0.1].asSpec.map(val/127)) },
	35,{ ~index2=([0.1,20,\lin,0.1].asSpec.map(val/127))}
	)}).fix(true);
)





//drones

(
var w, carfreqslider, modfreqslider, roomsizeslider,revtimeslider,taillevelslider,synth,carfreqslider22, modfreqslider21,modfreqslider20, synth2;


w=Window("A Synth", Rect(100, 400, 400, 300));
w.view.decorator = FlowLayout(w.view.bounds);


synth= {arg freq1= 140, freq2=240,roomsize=100, revtime=30, taillevel=0, amp=1;

var modFreq= PinkNoise.ar;
	var modFreq2= SinOsc.ar(freq1,0,0.33);
	var carFreq= SinOsc.ar(freq2,0,0.33);
	var added= modFreq+modFreq2;
	var filtered= Resonz.ar(carFreq*added);
	var gverbed= GVerb.ar(filtered,roomsize,revtime,taillevel:taillevel);


	Out.ar(0, amp*gverbed.dup);


}.play;

synth2= {arg freq11=140, freq12=40, freq13=350;

var modFreq11= SinOsc.ar(freq11,0,0.33);
	var modFreq12 = SinOsc.ar(freq12,0,0.33);
	var carFreq10= SinOsc.ar(freq13,0,0.33);
	var added = modFreq11+modFreq12;

	Out.ar(0, added+carFreq10.dup);


}.play;


carfreqslider= EZSlider(w, 300@50, "carfreq", ControlSpec(20, 5000, 'exponential', 10, 440), {|ez|  synth.set(\freq2, ez.value)});
~cs = carfreqslider;
w.view.decorator.nextLine;

modfreqslider= EZSlider(w, 300@50, "modfreq", ControlSpec(1, 5000, 'exponential', 1, 1), {|ez|  synth.set(\freq1, ez.value)});
w.view.decorator.nextLine;

roomsizeslider= EZSlider(w, 300@50, "roomsize", ControlSpec(0.0, 40, 'linear', 0.01, 0.0), {|ez|  synth.set(\roomsize, ez.value)});
w.view.decorator.nextLine;

revtimeslider= EZSlider(w, 300@50, "revtime", ControlSpec(0.0, 40, 'linear', 0.01, 0.0), {|ez|  synth.set(\revtime, ez.value)});
w.view.decorator.nextLine;

taillevelslider= EZSlider(w, 300@50, "taillevel", ControlSpec(0.0, 40, 'linear', 0.01, 0.0), {|ez|  synth.set(\taillevel, ez.value)});
w.view.decorator.nextLine;

carfreqslider22= EZSlider(w, 300@50, "carfreq22", ControlSpec(20, 5000, 'exponential', 10, 440), {|ez|  synth2.set(\freq13, ez.value)});
w.view.decorator.nextLine;

modfreqslider21= EZSlider(w, 300@50, "modfreq21", ControlSpec(1, 5000, 'exponential', 1, 1), {|ez|  synth2.set(\freq11, ez.value)});
w.view.decorator.nextLine;

modfreqslider20= EZSlider(w, 300@50, "modfreq22", ControlSpec(1, 5000, 'exponential', 1, 1), {|ez|  synth2.set(\freq12, ez.value)});

MIDIIn.connectAll;
MIDIdef.cc(\guiCtl,{ arg val, num, chan;
	switch(num.postln,	// 'switch' matches a value with an appropriate response
		21,{ { carfreqslider.valueAction_(carfreqslider.controlSpec.map(val/127)) }.defer },
		22,{ { modfreqslider.valueAction_(modfreqslider.controlSpec.map(val/127)) }.defer },
		23,{ { roomsizeslider.valueAction_(roomsizeslider.controlSpec.map(val/127)) }.defer },
	24,{ { revtimeslider.valueAction_(revtimeslider.controlSpec.map(val/127)) }.defer },
		25,{ { taillevelslider.valueAction_(taillevelslider.controlSpec.map(val/127)) }.defer },
		26,{ { carfreqslider22.valueAction_(carfreqslider22.controlSpec.map(val/127)) }.defer },
		27,{ { modfreqslider21.valueAction_(modfreqslider21.controlSpec.map(val/127)) }.defer },
		28,{ { modfreqslider20.valueAction_(modfreqslider20.controlSpec.map(val/127)) }.defer })
}).fix(true);

w.front.onClose_({ synth.free });
)






