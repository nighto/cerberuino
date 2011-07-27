Cerberuino is a door/gate controller using Arduino.

Requirements:
- Arduino (we used Brasuino BS1, a Arduino One compatible)
- EtherShield w/ ENC28J60 (we bought it from seeedstudio.com)
- RFID Reader (idem)
- Homemade connector shield (optional, we created a shield instead of plugging the wires directly, and connected them using Ethernet Cables on the following table. Schematics should be put online soon)

Pin		Type	Function	Eth. Cable
===		====	========	==========
Digital 0	RX	RFID		Light Blue
Digital 1	TX	RFID		Light Green
Digital 2		Eth
Digital 3	PWM	Speaker
Digital 4		Relay
Digital 5	PWM	LED Blue	Blue
Digital 6	PWM	LED Green	Green
Digital 7		LED Red		Orange
Power GND				Light Orange
Power +5V				Light Brown
Analog 3		Switch		Brown