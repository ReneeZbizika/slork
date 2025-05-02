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

    Texture slide_textures[6];

    // 0. black screen (black image)
    Texture.load(me.dir() + "assets/popup.png") @=> slide_textures[0];

    // 1. kiran roaring (video)
    Video roar_video(me.dir() + "assets/roar.mpg") => dac;
    roar_video.rate(0);
    roar_video.texture() @=> slide_textures[1];

    // 2. renee and keshav Drawn2Noize (image), then back to black screen (slide 0)
    Texture.load(me.dir() + "assets/title.png") @=> slide_textures[2];

    // 3. ipad video (webcam texture)
    Webcam webcam(c.WEBCAM_DEVICE);
    <<< "webcam name: ", webcam.deviceName() >>>;
    webcam.texture() @=> slide_textures[3];
    UI_Bool capture(webcam.capture());
    
    // 4. ipad glitching (video), then back to ipad video (slide 3)
    Video glitching_video(me.dir() + "assets/glitch.mpg");
    glitching_video.rate(0);
    glitching_video.loop(true);
    glitching_video.texture() @=> slide_textures[4];

    // 5. fin (video)
    Video fin_video(me.dir() + "assets/fin.mpg");
    fin_video.rate(0);
    fin_video.texture() @=> slide_textures[5];

    


    fun void jump_to_slide(int slide_idx)
    {
        plane.colorMap(slide_textures[slide_idx]);
        rescale(slide_idx);
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

    fun void rescale(int slide_idx)
    {
        <<< "rescaling to slide: ", slide_idx >>>;
        if (slide_idx == 0) plane.sca(@(slide_width, -slide_height, 1));
        if (slide_idx == 1) plane.sca(@(slide_width, -slide_height, 1));
        if (slide_idx == 2) plane.sca(@(webcam.aspect() * slide_height, -slide_height, 1));
        if (slide_idx == 3) plane.sca(@(webcam.aspect() * slide_height, slide_height, 1));
        if (slide_idx == 4) plane.sca(@(webcam.aspect() * slide_height, slide_height, 1));
        if (slide_idx == 5) plane.sca(@(slide_width, -slide_height, 1));
    }

    fun void popup(dur popup_duration)
    {
        FlatMaterial popup_mat;
        popup_mat.scale(@(1, -1));  // flip across the y-axis
        Texture.load(me.dir() + "assets/popup.png") @=> Texture popup_texture;
        popup_mat.colorMap(popup_texture);
        PlaneGeometry popup_geo;
        GMesh popup(popup_geo, popup_mat) --> this;
        popup.translateZ(2);
        popup.scaY(0.9);

        popup_duration => now;
        popup --< this;

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