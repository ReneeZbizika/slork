@import "config.ck";
Config c;

@import "ipad.ck";
iPad ipad --> GG.scene();

@import "GSlideshow.ck";
GSlideshow slideshow --> GG.scene();

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
    
    fun Granulator()
    {
        // set the sample for the LiSa (use one LiSa per sound)
        setSound(0);
        // 0 => master_gain.gain;
        
        0.05 => this.reverb.mix;     // reverb mix
        0.99 => this.blocker.blockZero; // pole location to block DC and ultra low frequencies

        this.lisa.chan(0) => this.blocker => this.reverb => this.master_gain => dac;

        spork ~ this.granulate();
        spork ~ this.ipad_listener();
        // spork ~ this.mouse_listener();

        this.mute();
        
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

    // takes a sound index and sets the sample for the LiSa
    fun void setSound(int index)
    {
        // 1 => this.master_gain.gain;
        "samples/" + c.GRANULATOR_WAVS[index] => string filename;
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

            <<< "we_are_currently_playing", we_are_currently_playing >>>;
            <<< "grain position", c.GRAIN_POSITION >>>;
            <<< "grain play rate", grain_play_rate >>>;


            // Set grain playback position from X
            Math.remap(ipad.pencil.x, 0, 1360, 0.0, 1.0) => c.GRAIN_POSITION;

            // Set playback rate from Y
            if (ipad.pencil.y > 500)
                Math.remap(ipad.pencil.y, 1000, 500, -1.0, 2.0) => grain_play_rate;
            else
                Math.remap(ipad.pencil.y, 500, 0, 2.0, 3.0) => grain_play_rate;

            // if we are currently playing (i.e. the pressure has changed)
            if (ipad.pencil.pressure != prev_pressure) {
                0 => same_pressure_count;

                update_sound_parameters(ipad.pencil.pressure);      // then update the sound

                if (!we_are_currently_playing) {        // unmute the sound if its not already playing
                    // <<< "pressure being applied" >>>;
                    spork ~ this.unmute(100::ms);
                    true => we_are_currently_playing;
                }
            }
            else same_pressure_count++;

            // if the pencil pressure is the same for 4 consecutive frames, 
            // assume we lifted the pencil and mute the sound
            if (same_pressure_count > 8 && we_are_currently_playing)
            {
                // <<< "pressure removed" >>>;
                spork ~ this.mute(300::ms);
                false => we_are_currently_playing;
            }

            ipad.pencil.pressure => prev_pressure;
            
            GG.nextFrame() => now; // loop every 10ms
        }
    }

    fun void update_sound_parameters(float pressure) {
        // update the sound parameters based on the pressure
       pressure / 1.5 => this.lisa.gain;
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

    fun SoundPlayer(string filename, int loops)
    {
        buf => g => dac;
        0 => g.gain;
        buf.read(filename);
        loops => buf.loop;
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

    fun void fade_out(dur du) {
        Envelope env => blackhole;
        env.duration(du);
        env.value(1);
        env.target(0);
        while (env.value() > 0)
        {
            env.value() => g.gain;
            1::ms => now;
            <<< "fade out gain()", g.gain() >>>;
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

SoundPlayer intro_music("samples/intro_music.wav", false);
SoundPlayer night_music("samples/night_music.wav", true);
SoundPlayer chaos_music("samples/chaos_music.wav", true);
SoundPlayer glitch_music("samples/glitch_music.wav", true);
SoundPlayer friendship_music("samples/friendship_music.wav", false);
SoundPlayer fin_music("samples/fin_music.wav", false);

// Set up the granular player
Granulator granulator;

// Set up the next slide event
Event next_slide;

// ----------------- Functions -----------------

fun void keyboard_listener()
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
                        granulator.setSound(i);
                    }
                }

                if (msg.which == c.GLITCH_KEY) {
                    next_slide.signal();
                }
            }
        }
    }
}

spork ~ keyboard_listener();


fun intro()
{
    slideshow.jump_to_slide(5);
    next_slide => now;

    <<< "showing roar video" >>>;
    slideshow.roar_video.rate(1);
    intro_music.toggle();
    slideshow.jump_to_slide_with_fade(1, 0.1::second, 2::second);
    3::second => now;

    <<< "showing title screen" >>>;
    slideshow.jump_to_slide_with_fade(2, 2::second, 2::second);
    5::second => now;
    slideshow.jump_to_slide_with_fade(5, 3::second, 0.1::second);     // fade to black
}

// renee draws in the dark, then we fade into the drawings
fun void act_1()
{
    next_slide => now;

    <<< "playing night music + fading in ipad" >>>;
    night_music.toggle();
    slideshow.jump_to_slide_with_fade(3, 0.2::second, 10::second);
}

// keshav and renee fight over the drawings
fun void act_2()
{
    next_slide => now;
    spork ~ night_music.fade_out(3.5::second);     // fade out the night background music
    chaos_music.toggle();
}

// ipad glitches out
fun void act_3()
{
    next_slide => now;
    slideshow.jump_to_slide(4);
    slideshow.glitching_video.rate(1);

    glitch_music.toggle();
    chaos_music.buf.pos() => glitch_music.buf.pos;  // glitch music starts at the same position as chaos music
    chaos_music.toggle();
}

// drawing is lost, then kehsav draws a new drawing for renee
fun void act_4()
{
    next_slide => now;

    slideshow.jump_to_slide(3);
    spork ~ slideshow.popup(6::second);

    chaos_music.toggle();
    glitch_music.buf.pos() => chaos_music.buf.pos;
    glitch_music.toggle();
    chaos_music.fade_out(3::second);
    friendship_music.toggle();
}

fun void fin()
{   
    next_slide => now;
    spork ~ friendship_music.fade_out(2::second);
    fin_music.toggle();
    
    4::second => now;
    slideshow.fin_video.rate(0.5);
    slideshow.jump_to_slide_with_fade(5, 2::second, 2::second);
    

    next_slide => now;
}

GG.scene().light().intensity(0.7);
GG.scene().ambient(@(0.7, 0.7, 0.7));
intro();
act_1();
act_2();
act_3();
act_4();
fin();






