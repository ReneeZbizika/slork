// synth.ck

// Create and initialize instance
//PitchMap pitchMap;
//0 => pitchMap.root;
//[0, 2, 4, 5, 7, 9, 11] @=> pitchMap.scale;

SinOsc osc => dac;
0.3 => osc.gain;

while(true)
{
    10::ms => now;

    if(Shared.isPressed)
    {
        Shared.pitchX => float x;
        pitchMap.quantize(x) => int midiNote;
        Std.mtof(midiNote) => osc.freq;
        0.3 => osc.gain;
    }
    else
    {
        0 => osc.gain;
    }
}

