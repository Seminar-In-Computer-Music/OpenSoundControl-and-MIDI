// Extensions, SC3-Plugins and Quarks

// SC3 Plugins and Extensions
(
// Plugins are UGens written by other users, that run audio on the Server.  They are written in C++, so you must download the appropriate compilations for Mac or Windows, or build them from sourcecode in Linux.  On Mac, put the downloaded files in your /User/Library/Application Support/SuperCollider/Extensions folder, then recompile. (On Windows, you should be able to find a similar "SuperCollider/Extensions" folder.)

// Extensions are class libraries written by other users in the SuperCollider language -- they are therefore cross-platform, so you need only the source code. These are available in a package-management system called Quarks, which you can read about in the [UsingQuarks] helpfile.  But briefly, they can be automatically downloaded and installed in your compilation path by typing

Quarks.gui

https://github.com/supercollider-quarks/quarks

git

You should install git if you do not already have it:

http://git-scm.com/

If you cannot or do not want to install git then you can still download things you find on the webs and then install them manually:

Quarks.install("~/Downloads/some-thing-i-found-on-the-internet");

And you can also download all of the community contributed Quarks in a single download:

https://github.com/supercollider-quarks/downloaded-quarks

The Quarks interface will let you browse those and install them, just as normal.
// put this in your startup.scd
Quarks.addFolder("~/supercollider/quarks");

Quarks.uninstall("arduino")

"~/supercollider/"

Quarks.localPath

// which brings up a selection panel.  Choose a library to install then recompile, and a link to the chosen quarks code is created in your /User/Library/Application Support/SuperCollider/Extensions/quarks folder.  If you have trouble with Quarks.gui you can download and install them manually, by putting them in a Quarks folder and moving it into the /User/Library/Application Support/SuperCollider folder.

// CV (Control-Value) is a Quark that associates data with a ControlSpec
// it also allows flexible connection to GUI objects
(
~dly = {|spd=2,freq=800,rq=0.1,dlyTime=1,dcyTime=5,dlyAmp=0.25|
	var sig=Ringz.ar(Impulse.ar(spd),freq,1);
	[CombC.ar(sig,2,dlyTime,dcyTime,dlyAmp),sig] }.play;
~spd = CV.new(ControlSpec(0.125, 12, 'exp', 0, 4));
~spd.action_({|cv| ~dly.set(\spd,cv.value)});
~freq = CV(\freq.asSpec,1200);
~freq.action_({|cv| ~dly.set(\freq,cv.value)});
~dlyTime = CV([0.05,2.0,\exp,0].asSpec,1.0);
~dlyTime.action_({|cv| ~dly.set(\dlyTime,cv.value)});
~dcyTime = CV([0.1,40,\exp,0].asSpec,5);
~dcyTime.action_({|cv| ~dly.set(\dcyTime,cv.value)});
~dlyAmp = CV(nil,0.25);
~dlyAmp.action_({|cv| ~dly.set(\dlyAmp,cv.value)});

w = Window("dlyTest",Rect(25, 392, 690, 150)).front.onClose_({ ~dly.free });
f = FlowView.new(w, margin: 5@5);
StaticText(f,80@20).string_("speed"); ~spd.connect(Slider(f,220@20)); ~spd.connect(NumberBox(f,50@20));
f.startRow;
StaticText(f,80@20).string_("frequency"); ~freq.connect(Slider(f,220@20)); ~freq.connect(NumberBox(f,50@20));
f.startRow;
StaticText(f,80@20).string_("dlyTime"); ~dlyTime.connect(Slider(f,220@20)); ~dlyTime.connect(NumberBox(f,50@20));
f.startRow;
StaticText(f,80@20).string_("dcyTime"); ~dcyTime.connect(Slider(f,220@20)); ~dcyTime.connect(NumberBox(f,50@20));
f.startRow;
StaticText(f,80@20).string_("dlyAmp"); ~dlyAmp.connect(Slider(f,220@20)); ~dlyAmp.connect(NumberBox(f,50@20));

MIDIIn.connectAll;
MIDIdef.cc(\guiCtl,{ arg val, num, chan;
	switch(num.postln,	// 'switch' matches a value with an appropriate response
		30,{~spd.value_(val/127) },
		31,{~freq.value_(val/127) },
		32,{~dlyTime.value_(val/127) },
		33,{ ~dcyTime.value_(val/127) },
		34,{ ~dlyAmp.value_(val/127) })
}).fix(true);
)