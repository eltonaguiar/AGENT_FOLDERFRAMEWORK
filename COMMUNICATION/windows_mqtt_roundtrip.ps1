# Run on Windows (192.168.2.32). Requires: pip install paho-mqtt
# 1) publish to Linux, 2) subscribe briefly for the reverse ping.
$ErrorActionPreference = "Stop"
python -c @"
import paho.mqtt.client as mqtt, time
c = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
c.connect('192.168.2.52', 1883, 60)
c.loop_start()
c.publish('mentions/linux-test', 'PONG from Windows: I hear you, Linux!', qos=1)
print('published mentions/linux-test')
seen = []
def on_msg(client, userdata, msg):
    seen.append((msg.topic, msg.payload.decode()))
    print('RECEIVED', msg.topic, msg.payload.decode())
c.on_message = on_msg
c.subscribe('mentions/windows-test')
time.sleep(3)
c.loop_stop()
c.disconnect()
print('done', len(seen))
"@
