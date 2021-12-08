import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Collections;
import java.util.Comparator;
import java.util.Arrays;
import java.util.Random;

public class Button {
  int xPos;
  int yPos;
  int width;
  int height;
  String text;
  int textSize;
  int textColor;
  int buttonColor;
  int hoverColor;
  int spacer = 5;
  boolean hover = false;
  
  
  public Button(int xPos, int yPos, int width, int height, String text, int textSize, int textColor, 
    int buttonColor, int hoverColor) {
    this.xPos = xPos;
    this.yPos = yPos;
    this.width = width;
    this.height = height;
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
                      new Key("q", 1), new Key("w", 1), new Key("e", 1), new Key("r", 1), new Key("t", 1), new Key("y", 1), new Key("u", 1), new Key("o", 1), new Key("p", 1), new Key("i", 1),
                      new Key("a", 2), new Key("s", 2), new Key("d", 2), new Key("f", 2), new Key("g", 2), new Key("h", 2), new Key("j", 2), new Key("k", 2), new Key("l", 2), 
                      new Key("z", 3), new Key("x", 3), new Key("c", 3), new Key("v", 3), new Key("b", 3), new Key("n", 3), new Key("m", 3), new Key("_", 3), new Key("<", 3));
  int keyWidth = 15;
  int topLevelIncrement;
  int otherLevelIncrement;
  int yMargin = 10;
  int borderX;
  int borderY;
  
  public Keyboard(int x, int y, float inputWidth) {
    int topX = x;
    int topY = y;
    borderX = topX;
    borderY = topY;
    int keyHeight = 18;
    int currKeyLevel = 1;
    topLevelIncrement = int(inputWidth / 10) - keyWidth;
    otherLevelIncrement = int(inputWidth / 9) - keyWidth;
    topX = topX + topLevelIncrement;
    for (Key k : keyboard) {
      if(k.level != currKeyLevel) {
        topX = x + otherLevelIncrement;
        topY = topY + keyHeight + yMargin;
        currKeyLevel = k.level;
      }
      Button b = new Button(topX, topY, keyWidth, keyHeight, k.letter, 12, 0, 200, 400);
      k.button = b;
      if (currKeyLevel == 1)
        topX = topX + keyWidth + topLevelIncrement;
      else
        topX = topX + keyWidth + otherLevelIncrement;
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
      //if(mouseX >= b.xPos && mouseX <= (b.xPos + b.width) &&
      //   mouseY >= b.yPos && mouseY <= (b.yPos + b.height)) {
      //  fill(b.hoverColor);
      //  rect(b.xPos, b.yPos, b.width, b.height);
      b.hover = false;
        
      fill(b.buttonColor);
      rect(b.xPos, b.yPos, b.width, b.height);
      textSize(b.textSize);
        
      fill(b.textColor);
      text(b.text, b.xPos+(b.width/3), b.yPos+(2*b.height/3));
      
      //System.out.println(topX);
      //System.out.println(topY);
      //System.out.println(mouseX);
      //System.out.println(mouseY);
      if (c == k && mouseX > borderX && mouseY > borderY - yMargin) {
        b.hover = true;
        fill(0, 100);
        if (k.level == 1)
          rect(b.xPos - topLevelIncrement, b.yPos - yMargin, b.width + 2 * topLevelIncrement, b.height + 2 * yMargin);
        else
          rect(b.xPos - otherLevelIncrement, b.yPos - yMargin, b.width + 2 * otherLevelIncrement, b.height + 2 * yMargin);
      }
    }
  }
}
