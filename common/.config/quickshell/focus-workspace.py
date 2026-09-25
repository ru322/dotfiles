"""Focus by stable niri workspace ID, including workspaces on other outputs."""

import json
import os
import socket
import sys

request = {"Action": {"FocusWorkspace": {"reference": {"Id": int(sys.argv[1])}}}}
with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
    connection.settimeout(3)
    connection.connect(os.environ["NIRI_SOCKET"])
    connection.sendall((json.dumps(request) + "\n").encode())
    with connection.makefile() as response:
        reply = json.loads(response.readline())
    if "Err" in reply:
        sys.exit(reply["Err"])
