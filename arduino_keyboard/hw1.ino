int ledPin = 9;    // LED connected to digital pin 9

void setup()  {
  // nothing happens in setup
  Serial.begin(9600);
  analogWrite(ledPin, 255);

  for (int i = 0; i < 4; i++) {
    // make the SEL line an input
    pinMode(i, INPUT);
    // turn on the pull-up resistor for the SEL line (see http://arduino.cc/en/Tutorial/DigitalPins)
    digitalWrite(i, HIGH);
  }
}

void printPins(char analogOrDigital, char inputOrOutput, int numberOfPins) { 
  for (int i = 0; i < 6; i += 4) {
    Serial.print(analogOrDigital);
    Serial.print(i);
    Serial.print(inputOrOutput);
    Serial.print('=');
    int val = (analogOrDigital == 'A') ? ((inputOrOutput == 'I') ? analogRead(i) : 255 - analogRead(i) / 4) 
                                       : digitalRead(i);
    Serial.print(val); // ???
    Serial.print(',');
  }
}

void printPinsJoystick() {
  for (int i = 0; i < 4; i++) {
    Serial.print('A');
    Serial.print(i);
    Serial.print('I');
    Serial.print('=');
    Serial.print(analogRead(i));
    Serial.print(',');
  }
  for (int i = 0; i < 4; i++) {
    Serial.print('D');
    Serial.print(i);
    Serial.print('I');
    Serial.print('=');
    Serial.print(digitalRead(i));
    Serial.print(',');
  }
}

void loop()  {
  //read in from Analog0 (which is connected to the potentiometer)
  int sensorValue = analogRead(0);
 
  //remember that our analogWrite has a min value of 0 and a max value of 255,
  //so we should map our input range to our output range
  int analogOut = map(sensorValue, 0, 1023, 0, 255);
  //analogWrite(ledPin, analogOut);
  analogWrite(ledPin, 255 - analogOut);  
 
  //print out the data!
  //String printOut = "sensorValue=" + String(sensorValue) + ", analogOut=" + String(analogOut);
  //Serial.println(printOut);

  //Serial.println(sensorValue);

  // A0I=X, A1I=Y, .... A5I=Z (for analog in), 
  // D0I=X, D1I=Y,....D13I=Z (for digital in), 
  // D0O=X, D1O=Y,....D13O=Z (for digital out), millis
  Serial.print("OSCILLOSCOPE:");
//  printPins('A', 'I', 6);
//  printPins('A', 'O', 14);
//  printPins('D', 'I', 14);
//  printPins('D', 'O', 14);
  printPinsJoystick();
  Serial.println(millis());
}
