public class OSCListener {
    OscRecv recv;
    OscEvent xEvent, yEvent, pressureEvent;
    global float x, y, pressure;

    // constructor
    fun void init(int port) {
        port => recv.port;
        recv.listen();

        recv.event("/x") @=> xEvent;
        recv.event("/y") @=> yEvent;
        recv.event("/pressure") @=> pressureEvent;

        spork ~ listenX();
        spork ~ listenY();
        spork ~ listenPressure();
    }

    fun void listenX() {
        while (true) {
            xEvent => now;
            while (xEvent.nextMsg()) {
                xEvent.getFloat() => x;
                <<< "/x:", x >>>;
            }
        }
    }

    fun void listenY() {
        while (true) {
            yEvent => now;
            while (yEvent.nextMsg()) {
                yEvent.getFloat() => y;
                <<< "/y:", y >>>;
            }
        }
    }

    fun void listenPressure() {
        while (true) {
            pressureEvent => now;
            while (pressureEvent.nextMsg()) {
                pressureEvent.getFloat() => pressure;
                <<< "/pressure:", pressure >>>;
            }
        }
    }
}