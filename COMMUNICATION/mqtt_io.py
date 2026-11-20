#!/usr/bin/env python3
"""Minimal MQTT publish/subscribe CLI for COMS transport tests.

Why this exists: `verify_coms_windows.ps1` used to record three SKIPs because
`mosquitto_pub`/`mosquitto_sub` are not installed on the Windows host, and a
skipped transport test meant the 500 KB path had *never* been exercised. The
transport coms.ps1 itself publishes with is python + paho, which is installed,
so tests use that instead of skipping.

    python mqtt_io.py pub --topic notes/x --message hello [--retain]
    python mqtt_io.py pub --topic notes/x --file big.bin   [--retain]
    python mqtt_io.py sub --topic notes/x [--wait 3] [--len]

`sub --len` prints the payload size of the last message received, or -1 if none
arrived — that is what makes a byte-for-byte comparison possible for a 500 KB
payload without moving it through argv.
"""
from __future__ import annotations

import argparse
import sys
import time

try:
    import paho.mqtt.client as mqtt
except ImportError:
    print("ERROR: paho-mqtt not installed (pip install paho-mqtt)", file=sys.stderr)
    raise SystemExit(2)


def client():
    try:
        return mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    except AttributeError:  # paho < 2.0
        return mqtt.Client()


def cmd_pub(a) -> int:
    if a.file:
        try:
            data = open(a.file, "rb").read()
        except OSError as exc:
            print("ERROR: %s" % exc, file=sys.stderr)
            return 2
    else:
        data = (a.message or "").encode("utf-8")
    c = client()
    try:
        c.connect(a.broker, a.port, 60)
        info = c.publish(a.topic, data, qos=1, retain=a.retain)
        info.wait_for_publish(30)
    except Exception as exc:
        print("ERROR: publish failed: %s" % exc, file=sys.stderr)
        return 1
    finally:
        try:
            c.disconnect()
        except Exception:
            pass
    print("published %d bytes to %s%s"
          % (len(data), a.topic, " (retained)" if a.retain else ""))
    return 0


def cmd_sub(a) -> int:
    got: list[bytes] = []

    def on_message(_c, _u, msg):
        got.append(msg.payload)

    c = client()
    c.on_message = on_message
    try:
        c.connect(a.broker, a.port, 60)
        c.subscribe(a.topic, qos=1)
        c.loop_start()
        time.sleep(a.wait)
        c.loop_stop()
    finally:
        try:
            c.disconnect()
        except Exception:
            pass

    if a.len:
        print(len(got[-1]) if got else -1)
        return 0
    if got:
        sys.stdout.write(got[-1].decode("utf-8", "replace"))
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    # --broker/--port belong on EACH subcommand, not only the parent: callers
    # write `mqtt_io.py pub --broker X --topic T`, and a parent-only option is
    # rejected after the subcommand (measured 2026-11-20).
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--broker", default="192.168.2.52")
    common.add_argument("--port", type=int, default=1883)

    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("pub", parents=[common])
    p.add_argument("--topic", required=True)
    p.add_argument("--message", default="")
    p.add_argument("--file", default="")
    p.add_argument("--retain", action="store_true")
    p.set_defaults(func=cmd_pub)

    s = sub.add_parser("sub", parents=[common])
    s.add_argument("--topic", required=True)
    s.add_argument("--wait", type=float, default=3.0)
    s.add_argument("--len", action="store_true")
    s.set_defaults(func=cmd_sub)

    a = ap.parse_args()
    return a.func(a)


if __name__ == "__main__":
    raise SystemExit(main())
