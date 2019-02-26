/*
 FX Lib
*/

/*
// Delay
SynthDef(\delay, { arg out=0, in=0;

	~delaytime = MouseX.kr(0.01,0.05);
	//d =  DelayL.ar(signal, 0.6, delaytime);
	d = CombL.ar(signal, 0.6, delaytime, MouseY.kr(0.001,4));
	//d =  AllpassL.ar(signal, 0.6, delaytime, MouseY.kr(0.001,4));

	(in+d).dup

	Out.ar([out, out+1], mixed);

}).add;
*/

// Phaser
/*
TODO
*/



// Flanger
SynthDef(\flanger, { arg out=0, in=0, delay=0.1, depth=0.08, rate=0.06, fdbk=0.0, decay=0.0;
	var input, maxdelay, maxrate, dsig, mixed, local;
	maxdelay = 0.013;
	maxrate = 10.0;
	input = In.ar(in, 1);
	local = LocalIn.ar(1);
	dsig = AllpassL.ar( // the delay (you could use AllpassC (put 0 in decay))
		input + (local * fdbk),
		maxdelay * 2,
		LFPar.kr( // very similar to SinOsc (try to replace it) - Even use LFTri
			rate * maxrate,
			0,
			depth * maxdelay,
			delay * maxdelay),
		decay);
	mixed = input + dsig;
	LocalOut.ar(mixed);
	Out.ar([out, out+1], mixed);
}).add;


SynthDef(\flanger2, { arg out=0, in=0, depth=1, feedback_gain=0, flange_delay_offset=1, flange_delay=10, invert=0, level=0, lfobpm=24;
	var input, sig;
	input = In.ar(in, 2);
	sig = FaustFlanger.ar(input, input, depth, feedback_gain, flange_delay_offset, flange_delay, invert, level, lfobpm);
	Out.ar(out, sig);
}).add;

(

SynthDef(\flanger2, { arg out=0, in=0, depth=1, feedback_gain=0, flange_delay_offset=1, flange_delay=10, invert=0, level=0, lfobpm=24;
	var input, sig;
	input = In.ar(in, 2);
	sig = FaustEcho.ar(FaustFlanger.ar(input, input, depth, feedback_gain, flange_delay_offset, flange_delay, invert, level, lfobpm), 120, 50);
	Out.ar(out, sig);
}).add;

)
r = Synth(\distorted, [\out, 0], addAction:\addToTail)
r.free
(
SynthDef(\distorted, {arg out=0, in=0, drive=0.84, gain=2, high_drive=1, high_gain=10, level=0, low_drive=1, low_gain=10, middle_h_drive=1, middle_h_gain=15, middle_l_drive=1, middle_l_gain=15, resonator_on_off=0, split_high_freq=1250, split_low_freq=250, split_middle_freq=650, trigger=0.72, vibrato=1, wet_dry=200, feedback=0.8;
	var input, sig;
	input = In.ar(in, 2);
	sig = FaustAntiAlias.ar(
		FaustMultiBandDistortion.ar(input, drive, gain, high_drive, high_gain, level, low_drive, low_gain, middle_h_drive, middle_h_gain, middle_l_drive, middle_l_gain, resonator_on_off, split_high_freq, split_low_freq, split_middle_freq, trigger, vibrato, wet_dry), feedback);
	Out.ar(out, sig*0.05);
}).add;
)




//Chorus

SynthDef(\chorus, { arg inbus=10, outbus=0, predelay=0.08, speed=0.05, depth=0.1, ph_diff=0.5;
	var in, sig, modulators, numDelays = 12;
	in = In.ar(inbus, 1) * numDelays.reciprocal;
	modulators = Array.fill(numDelays, {arg i;
      	LFPar.kr(speed * rrand(0.94, 1.06), ph_diff * i, depth, predelay);});

	sig = DelayC.ar(in, 0.5, modulators);
	sig = sig.sum; //Mix(sig);
	Out.ar(outbus, sig!2); // output in stereo
}).add


// Reverb

SynthDef(\reverb, {arg inbus=0, outbus=0, predelay=0.048, combdecay=15, allpassdecay=1, revVol=0.31;
	var sig, y, z;
	sig = In.ar(inbus, 1);

	// predelay
	z = DelayN.ar(sig, 0.1, predelay); // max 100 ms predelay
	// 7 length modulated comb delays in parallel :

	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.05, rrand(0.03, 0.05), combdecay) }));

	6.do({ y = AllpassN.ar(y, 0.050, rrand(0.03, 0.05), allpassdecay) });
	Out.ar(outbus, sig + (y * revVol) ! 2); // as fxlevel is 1 then I lower the vol a bit

}).add;

// Tremolo

SynthDef(\tremolo, {arg inbus=0, outbus=0, freq=1, strength=1;
   var fx, sig;
   sig = In.ar(inbus, 1);
   fx = sig * SinOsc.ar(freq, 0, strength, 0.5, 2);
   Out.ar(outbus, (fx+ sig).dup )
}).add;


/*
// Distortion

SynthDef(\distortion, {arg in=0, gain=50,out=0;
	in=in.abs;
	((in.squared + (gain*in))/(in.squared + ((gain-1)*in) + 1));
	Out.ar(out!2)
}).add;
*/

SynthDef(\eq, {|in, lofreq = 80, midfreq = 800, hifreq = 2000, band1 = -45, band2 = -45, out, band3 = -45, mix = -1|
    var dry, wet;
    dry = In.ar(in, 2);

    wet = BPeakEQ.ar(dry, lofreq, 1, band1);
    wet = BPeakEQ.ar(wet, midfreq, 1, band2);
    wet = BPeakEQ.ar(wet, hifreq, 1, band3);

    Out.ar(out, XFade2.ar(dry, wet, mix));
}).add;

SynthDef(\robolay, {arg in, out=0, rev=0.4, pan=2, e1bpm=3000, e1p=49, d1bpm=120, d1p=1, e2bpm=120, e2p=50, mul=1;
	var sig, echo1, echo2, pitsh, enh, fin;
	sig = SoundIn.ar(in);
	pitsh = PitchShift.ar(sig,0.2,4);
	echo1 = FaustEcho.ar(FaustDelay.ar(FaustEcho.ar(FaustDrive.ar(pitsh),e1bpm,e1p),d1bpm,d1p),e2bpm,e2p);
	echo2 = FaustEcho.ar(FaustDelay.ar(FaustEcho.ar(FaustDrive.ar(pitsh),e1bpm,e1p),d1bpm,d1p),e2bpm,e2p);
	enh = FaustBassEnhancer.ar(echo1+echo2, echo2+echo1);
	fin = Pan2.ar(FreeVerb.ar(enh, rev),FSinOsc.kr(200));
	Out.ar(out, fin*mul);
}).add;

(
// ampeg
SynthDef(\ampeg, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustAmpegStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.6);
	Out.ar([0,1], fin*mul);
}).add;

// ampeg reverb rocket
SynthDef(\revrocket, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustRevRocketStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.6);
	Out.ar([0,1], fin*mul);
}).add;

// sovtek mig 100h
SynthDef(\sovtek, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustMIG100HStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.6);
	Out.ar([0,1], fin*mul);
}).add;

// groove trio
SynthDef(\trio, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustTrioPreampStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.6);
	Out.ar([0,1], fin*mul);
}).add;

// hugheskettner
SynthDef(\ht, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustHughesKettnerStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.6);
	Out.ar([0,1], fin*mul);
}).add;

// mesaboogie
SynthDef(\mesaboogie, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustMesaBoogieStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.6);
	Out.ar([0,1], fin*mul);
}).add;

// gibsen
SynthDef(\gibsen, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustGibsenStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// engl
SynthDef(\gibsen, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustEnglStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// fender
SynthDef(\fender, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustFenderStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// fender blues junior
SynthDef(\fenderblues, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustJuniorStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.6);
	Out.ar([0,1], fin*mul);
}).add;

// fender deville
SynthDef(\deville, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustDevilleStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.6);
	Out.ar([0,1], fin*mul);
}).add;

// fender bassman
SynthDef(\bassman, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustBassmanStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// fender princeton
SynthDef(\princeton, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustPrincetonStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// fender princeton
SynthDef(\gibsen, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustPrincetonStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// marshall jcm800
SynthDef(\jcm800, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustJCM800Style.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// marshall jcm2000
SynthDef(\jcm2000, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustJCM2000Style.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// marshall lead
SynthDef(\marshall, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustMLeadStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// marshall m2199
SynthDef(\m2199, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustM2199Style.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// marshall jtm45
SynthDef(\jtm45, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustJTM45Style.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// soldano 100
SynthDef(\soldano, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustSOL100Style.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// peavey

SynthDef(\peavey, {arg in, out=0, mul=3;
	var sig, fin;
	sig = SoundIn.ar(in);
	fin = FreeVerb.ar(Pan2.ar(FaustMIG100HStyle.ar(FaustAmpT2.ar(FaustCompressor.ar(sig, 0.432, 6, 7, 4, -12),4,4), 0.7, 0.25, 0.4)),0.1);
	Out.ar([0,1], fin*mul);
}).add;

a = Synth(\peavey, [\in, 0])
a.free
s.record
s.stopRecording


// ibanez
SynthDef(\ibanez, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustIbanezStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// roland
SynthDef(\roland, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustRolandStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// vox ac15
SynthDef(\ac15, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustAC15Style.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// vox ac30
SynthDef(\ac30, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustAC30Style.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;

// Bogner Hafler Triple Giant
SynthDef(\triplegiant, {arg in, out=0, mul=1;
	var sig, fin;
	sig = SoundIn.ar(in, 3);
	fin = FreeVerb.ar(Pan2.ar(FaustMultiBandDistortion.ar(FaustTripleGiantStyle.ar(sig, 0.6, 0.7, 0.4),0.8,3)),0.3);
	Out.ar([0,1], fin*mul);
}).add;
)


SynthDef(\bitcrush, {arg in, out=0, bits=6, downsampling=1, gain=1, volume=1;
	var sig, bitcrush, fin;
	sig = SoundIn.ar(in);
	bitcrush = FaustBitDowner.ar(sig, bits, downsampling, gain, volume);
	fin = FreeVerb.ar(Pan2.ar(FaustMesaBoogieStyle.ar(bitcrush,0.5,0.9,0.7)));
	Out.ar(out, fin);
}).add;

SynthDef(\bitcrushd, {arg in, out=0, bits=4, downsampling=1, gain=1, volume=1;
	var sig, bitcrush, pitsh, fin;
	sig = SoundIn.ar(in);
	bitcrush = DelayC.ar(FaustBitDowner.ar(sig, bits, downsampling, gain, volume),1,1);
	pitsh = PitchShift.ar(bitcrush,0.2,4,0.1);
	fin = FreeVerb.ar(Pan2.ar(FaustMesaBoogieStyle.ar(pitsh,0.5,0.9,0.7)));
	Out.ar(out, fin*2);
}).add;

SynthDef(\compressor, {arg in, out=0;
	var sig, compander;
	sig = SoundIn.ar(in);
	compander = Compander.ar(in, in, MouseX.kr(0.001, 1, 1), 1, 0.5, 0.01, 0.01);
	Out.ar([out, out+1], compander);
}).add;

SynthDef(\bass, {arg in, out=0, freq=100, harm=2;
	var sig, bass;
	sig = SoundIn.ar(in);
	bass = FaustBassEnhancer.ar(sig, sig, freq, harm);
	Out.ar([0,1], bass);
}).add;





)