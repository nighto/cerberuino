/*
   Cerberuino
   (C) 2011 by Arlindo "Nighto" Pereira, João Carlos "JC" Pena
   Licensed on GPLv3+
   https://github.com/nighto/cerberuino
   
   Uses square wave tune code from: Daniel Gimpelevich - http://www.arduino.cc/playground/Code/MusicalAlgoFun
*/

const int serialRxPin = 0; // RX
const int serialTxPin = 1; // TX
const int switchPin =   2;
const int speakerPin =  3; // PWM
const int relayPin =    4;
const int ledBPin =     5; // PWM
const int ledGPin =     6; // PWM
const int ledRPin =     7;

const int analogValueOn = 255;
const int analogValueOff = 0;

const int debugDelay = 1000;

/* Speaker */

/* 9.5 octaves :: semitones. 60 = do, 62 = re, etc. */
/* MIDI notes from 0 to 113. */
unsigned int timeUpDown[114];

const char song[] = {	64,4,64,4,65,4,67,4,		67,4,65,4,64,4,62,4,
			60,4,60,4,62,4,64,4,		64,-4,62,8,62,2,
			64,4,64,4,65,4,67,4,		67,4,65,4,64,4,62,4,
			60,4,60,4,62,4,64,4,		62,-4,60,8,60,2,
			62,4,62,4,64,4,60,4,		62,4,64,8,65,8,64,4,60,4,
			62,4,64,8,65,8,64,4,62,4,	60,4,62,4,55,2,
			64,4,64,4,65,4,67,4,		67,4,65,4,64,4,62,4,
			60,4,60,4,62,4,64,4,		62,-4,60,8,60,2};

int period, i;
unsigned int timeUp, beat;
byte statePin = LOW;
const byte BPM = 120;
const float TEMPO_SECONDS = 60.0 / BPM; 
const unsigned int MAXCOUNT = sizeof(song) / 2;

/* /Speaker */

void setup() {
  pinMode(ledRPin, OUTPUT);
  pinMode(ledGPin, OUTPUT);
  pinMode(ledBPin, OUTPUT);
  
  pinMode(speakerPin, OUTPUT);
  
  setupSpeaker();
}

void loop() {
  debug();
}

void debug() {
  debugBlinkLeds();
  debugPlayBeethoven();
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
  delay(debugDelay);
}

void blinkAnalogLed(int pin) {
  analogLedOn(ledBPin);
  delay(debugDelay);
  analogLedOff(ledBPin);
  delay(debugDelay);
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

void setupSpeaker() {
  for (i = 0; i < 114; i++)
    timeUpDown[i] = 1000000 / (pow(2, (i - 69) / 12.0) * 880);
}

void debugPlayBeethoven() {
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
  delay(1000);
}
