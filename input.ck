// input.ck
// MMouse tracking (absolute X) + button press


Hid hi;
HidMsg msg;

// open device 0 (trackpad)
if( !hi.openMouse(0) ) me.exit();
<<< "input.ck: opened mouse:", hi.name() >>>;

// loop to receive HID events
while( true )
{
    hi => now;

    while( hi.recv(msg) )
    {
        // Mouse button down
        if( msg.isButtonDown() )
        {
            1 => Shared.isPressed;
            <<< "button down" >>>;
        }

        // Mouse button up
        else if( msg.isButtonUp() )
        {
            0 => Shared.isPressed;
            <<< "button up" >>>;
        }

        // Trackpad movement: always update position
        if( msg.scaledCursorX >= 0.0 && msg.scaledCursorX <= 1.0 )
        {
            msg.scaledCursorX => Shared.pitchX;
            <<< "x:", Shared.pitchX >>>;
        }
    }
}

