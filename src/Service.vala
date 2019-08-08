/*
* Copyright (c) 2019 Manexim (https://github.com/manexim)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class iRobot.Service {
    private static Service? _instance;
    private Socket socket;

    public signal void on_new_device (string message);

    public static Service instance {
        get {
            if (_instance == null) {
                _instance = new Service ();
            }

            return _instance;
        }
    }

    private Service () {
        setup_socket ();
        listen ();
        discover ();
    }

    private void setup_socket () {
        try {
            socket = new Socket (SocketFamily.IPV4, SocketType.DATAGRAM, SocketProtocol.UDP);
            socket.broadcast = true;

            #if HAVE_SO_REUSEPORT
            int32 enable = 1;
            Posix.setsockopt(
                socket.fd, Platform.Socket.SOL_SOCKET, Platform.Socket.SO_REUSEPORT, &enable,
                (Posix.socklen_t) sizeof(int)
            );
            #endif

            var sa = new InetSocketAddress (new InetAddress.any (SocketFamily.IPV4), 5678);
            socket.bind (sa, true);
        } catch (Error e) {
            stderr.printf (e.message);
        }
    }

    private void listen () {
        new Thread<void*> (null, () => {
            while (true) {
                var source = socket.create_source (IOCondition.IN);
                source.set_callback ((s, cond) => {
                    try {
                        uint8 buffer[256];
                        s.receive (buffer);

                        if ((string) buffer != "irobotmcs") {
                            on_new_device ((string) buffer);
                        }
                    } catch (Error e) {
                        stderr.printf (e.message);
                    }
                    return true;
                });
                source.attach (MainContext.default ());

                new MainLoop ().run ();
            }
        });
    }

    private void discover () {
        new Thread<void*> (null, () => {
            while (true) {
                var buffer = "irobotmcs";

                try {
                    socket.send_to (
                        new InetSocketAddress (
                            new InetAddress.from_string ("255.255.255.255"), 5678),
                        buffer.data
                    );
                } catch (Error e) {
                    stderr.printf (e.message);
                }

                Thread.usleep (1 * 1000 * 1000);
            }
        });
    }
}
