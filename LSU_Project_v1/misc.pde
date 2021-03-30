//  returns true if the input line (1st 2 PVectors) intersects with the line segment (2nd 2 PVectors)
boolean lineLineSegmentIntersection(PVector p1a, PVector p1b, PVector p2a, PVector p2b) {

  //  get point of intersection
  PVector inter = lineIntersection(p1a, p1b, p2a, p2b);

  //  null (parallel) check
  if (inter == null)
    return false;

  /*
  //  check if segment y is different
   if (p1a.x != p1b.x) {
   //  return if y value is within segment bounds
   return (min(p1a.y, p1b.y) <= inter.y  &&  inter.y <= max(p1a.y, p1b.y));
   }
   //  else, use x
   return (min(p1a.x, p1b.x) <= inter.x  &&  inter.x <= max(p1a.x, p1b.x));
   */

  return ((min(p1a.y, p1b.y) <= inter.y  &&  inter.y <= max(p1a.y, p1b.y)) && (min(p1a.x, p1b.x) <= inter.x  &&  inter.x <= max(p1a.x, p1b.x)));
}


//  returns the intersection point of 2 lines (or null for parallel lines)
PVector lineIntersection(PVector p1a, PVector p1b, PVector p2a, PVector p2b) {

  //  check no vertical lines
  if (p1a.x != p1b.x && p2a.x != p2b.x) {
    //  get slopes
    float m1 = (p1b.y - p1a.y)/(p1b.x - p1a.x);
    float m2 = (p2b.y - p2a.y)/(p2b.x - p2a.x);
    //  parallel check
    if (m1 == m2)
      return null;
    //  find intercepts (using point a)
    float b1 = p1a.y - p1a.x*m1;
    float b2 = p2a.y - p2a.x*m2;

    /*
  y = mx + b
     m1*x + b1 = m2*x + b2
     m1*x - m2*x = b2 - b1
     (m1 - m2)*x = b2 - b1
     x = (b2 - b1) / (m1 - m2)
     //  and then find y with line with x value
     */

    float x = (b2 - b1) / (m1 - m2);
    float y = m1*x + b1;

    return new PVector(x, y);
  }

  //  if so, check no horizontal lines
  else if (p1a.y != p1b.y && p2a.y != p2b.y) {
    //  get slopes
    float n1 = (p1b.x - p1a.x)/(p1b.y - p1a.y);
    float n2 = (p2b.x - p2a.x)/(p2b.y - p2a.y);
    //  parallel check
    if (n1 == n2)
      return null;
    //  find intercepts (using point a)
    float a1 = p1a.x - p1a.y*n1;
    float a2 = p2a.x - p2a.y*n2;

    /*
    x = ny + a
     n1*y + a1 = n2*y + a2
     n1*y - n2*y = a2 - a1
     (n1 - n2)*y = a2 - a1
     y = (a2 - a1)/(n1 - n2)
     //  and then find x with line with x value
     */

    float x = (a2 - a1) / (n1 - n2);
    float y = n1*x + a1;

    return new PVector(x, y);
  }

  //  else, there is a vertical line and a horizontal line
  else {
    //  find which is which
    //  1 is vertical and 2 is horizontal
    if (p1a.x == p1b.x && p2a.y == p2b.y)
      return new PVector(p1a.x, p2a.y);
    //  2 is vertical and 1 is horizontal
    else
      return new PVector(p2a.x, p1a.y);
  }
}



boolean mouseIn(float x, float y, float w, float h) {
  if (mouse.x >= x && mouse.x <= x+w && mouse.y >= y && mouse.y <= y+h)
    return true;
  return false;
}

boolean mouseIn(PVector pos, PVector dim) {
  return mouseIn(pos.x, pos.y, dim.x, dim.y);
}

boolean mouseWithin(float x, float y, float d) {
  return (dist(mouse.x, mouse.y, x, y) <= d);
}

boolean mouseWithin(PVector pos, float d) {
  return mouseWithin(pos.x, pos.y, d);
}














//  writes text in center of input coordinates
void centerText(String s, float x, float y) {
  PVector offset = new PVector(textWidth(s)/2, (textAscent()+textDescent())/2);
  text(s, x - offset.x, y + offset.y);
}
void centerText(String s, PVector pos) {
  centerText(s, pos.x, pos.y);
}







void setTextSize(float size) {
  setTextSize(int(size));
}
void setTextSize(int size) {
  //  println(size);
  //  println(fonts.length);
  textFont(fonts[size]); 
  textSize(sizes[size]); 
  textSize = size;
}

















//  displays input information at mouse
void displayInfo(String title, String[] lines, float x, float y) {
  displayInfo(title, lines, int(x), int(y));
}
//  displays input information at mouse
void displayInfo(String title, String[] lines, int x, int y) {
  //  get dimensions
  setTextSize(25); 
  float w = textWidth(title); 
  setTextSize(15); 
  for (int i = 0; i < lines.length; i++)
    if (textWidth(lines[i]) > w)
      w = textWidth(lines[i]); 
  w += 10; 
  float h = 35 + 20*lines.length; 

  //  adjust for screen size
  /*
        //  minimums
   while (x < 0)
   x++;
   while (y < 0)
   y++;
   //  maximums
   while (x + w > widthValue)
   x--;
   while (y + h > heightValue)
   y--;
   */
  //  check to hid cursor
  boolean hideCursor = true; 
  if (x + w > widthValue) {
    x -= w; 
    hideCursor = false;
  }
  if (y + h > heightValue) {
    y -= h; 
    hideCursor = false;
  }
  drawCursor = !hideCursor; 

  //  draw
  fill(255); 
  rect(x, y, w, h); 
  fill(0); 
  line(x, y+30, x+w, y+30); 
  setTextSize(25); 
  centerText(title, x + w/2, y + 10); 
  setTextSize(15); 
  for (int i = 0; i < lines.length; i++)
    text(lines[i], x + 5, y + 50 + 20*i); 

  //  restore cursor
  //  drawCursor = cursorSeen;
  refreshCursor = true;
}

//  displays input information at mouse
void displayInfo(String title, float x, float y) {
  displayInfo(title, int(x), int(y));
}
//  displays input information at mouse
void displayInfo(String title, int x, int y) {
  //  get dimensions
  setTextSize(25); 
  float w = textWidth(title); 
  float h = 35; 
  //  check to hid cursor
  boolean hideCursor = true; 
  if (x + w > widthValue) {
    x -= w; 
    hideCursor = false;
  }
  if (y + h > heightValue) {
    y -= h; 
    hideCursor = false;
  }
  drawCursor = !hideCursor; 

  //  draw
  fill(255); 
  rect(x, y, w, h); 
  fill(0); 
  centerText(title, x + w/2, y + 10); 

  //  restore cursor
  //  drawCursor = cursorSeen;
  refreshCursor = true;
}


























//  menu for selecting new, load, settings or, credits
class MainMenu extends State {

  boolean load = false; 

  RectButton[] buttons = new RectButton[4]; 
  String[] buttonLables = {"New Game", "Load Game", "Settings", "Credits"};

  //  PImage menuImage = loadImage("menu_image.png"); //  image should be square as it is scaled to a square

  int selected = -1; 

  MainMenu() {
    //  check for saved game
    boolean addThisLater;
    //  if (gameSaved())
    //    load = true; 

    //  create buttons
    for (int i = 0; i < buttons.length; i++)
      buttons[i] = new RectButton(buttonLables[i], 380, 225 + i * 75, null, 120, 50, 20);


    //  RectButton(String lab, int x, int y, PImage i, int l, int h, float t)


    boolean finishCreatingThisClass;
  }

  void drawState() {
    background(255); 

    //  image(menuImage, 0, 0, widthValue, heightValue); 

    buttons[0].drawButton(); 
    buttons[1].drawButton(); 
    buttons[2].drawButton(); 
    buttons[3].drawButton(); 
    if (!load) {  //  draw over load button if can't load
      fill(255, 150); 
      rect(buttons[1].pos.x, buttons[1].pos.y, buttons[1].size.x, buttons[1].size.y); 
      fill(255);
    }
    //  highlight selected
    if (selected >= 0)
      buttons[selected].drawButtonNegative();
  }

  void updateState() {
    //  mouse control
    for (int i = 0; i < buttons.length; i++) {
      if ((i == 1 && load) || i != 1)  //  check load
        if (buttons[i].checkOver()) {
          buttons[i].drawButtonNegative(); 
          selected = i; 
          if (mousePressed && !mpress) {
            mpress = true; 
            activate(selected);
          }
        }
    }
    boolean finishSelectionControls = false; 

    //  arrow control
    //  up
    if (input[4] && !menuKeysTriggers[4]) {
      menuKeysTriggers[4] = true; 
      if (selected == -1 || selected == 0)
        selected = 3; 
      else if (selected == 3 || selected == 1)
        selected--; 
      else if (selected == 2) {
        if (load)
          selected = 1; 
        else
          selected = 0;
      }
    }
    //  down
    else if (input[6] && !menuKeysTriggers[6]) {
      menuKeysTriggers[6] = true; 
      if (selected == -1 || selected == 3)
        selected = 0; 
      else if (selected == 2 || selected == 1)
        selected++; 
      else if (selected == 0) {
        if (load)
          selected = 1; 
        else
          selected = 2;
      }
    }
    //  enter
    else if (input[0] && !menuKeysTriggers[0]) {
      menuKeysTriggers[0] = true; 
      if (selected >= 0)
        activate(selected);
    }
  }

  //  activates the pressed button
  void activate(int i) {
    //  New Game
    if (i == 0) {
      //  stateStack.addState(new CreatePlayer());
    }
    //  Load Game
    else if (i == 1) {
      boolean loadGameHere;
    }
    //  Settings
    else if (i == 2) {
    }
    //  Credits
    else if (i == 3) {
    }
  }
}









//  end of the game
class End extends State {

  int fade = 255; 

  int delay = int(1.0*frameRate); 

  End() {
  }

  void updateState() {
  }

  void drawState() {
    background(0); 
    fill(255); 
    setTextSize(85); 
    centerText("GAME OVER", heightValue/2, widthValue/2-40); 

    //  fade in
    if (delay > 0)
      delay--; 
    else if (fade > 0) {
      //  println(fade);
      fade--;
    }
    fill(0, fade); 
    noStroke(); 
    rect(-1, -1, widthValue+2, heightValue+2); 
    stroke(0);
  }
}





















//  skips all spaces and comments and returns the new counter value
//  also skips "*" and "**" lines if they do not apply
int skipSpacesNotIf(int counter, String[] lines) {
  //  skip blanks and comments
  boolean skip = true; 
  while (skip) {
    //  skip blank lines
    if (lines[counter].equals(""))
      counter++; 
    //  skip if closers
    else if (lines[counter].length() > 1) {
      //  skip comments
      if (lines[counter].substring(0, 2).equals("//"))
        counter++;
      else
        skip = false;
    } else
      skip = false;
  }
  return counter;
}

//  skips all spaces and comments and if closers ("}") and returns the new counter value
int skipSpaces(int counter, String[] lines) {
  //  skip blanks and comments
  boolean skip = true; 
  println("start skipping at ");
  while (skip) {

    println("skipping", counter, lines[counter]);

    //  don't run out of bounds
    if (counter >= lines.length) {
      skip = false;
    } else {
      //  skip blank lines
      if (lines[counter].equals(""))
        counter++; 
      //  skip if closers
      else if (lines[counter].length() == 1) {
        if (lines[counter].charAt(0) == '}')
          counter++; 
        else
          skip = false;
      } else if (lines[counter].length() > 1) {
        //  skip comments
        if (lines[counter].substring(0, 2).equals("//"))
          counter++; 
        //  check if
        else if (lines[counter].substring(0, 2).equals("if")) {

          String[] parts = lines[counter].split(", "); //  part 0 is "if"
          println("counter:", counter); 
          if (ifCheck(parts[1], parts[2], boolean(parts[3])))
            counter++; 
          else {
            counter = skipIf(++counter, lines);
          }
          println("counter:", counter);
        }
        else
          skip = false;
      } else
        skip = false;
    }
  }
  println("done skipping at " + counter);
  return counter;
}

//  skips all lines until and including the "}" of an if statement and returns the new counter value
int skipIf(int counter, String[] lines) {
  int ifCounter = 1;  //  can start at 1 as it skips the first if that triggers it
  println("skipping ifs at " + counter);
  //  one the first "if" that does not apply is found, then the program will run through all lines and remove from the counter for each end ("}") found, but increment for each additional if found within
  while (ifCounter > 0) {
    if (lines[counter].equals("}"))
      ifCounter--;
    if (lines[counter].length() > 2)
      if (lines[counter].substring(0, 2).equals("if"))
        ifCounter++;
    counter++;
  }
  println("finished skipping ifs at " + counter);
  return counter;
}



//  returns true if the input string is just empty space(s), false otherwise
//  will also return true for an empty string ("")
boolean justSpaces(String s) {
  String[] parts = s.split(""); 
  for (String p : parts)
    if (!p.equals(" "))
      return false; 
  return true;
}











//  checks an if statement and returns true if it applies
boolean ifCheck(String type, String bname, boolean value) {
  println("checking if", bname, "is", value, "but it is", getBoolialeValue(bname)); 
  if (type.equals("booliale")) {
    if (getBoolialeValue(bname) == value)
      return true;
  }
  /*
  else if (type.equals("character")) {
   if (getBooliale(bname).getBoolialeValue() == value)
   return true;
   }
   */

  boolean addItemsWhenImplemented; //  or perhaps don't if there do not end up being any if item conditions

  return false;
}



















//  function that turns a string into string[] with each being <= the given max
String[] stringToLines(String s, float max) {

  StringList liness = new StringList(); 
  liness.append(s); 

  for (int i = 0; i < liness.size(); i++) {
    if (textWidth(liness.get(i)) > max) {

      int tracker = 1; 

      while (textWidth(liness.get(i).substring(0, tracker)) <= max)
        //  increase tracker until over limit
        tracker++; 

      String temp = liness.get(i).substring(0, tracker); 

      //  find first space before max line
      for (int j = tracker-1; j > 0; j--) {
        if (temp.charAt(j) == ' ') {
          //  add current line
          liness.append(liness.get(i).substring(0, j)); 
          //  add long next line to be processed
          liness.append(liness.get(i).substring(j+1)); 
          //  remove current long string
          liness.remove(liness.size()-3); 
          //  break for loop
          break;
        }
      }

      //  check if long string without spaces was left
      if (textWidth(liness.get(i)) > max) {
        //  add current line
        liness.append(liness.get(i).substring(0, tracker-1)); 
        //  add long next line to be processed
        liness.append(liness.get(i).substring(tracker-1)); 
        //  remove current long string
        liness.remove(liness.size()-3);
      }
    }
  }

  //  return liness as an array
  return liness.array();
}






















//  prints out a traceable error message and closes the game
void error(int e) {
  String s = ""; 
  if (e < 10)
    s = "0" + str(e); 
  else
    s = str(e); 
  println("ERROR : " + s);

  super.exit();
}
