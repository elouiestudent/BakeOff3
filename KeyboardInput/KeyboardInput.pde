import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Collections;
import java.util.Comparator;
import java.util.Arrays;
import java.util.Random;


public class DictionaryVal {
  String word;
  int numOccurances;
  
  public DictionaryVal(String w, int n) {
     this.word = w;
     this.numOccurances = n;
  }
}

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 200; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
int nextButtonHeight = 20;
int nextButtonWidth = 50;
PImage watch;

int rowHeight = 20;
Map<String, String> dictionary = new HashMap<>();
Map<String, String> misspelledDictionary = new HashMap<>();
Trie trie;
Trie misspelledTrie;
List<String> searchedWords = new ArrayList<String>();
List<String> forms = new ArrayList<String>();
ArrayList<Button> wordButtons = new ArrayList<Button>();
Keyboard keyboard;

void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
  
  String[] lines = loadStrings("count_big.txt");
  List<String> words = new ArrayList<String>();
  for (int i = 0 ; i < lines.length; i++) {
    String num = lines[i].replaceAll("[^0-9]", "");
    String word = lines[i].replaceAll("[^a-z]", "");
    dictionary.put(word, num);
    words.add(word);
  }
  
  String[] misspelledLines = loadStrings("ngrams/spell-errors.txt");
  List<String> mWords = new ArrayList<String>();
  for (int i = 0 ; i < misspelledLines.length; i++) {
    String num = misspelledLines[i].replaceAll("((\\b\\w+\\b)(?!:))", "").replaceAll("[^a-z]", "");
    String wordsWCommas = misspelledLines[i].replaceAll("((\\b\\w+\\b)(?=:)):", "");
    String[] wordsWOCommas = wordsWCommas.split(",");
    for (String w : wordsWOCommas) {
      w = w.replaceAll("[^a-zA-Z]", "");
      misspelledDictionary.put(w, num); 
      mWords.add(w);
    }
  }
  
  trie = new Trie(words);
  misspelledTrie = new Trie(mWords);
  keyboard = new Keyboard(round(width/2-sizeOfInputArea/2), round(height/2+sizeOfInputArea/2 - 102), round(width/2+sizeOfInputArea/2), round(height/2+sizeOfInputArea/2), sizeOfInputArea);
}

List<String> searchDictionary(String text) {
  List<String> words = trie.suggest(text);
  List<DictionaryVal> wordsAndNums = new ArrayList<DictionaryVal>();
  for (String word : words) {
    String num = dictionary.get(word); 
    if(num != "") {
      wordsAndNums.add(new DictionaryVal(word, parseInt(num)));
    }
  }
  Collections.sort(wordsAndNums, new Comparator<DictionaryVal>() {
    @Override
    public int compare(DictionaryVal lhs, DictionaryVal rhs) {
        return lhs.numOccurances > rhs.numOccurances ? -1 : (lhs.numOccurances < rhs.numOccurances) ? 1 : 0;
    }
  });
  
  List<String> misspelledWords = misspelledTrie.suggest(text);
  words = new ArrayList<String>();
  if(misspelledWords.size() <= 2 || wordsAndNums.size() == 0) {
    for (String w : misspelledWords) {
      words.add(misspelledDictionary.get(w));   
    } 
  }
  for (DictionaryVal val : wordsAndNums) {
    words.add(val.word);
  }
  if(words.size() >= 5) {
    return words.subList(0, 5);
  } else {
    return words;
  }
}

boolean isSingular(String word) // not used
{
  word = word.toLowerCase();
  if (word.length() <= 0) return false;
  if (word.charAt(word.length()-1) != 's') return true;
  if (word.length() >= 2 && word.charAt(word.length()-2) == 's')
    return true;  // word ends in -ss
  return false;  // word is not irregular, and ends in -s but not -ss
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"

  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " , 70, 140); //draw what the user has entered thus far 
    text(currentTyped +"|", 120, 140); //draw what the user has entered thus far 
    
    fill(255, 0, 0);
    rect(round(width/2)+sizeOfInputArea/2+50, round(height/2-sizeOfInputArea/2), 200, 200); //draw next button
    fill(255);
    text("NEXT > ", round(width/2)+sizeOfInputArea/2+50 + 5, round(height/2-sizeOfInputArea/2+15)); //draw next label
    
    String[] words = currentTyped.split(" ");
    if(words.length > 0) {
      searchedWords = searchDictionary(words[words.length - 1]);
      // forms = getVariations(words[words.length - 1]);
    } else {
      searchedWords = searchDictionary("");
    }
    drawSuggested();
    drawTimer();
    keyboard.drawKeyboard();
  }
}


ArrayList<Button> wordsToButtons(int x, int y) {
  int topX = x;
  int topY = y;
  int keyHeight = 18;
  ArrayList<Button> bs = new ArrayList<Button>();
  for (int i = searchedWords.size() - 1; i > -1; i--) {
    String s = searchedWords.get(i);
    int keyWidth = s.length() * 12;
    Button b = new Button(topX, topY, keyWidth, keyHeight, keyWidth, keyHeight, s, 12, 0, 200, color(255, 255, 0));
    topY = topY + keyHeight;
    bs.add(b);
  }
  //for (String s : forms) {
  //  int keyWidth = s.length() * 12;
  //  Button b = new Button(topX + 150, topY, keyWidth, keyHeight, s, 12, 0, 200, 400);
  //  topY = topY - keyHeight;
  //  bs.add(b);
  //}
  return bs;
}

ArrayList<Button> wordsToButtonsBottomUp(int x, int y) {
  int topX = x;
  int topY = y;
  int keyHeight = 18;
  ArrayList<Button> bs = new ArrayList<Button>();
  for (int i = searchedWords.size() - 1; i > -1; i--) {
    String s = searchedWords.get(i);
    int keyWidth = s.length() * 12;
    Button b = new Button(topX, topY, keyWidth, keyHeight,keyWidth, keyHeight, s, 12, 0, 200, 400);
    topY = topY + keyHeight;
    bs.add(b);
  }
  //for (String s : forms) {
  //  int keyWidth = s.length() * 12;
  //  Button b = new Button(topX + 150, topY, keyWidth, keyHeight, s, 12, 0, 200, 400);
  //  topY = topY - keyHeight;
  //  bs.add(b);
  //}
  return bs;
}

void drawSuggested() {
  wordButtons = wordsToButtons(round(width/2-sizeOfInputArea/2), round(height/2-sizeOfInputArea/2));
  for (Button b : wordButtons) {
    if(mouseX >= b.xPos && mouseX <= (b.xPos + b.width) &&
         mouseY >= b.yPos && mouseY <= (b.yPos + b.height)) {
        fill(b.hoverColor);
        rect(b.xPos, b.yPos, b.width, b.height);
      } else {
        fill(b.buttonColor);
        rect(b.xPos, b.yPos, b.width, b.height);
      }
      textSize(b.textSize);
      // textAlign(CENTER);
        
      fill(b.textColor);
      text(b.text, b.xPos, b.yPos+(b.height/2 + 1));
  }
}


void drawTimer()
{
  fill(255);
  int timeSpent = int((millis() - startTime)/1000);
  int DecimalPoint = int((millis() - startTime) % 1000 / 100);
  text("Time: " + timeSpent + "." + DecimalPoint + " second", round(width/2), round(height/2-sizeOfInputArea/2 + rowHeight));
}
//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

String autocompleteClicked() {
  for (Button b : wordButtons) {
    if(didMouseClick(b.xPos, b.yPos, b.width, b. height)) {
      return b.text;
    }
  }
  return "";
}

//my terrible implementation you can entirely replace
void mousePressed()
{
  String letter = keyboard.keyClicked();
  if(letter == "") {
    String word = autocompleteClicked();
    if(word != "") {
      String[] words = currentTyped.split(" ");
      if(words.length > 0) {
        words[words.length - 1] = word;
        currentTyped = String.join(" ", words) + " ";
      }
    }
  } else if (letter=="_") { //if underscore, consider that a space bar
    currentTyped+=" ";
  } else if (letter=="<" && currentTyped.length() > 0) { //if `, treat that as a delete command
    currentTyped = currentTyped.substring(0, currentTyped.length()-1);
  } else if (letter=="<<" && currentTyped.length() > 0) {
    int index = 0;
    boolean c = false;
    for (int i = currentTyped.length() - 1; i > -1; i--) {
      if (currentTyped.charAt(i) != ' ') {
        c = true;
      } else if (currentTyped.charAt(i) == ' ' && c) {
        index = i;
        break;
      }
    }
    currentTyped = currentTyped.substring(0, index);
  } else if (letter != "<" && letter != "<<") { //if not any of the above cases, add the current letter to the typed string
    currentTyped+=letter;
  }
  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(round(width/2)+sizeOfInputArea/2+50, round(height/2-sizeOfInputArea/2), 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
  return;
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}



//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
