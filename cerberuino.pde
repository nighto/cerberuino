/*
   Cerberuino
   (C) 2011 by Arlindo "Nighto" Pereira, João Carlos "JC" Pena
   Licensed on GPLv3+
   https://github.com/nighto/cerberuino
   
   Uses square wave tune code from: Daniel Gimpelevich - http://www.arduino.cc/playground/Code/MusicalAlgoFun
*/

#include <EtherShield.h>
#include <EtherShieldUDP.h>


// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
static uint8_t mymac[6] = {
  0x54,0x55,0x58,0x10,0x00,0x25}; 
  
static uint8_t myip[4] = {
  10,0,0,8};
  

static uint16_t localPort = 50000;
static uint16_t remotePort = 11000;

static EtherShieldUDP udp = EtherShieldUDP();

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

// mi mi __ mi __ do mi __ sol __ __ __ sol

const char mario[] = {76,8,76,8,0,8,76,8,0,8,72,8,76,8,0,8,79,8,0,4,0,8,67,8};

const char scale[] = {60,16,62,16,64,16,65,16,67,16,69,16,71,16,72,8};

int period, i;
unsigned int timeUp, beat;
byte statePin = LOW;
const byte BPM = 240;
const float TEMPO_SECONDS = 60.0 / BPM; 
const unsigned int MAXCOUNT = sizeof(mario) / 2;


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
  udp.configure(mymac, myip, localPort, remotePort);

  Serial.begin(9600);
  
  //Call Post function
  debug();
}


void loop() {
  loopsCount();
 
  Serial.println(loops);
    
  checkDoorBell();
  checkOpenDoorRequests();

  delay(50);
}


/////// ### REAL PROGRAM!

void loopsCount() {
  loops++;
  if (loops < 5) {
      analogLedOn(ledBPin);
  } else if (loops > 10) {
      analogLedOff(ledBPin);
  } 
  
  if (loops > 150) {
      loops = 0;
  } 
}

void playDoorBell() {
  debugPlayMusic(mario);
}

void checkDoorBell() {
  Serial.println("checkDoorBell");
  
  if (digitalRead(switchPin) == HIGH) {
    Serial.println("checkDoorBell-HIGH");
    
    notifyComputers();
    playDoorBell();
    notifyComputers();
  }
  
}


void notifyComputers() {
    udp.sendBroadcast("DOORBELL");
}

void checkOpenDoorRequests() {
  
  int dat_p = udp.receiveTCP();
  
  if(dat_p != 0) {
    String receivedString = udp.getReceivedString(dat_p);
    
    if (receivedString.equals("OPENDOOR")) {
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
