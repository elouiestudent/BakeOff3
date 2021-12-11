import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Collections;
import java.util.Comparator;
import java.util.Arrays;
import java.util.Random;


int hoverEnlarge = 4;

public class Button {
  float xPos;
  float yPos;
  int width;
  int height;
  int hoverWidth;
  int hoverHeight;
  String text;
  int textSize;
  int textColor;
  int buttonColor;
  color hoverColor;
  int spacer = 5;
  boolean hover = false;
  
  
  public Button(float xPos, float yPos, int width, int height, int hoverWidth, int hoverHeight, String text, int textSize, int textColor, 
    int buttonColor, color hoverColor) {
    this.xPos = xPos;
    this.yPos = yPos;
    this.width = width;
    this.height = height;
    this.hoverWidth = hoverWidth;
    this.hoverHeight = hoverHeight;
    this.text = text;
    this.textSize = textSize;
    this.textColor = textColor;
    this.buttonColor = buttonColor;
    this.hoverColor = hoverColor;
  }
}

public class Key {
 String letter;
 int level;
 Button button;
 
 public Key(String letter, int level) {
  this.letter = letter;
  this.level = level;
 }
}

public class Keyboard {
  List<Key> keyboard = List.of(
                      new Key("q", 1), new Key("w", 1), new Key("e", 1), new Key("r", 1), new Key("t", 1), new Key("y", 1), new Key("u", 1), new Key("i", 1), new Key("o", 1), new Key("p", 1),
                      new Key("a", 2), new Key("s", 2), new Key("d", 2), new Key("f", 2), new Key("g", 2), new Key("h", 2), new Key("j", 2), new Key("k", 2), new Key("l", 2), 
                      new Key("z", 3), new Key("x", 3), new Key("c", 3), new Key("v", 3), new Key("b", 3), new Key("n", 3), new Key("m", 3), 
                      new Key("_", 4), new Key("<", 4), new Key("<<", 4));
  float[] levels;
  int[] keyWidths = new int[]{15, 15, 15, 45};
  int[] keyHoverWidths = new int[]{15 + hoverEnlarge, 15 + hoverEnlarge, 15 + hoverEnlarge, 45 + hoverEnlarge};

  int yMargin = 8;
  int borderX;
  int borderY;
  int bottomX;
  int bottomY;
  
  public Keyboard(int x, int y, int botx, int boty, float inputWidth) {
    float topX = x;
    float topY = y;
    bottomX = botx;
    bottomY = boty;
    borderX = x;
    borderY = y;
    int keyHeight = 18;
    int keyHoverHeight = keyHeight + hoverEnlarge;
    int currKeyLevel = 1;
    levels = new float[]{(inputWidth - 10 * keyWidths[0]) / 11, (inputWidth - 9 * keyWidths[1]) / 10, (inputWidth - 7 * keyWidths[2]) / 8, (inputWidth - 3 * keyWidths[3]) / 4};
    topX = topX + levels[currKeyLevel - 1];
    for (Key k : keyboard) {
      if(k.level != currKeyLevel) {
        topX = x + levels[k.level - 1];
        topY = topY + keyHeight + yMargin;
        currKeyLevel = k.level;
      }
      Button b = new Button(topX, topY, keyWidths[currKeyLevel - 1], keyHeight, keyHoverWidths[currKeyLevel - 1], keyHoverHeight, k.letter, 12, 0, 200, color(255, 255, 0));
      k.button = b;
      topX = topX + keyWidths[currKeyLevel - 1] + levels[currKeyLevel - 1];
    }
  }

  String keyClicked() {
    for (Key k : keyboard) {
      Button b = k.button;
      if (b.hover)
        return k.letter;
    }
    return "";
  }

  void drawKeyboard() {
    Key c = keyboard.get(0);
    float dist = (mouseX - (c.button.xPos + c.button.width / 2)) * (mouseX - (c.button.xPos + c.button.width / 2)) + (mouseY - (c.button.yPos + c.button.height / 2)) * (mouseY - (c.button.yPos + c.button.height / 2));
    for (Key k : keyboard) {
      Button b = k.button;
      float d = (mouseX - (b.xPos + b.width / 2)) * (mouseX - (b.xPos + b.width / 2)) + (mouseY - (b.yPos + c.button.height / 2)) * (mouseY - (b.yPos + b.height / 2));
      if (d < dist) {
        dist = d;
        c = k;
      }
    }
    for (Key k : keyboard) {
      Button b = k.button;
      b.hover = false;
      
      fill(b.buttonColor);      
      rect(b.xPos, b.yPos, b.width, b.height);
      textSize(b.textSize);
      fill(b.textColor);
      text(b.text, b.xPos+(b.width/3), b.yPos+(2*b.height/3));
      
      if (c == k && mouseX >= borderX && mouseY >= borderY - yMargin && mouseX <= bottomX && mouseY <= bottomY) {
        fill(b.buttonColor);
        rect(b.xPos-hoverEnlarge/2, b.yPos - hoverEnlarge/2, b.hoverWidth, b.hoverHeight);
        textSize(b.textSize);
        fill(b.textColor);
        text(b.text, b.xPos+(b.width/3), b.yPos+(2*b.height/3));
        b.hover = true;
        fill(b.hoverColor, 100);
        rect(b.xPos - levels[c.level - 1], b.yPos - yMargin, b.width + 2 * levels[c.level - 1], b.height + 2 * yMargin);
      }
      else 
      {
        fill(b.buttonColor);      
        rect(b.xPos, b.yPos, b.width, b.height);
        textSize(b.textSize);
        fill(b.textColor);
        text(b.text, b.xPos+(b.width/3), b.yPos+(2*b.height/3));
      }
    }
  }
}
