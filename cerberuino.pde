/*
   Cerberuino
   (C) 2011 by Arlindo "Nighto" Pereira, João Carlos "JC" Pena
   Licensed on GPLv3+
   https://github.com/nighto/cerberuino
   
   Uses square wave tune code from: Daniel Gimpelevich - http://www.arduino.cc/playground/Code/MusicalAlgoFun
*/

#include <SPI.h>         // needed for Arduino versions later than 0018
#include <Ethernet.h>
#include <Udp.h>         // UDP library from: bjoern@cs.stanford.edu 12/30/2008

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {  
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 
  10,0,0,9 };

unsigned int localPort = 11000;      // local port to listen on

// the next two variables are set when a packet is received
byte broadcastIp[] = { 
  10,0,0,100 };

byte remoteIp[4];        // holds received packet's originating IP
unsigned int remotePort; // holds received packet's originating port

// buffers for receiving and sending data
char packetBuffer[UDP_TX_PACKET_MAX_SIZE]; //buffer to hold incoming packet,
char  DoorBellRinging[] = "DOORRINGING";      // a string to send back



const int serialRxPin = 0; // RX
const int serialTxPin = 1; // TX
const int speakerPin =  3; // PWM
const int relayPin =    4;
const int ledBPin =     5; // PWM
const int ledGPin =     6; // PWM
const int ledRPin =     7;

const int switchPin =   A3;

const int analogValueOn = 255;
const int analogValueOff = 0;

const int debugDelay = 500;

/* Speaker */

/* 9.5 octaves :: semitones. 60 = do, 62 = re, etc. */
/* MIDI notes from 0 to 113. */
unsigned int timeUpDown[114];

const char beethoven[] = {	64,4,64,4,65,4,67,4,		67,4,65,4,64,4,62,4,
			60,4,60,4,62,4,64,4,		64,-4,62,8,62,2,
			64,4,64,4,65,4,67,4,		67,4,65,4,64,4,62,4,
			60,4,60,4,62,4,64,4,		62,-4,60,8,60,2,
			62,4,62,4,64,4,60,4,		62,4,64,8,65,8,64,4,60,4,
			62,4,64,8,65,8,64,4,62,4,	60,4,62,4,55,2,
			64,4,64,4,65,4,67,4,		67,4,65,4,64,4,62,4,
			60,4,60,4,62,4,64,4,		62,-4,60,8,60,2};

// 72 do 74 re 76 mi 77 fa 79 sol 81 la 83 si 84 do 86 re 88 mi
// mi-re fa# sol#, do#-si re mi, si-la do# mi laaa

const char nokia[] = {88,8,86,8,78,4,79,4, 85,8,83,8,74,4,76,4, 83,8,81,8,73,4,76,4, 81,2};

const char scale[] = {60,16,62,16,64,16,65,16,67,16,69,16,71,16,72,8};

int period, i;
unsigned int timeUp, beat;
byte statePin = LOW;
const byte BPM = 240;
const float TEMPO_SECONDS = 60.0 / BPM; 
const unsigned int MAXCOUNT = sizeof(nokia) / 2;


int loops = 0;

/* /Speaker */

void setup() {
  pinMode(ledRPin, OUTPUT);
  pinMode(ledGPin, OUTPUT);
  pinMode(ledBPin, OUTPUT);
  pinMode(relayPin, OUTPUT);
  pinMode(speakerPin, OUTPUT);
  
  pinMode(switchPin, INPUT);
  
  setupSpeaker();
  
  
  // start the Ethernet and UDP:
  Ethernet.begin(mac,ip);
  Udp.begin(localPort);

  Serial.begin(9600);
  
  //Call Post function
  debug();
}


void loop() {
  
  loops++;
  if (loops < 5) {
      analogLedOn(ledBPin);
  } else if (loops > 10) {
      analogLedOff(ledBPin);
  } 
  
  if (loops > 150) {
      loops = 0;
  } 
  
  Serial.println(loops);
    
  checkDoorBell();
  checkOpenDoorRequests();

  delay(50);
}


/////// ### REAL PROGRAM!

void playDoorBell() {
  debugPlayMusic(nokia);
}

void checkDoorBell() {
  Serial.println("checkDoorBell");
  
  if (digitalRead(switchPin) == HIGH) {
    Serial.println("checkDoorBell-HIGH");
    
    //notifyComputers();
    playDoorBell();
    notifyComputers();
  }
  
}


void notifyComputers() {
    
    Udp.sendPacket(DoorBellRinging, broadcastIp, localPort);
}

void checkOpenDoorRequests() {
  
  
  Serial.println("checkOpenDoorRequests");
  // if there's data available, read a packet
  int packetSize = Udp.available(); // note that this includes the UDP header
  if(packetSize)
  {
    packetSize = packetSize - 8;      // subtract the 8 byte header
    Serial.print("Received packet of size ");
    Serial.println(packetSize);

    // read the packet into packetBufffer and get the senders IP addr and port number
    Udp.readPacket(packetBuffer,UDP_TX_PACKET_MAX_SIZE, remoteIp, remotePort);
    Serial.println("Contents:");
    Serial.println(packetBuffer);
    
    if (packetBuffer == "OPENDOOR")
    {
        openDoor();
    }

    
  }
}

void openDoor() {
    analogLedOn(ledGPin);
    
    digitalWrite(relayPin, HIGH);
    delay(100);
    digitalWrite(relayPin, LOW);
    
    delay(1000);
    analogLedOff(ledGPin);
}




void debug() {
  beep();
  debugBlinkLeds();
  //debugPlayMusic(nokia);
  //debugSwitch();
}

/* LEDs */
void debugBlinkLeds() {
  blinkDigitalLed(ledRPin);
  
  blinkAnalogLed(ledGPin);
  
  blinkAnalogLed(ledBPin);
}

void blinkDigitalLed(int pin) {
  digitalLedOn(pin);
  delay(debugDelay);
  digitalLedOff(pin);
  //delay(debugDelay);
}

void blinkAnalogLed(int pin) {
  analogLedOn(pin);
  delay(debugDelay);
  analogLedOff(pin);
  //delay(debugDelay);
}

void digitalLedOn(int pin) {
  digitalWrite(pin, HIGH);
}

void digitalLedOff(int pin) {
  digitalWrite(pin, LOW);
}

void analogLedOn(int pin) {
  analogWrite(pin, analogValueOn);
}

void analogLedOff(int pin) {
  analogWrite(pin, analogValueOff);
}

/* Speaker */

void beep() {
  for (int i=0; i<200; i++) {  // generate a 1KHz tone for 1/2 second
    digitalWrite(speakerPin, HIGH);
    delayMicroseconds(500);
    digitalWrite(speakerPin, LOW);
    delayMicroseconds(500);
  } 
}

void setupSpeaker() {
  for (i = 0; i < 114; i++)
    timeUpDown[i] = 1000000 / (pow(2, (i - 69) / 12.0) * 880);
}

void debugPlayMusic(const char song[]) {
  digitalWrite(speakerPin, LOW);     
  for (beat = 0; beat < MAXCOUNT; beat++) {
    statePin = !statePin;
    //digitalWrite(ledPin, statePin);

    i = song[beat * 2];
    timeUp = (i < 0) ? 0 : timeUpDown[i];

    period = (timeUp ? (1000000 / timeUp) / 2 : 250) * TEMPO_SECONDS
      * 4 / song[beat * 2 + 1];
    if (period < 0)
      period = period * -3 / 2;
    for (i = 0; i < period; i++) {
      digitalWrite(speakerPin, timeUp ? HIGH : LOW);
      delayMicroseconds(timeUp ? timeUp : 2000);
      digitalWrite(speakerPin, LOW);
      delayMicroseconds(timeUp ? timeUp : 2000);
    }
  delay(50);
  }
  digitalWrite(speakerPin, LOW);
}

/* Switch */

void debugSwitch() {
  int switchState = digitalRead(switchPin);
  
  digitalWrite(ledRPin, HIGH);
  
  while(switchState == LOW) {
    beep();
    delay(500);
    switchState = digitalRead(switchPin);
  }

  digitalWrite(ledRPin, LOW);
  blinkAnalogLed(ledGPin);
}
