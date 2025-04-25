@import "config.ck";
Config c;

@import "ipad.ck";
iPad ipad --> GG.scene();

// ======================== Granular Synthesis ========================
class Granulator
{
    int sound_index;

    LiSa lisa;
    PoleZero blocker;
    NRev reverb;
    ADSR adsr;
    Gain master_gain;

    float saved_gain;
    float muted;
    1.0 => float grain_play_rate;       // current playback rate for grains (can be modified by height of cursor)
    
    fun Granulator(int sound_index)
    {
        sound_index => this.sound_index;

        // set the sample for the LiSa (use one LiSa per sound)
        setSample("samples/" + c.GRANULATOR_WAVS[sound_index]);
        
        0.05 => this.reverb.mix;     // reverb mix
        0.99 => this.blocker.blockZero; // pole location to block DC and ultra low frequencies

        this.lisa.chan(0) => this.blocker => this.reverb => this.master_gain => dac;

        spork ~ this.granulate();
        spork ~ this.ipad_listener();
        // spork ~ this.mouse_listener();

        this.mute();
        this.toggle();
    }

    fun void toggle()
    {
        !(this.master_gain.gain() $ int) => this.master_gain.gain;
        // <<< "master gain:", this.master_gain.gain() >>>;
        <<< "pen", c.GRANULATOR_WAVS[this.sound_index], "gain:", this.master_gain.gain() >>>;
    }

    fun void granulate() {
        while( true ) {
            // fire a grain
            fireGrain();
            // amount here naturally controls amount of overlap between grains
            c.GRAIN_LENGTH[this.sound_index] / c.GRAIN_OVERLAP + Math.random2f(0,c.GRAIN_FIRE_RANDOM)::ms => now;
        }
    }

    fun void setSample(string filename)
    {
        SndBuf buf;
        buf.read(filename);

        buf.samples()::samp => this.lisa.duration;

        for (int i; i < buf.samples(); i++)
        {
            this.lisa.valueAt(buf.valueAt(i * buf.channels()), i::samp);
        }

        this.lisa.play(false);
        this.lisa.loop(false);
        this.lisa.maxVoices(c.LISA_MAX_VOICES);
    }

    fun void mute() {
        // <<< "muting" >>>;
        if (this.lisa.gain() < .01) return;
        this.lisa.gain() => saved_gain;
        0 => this.lisa.gain;
    }

    fun void mute(dur du) {
        // <<< "muting" >>>;
        if (this.lisa.gain() < .01) return;
        this.lisa.gain() => saved_gain;
        now + du => time later;
        while (now < later) {
            ((later - now) / du) => this.lisa.gain;
            1::ms => now;
        }
    }

    fun void unmute(dur du) {
        // <<< "unmuting" >>>;
        if (this.lisa.gain() > .01) return;
        now + du => time later;
        while (now < later) {
            saved_gain * (1 - ((later - now) / du)) => this.lisa.gain;
            1::ms => now;
        }
    }

    fun void fireGrain()
    {
        c.GRAIN_LENGTH[this.sound_index] => dur grain_length;
        grain_length * c.GRAIN_RAMP_FACTOR => dur ramp_time;
        // c.GRAIN_POSITION + Math.random2f(0, c.GRAIN_POSITION_RANDOM) => float pos;
        c.GRAIN_POSITION => float pos;

        if( pos >= 0 )
            spork ~ grain(pos * this.lisa.duration(), grain_length, ramp_time, ramp_time,
            grain_play_rate, c.GRAIN_PLAY_RATE_OFF, c.GRAIN_SCALE_DEG);
    }


    fun void grain(dur pos, dur grainLen, dur rampUp, dur rampDown, float rate, float off, float deg )
    {
        // get a voice to use
        this.lisa.getVoice() => int voice;

        // if available
        if( voice > -1 )
        {
            // set rate
            this.lisa.rate( voice, c.RATE_MOD * rate * Math.pow(2, off) * deg ); // TODO: modify rate by offset here
            // set playhead
            this.lisa.playPos( voice, pos );
            // ramp up
            this.lisa.rampUp( voice, rampUp );
            // wait
            (grainLen - rampUp) => now;
            // ramp down
            this.lisa.rampDown( voice, rampDown );
            // wait
            rampDown => now;
        }
    }

    // NOT CURRENTLY USED, REPLACED WITH IPAD LISTENER
    fun void mouse_listener()
    {
        1.0 => float distance_from_camera;
        vec3 mousePos;
        5.3 => float mouseRangeX;
        3.3 => float mouseRangeY;
        
        while (true)
        {
            // <<< "lisa gain:", this.lisa.gain() >>>;
            // <<< "master gain:", this.master_gain.gain() >>>;

            GG.nextFrame() => now;

            if (GWindow.mouseLeftDown()) {
                spork~this.unmute(100::ms);
            }
            else if (GWindow.mouseLeftUp())
            {
                spork~this.mute(300::ms);
            }

            GG.camera().screenCoordToWorldPos(GWindow.mousePos(), distance_from_camera) => mousePos;

            Math.remap(mousePos.x, -mouseRangeX, mouseRangeY, 0.0, 1.0) => float p;
            if (p > 0.95) 0.95 => p;
            else if (p < 0) 0 => p;
            p => c.GRAIN_POSITION;
            
            mousePos.y => float r;
            if (r > 0)
                Math.remap(r, 0, mouseRangeY, 1.0, 4.0) => grain_play_rate;
            else
                Math.remap(r, -mouseRangeY, 0, 0.0, 1.0) => grain_play_rate;
        }
    }


    fun void ipad_listener()
    {
        1 => float prev_pressure;
        int same_pressure_count;

        int we_are_currently_playing;

        while (true) {
            // Set grain playback position from X
            Math.remap(ipad.pencil.x, 0, 1360, 0.0, 1.0) => c.GRAIN_POSITION;

            // Set playback rate from Y
            if (ipad.pencil.y > 500)
                Math.remap(ipad.pencil.y, 1000, 500, -1.0, 2.0) => grain_play_rate;
            else
                Math.remap(ipad.pencil.y, 500, 0, 2.0, 3.0) => grain_play_rate;

            // <<< "grain position:", c.GRAIN_POSITION >>>;
            // <<< "grain play rate:", grain_play_rate >>>;

            // Set volume from pressure
            // <<< "pressure:", listener.pressure >>>;

            if (ipad.pencil.pressure != prev_pressure) {
                0 => same_pressure_count;

                if (!we_are_currently_playing) {
                    // <<< "pressure being applied" >>>;
                    spork ~ this.unmute(100::ms);
                    true => we_are_currently_playing;
                }
            }
            else same_pressure_count++;


            if (same_pressure_count > 4 && we_are_currently_playing)        // if the pencil pressure is the same for 4 consecutive frames, assume we lifted the pencil and mute the sound
            {
                // <<< "pressure removed" >>>;
                spork ~ this.mute(300::ms);
                false => we_are_currently_playing;
            }

            ipad.pencil.pressure => prev_pressure;
            
            GG.nextFrame() => now; // loop every 10ms
        }
    }

}

// ======================== Sound Player ========================

class SoundPlayer
{
    int sound_index;
    int do_loop;
    int sound_playing;

    SndBuf buf;
    Gain g;

    fun SoundPlayer(int sound_index)
    {
        sound_index => this.sound_index;
        
        buf => g => dac;
        0 => g.gain;
        buf.read("samples/" + c.SOUND_WAVS[sound_index]);
        c.LOOPS[sound_index] => buf.loop;
    }

    fun void toggle()
    {
        <<< "toggling sound", this.sound_index >>>;
        // if the sound is not looping, play it once
        // if (!c.LOOPS[this.sound_index])
        // {
        //     <<< "playing sound once", this.sound_index >>>;
        //     1 => g.gain;
        //     0 => buf.pos;
            
        //     return;
        // }

        // otherwise, use toggling to turn the sound on/off
        if (!sound_playing)
        {
            0 => buf.pos;
            1 => g.gain;
            true => sound_playing;
        }
        else
        {
            0 => g.gain;
            false => sound_playing;
        }
    }
}


// ======================== Main Control Flow ========================

// ----------------- Global variables -----------------

// Set up the sound players
SoundPlayer players[0];
for (0 => int i; i < c.NUM_SOUNDS; i++) {
    SoundPlayer sp(i);
    players << sp;
}

// Set up the granular players
Granulator granulators[0];
for (0 => int i; i < c.NUM_GRANULATORS; i++) {
    Granulator gran(i);
    granulators << gran;
}


// ----------------- Functions -----------------

// fun void print_state(int changed_index)
// {
//     string print_string;
//     for (0 => int i; i < c.WAVS.size(); i++) {
//         if (i % 4 == 0) "\n" +=> print_string;
//         if (i == changed_index) "[" +=> print_string;
//         else " " +=> print_string;

//         "(" + c.KEYS[i] + ") " + c.WAVS[i] + " on mode " + players[i].mode +=> print_string;

//         if (i == changed_index) "]" +=> print_string;
//         else " " +=> print_string;

//         "   " +=> print_string;

//         <<< "master gain:", players[i].gran.master_gain.gain() >>>;
        
//     }
//     <<< print_string, "" >>>;
// }


fun void main()
{
    Hid kb;
    HidMsg msg;

    if( !kb.openKeyboard( c.KEYBOARD_DEVICE ) ) me.exit();
    <<< "keyboard '" + kb.name() + "' ready", "" >>>;

    while (true)
    {
        kb => now;

        while (kb.recv(msg)) {
            if (msg.isButtonDown()) {
                for (0 => int i; i < c.NUM_SOUNDS; i++)
                {
                    if (msg.which == c.SOUND_KEYS[i])
                    {
                        players[i].toggle();
                        <<< "sound", i, "toggled" >>>;
                    }
                }

                for (0 => int i; i < c.NUM_GRANULATORS; i++)
                {
                    if (msg.which == c.GRANULATOR_KEYS[i])
                    {
                        granulators[i].toggle();
                        <<< "granulator", i, "toggled" >>>;
                    }
                }
            }
        }
    }
}

main();

