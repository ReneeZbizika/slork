public class OSCListener {
    OscRecv recv;
    OscEvent xEvent;
    OscEvent yEvent;
    OscEvent pressureEvent;
    float x;
    float y;
    float pressure;

    // constructor
    fun void init(int port) {
        port => recv.port;
        recv.listen();

        recv.event("/x, f") @=> xEvent;
        spork ~ listenX();

        recv.event("/y, f") @=> yEvent;
        spork ~ listenY();

        recv.event("/pressure, f") @=> pressureEvent;
        spork ~ listenPressure();
        
    }

    fun void listenX() {
        while (true) {
            xEvent => now;
            while (xEvent.nextMsg()) {
                xEvent.getFloat() => x;
                // <<< "/x:", x >>>;
            }
        }
    }

    fun void listenY() {
        while (true) {
            yEvent => now;
            while (yEvent.nextMsg()) {
                yEvent.getFloat() => y;
                // <<< "/y:", y >>>;
            }
        }
    }

    fun void listenPressure() {
        while (true) {
            pressureEvent => now;
            while (pressureEvent.nextMsg()) {
                pressureEvent.getFloat() => pressure;
                // <<< "/pressure:", pressure >>>;
            }
        }
    }
}

OSCListener listener;
listener.init(9000);  // match the port set in iDraw OSC
1::eon => now;



