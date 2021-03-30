void keyPressed() {
  //  update inputs
  for (int i = 0; i < keys.length; i++) {
    if (key == keys[i].lowerLetter || key == keys[i].upperLetter || keyCode == keys[i].code) {
      input[i] = true;
      break;
    }
  }

  /*
  //  full screen
   if (key == 'p')
   if (!fullPress) {
   switchFullScreen();
   fullPress = true;
   }
   */


  /*
  //  set textmode to model
   if (key == 'T')
   textMode(MODEL);
   */


  /*
  //  switch to french for language testing
   if (key == 'F') {
   switchLanguage("french");
   }
   */



  //  quit (and export recording)
  //  if (key == 'q') {
  //    videoExport.endMovie();
  //    exit();
  //  }



  //  escape key exit
  if (key == ESC) {
    key = 0;
    if (!(stateStack.peek() instanceof Quit))
      stateStack.addState(new Quit());
  }
}

void keyReleased() {
  press = false;

  for (int i = 0; i < keys.length; i++)
    if (key == keys[i].lowerLetter || key == keys[i].upperLetter || keyCode == keys[i].code) {
      input[i] = false;
      menuKeysTriggers[i] = false;
      break;
    }

  kpress = false;
  if (key == BACKSPACE)
    bpress = false;
  if (key == ' ')
    spress = false;
  if (key == ENTER)
    epress = false;
  //  if (key == CODED && (keyCode == RIGHT || keyCode == LEFT))
  //    apress = false;

  //  fullscreen
  if (key == 'p')
    fullPress = false;

  /*
  //  recording
   if (key == recordKey)
   rpress = false;
   */
}

void mouseReleased() {
  mpress = false;
  release = true;
}


class KeySet {
  char lowerLetter;
  char upperLetter;

  int code;

  KeySet(char l, int c) {
    //  turn char into string, set as both lower and upper case and set chars accordingly
    String letter = str(l);
    letter = letter.toLowerCase();
    lowerLetter = letter.charAt(0);
    letter = letter.toUpperCase();
    upperLetter = letter.charAt(0);

    code = c;
  }
}
