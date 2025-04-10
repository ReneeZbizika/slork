// Setup
Hid hi;
HidMsg msg;

// Open default mouse device
if( !hi.openMouse(0) ) me.exit();
<<< "Opened:", hi.name() >>>;

// Synth
SinOsc osc => dac;
0 => osc.gain;

// State
false => int isPressed;

// Main loop
while( true )
{
    hi => now;

    while( hi.recv(msg) )
    {
        // Button down = play mode
        if( msg.isButtonDown() )
        {
            <<< "button down" >>>;
            1 => isPressed;
        }

        // Button up = stop sound
        else if( msg.isButtonUp() )
        {
            <<< "button up" >>>;
            0 => isPressed;
            0 => osc.gain;
        }

        // Always use scaledCursorX if pressed
        if( isPressed )
        {
            // Make sure X is in [0,1]
            if( msg.scaledCursorX >= 0.0 && msg.scaledCursorX <= 1.0 )
            {
                // Map to pitch
                msg.scaledCursorX * 48 + 48 => float midiF;
                Std.mtof(midiF $ int) => osc.freq;
                0.3 => osc.gain;
                <<< "pitch:", osc.freq(), "x:", msg.scaledCursorX >>>;
            }
        }
    }
}
