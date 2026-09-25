"""Stream Linux CPU, memory, battery and NetworkManager status as JSON lines."""

import json
import os
from pathlib import Path
import subprocess
import time


def read(path):
    try:
        return Path(path).read_text().strip()
    except OSError:
        return ""


def command(*args):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=3,
                              env={**os.environ, "LC_ALL": "C"}, check=True).stdout
    except (OSError, subprocess.SubprocessError):
        return ""


def network():
    devices = command("nmcli", "-t", "-f", "TYPE,STATE", "device", "status")
    if "ethernet:connected" in devices.splitlines():
        return "󰈀"
    if "wifi:connected" in devices.splitlines():
        signals = command("nmcli", "-t", "-f", "IN-USE,SIGNAL", "device", "wifi", "list", "--rescan", "no")
        for line in signals.splitlines():
            if line.startswith("*:"):
                return "󰤨 " + line.split(":")[1] + "%"
        return "󰤨"
    return "󰤭"


def batteries():
    result = []
    icons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    for battery in sorted(Path("/sys/class/power_supply").glob("*")):
        if read(battery / "type") != "Battery" or read(battery / "present") == "0":
            continue
        capacity = read(battery / "capacity")
        if not capacity.isdigit():
            continue
        icon = "󰂄" if read(battery / "status") == "Charging" else icons[min(9, int(capacity) // 10)]
        result.append(f"{icon} {capacity}%")
    return "  ".join(result)


def main():
    previous = None
    network_text = "󰤭"
    next_network = 0
    while True:
        cpu = None
        # Exclude guest fields, which are already included in user/nice.
        values = [int(v) for v in read("/proc/stat").splitlines()[0].split()[1:9]]
        total, idle = sum(values), values[3] + values[4]
        if previous and total > previous[0]:
            cpu = round(100 * (1 - (idle - previous[1]) / (total - previous[0])))
        previous = total, idle
        memory = {line.split(":")[0]: int(line.split()[1])
                  for line in read("/proc/meminfo").splitlines()}
        used = round(100 * (1 - memory["MemAvailable"] / memory["MemTotal"]))
        if time.monotonic() >= next_network:
            network_text = network()
            next_network = time.monotonic() + 10
        print(json.dumps({"cpu": cpu, "memory": used, "network": network_text,
                          "battery": batteries()}), flush=True)
        time.sleep(2)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        pass
