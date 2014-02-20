/*
 * Joystickboard
 */
import processing.serial.*;

int lf = 10;    // Linefeed in ASCII
String str = null;
Serial port;  // Create object from Serial class

int R = 200;  // Radius of the circles.
int P = 100;  // Padding around the circle.
int H = P + R;  // Half a circle + padding.
int C = 2 * H;  // Circle area.

// http://mdickens.me/typing/letter_frequency.htm 

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

void shift() {
  if (mode == 1) {
    mode = 0;
  } else {
    mode = 1;
  }
}

void toggle() {
  if (mode == 2) {
    mode = 0;
  } else {
    mode = 2;
  }
}

void drawCircles() {
  background(240);  // bright gray
  drawCircle(H, H, R, left[mode]);
  drawCircle(C + H, H, R, right[mode]);
}


void setup() 
{
  size(2 * C, C);
  
  smooth();
}

void drawCircle(int x, int y, int r, char[] characters) {
  stroke(200);
  fill(255);
  ellipse(x, y, 2 * r, 2 * r);

  for (int i = 0; i < characters.length; i++) {
    float angle = radians(i * 360 / characters.length);
    
    fill(0);
    textSize(20);
    text(characters[i], 
         x + r * cos(angle) - 5,
         y - r * sin(angle) + 5);
  }
}

int time = 0;
void draw() {
  drawCircles();
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
  
//  background(240);  // bright gray
//
//  drawCircle(H, H, R, left[0]);
//  drawCircle(C + H, H, R, right[0]);
//  drawCircle(H, C + H, R, left[1]);
//  drawCircle(C + H, C + H, R, right[1]);
//  drawCircle(H, 2 * C + H, R, left[2]);
//  drawCircle(C + H, 2 * C + H, R, right[2]);
}
