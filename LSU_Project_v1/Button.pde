class Button {

  PVector pos = new PVector();

  boolean bpress = false;

  void drawButton() {
  }

  //  shouldn't be accessed
  boolean checkClicked() {
    return false;
  }

  //  shouldn't be accessed
  boolean checkOver() {
    return false;
  }

  PVector getPos() {
    return pos;
  }
}


//  for regular rectangular buttons
//  text automatically is centred (manually)
class RectButton extends Button {

  String label;
  PImage image;
  PVector size = new PVector();
  float textSize;

  //  display
  String display = null;

  RectButton(String lab, int x, int y, PImage i, int l, int h, float t) {
    label = lab;
    pos.x = x;
    pos.y = y;
    image = i;
    size.x = l;
    size.y = h;
    textSize = t;
  }

  void setDisplay(String d) {
    display = d;
  }

  String getLabel() {
    return label;
  }

  void drawButton() {
    //  button
    fill(255);
    rect(pos.x, pos.y, size.x, size.y);
    //  text
    if (image == null) {
      fill(0);
      setTextSize(textSize);
      text(label, (pos.x+size.x/2) - textWidth(label)/2, (pos.y+size.y/2) + textSize/2);
    } else
      image(image, pos.x, pos.y, size.x, size.y);
  }

  void drawButtonNegative() {
    //  button
    fill(0);
    rect(pos.x, pos.y, size.x, size.y);
    //  text
    fill(255);
    int currentSize = int(textAscent());
    setTextSize(textSize);
    text(label, (pos.x+size.x/2) - textWidth(label)/2, (pos.y+size.y/2) + textSize/2);
    //  restore text size
    setTextSize(currentSize);
  }

  boolean checkClicked() {
    if (mouseIn(pos, size)) {
      if (mousePressed && mpress == false) {
        //  draw negative
        drawButtonNegative();
        mpress = true;
        bpress = true;
        return true;
      }
    } else if (bpress)
      bpress = false;

    return false;
  }

  //  returns true if the mouse is over the button
  boolean checkOver() {
    return mouseIn(pos, size);
  }

  //  show display text if available if mouse is over button
  void display() {
    if (display != null)
      if (mouseIn(pos, size))
        displayInfo(display, int(mouse.x), int(mouse.y));
  }
}

//  rect button, but invisible box showing only the text
class InvisibleButton extends RectButton {

  InvisibleButton(String lab, int x, int y, PImage i, int l, int h, float t) {
    super(lab, x, y, i, l, h, t);
  }
  InvisibleButton(String lab, int x, int y, int l, int h, float t) {
    super(lab, x, y, null, l, h, t);
  }

  void drawButton() {
    fill(0);
    setTextSize(textSize);
    text(label, (pos.x+size.x/2) - textWidth(label)/2, (pos.y+size.y/2) + textSize/2);
    //  draw image
    boolean haveImageDrawn;
  }
}

//  back button
class BackButton extends RectButton {

  BackButton() {
    super("< back", 10, 10, null, 40, 15, 15);
  }


  boolean checkClicked() {

    //  mouse
    if (mouseIn(pos, size)) {
      if (mousePressed && mpress == false) {
        //  draw negative
        drawButtonNegative();
        mpress = true;
        bpress = true;
        return true;
      }
      if (input[0] && !menuKeysTriggers[0]) {
        //  draw negative
        drawButtonNegative();
        menuKeysTriggers[0] = true;
        bpress = true;
        return true;
      }
    } else if (bpress)
      bpress = false;


    return false;
  }
}



class Prompt extends State {

  //  type
  //  false = ok
  //  true = choice
  boolean type;
  String message;

  PVector dim;
  PVector pos;


  Prompt(boolean t, String m) {
    type = t;
    message = m;
    setTextSize(20);  //  must be here before setting dim for textwidth to work properly
    if (!type)  //  ok
      dim = new PVector(max(150, textWidth(message)*1.1), 100);
    else        //  choice
    dim = new PVector(max(200, textWidth(message)*1.1), 100);
    pos = new PVector(widthValue/2-dim.x/2, heightValue/2-dim.y/2);
  }

  void drawState() {
    //  background
    fill(100, 100);
    rect(-1, -1, widthValue+2, heightValue+2);
    //  draw box
    fill(255);
    rect(pos.x, pos.y, dim.x, dim.y);
    //  write prompt
    fill(0);
    setTextSize(20);
    text(message, widthValue/2-textWidth(message)/2, heightValue/2-20);
    //  ok prompt
    if (!type) {
      //  draw button
      fill(255);
      rect(widthValue/2-50, heightValue/2, 100, 30);
      fill(0);
      setTextSize(20);
      text("Confirm", widthValue/2-40, heightValue/2+22);
    }
    //  choice prompt
    else {
      //  draw buttons
      //  Yes
      fill(255);
      rect(widthValue/2-85, heightValue/2, 70, 30);
      fill(0);
      setTextSize(20);
      text("Yes", widthValue/2-65, heightValue/2+22);
      //  No
      fill(255);
      rect(widthValue/2+15, heightValue/2, 70, 30);
      fill(0);
      setTextSize(20);
      text("No", widthValue/2+38, heightValue/2+22);
    }
  }

  void updateState() {
    //  enter key for yes/ok
    //  if (keyPressed && key == ENTER && !epress) {
    if (keyPressed && input[0] && !menuKeysTriggers[0]) {
      menuKeysTriggers[0] = true;
      if (key == ENTER)
        epress = true;
      yes();
    }
    //  enter key for no (if choice)
    if (type) {
      if (keyPressed && input[1] && !menuKeysTriggers[1]) {
        menuKeysTriggers[1] = true;
        no();
      }
    }
    //  ok prompt
    if (!type) {
      //  button
      if (mouseIn(widthValue/2-50, heightValue/2, 100, 30)) {
        //  redraw
        fill(0);
        rect(widthValue/2-50, heightValue/2, 100, 30);
        fill(255);
        setTextSize(20);
        text("Confirm", widthValue/2-40, heightValue/2+22);
        //  activate button
        if (mousePressed && !mpress) {
          mpress = true;
          yes();
        }
      }
    }
    //  choice prompt
    else {
      //  buttons
      //  Yes
      if (mouseIn(widthValue/2-85, heightValue/2, 70, 30)) {
        //  redraw
        fill(0);
        rect(widthValue/2-85, heightValue/2, 70, 30);
        fill(255);
        setTextSize(20);
        text("Yes", widthValue/2-65, heightValue/2+22);
        //  press
        if (mousePressed && !mpress) {
          mpress = true;
          yes();
        }
      }
      //  No
      if (mouseIn(widthValue/2+15, heightValue/2, 70, 30)) {
        //  redraw
        fill(0);
        rect(widthValue/2+15, heightValue/2, 70, 30);
        fill(255);
        setTextSize(20);
        text("No", widthValue/2+38, heightValue/2+22);
        //  press
        if (mousePressed && !mpress) {
          mpress = true;
          no();
        }
      }
    }
  }

  //  result functions (to be used by subclass)
  //  called for the "Yes" or "Confirm"
  void yes() {
    //  in the least, this super class at least pops itself then messages the top class the response of "<prompt message> yes"
    stateStack.pop();
    stateStack.message(message + " yes");
  }
  //  called for the "No"
  void no() {
    //  in the least, this super class at least pops itself then messages the top class the response of "<prompt message> no"
    stateStack.pop();
    stateStack.message(message + " no");
  }
}




//  Quit warning state
class Quit extends Prompt {

  Quit() {
    super(true, "Do you wish to quit the game?");
  }

  void yes() {
    //  close game
    exit();
  }

  void no() {
    stateStack.pop();
    println("exiting");
  }
}


//  this is only called when exitting normally as errors call super.exit() directly
void exit() {
  //  delete log file if printing to log
  //  if (PRINTTOLOGFILE)
  //    new File(logFile).delete();
  super.exit();
}
