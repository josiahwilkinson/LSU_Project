class Cutscene extends State {


  String[] lines;

  int cutsceneLine = 0;


  //  screen
  boolean screen = false;
  color s;

  //  tracker to move on to next part
  boolean moveOn = true;


  //  cutscene characters
  ArrayList<CutsceneCharacter> cutsceneCharacters = new ArrayList<CutsceneCharacter>();


  //  text variable
  boolean showTextbox = false;
  ArrayList<TextLines> textLines;
  String lineA = "";
  String lineB = "";
  String lineC = "";
  String speakerName;
  PImage speakerFace;
  boolean lineFinishedA = false;
  boolean lineFinishedB = false;
  boolean lineFinishedC = false;
  String displayLine = "";
  int textSpeed = 2;
  int textSpeedCounter = 0;

  //  choice
  boolean showChoicebox = false;
  String[] choice = new String[3];
  String[] booliale = new String[3];
  int choiceTracker = 0;

  //  move actions
  ArrayList<CharacterMovement> movements = new ArrayList<CharacterMovement>();


  //  command to send to map
  String command = "";


  //  wait
  int wait = 0;


  //  fade
  int alpha = 0;
  int rate = 0;



  Cutscene(int fileNumber) {
    println("starting cutscene: " + fileNumber);
    lines = loadStrings("cutscenes/cutscene_" + fileNumber + ".txt");
  }
  Cutscene(String fileName) {
    println("starting cutscene: " + fileName);
    lines = loadStrings("cutscenes/" + fileName + ".txt");
  }

  Cutscene(String[] l) {
    lines = l;
  }

  //  update function
  void updateState() {

    //  if (moveOn) {
    while (moveOn) {
      println(lines[cutsceneLine]);
      moveOn = false;

      //  turn off textbox
      showTextbox = false;

      //  get next meaningful line
      skipSpaces(cutsceneLine, lines);

      //  check that it isn't end command
      if (!lines[cutsceneLine].equals("<END>")) {

        //  text box
        if (lines[cutsceneLine].equals("text")) {
          showTextbox = true;
          textLines = new ArrayList<TextLines>();
          //  get title and image
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          //  if none
          if (lines[cutsceneLine].equals("null")) {
            speakerName = "";
            speakerFace = null;
          }
          //  otherwise, check for each
          else {
            String[] parts = lines[cutsceneLine].split(", ");
            if (parts[0].equals(null) || parts[0].equals("null"))
              speakerName = "";
            else
              speakerName = parts[0];
              /*
            if (parts[1].equals(null) || parts[1].equals("null"))
              speakerFace = null;
            else
              speakerFace = loadImage(parts[1]);
              */
          }
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          //  reset textbox
          textLines = new ArrayList<TextLines>();
          showTextbox = true;
          lineA = "";
          lineB = "";
          lineC = "";
          lineFinishedA = false;
          lineFinishedB = false;
          lineFinishedC = false;
          //  add lines
          while (!lines[cutsceneLine].equals("end")) {
            //  get line for text box
            String textBoxLine = lines[cutsceneLine];
            //  get translation
            //  textBoxLine = translation(textBoxLine);
            //  check for player name
            //  String[] parts = textBoxLine.split("PLAYER");  //  switch to ";;p;;"
            String[] parts = textBoxLine.split(";;p;;");  //  switch to ";;p;;"
            textBoxLine = parts[0];
            for (int i = 1; i < parts.length; i++)
              textBoxLine += playerName + parts[i];
            //  split lines according to ;;n;; signal
            ArrayList<String> textBoxLineList = new ArrayList<String>();
            String[] textBoxLines = textBoxLine.split(";;n;;");
            //  add textBoxLines to textBoxLineList taking length into account
            for (int i = 0; i < textBoxLines.length; i++) {
              //  get the lines from the line
              String[] lineSegments = stringToLines(textBoxLines[i], widthValue-100);  //  split a long line into segments based on length (100 is the text indent on each side for text in the box)
              for (int j = 0; j < lineSegments.length; j++)
                textBoxLineList.add(lineSegments[j]);
            }
            //  add new triples of lines to textLines
            for (int i = 0; i < textBoxLineList.size(); i+=3) {
              String[] tllines = new String[min(3, textBoxLineList.size()-i)];  //  uses min of 3 and list size minus i to account for excess != 3
              for (int j = 0; j < tllines.length; j++)
                tllines[j] = textBoxLineList.get(i+j);
              TextLines tl = new TextLines(tllines);
              textLines.add(tl);
            }
            cutsceneLine = skipSpaces(++cutsceneLine, lines);
          }
        }

        //  set booliale
        //  "<booliale name>, boolean new state"
        else if (lines[cutsceneLine].equals("booliale")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          String[] parts = lines[cutsceneLine].split(", ");
          setBooliale(parts[0], boolean(parts[1]));
          println("setting booliale " + parts[0] + " to " + boolean(parts[1]));
          //  move on
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }

        //  choice box
        else if (lines[cutsceneLine].equals("choice")) {

          println("setting up choice");
          println(cutsceneLine, lines[cutsceneLine]);

          //  turn on choice box
          showChoicebox = true;
          choiceTracker = 0;
          //  get choices
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          int numOfChoices = int(lines[cutsceneLine]);

          println("getting number");
          println(cutsceneLine, lines[cutsceneLine]);

          choice = new String[numOfChoices];
          booliale = new String[numOfChoices];
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          for (int i = 0; i < numOfChoices; i++) {
            println("getting option " + i);
            println(cutsceneLine, lines[cutsceneLine]);
            String[] parts = lines[cutsceneLine].split(", ");
            //  get choice
            String c = parts[0];
            for (int j = 1; j < parts.length-1; j++)
              c += parts[j];
            choice[i] = c;
            //  get last for booliale
            booliale[i] = parts[parts.length-1];
            //  get next (if not last one)
            if (i < numOfChoices-1)
              cutsceneLine = skipSpaces(++cutsceneLine, lines);
          }
          println(numOfChoices);

          //  move on to next line after getting all options

          //  DO NOT USE skipSpaces() HERE!!!
          //  IF DONE, IT MAY SKIP OVER THE RESULT OF THE CHOICE
          //  INSTEAD, MANUALLY INCREMENT THE LINE BY 1
          //  skipSpaces(++cutsceneLine, lines);
          cutsceneLine++;
        }

        //  wait an amount of time before continuing
        else if (lines[cutsceneLine].equals("wait")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          wait = int(frameRate*float(lines[cutsceneLine]));  //  wait the input (float) number of second
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
        }

        //  change character sprite
        //  line after "character sprite" is:
        //  normal (idle/walk): "<character name> ("player", "reve", or "crab"), <filename>"
        //  special: "<character name> ("player", "reve", or "crab"), <filename>, <length> (number of sprites in animation), <sprite width>, <sprite height>,"
        else if (lines[cutsceneLine].equals("character sprite")) {
          //  get character
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          String[] parts = lines[cutsceneLine].split(", ");
          MapCharacter c = null;
          //  search main characters
          if (parts[0].equals("player"))
            c = player;
          //  if not found, search map below
          if (c == null) {
            ArrayList<MapCharacter> npcs = stateStack.peekSecond().getNPCs();  //  gets npcs from state below this cutscene (will return null if not Map state)
            if (npcs != null) {
              for (MapCharacter cs : npcs)
                if (parts[0].equals(cs.name))
                  c = cs;
            }
          }
          //  if character was found
          if (c != null) {
            if (parts.length == 2)
              c.setSprite(parts[1]);
            else if (parts.length == 5)
              c.setSpecialSprite(parts[1], int(parts[2]), int(parts[3]), int(parts[4]));
          }
          //  if character was not found
          else {
            //  display issue
            println("CHARACTER NOT FOUND!");
            println("COULD NOT FIND CHARACTER: " + parts[0]);
            println("LOWER STATE CHARACTERS ARE NULL: " + (stateStack.peekSecond().getNPCs() == null));
          }
          //  move on
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }
        //  use special sprite
        //  line after: "<character name> ("player", "reve", or "crab"), repeat boolean"
        //  will not incorporate a wait function; if needed, that can just be added as the next line
        else if (lines[cutsceneLine].equals("special sprite")) {
          //  get character
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          String[] parts = lines[cutsceneLine].split(", ");
          MapCharacter c = null;
          if (parts[0].equals("player"))
            c = player;
          //  if not found, search map below
          if (c == null) {
            ArrayList<MapCharacter> npcs = stateStack.getMap().getNPCs();  //  gets npcs from state below this cutscene (will return null if not Map state)
            if (npcs != null) {
              for (MapCharacter cs : npcs)
                if (parts[0].equals(cs.name))
                  c = cs;
            }
          }
          //  if character was found
          if (c != null) {
            //  if no repeat specification, assume only used once
            if (parts.length == 1)
              c.special(true);
            else if (parts.length == 2)
              c.special(boolean(parts[1]));
          }
          //  move on
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }
        //  trigger to set new map
        else if (lines[cutsceneLine].equals("map")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          String[] parts = lines[cutsceneLine].split(", ");
          stateStack.replaceMap(loadMap(int(parts[0]), new PVector(int(parts[1]), int(parts[2]))));
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
          boolean removeThisLater;
          player.setIdle();
        }
        //  triggers passed on to map
        //  else if (lines[cutsceneLine].equals("move") || lines[cutsceneLine].equals("move to")) {
        else if (lines[cutsceneLine].equals("move to")) {
          String s = lines[cutsceneLine];
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          command = s + ", " + lines[cutsceneLine];
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          //  check for move on or not
          //  move on (set as movement)
          if (lines[cutsceneLine].equals("true")) {
            movements.add(new CharacterMovement(command));
            command = "";
            moveOn = true;
          }
          //  otherwise, don't move on and leave command as set (nothing needs to be done for that)
        }
        //  waits until all movements have been finished
        else if (lines[cutsceneLine].equals("resolve movements")) {
          println("resolving movements, movement size: " + movements.size());
          if (movements.size() == 0) {
            cutsceneLine = skipSpaces(++cutsceneLine, lines);
            moveOn = true;
          }
          println("resolving movements, moveOn: " + moveOn);
        }
        /*
        //  fight
         else if (lines[cutsceneLine].equals("fight")) {
         stateStack.addState(new TutorialFight(0));
         cutsceneLine = skipSpaces(++cutsceneLine, lines);
         moveOn = true;
         }
         
         //  cinematic
         else if (lines[cutsceneLine].equals("cinematic")) {
         stateStack.addState(new Cinematic());
         cutsceneLine = skipSpaces(++cutsceneLine, lines);
         moveOn = true;
         }
         */
        //  add character
        else if (lines[cutsceneLine].equals("add character")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          String[] parts = lines[cutsceneLine].split(", ");

          //  name, side, imageName

          //  character images are 400x500

          //  on left side
          if (parts.length == 2 || (parts.length == 3 && boolean(parts[1]))) {
            //  check first free spot
            int tracker = 0;
            boolean taken = true;
            while (taken) {
              taken = false;  //  reset taken
              for (CutsceneCharacter c : cutsceneCharacters)
                if (c.pos.x == tracker) {
                  taken = true;
                  tracker += 100;
                  break;
                }
            }
            //  check length of input and create character
            if (parts.length == 2)
              cutsceneCharacters.add(new CutsceneCharacter(parts[0], new PVector(tracker, heightValue-500), true, parts[1]));
            else
              cutsceneCharacters.add(new CutsceneCharacter(parts[0], new PVector(tracker, heightValue-500), true, parts[2]));
          }
          //  on right side
          else {
            //  check first free spot
            int tracker = widthValue-400;
            boolean taken = false;
            while (taken) {
              taken = false;  //  reset taken
              for (CutsceneCharacter c : cutsceneCharacters)
                if (c.pos.x == tracker) {
                  taken = true;
                  tracker -= 100;
                  break;
                }
            }
            cutsceneCharacters.add(new CutsceneCharacter(parts[0], new PVector(tracker, heightValue-500), boolean(parts[1]), parts[2]));
          }
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }

        //  remove character
        else if (lines[cutsceneLine].equals("remove character")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          for (CutsceneCharacter c : cutsceneCharacters)
            if (c.name.equals(lines[cutsceneLine])) {
              cutsceneCharacters.remove(c);
              break;
            }
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }

        //  change character display name
        else if (lines[cutsceneLine].equals("change character display name")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          String[] parts = lines[cutsceneLine].split(", ");
          for (CutsceneCharacter c : cutsceneCharacters)
            if (c.name.equals(parts[0])) {
              c.setDisplayName(parts[1]);
              break;
            }
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }

        //  change character image
        else if (lines[cutsceneLine].equals("change character image")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          String[] parts = lines[cutsceneLine].split(", ");
          for (CutsceneCharacter c : cutsceneCharacters)
            if (c.name.equals(parts[0])) {
              c.setImage(parts[1]);
              break;
            }
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }

        //  flip character
        else if (lines[cutsceneLine].equals("flip character")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          String[] parts = lines[cutsceneLine].split(", ");
          for (CutsceneCharacter c : cutsceneCharacters)
            if (c.name.equals(parts[0])) {
              if (parts.length == 1)
                c.flip();
              else
                c.setFlip(boolean(parts[1]));
              break;
            }
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }

        //  change character side
        else if (lines[cutsceneLine].equals("change character side")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          String[] parts = lines[cutsceneLine].split(", ");
          for (CutsceneCharacter c : cutsceneCharacters)
            if (c.name.equals(parts[0])) {
              //  relabel side
              if (parts.length == 1)
                c.setSide(!c.side);
              else
                c.setSide(boolean(parts[1]));

              //  reset x position
              int tracker = 0;
              if (!c.side)
                tracker = widthValue-400;

              //  check first free spot
              boolean taken = false;
              while (taken) {
                taken = false;  //  reset taken
                for (CutsceneCharacter c2 : cutsceneCharacters)
                  if (c2.pos.x == tracker) {
                    taken = true;
                    tracker += 100*(int(c.side)*2-1);
                    break;
                  }
              }
              c.setPosition(new PVector(tracker, heightValue-500));

              break;
            }
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }




        //  fades to black
        else if (lines[cutsceneLine].equals("fade out")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          rate = int(lines[cutsceneLine]);
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }
        //  fades to normal
        else if (lines[cutsceneLine].equals("fade in")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          rate = -1*int(lines[cutsceneLine]);
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }
        //  game over
        else if (lines[cutsceneLine].equals("game over")) {
          stateStack.addState(new End());
          //  don't bother moving on after this
        }
        /*
        //  music
         else if (lines[cutsceneLine].equals("music")) {
         cutsceneLine = skipSpaces(++cutsceneLine, lines);
         if (lines[cutsceneLine].equals("out") || lines[cutsceneLine].equals("stop"))
         fadeOutSong();
         else
         fadeInSong(getSong(lines[cutsceneLine]));
         cutsceneLine = skipSpaces(++cutsceneLine, lines);
         moveOn = true;
         }
         //  shop
         else if (lines[cutsceneLine].equals("shop")) {
         cutsceneLine = skipSpaces(++cutsceneLine, lines);
         stateStack.addState(new Shop(int(lines[cutsceneLine])));
         cutsceneLine = skipSpaces(++cutsceneLine, lines);
         moveOn = true;
         }
         */

        //  skip lines
        else if (lines[cutsceneLine].equals("skip")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          cutsceneLine += int(lines[cutsceneLine]);
          moveOn = true;
        }
        //  go to line
        else if (lines[cutsceneLine].equals("goto")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          cutsceneLine = int(lines[cutsceneLine]);
          moveOn = true;
        }
        //  go to label
        else if (lines[cutsceneLine].equals("goto label")) {
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          println("going to label: " + lines[cutsceneLine]);
          cutsceneLine = findLabel(lines[cutsceneLine]);
          cutsceneLine++;  //  skip 1 line as it is currently on the label's line (which should be skipped in case the label name may trigger something)
          println("now at line " + cutsceneLine);
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }

        //  move on if no triggers
        else {
          //  display fail
          println("FAIL: " + lines[cutsceneLine]);
          //  move on
          cutsceneLine = skipSpaces(++cutsceneLine, lines);
          moveOn = true;
        }
      }

      //  otherwise, if end command
      else {
        stateStack.pop(this);
      }
    }


    //  run scene

    //  check for fade
    if (rate != 0) {
      alpha += rate;
      if (alpha <= 0) {
        alpha = 0;
        rate = 0;
      }
      if (alpha > 255) {
        alpha = 255;
        rate = 0;
      }
    }

    //  check for wait
    if (wait > 0) {
      wait--;
      if (wait == 0)
        moveOn = true;
    }

    //  check for command
    if (!command.equals("")) {
      println("sending command", command);
      if (stateStack.messageNext(command)) {
        command = "";
        moveOn = true;
      }
    }

    //  update and remove finished movements
    for (int i = 0; i < movements.size(); i++) {
      movements.get(i).updateMovement();
      if (movements.get(i).finished) {
        movements.remove(i);
        i--;
      }
      //  keep on moving on if checking for resolving movements
      if (lines[cutsceneLine].equals("resolve movements"))
        moveOn = true;
    }

    //  check for cutscene
    if (showTextbox) {
      //  run textbox
      if (!lineFinishedA) {
        //  check for completion
        println(textLines.size());
        if (lineA.equals(textLines.get(0).textBoxLines[0])) {
          lineFinishedA = true;  //  finish line
          //  textLines.remove(0);  //  remove top line
        } else if (textSpeedCounter == 0) {
          lineA += textLines.get(0).textBoxLines[0].charAt(lineA.length());
          textSpeedCounter = textSpeed;
        } else
          textSpeedCounter--;
      } else if (!lineFinishedB) {
        //  check for completion
        if (textLines.size() == 0) {
          lineFinishedB = true;
        } else {
          //  check for completion
          if (lineB.equals(textLines.get(0).textBoxLines[1])) {
            lineFinishedB = true;  //  finish line
            //  textLines.remove(0);  //  remove top line
          } else if (textSpeedCounter == 0) {
            lineB += textLines.get(0).textBoxLines[1].charAt(lineB.length());
            textSpeedCounter = textSpeed;
          } else
            textSpeedCounter--;
        }
      } else if (!lineFinishedC) {
        //  check for completion
        if (textLines.size() == 0) {
          lineFinishedC = true;
        } else {
          //  check for completion
          if (lineC.equals(textLines.get(0).textBoxLines[2])) {
            lineFinishedC = true;  //  finish line
            //  textLines.remove(0);  //  remove top line
          } else if (textSpeedCounter == 0) {
            lineC += textLines.get(0).textBoxLines[2].charAt(lineC.length());
            textSpeedCounter = textSpeed;
          } else
            textSpeedCounter--;
        }
      }
      //  both lines completed
      else {
        if (input[0] && !menuKeysTriggers[0]) {
          menuKeysTriggers[0] = true;

          textLines.remove(0);  //  remove top line

          //  end of text scene
          if (textLines.size() == 0) {
            moveOn = true;
            showTextbox = false;
          }
          //  reset textbox
          lineA = "";
          lineB = "";
          lineC = "";
          lineFinishedA = false;
          lineFinishedB = false;
          lineFinishedC = false;
        }
      }

      //  short cut to immediately finish lines
      //  will not trigger if both lines are already completed as the above if will catch and set off the key trigger
      if (input[0] && !menuKeysTriggers[0]) {
        menuKeysTriggers[0] = true;
        if (!lineFinishedA) {
          lineFinishedA = true;
          lineA = textLines.get(0).textBoxLines[0];
          //  textLines.remove(0);  //  remove top line
        }
        if (!lineFinishedB) {
          lineFinishedB = true;
          //  if (textLines.size() > 0) {
          lineB = textLines.get(0).textBoxLines[1];
          //    textLines.remove(0);  //  remove top line
          //  }
        }
        if (!lineFinishedC) {
          lineFinishedC = true;
          //  if (textLines.size() > 0) {
          lineC = textLines.get(0).textBoxLines[2];
          //    textLines.remove(0);  //  remove top line
          //  }
        }
        //  textLines.remove(0);  //  remove top line
      }
    }

    //  check for choice box
    if (showChoicebox) {
      //  check for movement
      //  move up
      if (input[4] && !menuKeysTriggers[4]) {
        menuKeysTriggers[4] = true;
        if (choiceTracker > 0)
          choiceTracker--;
      }
      //  move down
      if (input[6] && !menuKeysTriggers[6]) {
        menuKeysTriggers[6] = true;
        if (choiceTracker < choice.length-1)
          choiceTracker++;
      }
      // check for enter
      if (input[0] && !menuKeysTriggers[0]) {
        menuKeysTriggers[0] = true;
        showChoicebox = false;
        setBooliale(booliale[choiceTracker], true);
        moveOn = true;
      }
    }

    //  println("move on:", moveOn);
  }

  //  update function
  void drawState() {

    //  back screen
    if (alpha != 0) {
      fill(0, alpha);
      rect(-1, -1, widthValue+2, heightValue+2);
    }

    //  show cutscene box
    if (showTextbox) {
      //  draw box
      fill(0);
      rect(10, heightValue - 95 - 10, widthValue - 20, 95, 15);
      //  check for name
      if (!speakerName.equals("")) {
        setTextSize(25);
        rect(25, heightValue - 95 - 10 - 30, textWidth(speakerName) + 10, 95, 15);
        fill(255);
        text(speakerName, 30, heightValue - 110);
      }
      //  check for face
      if (speakerFace != null)
        image(speakerFace, 15, heightValue - 95 - 10, 85, 85);
      //  show content
      fill(255);
      setTextSize(25);
      int x = 100;
      if (speakerFace == null)
        x = 20;
      text(lineA, x, heightValue - 80);
      text(lineB, x, heightValue - 50);
      text(lineC, x, heightValue - 20);
    }
    //  show choice box
    if (showChoicebox) {
      //  draw box
      fill(0);
      rect(10, heightValue - 95 - 10, widthValue - 20, 95, 15);
      //  show content
      fill(255);
      setTextSize(25);
      int x = 20;
      for (int i = 0; i < choice.length; i++)
        text(choice[i], x, heightValue - (20 + 30*(2-i)));
      //  highlight option
      fill(255);
      rect(x-5, heightValue - (20 + 30*(2-choiceTracker)) - 22, widthValue - 30, 27, 3);
      fill(0);
      println(choiceTracker, choice.length);
      println(choice[choiceTracker]);
      text(choice[choiceTracker], x, heightValue - (20 + 30*(2-choiceTracker)));
    }
  }


  //  returns true if the input string is a cutscene trigger
  boolean trigger(String s) {
    return (s.equals("text") || s.equals("choice") || s.equals("move") || s.equals("move to") || s.equals("cinematic") || s.equals("map") || s.equals("wait") || s.equals("fight") || s.equals("game over")
      || s.equals("fade in") || s.equals("fade out") || s.equals("music") || s.equals("shop") || s.equals("<END>"));
  }

  //  returns the line of the desired label
  //  labels can be picked out of anywhere and so, to avoid issues, skipSpaces() will not be used while searching except to get the name directly after the "label" tag
  int findLabel(String label) {
    int line = 0;
    while (line < lines.length) {
      if (lines[line].equals("label")) {
        //  line = skipSpaces(++cutsceneLine, lines);
        line++;
        if (lines[line].equals(label)) {
          return line;
        }
      } else {
        //  println(line, lines.length, lines[line]);
        line++;
      }
    }
    println("cannot find label " + label + " in cutscene");
    error(20);
    return 0;
  }





  //  class used for running character movements without holding up cutscene
  class CharacterMovement {

    String movement;
    boolean finished = false;

    CharacterMovement(String m) {
      movement = m;
    }

    void updateMovement() {
      //  check for command
      if (!finished)
        if (stateStack.messageNext(movement))
          finished = true;
      //  println("movement finished: " + finished);
    }
  }



  //  stores sets of up to 3 strings for cutscenes
  class TextLines {
    String[] textBoxLines = {" ", " ", " "};

    //  contructors do not overwrite string[], but overwrite lines so as to keep 3 strings; otherwise, issues may occur when displaying line with less than 3
    //  contructors will also flag an error if the input is greater than 3
    TextLines(String[] l) {
      if (l.length > 3) {
        println("TextLines given size greater than can hold");
        error(22);
      }
      for (int i = 0; i < min(l.length, 3); i++)
        textBoxLines[i] = l[i];

      println("New TextLines: {" + textBoxLines[0] + ", " + textBoxLines[1] + ", " + textBoxLines[2] + "}");
    }
    TextLines(ArrayList<String> l) {
      if (l.size() > 3) {
        println("TextLines given size greater than can hold");
        error(23);
      }
      for (int i = 0; i < min(l.size(), 3); i++)
        textBoxLines[i] = l.get(i);
    }
  }






  //  simple class to hold character objects with fade and position control
  //  no gradual fading or movement programmed
  //  may add later (will need an update function)
  class CutsceneCharacter {

    String name;
    String displayName = "???";

    PImage image;
    PVector pos;  //  position
    PVector size;  //  image size
    boolean side;  //  true = left side, false = right side
    boolean flipped = false;  //  false = facing center, true = facing away from center
    boolean shaded = false;

    CutsceneCharacter(String n, PVector p, boolean s, String imageName) {
      name = n;
      setDisplayName(name);
      pos = p;
      side = s;
      setImage(imageName);
    }

    void setDisplayName(String d) {
      displayName = d;
    }

    String getDisplayName() {
      return displayName;
    }

    String getRealName() {
      return name;
    }

    void setSide(boolean s) {
      side = s;
    }

    void setFlip(boolean f) {
      flipped = f;
    }

    void flip() {
      flipped = !flipped;
    }

    void setImage(String imageName) {
      image = loadImage("characters/" + imageName);
      size = new PVector(image.width, image.height);
    }

    void setImage(String imageName, PVector s) {
      image = loadImage("characters/" + imageName);
      size = s;
    }

    void setPosition(PVector p) {
      pos = p.copy();
    }

    void unshade() {
      shaded = false;
    }

    void drawCharacter() {
      if (image != null) {
        //  set shading
        if (shaded)
          tint(150);

        //  flip
        if (flipped || (!side && !flipped)) {
          scale(-1, 1);
          image(image, -pos.x-size.x, pos.y, size.x, size.y);
        } else
          image(image, pos.x, pos.y, size.x, size.y);
        //  reset flip
        if (flipped || (!side && !flipped))
          scale(-1, 1);

        //  reset shading
        if (shaded)
          tint(255);
      }
      shaded = true;  //  this is set to false each frame
    }
  }
}


/*
class Cinematic extends State {
 
 String[] lines;
 int lineCounter = 0;
 
 int number;
 
 int numberOfImages;
 
 PImage current;
 PImage past;
 
 boolean fade = false;
 float fadeCounter = 0;
 float fadeRate = 0;
 int timeCounter = 0;
 
 Cinematic(String s) {
 setupCinematic(int(s));
 }
 Cinematic(int s) {
 setupCinematic(s);
 }
 
 void setupCinematic(int s) {
 number = s;
 lines = loadStrings("cinematic_" + str(s) + ".txt");
 //  load images
 lineCounter = skipSpaces(lineCounter, lines);
 numberOfImages = int(lines[lineCounter]);
 //  prep first image
 }
 
 void updateState() {
 }
 void drawState() {
 background(255);
 }
 }
 */


/*
class Cinematic extends State {
 
 int numberOfImages = 6;
 
 PImage image;
 
 int imageNum = 1;
 
 int counter = int(frameRateValue*1);
 
 AudioPlayer voice;
 
 Cinematic() {
 image = loadImage("cinematics/1_" + str(imageNum) + ".png");
 drawCursor = false;
 }
 
 boolean playSound = true;
 
 void updateState() {
 
 if (playSound) {
 fadeOutSong(500);
 playSound = false;
 
 voice = minim.loadFile("cinematics/lotus_voice.mp3");
 println(voice == null);
 println(voice.getGain());
 //  voice.play();
 boolean addBackInAfterItIsReplaced;
 }
 
 
 
 counter--;
 if (counter <= 0) {
 counter = int(frameRateValue*0.5);
 if (imageNum == 6)
 counter = int(frameRateValue*1.5);
 if (imageNum == 3)
 fadeInSong(getSong("battle"), 2500);
 if (imageNum <= numberOfImages) {
 image = loadImage("cinematics/1_" + str(imageNum) + ".png");
 imageNum++;
 } else {
 stateStack.pop(this);
 drawCursor = true;
 }
 }
 }
 void drawState() {
 background(255);
 //  will not need to scale or stretch images as they will be drawn to scale
 image(image, 0, 0);
 
 println(counter);
 }
 }
 */
