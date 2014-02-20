/*
 * Joystickboard
 */
import ddf.minim.*;
import processing.serial.*;

int lf = 10;    // Linefeed in ASCII
String str = null;
Serial port;  // Create object from Serial class

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

void shift() {
  if (left_selected == -1) {
    if (mode == 1) {
      mode = 0;
    } else {
      mode = 1;
    }
  } else {
    txt += left[mode][left_selected];
  }
}

void toggle() {
  if (right_selected == -1) {
    if (mode == 2) {
      mode = 0;
    } else {
      mode = 2;
    }
  } else {
    txt += right[mode][right_selected];
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
  char characters[] = (joystick == 0 ? right[mode] : left[mode]);
  int index = Math.round(angle / 360 * characters.length);
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
  // frameRate(20);
  drawCirclesAndText();
  selectAngle(0, 50);
  if (time == 300) {
    shift();
  }
  if (time == 600) {
    toggle();
  }
  if (time == 1000) {
    toggle();
  }
  time++;
  
  if (time % 30 == 0) {
    int note = int(random(NOTES));
    guitar[note].rewind();
    guitar[note].play();
  }
}
