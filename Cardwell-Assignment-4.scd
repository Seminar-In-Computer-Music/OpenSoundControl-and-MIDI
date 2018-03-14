/*
(

SynthDef(\VoiceIn,{ arg out=0;
	Out.ar(out, AudioIn.ar([1,2])
	)
}).play;
*/


(

var w, synth, freqslider, freqslider1, freqslider2;

w = Window("Vocal Processor", Rect(100, 400, 400, 300));
w.view.decorator = FlowLayout(w.view.bounds);

s = Server.local;
b = Buffer.alloc(s, 44100 * 1.0, 1);

synth = {arg trigger = 0, graindur = 0.2, sndbuf, transp = 1, pos = 0, pan = 0, envbuf = -1, amp = 1,
	freq = 440, freq1 = 440, freq2 = 440, gate = 1;
	var env, send;
	RecordBuf.ar(SoundIn.ar(0), sndbuf, loop: 1);
	env = EnvGen.kr(Env.adsr(0.1, 3, 0.6, 6, 1, [2, -3]), gate, doneAction: 2);
	send = GrainBuf.ar(
		numChannels: 1,
		trigger: Impulse.kr(trigger),
		dur: graindur,
		sndbuf: sndbuf,
		rate: transp,
		pos: pos,
		pan: pan,
		envbufnum: envbuf);
    send = GVerb.ar(BPF.ar(send, 90.midicps), roomsize: 30, revtime: 8, drylevel: 0.5);
    send = send!2 * 0.8 + (SoundIn.ar([0,1]) * 0.5);
	send = FreqShift.ar(send, freq) + FreqShift.ar(send, freq1) + FreqShift.ar(send, freq2);
	Out.ar(0, send * env)
}.play;

freqslider = EZSlider(w, 300@50, "freq", ControlSpec(60, 1000, 'exponential', 10, 440), {|ez|  synth.set(\freq, ez.value)});
~fs = freqslider;
w.view.decorator.nextLine;

freqslider1 = EZSlider(w, 300@50, "freq1", ControlSpec(60, 1000, 'exponential', 10, 440), {|ez|  synth.set(\freq1, ez.value)});
w.view.decorator.nextLine;

freqslider2 = EZSlider(w, 300@50, "freq2", ControlSpec(60, 1000, 'exponential', 10, 440), {|ez|  synth.set(\freq2, ez.value)});


MIDIIn.connectAll;
MIDIdef.cc(\guiCtl,{ arg val, num, chan;
	switch(num.postln,
		36,{ { freqslider.valueAction_(freqslider.controlSpec.map(val/127)) }.defer },
		37,{ { freqslider1.valueAction_(freqslider1.controlSpec.map(val/127)) }.defer },
		38,{ { freqslider2.valueAction_(freqslider2.controlSpec.map(val/127)) }.defer })
}).fix(true);

w.front.onClose_({ synth.free });

)


-----------

(
var w, synthwaves, synthwalking, wavesampslider, wavesfreqslider, walkingampslider, walkingfreqslider;

w = Window("Beach Processor", Rect(100, 400, 400, 300));
w.view.decorator = FlowLayout(w.view.bounds);

synthwaves = { arg freq = 60, rq = 1, pan = 0, amp = 0.5, gate = 1;
	var wave;
	wave = BPF.ar(BrownNoise.ar, freq, rq);
	wave = FreeVerb.ar(wave, 1, 10, 0.1, 0.5);
	Out.ar(0, Pan2.ar(wave*amp,pan));
}.play;

synthwalking = {arg freq = 60, amp = 0.2, pan = 0, gate = 1;
	var sig;
	sig = (BrownNoise.ar + SinOsc.ar(freq));
	sig = CombN.ar(sig, 1, 0.2, 6, 0.5);
	Out.ar(0, Pan2.ar(sig*amp))
}.play;


wavesampslider = EZSlider(w, 300@50, "amp", ControlSpec(0, 1, 'linear', 0.05, 0.5), {|ez|  synthwaves.set(\amp, ez.value)});
~ws = wavesampslider;
w.view.decorator.nextLine;

wavesfreqslider = EZSlider(w, 300@50, "freq", ControlSpec(60, 300, 'exponential', 10, 620), {|ez|  synthwaves.set(\freq, ez.value)});
w.view.decorator.nextLine;

walkingampslider = EZSlider(w, 300@50, "amp", ControlSpec(0, 1, 'linear', 0.05, 0.5), {|ez|  synthwalking.set(\amp, ez.value)});
w.view.decorator.nextLine;

walkingfreqslider = EZSlider(w, 300@50, "freq", ControlSpec(60, 120, 'exponential', 10, 80), {|ez|  synthwalking.set(\freq, ez.value)});

MIDIIn.connectAll;
MIDIdef.cc(\guiCtl,{ arg val, num, chan;
	switch(num.postln,
		39,{ { wavesampslider.valueAction_(wavesampslider.controlSpec.map(val/127)) }.defer },
		40,{ { wavesfreqslider.valueAction_(wavesfreqslider.controlSpec.map(val/127)) }.defer },
		41,{ { walkingampslider.valueAction_(walkingampslider.controlSpec.map(val/127)) }.defer },
		42,{ { walkingfreqslider.valueAction_(walkingfreqslider.controlSpec.map(val/127)) }.defer })
}).fix(true);

w.front.onClose_({ synthwaves.free });
w.front.onClose_({ synthwalking.free });

)