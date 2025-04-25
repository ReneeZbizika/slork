@import "config.ck";
@import "osc_listener.ck";

public class iPad extends GGen
{
    Config c;
    OSCListener pencil;

    // ipad screen input
    Webcam webcam(c.WEBCAM_DEVICE);
    <<< "webcam width: ", webcam.width() >>>;
    <<< "webcam height: ", webcam.height() >>>;
    <<< "webcam fps: ", webcam.fps() >>>;
    <<< "webcam aspect: ", webcam.aspect() >>>;
    <<< "webcam name: ", webcam.deviceName() >>>;

    // video input
    Video video(me.dir() + "./glitch_img.mpg") => dac;
    video.loop(true);

    FlatMaterial plane_mat;
    plane_mat.scale(@(-1, 1));  // flip across the y-axis
    plane_mat.colorMap(webcam.texture());
    PlaneGeometry plane_geo;
    GMesh plane(plane_geo, plane_mat) --> this;

    plane.scaX(3 * webcam.aspect());
    plane.scaY(3);

    UI_Bool capture(webcam.capture());
    
    // constructor
    fun iPad()
    {
        pencil.init(c.OSC_PORT);  // match the port set in iDraw OSC
    }

    // display the webcam (which is the iPad's live feed)

    // 
    fun void glitch_and_turn_off()
    {
        plane_mat.colorMap(video.texture());
        // plane.mat(plane_mat);
    }

    // "fix the glitch" by displaying the ipad and a pop up "unable to save changes"
    fun void fix_glitch()
    {
        FlatMaterial popup_mat;
        popup_mat.scale(@(1, -1));  // flip across the y-axis
        Texture.load(me.dir() + "./popup.png") @=> Texture popup_texture;
        popup_mat.colorMap(popup_texture);
        PlaneGeometry popup_geo;
        GMesh popup(popup_geo, popup_mat) --> this;
        popup.translateZ(2);

        plane_mat.colorMap(webcam.texture());

        5::second => now;
        popup --< this;

    }
}


fun void foo()
{
    10::second => now;
    <<< "glitch and turn off" >>>;
    ipad.glitch_and_turn_off();
    5::second => now;
    <<< "fix glitch" >>>;
    ipad.fix_glitch();
}

iPad ipad --> GG.scene();
spork ~ foo();
while (true)
{
    GG.nextFrame() => now;
}



