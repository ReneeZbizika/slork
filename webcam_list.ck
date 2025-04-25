for (0 => int i; i < 5; i++)
{
    Webcam webcam(i);
    <<< "webcam: ", i >>>;
    <<< "webcam name: ", webcam.deviceName() >>>;
    <<< "webcam width: ", webcam.width() >>>;
    <<< "webcam height: ", webcam.height() >>>;
    <<< "webcam fps: ", webcam.fps() >>>;
    <<< "webcam aspect: ", webcam.aspect() >>>;
    <<< "--------------------------------" >>>;
}
