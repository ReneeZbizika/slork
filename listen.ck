// Setup OSC receiver
OscRecv recv;
9000 => recv.port;
recv.listen();

// Declare global variables to hold incoming values
global float x, y, pressure;


// Audio: basic sine oscillator
SinOsc s => dac;
0.3 => s.gain;


recv.event("*") @=> OscEvent anythingEvent;
spork ~ handleAny();

fun void handleAny() {
    while (true) {
        anythingEvent => now;
        while (anythingEvent.nextMsg()) {
            <<< "OSC RECEIVED (wildcard)" >>>;
        }
    }
}


// Spork handlers for each OSC path
recv.event("/x") @=> OscEvent xEvent;
spork ~ handleX();

recv.event("/y") @=> OscEvent yEvent;
spork ~ handleY();

recv.event("/pressure, f") @=> OscEvent pressureEvent;
spork ~ handlePressure();

fun void handleX() {
    while (true) {
        xEvent => now;
        while (xEvent.nextMsg()) {
            xEvent.getFloat() => x;
	    <<<"Recieved x:", x >>>;
            
	// Map x to frequency (e.g., 200–800 Hz)
            (x / 800.0) * 600 + 200 => s.freq;
        }
    }
}

fun void handleY() {
    while (true) {
        yEvent => now;
        while (yEvent.nextMsg()) {
            yEvent.getFloat() => y;
            // You could use y for filter cutoff, panning, etc.
        }
    }
}

fun void handlePressure() {
    while (true) {
        pressureEvent => now;
        while (pressureEvent.nextMsg()) {
            pressureEvent.getFloat() => pressure;
            // Map pressure to gain
            pressure * 0.5 => s.gain;
        }
    }
}

// Keep the program running forever
while (true) { 100::ms => now; }
