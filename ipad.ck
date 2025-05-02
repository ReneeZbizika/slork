@import "config.ck";
@import "osc_listener.ck";

public class iPad extends GGen
{
    Config c;
    OSCListener pencil;
    
    // constructor
    fun iPad()
    {
        pencil.init(c.OSC_PORT);  // match the port set in iDraw OSC
    }
}



