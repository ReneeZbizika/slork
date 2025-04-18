from pythonosc import dispatcher, osc_server

def print_handler(address, *args):
    print(f"{address}: {args}")

dispatcher = dispatcher.Dispatcher()
dispatcher.set_default_handler(print_handler)

ip = "0.0.0.0"
port = 9000

server = osc_server.ThreadingOSCUDPServer((ip, port), dispatcher)
print(f"Listening on {ip}:{port}")
server.serve_forever()
