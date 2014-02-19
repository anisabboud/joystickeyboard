/*
 * Joystickboard
 */
import processing.serial.*;

int lf = 10;    // Linefeed in ASCII
String str = null;
Serial port;  // Create object from Serial class

int R = 150;  // Radius of the circles.
int P = 100;  // Padding around the circle.
int H = P + R;  // Half a circle + padding.
int C = 2 * H;  // Circle area.

int SELECTORS = 8;

// 1. Default.
char LEFT1[] = {'t', 'r', 'e', 'w', 'a', 'c', 's', 'd'};
char RIGHT1[] = {'p', 'o', 'i', 'u', 'h', 'n', 'm', 'l'};
// 2. Pressing right thumb ("switch").
char LEFT2[] = {'g', 'f', ' ', 'q', 'z', 'x', 'v', 'b'};  // Can add character between F and Q.
char RIGHT2[] = {'k', '\'', 'p', 'y', 'j', ',', '.', '/'};

// 3. 1+2 with left thumb ("shift").
char SHIFT_LEFT1[] = {'T', 'R', 'E', 'W', 'A', 'C', 'S', 'D'};
char SHIFT_RIGHT1[] = {'P', 'O', 'I', 'U', 'H', 'N', 'M', 'L'};
char SHIFT_LEFT2[] = {'G', 'F', ' ', 'Q', 'Z', 'X', 'V', 'B'};  // Can add character between F and Q.
char SHIFT_RIGHT2[] = {'K', '"', 'P', 'Y', 'J', '<', '>', '?'};

// 4. Clicking the two thumbs switches to punctuation mode.
char NUMBERS1[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
char NUMBERS2[] = {')', '!', '@', '#', '$', '%', '^', '&', '*', '('};
// After shift.
char PUNCTUATION1[] = {']', '+', '=', '-', '[', ':', ';', '_'};
char PUNCTUATION2[] = {'}', '~', '`', '{', '\\', '|'};

char LEFT_PEDAL = '\b';  // Backspace.
char RIGHT_PEDAL = ' ';  // Space.
char TWO_PEDALS = '\n';  // Enter.

char SHIFT_LEFT_PEDAL = 'x';  // TODO(delete word).
char SHIFT_RIGHT_PEDAL = '\t';  // Tab.
char SHIFT_TWO_PEDALS = 'x';  // TODO(come up with something useful).

//    shift  toggle  punc
// 1. false  false   false
// 2. false  true    false
// 3. true   false   false
// 4. true   true    false
// 5. shift==toggle  true
// 6. shift!=toggle  true
boolean shift = false;  // left button clicked - "upper" case. 
boolean toggle = false;  // right button clicked - switch characters.
boolean punc = false;  // both buttons clicked - punctuation mode.

char left[] = LEFT1, right[] = RIGHT1;  // The current left and right circle characters.

void drawCircles() {
  if (!punc) {  // case 1-4
    if (!shift) {  // case 1-2
      if (!toggle) {  // case 1
        left = LEFT1;
        right = RIGHT1;
      } else {  // case 2
        left = LEFT2;
        right = RIGHT2;
      }
    } else {  // case 3-4
      if (!toggle) {  // case 3
        left = SHIFT_LEFT1;
        right = SHIFT_RIGHT1; 
      } else {  // case 4
        left = SHIFT_LEFT2;
        right = SHIFT_RIGHT2;
      }
    }
  } else {  // case 5-6
    if (shift == toggle) {  // case 5
      left = NUMBERS1;
      right = PUNCTUATION1;
    } else {  // case 6
      left = NUMBERS2;
      right = PUNCTUATION2;
    }
  }
  
  background(240);  // bright gray
  drawCircle(H, H, R, left);
  drawCircle(C + H, H, R, right);
}

void shift() {
  shift = !shift;
  drawCircles();
}
void toggle() {
  toggle = !toggle;
  drawCircles();
}
void punc() {
  punc = !punc;
  shift = false;
  toggle = false;
  drawCircles();
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

void draw() {
  drawCircles();
  shift();
  drawCircles();
  
//  background(240);  // bright gray
//
//  drawCircle(H, H, R, LEFT1);
//  drawCircle(C + H, H, R, RIGHT1);
//  drawCircle(H, C + H, R, LEFT2);
//  drawCircle(C + H, C + H, R, RIGHT2);
//
//  drawCircle(H, 2 * C + H, R, SHIFT_LEFT1);
//  drawCircle(C + H, 2 * C + H, R, SHIFT_RIGHT1);
//  drawCircle(H, 3 * C + H, R, SHIFT_LEFT2);
//  drawCircle(C + H, 3 * C + H, R, SHIFT_RIGHT2);
//
//  drawCircle(H, 4 * C + H, R, NUMBERS1);
//  drawCircle(C + H, 4 * C + H, R, PUNCTUATION1);
//  drawCircle(H, 5 * C + H, R, NUMBERS2);
//  drawCircle(C + H, 5 * C + H, R, PUNCTUATION2);
}
