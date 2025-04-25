@import "config.ck";
@import "osc_listener.ck";

public class iPad extends GGen
{
    Config c;
    OSCListener pencil;

    Webcam webcam(c.WEBCAM_DEVICE);
    <<< "webcam width: ", webcam.width() >>>;
    <<< "webcam height: ", webcam.height() >>>;
    <<< "webcam fps: ", webcam.fps() >>>;
    <<< "webcam aspect: ", webcam.aspect() >>>;
    <<< "webcam name: ", webcam.deviceName() >>>;

    FlatMaterial plane_mat;
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
    // fun void glitch_and_turn_off()
    // {

    // }

    
}






@import "Config.ck";

public class GSlideshow extends GGen
{
    Config c;

    GPlane plane --> this;

    c.SLIDE_WIDTH => float slide_width;
    c.SLIDE_HEIGHT => float slide_height;
    plane.scaX(slide_width);
    plane.scaY(slide_height);
    1.0 => float prev_scale;

    [
        "diskomponist.001.png",
        "diskomponist.002.png",
        "diskomponist.003.png",
        "diskomponist.004.png",
        "diskomponist.005.png",
        "diskomponist.006.png",
        "diskomponist.007.png",
        "diskomponist.008.png",
        "diskomponist.009.png",
        "diskomponist.010.png",
        "diskomponist.011.png",
        "diskomponist.012.png",
        "diskomponist.013.png",
        "diskomponist.014.png",
        "diskomponist.015.png",
        "diskomponist.016.png",
        "diskomponist.017.png",
        "diskomponist.018.png",
        "diskomponist.019.png",
        "diskomponist.020.png",
        "diskomponist.021.png",
        "diskomponist.022.png",
        "diskomponist.023.png",
        "diskomponist.024.png",
        "diskomponist.025.png",
        "diskomponist.026.png",
    ] @=> string slides[];


    TextureLoadDesc y_flipper;
    true => y_flipper.flip_y;
    Texture slide_textures[slides.size()];
    for(0 => int i; i < slides.size(); i++)
    {
        Texture.load(me.dir() + "assets/slides/" + slides[i], y_flipper) @=> slide_textures[i];
    }


    fun void jump_to_slide(int slide_idx)
    {
        plane.colorMap(slide_textures[slide_idx]);
    }

    fun void jump_to_slide_with_fade(int slide_idx, dur out, dur in)
    {
        fade_out(out);
        jump_to_slide(slide_idx);
        fade_in(in);
    }

    fun void fade_out(dur fade_duration)
    {
        _fade_lighting(0.0, fade_duration);
    }

    fun void fade_in(dur fade_duration)
    {
        _fade_lighting(0.7, fade_duration);
    }

    fun void _fade_lighting(float target, dur fade_duration)
    {
        Envelope env => blackhole;
        fade_duration => env.duration;
        GG.scene().light().intensity() => env.value;
        target => env.target;

        while (env.value() != env.target())
        {
            <<< "env.value(): " + env.value() >>>;
            GG.scene().light().intensity(env.value());
            GG.scene().ambient(@(env.value(), env.value(), env.value()));
            10::ms => now;
        }
    }

    fun void randomize(string section, dur duration, dur interval)
    {
        int included_slides[];
        if (section == "what you do to me") [9, 10, 11, 18] @=> included_slides;
        else if (section == "help") [12, 13, 14, 19] @=> included_slides;
        else if (section == "im human") [15, 16, 17, 24] @=> included_slides;
        else if (section == "trapped soul") [18, 19, 20, 21, 22, 23, 24, 25] @=> included_slides;
        else if (section == "normal") [0, 1, 2, 3, 4, 8, 10, 12, 15] @=> included_slides;
        else if (section == "normal + trapped soul") [0, 1, 2, 3, 4, 8, 10, 12, 15, 18, 19, 20, 21, 22, 23, 24, 25] @=> included_slides;
        

        dur time_elapsed;
        while (time_elapsed < duration)
        {
            Math.random2(0, included_slides.size() - 1) => int random_slide;
            included_slides[random_slide] => int slide_idx;
            <<< "slide_idx: " + slide_idx >>>;
            jump_to_slide(slide_idx);
            interval => now;
            time_elapsed + interval => time_elapsed;
        }
    }

    fun void update(float dt)
    {
        GG.windowWidth() / c.WINDOW_WIDTH_CONSTANT => float width_scale;
        GG.windowHeight() / c.WINDOW_HEIGHT_CONSTANT => float height_scale;
        Math.min(width_scale, height_scale) => float scale;

        if (scale != prev_scale)
        {
            scale => prev_scale;
            plane.scaX(c.SLIDE_WIDTH * scale);
            plane.scaY(c.SLIDE_HEIGHT * scale);
        }
    }
    

}