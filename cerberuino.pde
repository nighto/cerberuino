/*
   Cerberuino
   (C) 2011 by Arlindo "Nighto" Pereira, João Carlos "JC" Pena
   Licensed on GPLv3+
*/

const int serialRxPin = 0; // RX
const int serialTxPin = 1; // TX
const int switchPin = 2;
const int speakerPin = 3;  // PWM
const int relayPin = 4;
const int ledBPin = 5;     // PWM
const int ledGPin = 6;     // PWM
const int ledRPin = 7;

const int analogValueOn = 255;
const int analogValueOff = 0;
const int debugDelay = 1000;

void setup() {
  pinMode(ledRPin, OUTPUT);
  pinMode(ledGPin, OUTPUT);
  pinMode(ledBPin, OUTPUT);
}

void loop() {
  debugBlinkLeds();
}

void debug() {
  debugBlinkLeds();
}

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
  analogWrite(pin, analogValueOn);   // set the LED on
}

void analogLedOff(int pin) {
  analogWrite(pin, analogValueOff);   // set the LED on
}

