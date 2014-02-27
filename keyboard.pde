/*
 * Joystickboard
 */
import ddf.minim.*;
import processing.serial.*;

// Reading from serial stuff.
// ==========================

int lf = 10;    // Linefeed in ASCII
String str = null;
Serial port;  // Create object from Serial class

// a[0] = right x
// a[1] = right y
// a[2] = left x
// a[3] = left y
// d[0] = right select
// d[1] = left select
// d[2] = right pedal (space)
// d[3] = left pedal (backspace)
int a[], d[];
// analog is between 0 and 1023; scaledA is between -1 and 1.
float scaledA[];
boolean toggle_pressed, shift_pressed, space_pressed, backspace_pressed;
float leftTheta, rightTheta, leftR, rightR;

// Drawing stuff.
// ==============
int R = 200;  // Radius of the circles.
int P = 100;  // Padding around the circle.
int H = P + R;  // Half a circle + padding.
int C = 2 * H;  // Circle area.
int T = 100;  // Text area space.

AudioPlayer guitar[];
AudioPlayer flute[];
Minim minim;//audio context
int NOTES = 16;

// 1. Default.
char right[][] = {{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p'},
                  {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'},
                  {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '=', '`', '~', '\\', '|'}};
char left[][] = {{'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', ',', '.', '\'', '"', '/', '-'},
                 {'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', ',', '.', ';', ':', '?', '_'},
                 {'!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '<', '>'}};

char LEFT_PEDAL = '\b';  // Backspace.
char RIGHT_PEDAL = ' ';  // Space.
char TWO_PEDALS = '\n';  // Enter.

char SHIFT_LEFT_PEDAL = 'x';  // TODO(delete word).
char SHIFT_RIGHT_PEDAL = '\t';  // Tab.
char SHIFT_TWO_PEDALS = 'x';  // TODO(come up with something useful).

int mode = 0;  // 0 = letters, 1 = uppercase, 2 = punctuation.
int right_selected = -1;  // The index of the character selected by the right thumb.
int left_selected = -1;  // The index of the character selected by the left thumb.

String txt = "";

void toggle() {
  if (mode == 2) {
    mode = 0;
  } else {
    mode = 2;
  }
}

void shift() {
  if (mode == 1) {
    mode = 0;
  } else {
    mode = 1;
  }
}

void space() {
  txt += " ";
}

void backspace() {
  if (txt.length() > 0) {
    txt = txt.substring(0, txt.length() - 1);
  }
}

void drawCirclesAndText() {
  // Circles.
  background(240);  // bright gray
  drawCircle(C + H, H, R, right[mode], 0);
  drawCircle(H, H, R, left[mode], 1);
  
  // Text area.
  fill(255);
  stroke(255);
  rect(0, C, 2 * C, H);

  // Text.
  fill(0);
  textSize(40);
  text(txt, T/2, C + T/2 + 20);
}

// 0 is right, 1 is left.
void selectAngle(int joystick, float angle) {
  if (angle < 0) {
    angle += 2 * PI;
  }
  char characters[] = (joystick == 0 ? right[mode] : left[mode]);
  int index = Math.round(angle / (2 * PI) * characters.length) % characters.length;
  if (joystick == 0) {
    right_selected = index;
  } else {
    left_selected = index;
  }
}
void deselect(int joystick) {
  if (joystick == 0) {
    right_selected = -1;
  } else {
    left_selected = -1;
  }
}

void setup() 
{
  size(2 * C, C + T);
  
  smooth();

  minim = new Minim(this);
  guitar = new AudioPlayer[NOTES];
  flute = new AudioPlayer[NOTES];
  for (int i = 0; i < NOTES; i++) {
    guitar[i] = minim.loadFile("guitar/" + i + ".mp3");
    flute[i] = minim.loadFile("flute/" + i + ".mp3");
  }
  
  port = new Serial(this, Serial.list()[0], 9600);
  port.clear();
  // Throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  str = port.readStringUntil(lf);
  str = null;
  
  a = new int[4];
  scaledA = new float[4];
  d = new int[4];
}

// circleIndex = 0 for right, and 1 for left.
void drawCircle(int x, int y, int r, char[] characters, int circleIndex) {
  stroke(200);
  fill(255);
  ellipse(x, y, 2 * r, 2 * r);

  for (int i = 0; i < characters.length; i++) {
    float angle = radians(i * 360 / characters.length);

    fill(0);
    textSize(20);
    if ((right_selected == i && circleIndex == 0) || (left_selected == i && circleIndex == 1)) {
      fill(222, 0, 0);
      textSize(40);
    }
    text(characters[i], 
         x + r * cos(angle) - 5,
         y - r * sin(angle) + 5);
  }
}

int time = 0;
void draw() {
  readInput();
  convertToPolar();
  
  if (d[0] == 1 && toggle_pressed) {  // Was pressed, now released.
    toggle();
  }
  toggle_pressed = (d[0] == 0);

  if (d[1] == 1 && shift_pressed) {  // Was pressed, now released.
    shift();
  }
  shift_pressed = (d[1] == 0);
  
  if (d[2] == 1 && !space_pressed) {  // Was released, now pressed.
    space();
  }
  space_pressed = (d[2] == 1);
  
  if (d[3] == 1 && !backspace_pressed) {  // Was released, now pressed.
    backspace();
  }
  backspace_pressed = (d[3] == 1);
  
  
  // frameRate(20);
  drawCirclesAndText();
  if (rightR > 0.5) {
    selectAngle(0, rightTheta);
  } else {
    if (right_selected != -1) {
      txt += right[mode][right_selected];
    }
    right_selected = -1;
  }
  if (leftR > 0.5) {
    selectAngle(1, leftTheta);
  } else {
    if (left_selected != -1) {
      txt += left[mode][left_selected];
    }
    left_selected = -1;
  }
  time++;
  
  if (time % 30 == 0) {
    int note = int(random(NOTES));
    guitar[note].rewind();
    guitar[note].play();
  }
}

void readInput() {
  while (port.available () > 0) {
    str = port.readStringUntil(lf);
    
    if (str != null) {
      //print(str);  // Serial monitor functionality.
    }
    
    if (str == null || str.indexOf("OSCILLOSCOPE:") == -1) {
      continue;
    }
    // A0I=X, A1I=Y, .... A5I=Z (for analog in), 
    // A3O=X, A6O=Y, .... A13O=Z (for analog out), 
    // D0I=X, D1I=Y,....D13I=Z (for digital in), 
    // D0O=X, D1O=Y,....D13O=Z (for digital out), millis
    String[] tokens = splitTokens(trim(str), ",:");
    for (int i = 1; i < tokens.length - 1; i++) {
      String[] pinAndVal = split(tokens[i], '=');                           // A0I=Z
      String pin = pinAndVal[0];                                            // A0I
      char analogOrDigital = pin.charAt(0);                                 // A
      int pinIndex = Integer.parseInt(pin.substring(1, pin.length() - 1));  // 0
      char inputOrOutput = pin.charAt(pin.length() - 1);                    // I
      int val = Integer.parseInt(pinAndVal[1]);                             // Z
      if (analogOrDigital == 'A') {
        a[pinIndex] = val;
        scaledA[pinIndex] = (val - 512) / 512f;
      } else {
        d[pinIndex] = val;
      }
    }
  }
}

void convertToPolar() {
  float rightX = scaledA[0], rightY = -scaledA[1];
  rightTheta = atan2(rightY, rightX);
  rightR = sqrt(rightX * rightX + rightY * rightY);
  
  float leftX = scaledA[2], leftY = -scaledA[3];
  leftTheta = atan2(leftY, leftX);
  leftR = sqrt(leftX * leftX + leftY * leftY);
}
