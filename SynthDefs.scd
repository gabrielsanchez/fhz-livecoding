
(

SynthDef(\sampler, {arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig, env;
		sig = Mix.ar(PlayBuf.ar(2,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:2);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out, Pan2.ar(sig,pan));
}).add;

SynthDef(\msampler, {arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig, env;
		sig = Mix.ar(PlayBuf.ar(1,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:2);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out, Pan2.ar(sig,pan));
}).add;

SynthDef(\scramble,{
	|out=0, buf=0, maxDelay=1.0, delay=3, amp=0.3, pos=0,sus=2,window=0.2, ratio=1, disp=0, timeDisp=0,pan=0|
	var snd, env;
    snd = PlayBuf.ar(2, buf, BufRateScale.kr(buf),startPos:pos, loop: 0);
	env = EnvGen.ar(Env.new([0, 1, 1, 0], [0.05, sus, 0.02]), 1, doneAction:2);
    snd = DelayC.ar(snd, maxDelay, LFNoise0.ar(delay).range(0.0, 1.0)) * env;
	snd = PitchShift.ar(snd, window, ratio, disp, timeDisp);
	snd = Pan2.ar(snd,pan);
	Out.ar(out,snd!2 * amp);
}).add;

SynthDef(\glitch,{
	|out=0, buf=0, maxDelay=1.0, delay=3, amp=0.3, pos=0,sus=2,window=0.2, ratio=1, disp=0, timeDisp=0,pan=0, loop=0, freq=220|
	var snd, env, trig;
	trig = Impulse.kr(freq);
    snd = PlayBuf.ar(2, buf, BufRateScale.kr(buf),trig, startPos:pos, loop: loop);
	env = EnvGen.ar(
		Env.new([0, 1, 1, 0], [0.05, sus, 0.02]), 1, doneAction:2);
    snd = DelayC.ar(snd, maxDelay, LFNoise0.ar(delay).range(0.0, 1.0)) * env;
	snd = PitchShift.ar(snd, window, ratio, disp, timeDisp);
	snd = Pan2.ar(snd,pan);
	snd = FaustBitDowner.ar(snd,4,1);
	snd = snd + DelayC.ar(snd);
	snd = FaustCompressor.ar(snd,0.002,3,2,0.5,-12);
	Out.ar(out,snd!2 * amp);
}).add;

//taken from ixilang
SynthDef(\organ, {arg out=0, freq=220, gate=1, amp=0.3, pan=0;
	var wave, amps, env;
	amps = [0.6134, 0.5103, 0.3041, 0.2216, 0.4175, 0.1082, 0.067, 0.0773, 0, 0.01546];
	wave = amps.collect({|amp, i| SinOsc.ar([freq *(i+1), freq *(i+1) +Rand(1, 3.8)], 0, amp*0.1) }).sum;
	env = EnvGen.ar(Env.asr(0.01, 1, 0.2), gate, doneAction:2);
	Out.ar(out, Balance2.ar(wave[0], wave[1], pan, amp*env));
}).add;

SynthDef(\simpler, {
	arg buf=0
	,freq=220
	,sampleStart=0
	,loopStart=0
	,loopLen=1 // between 0 (min) and 1 (max)
	,fadeTime=0.1
	,gate=1
	,attack=0.01
	,sustain=1
	,release=1
	,f0=220,
    amp=0.5;

	var rate = freq / f0;
	var sr = rate*BufSampleRate.kr(buf);
	var fadeFrames = fadeTime*sr;
	var loopEnd = loopLen*(BufFrames.kr(buf) - loopStart) + loopStart;
	var loopFrames = loopEnd - loopStart + 1;
	var loopTime = (loopFrames - fadeFrames)/sr;
	var startUpTime = (loopStart - sampleStart)/sr;

	var trigLoop = TDuty.ar(Dseq([startUpTime + loopTime, Dseq([loopTime], inf)]), gapFirst:1);

	var phaseA = Phasor.ar(trigLoop, rate, sampleStart, inf, loopStart);
	var phaseB = Phasor.ar(trigLoop, rate, loopEnd - fadeFrames, inf, loopEnd - fadeFrames);

	var srcA = BufRd.ar(buf.numChannels, buf, phaseA);
	var srcB = BufRd.ar(buf.numChannels, buf, phaseB);

	var startLoop = SetResetFF.ar(trigLoop);
	var loopPan = Phasor.ar(trigLoop, 2/fadeFrames * rate, -1, inf, -1).clip(-1,1);

	var out = Select.ar(startLoop, [srcA, LinXFade2.ar(srcB, srcA, pan:loopPan)]);
	var env = EnvGen.ar(Env.asr(attack, sustain, release, 1), gate, doneAction:2);

	Out.ar(0, Splay.ar(out) * env * amp);
}).add;


)
