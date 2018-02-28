
/*
Open Sound Control (OSC)

OSC is a communication protocol used for sending information across a computer network. It can function as a successor to MIDI for real-time control of dsp instruments with greatly increased speed and high precision, user-customizable data representations.  It is supported by most sound programming software, and many commercial software synthesis applications.  For example, you can also use it to communicate with other programs like Processing, Max/MSP, or PD (for example to control SC Server synths in sync with Jitter).

It is the lifeblood of SuperCollider since all communication from the language  to the localhost server uses OSC! You may also send messages to any other SuperCollider Servers for which you know an IP address. So SuperCollider is immediately equipped for network music.

For OSC, you create your own OSC Address Space as a tree of methods that are called when their corresponding string is invoked. In practice, this means you can choose the    name-IDs of messages you want to send and receive.

(for more see http://opensoundcontrol.org/introduction-osc)

You might use

"/myparameters/object3/frequency"

Or any other string, where the forward slashes / split up the tree to be traversed.

 As well as the address string OSC messages include a type-tag string that says whether the information passed is a float,  integers, etc, followed by actual values for each type in the type string:

address, typetags, values

The message is passed to the appropriate method as soon as it arrives.

A 'bundle' can also be sent, which is a set of OSC commands that are to be called simultaneously - an absolute time tag is also enclosed, to control exactly when the commands are to be carried out.

To send general OSC to a known IP use the NetAddr class:
*/

[NetAddr]

NetAddr.new("pauline.mills.edu",57120);  //  communicate with CCM server !
NetAddr.myIP;  // get your own machine's IP address

//demo to send to the localhost Server
// run this code to get ready
(
s = Server.local.boot;
s.scope(2);
)

// see the helpfile [Server Command Reference] to learn about Server messages (OSC messages from the language to the Server) that are the basic building blocks of all higher-level communications from the Supercollider Language to the Server)
(
var n, id;

//loopback (send to yourself) address is 127.0.0.1 - try substituting the IP address of another user's machine
n=NetAddr("127.0.0.1", 57110); //57110 is the port number; this is the standard number used by the Server

id=s.nextNodeID; // get the next available number for a Synth (its superclass is Node)
n.sendMsg("s_new",\default,id,0,0);   //sendMsg works out the correct OSC message for you -- this plays a note on the \default Synth

SystemClock.sched(1.0,{n.sendMsg("n_free",id); });
)

/*
To send standard messages to control a SuperCollider server, the Server class is a better interface. Underneath, it uses NetAddr as above.

[Server]

You can also use Julian Rohrhuber's  BroadcastServer class to send messages to a list of NetAddrs (usually other SuperCollider Servers on other machines).  It's a Quark, so you'll first need to download and install it in your Extensions folder.

To view all OSC messages received by SC3, execute: */

OSCFunc.trace

// to turn this off...
OSCFunc.trace(false)

// To receive and react to OSC messages in SCLang, use the OSCdef class:

[OSCdef]

(
// the first three arguments of OSCdef.new are the most commonly used, the rest limit the response to matching sender, receiver-port, message-mapping, and dispatches to multiple responder functions
OSCdef.new (key, func, path, srcID, recvPort, argTemplate, dispatcher)
// register to trigger a response to a message
OSCdef(\test,  // this is the 'key' -- a symbol-name identifying this response to every message received by its OSC-address
	{ arg msg, time, addr, recvPort;  // this is the responder function
		"received trigger!".postln; },
		"/tr"   // this is the osc-address 'path'
);

//send a trigger message ("/tr" ) whenever the impulse fires (once every 2 seconds)
{SendTrig.kr(Impulse.kr(0.5))}.play;
)
// See also the SendReply class, which sends more than one value at a time as an Array

//keep it running, and replace the response function:
(
OSCdef(\test,{ arg msg, time, addr, recvPort;
	"new reaction!".post;
	" ".post; time.postln },"/tr"
);
)

OSCdef(\test).disable;   // stop responding
OSCdef(\test).enable;   // restart responding
OSCdef(\test).clear;    // clear the response function
OSCdef.freeAll    // clear all previously defined OSCdefs


// MIDI

//To access your MIDI interfaces you must initialize with:

MIDIIn.connectAll

// For obtaining incoming MIDI messages see the MIDIIn help file: [MIDIIn]

// For sending MIDI messages out see the MIDIOut help file: [MIDIOut]

// here's a simple program to turn on/off notes, and control faders with MIDI controllers
// first, a synth to trigger and control
(
SynthDef(\mmfmCascade,{ arg carFreq=440, amp=0.2, cmRatio1=1, cmRatio2=1,index1=0.5, index2=0.1,gate=1;
	var mod1Freq, mod2Freq,env;
	mod1Freq = cmRatio1*carFreq;
	mod2Freq = cmRatio2*mod1Freq;
	env = EnvGen.kr(Env.asr(0.001,1,0.2),gate,doneAction: 2);
	Out.ar(0,SinOsc.ar(
		SinOsc.ar(
			SinOsc.ar(mod2Freq,0,mod2Freq*index2,mod1Freq),
			0, mod1Freq*index1,carFreq),0,env*(amp)
	))
}).add;
)

(
MIDIIn.connectAll;  // you must first connect to your MIDI input-outputs
// see args delivered with each noteOn
MIDIdef.noteOn(\test,{ arg ... args; args.postln });
)

(	// play a note on any channel, but don't play more than one before releasing!
MIDIdef.noteOn(\testOn,{ arg vel,note;
	~synth = Synth(\mmfmCascade,[\carFreq,note.midicps,\carAmp,vel/127])
}).fix(true);   // needed to make this persist after Command-.

MIDIdef.noteOff(\testOff,{ arg vel,note;
	if(~synth.notNil,{ ~synth.release });
	//	if(~synth.notNil,{ ~synth.set(\gate,0)});  // this is what 'release' does
}).fix(true);   // needed to make this MIDIdef persist after Command-.
)

(
//  play only on channel one
MIDIdef.noteOn(\testOn,{ arg vel,note;
	~synth = Synth(\mmfmCascade,[\carFreq,note.midicps,\amp,vel/127]) //
},nil,0).fix(true);  // arg following the function sets the note number it responds to (if nil, it responds to any note), followed by the midichannel it responds to (as 0-15, subtract 1 from conventional chan number)
MIDIdef.noteOff(\testOff,{ arg vel,note;
	if(~synth.notNil,{ ~synth.set(\gate,0)})},nil,0) // also specify note, chan
.fix(true);

// interpret continuous controllers
MIDIdef.cc(\testCC,{ arg val, num, chan;  // this is the vector for controller events
	switch(num.postln,	// 'switch' matches a value with an appropriate response
		30,{ ~synth.set(\carFreq,\freq.asSpec.map(val/127)) },
		31,{ ~synth.set(\amp,\amp.asSpec.map(val/127)) },
		32,{ ~synth.set(\cmRatio1,[0.1,20,\lin,0.1].asSpec.map(val/127)) },
		33,{ ~synth.set(\index1,[0.1,20,\lin,0.1].asSpec.map(val/127)) },
		34,{ ~synth.set(\cmRatio2,[0.1,20,\lin,0.1].asSpec.map(val/127)) },
		35,{ ~synth.set(\index2,[0.1,20,\lin,0.1].asSpec.map(val/127)) }
	)}).fix(true);
)
 // let's next redefine the noteOn and cc MIDIdefs to use the last cc setting for the mod params of the next note played
// first create ~variables storing their last setting, which must be initialized so we don't send 'nil' to the synth (which will make it crash):
(
~cmRatio=1; ~index1=1; ~cmRatio2=1; ~index2=1;

MIDIdef.noteOn(\testOn,{ arg vel,note;
	~synth = Synth(\mmfmCascade,[
		\carFreq,note.midicps,\amp,vel/127,
		\cmRatio1,~cmRatio1, \index1,~index1,
		\cmRatio2,~cmRatio2, \index2, ~index2])
},nil,0).fix(true);

MIDIdef.cc(\testCC,{ arg val, num, chan;  // this is the vector for controller events
	switch(num.postln,	// save cmratios and indexes
		30,{ ~synth.set(\carFreq,\freq.asSpec.map(val/127)) },
		31,{ ~synth.set(\amp,\amp.asSpec.map(val/127)) },
		32,{ ~synth.set(\cmRatio1,~cmRatio1=([0.1,20,\lin,0.1].asSpec.map(val/127))) },
		33,{ ~synth.set(\index1,~index1=([0.1,20,\lin,0.1].asSpec.map(val/127))) },
		34,{ ~synth.set(\cmRatio2,~cmRatio2=([0.1,20,\lin,0.1].asSpec.map(val/127))) },
	35,{ ~synth.set(\index2,~index2=([0.1,20,\lin,0.1].asSpec.map(val/127))) }
	)}).fix(true);
)

// make a crude 12 voice-allocator for MIDIdef.noteOn and noteOff
(
~cmRatio=1; ~index1=1; ~cmRatio2=1; ~index2=1;
~synths = Array.fill(128,{nil});  // store records of Synth started by every note
MIDIdef.noteOn(\testOn,{ arg vel,note;
	~synths.put(note,Synth(\mmfmCascade,[
		\carFreq,note.midicps,\amp,vel/127,
		\cmRatio1,~cmRatio1, \index1,~index1,
		\cmRatio2,~cmRatio2, \index2, ~index2]));
},nil,0).fix(true);  // only on channel 1

MIDIdef.noteOff(\testOff,{ arg vel,note;
	if(~synths[note].notNil,{ ~synths[note].release; ~synths.put(note,nil) })
},nil,0) // also specify note, chan
.fix(true);
MIDIdef.cc(\testCC,{ arg val, num, chan;  // this is the vector for controller events
	switch(num.postln,	// save cmratios and indexes
		32,{ ~cmRatio1=([0.1,20,\lin,0.1].asSpec.map(val/127))},
		33,{ ~index1=([0.1,20,\lin,0.1].asSpec.map(val/127)) },
		34,{ ~cmRatio2=([0.1,20,\lin,0.1].asSpec.map(val/127)) },
	35,{ ~index2=([0.1,20,\lin,0.1].asSpec.map(val/127))}
	)}).fix(true);
)
// try using this one to set the value of four effect send amplitudes in a Pbind, assigning each of the
// tilde-variables of your source synth to \eff1Amp, \eff2Amp, \eff3Amp, \eff4Amp

MIDIdef.cc(\effCC,{ arg val, num, chan;  // this is the vector for controller events
	switch(num,	// 'switch' matches a value with an appropriate response
		30,{ ~effSend1Amp=\amp.asSpec.map(val/127) },
		31,{ ~effSend2Amp=\amp.asSpec.map(val/127) },
		32,{ ~effSend3Amp=\amp.asSpec.map(val/127) },
		33,{ ~effSend4Amp=\amp.asSpec.map(val/127) }
	)}).fix;

MIDIdef.freeAll;   // clear all MIDIdefs









