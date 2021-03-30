Map loadMap(int number, PVector startingPos) {
  return null;
}


//  map class
class Map extends State {
  //  for saving purposes
  int id = 0;

  //  walking and map variables
  PVector size = new PVector();

  //  map images
  ArrayList<MapImage> images = new ArrayList<MapImage>();
  //  offset
  PVector offset = new PVector(0, 0);


  //  moving tracker
  boolean moving = false;


  //  boundaries
  ArrayList<Hitbox> bounds = new ArrayList<Hitbox>();


  //  npcs
  ArrayList<MapCharacter> npcs = new ArrayList<MapCharacter>();
  //  objects
  ArrayList<Object> objects = new ArrayList<Object>();

  //  triggers
  ArrayList<Trigger> triggers = new ArrayList<Trigger>();


  Map(int number, PVector s, PVector intitalStep) {
    //  set id
    id = number;

    //  set size
    size = s;

    //  draw once (done to set offset for initial scene)
    drawState();
  }

  //  returns id (used for saving)
  int id() {
    return id;
  }

  //  overriden in Map to get Map from the stack rather than State
  Map mapVersion() {
    return this;
  }

  //  sets the maps bounaries
  void addBound(Hitbox b) {
    bounds.add(b);
  }
  //  removes a boundary from the map bounaries
  boolean removeBound(Hitbox bo) {
    for (Hitbox b : bounds)
      if (b.equals(bo)) {
        bounds.remove(b);
        return true;
      }
    return false;
  }

  //  sets the triggers
  void addTrigger(Trigger t) {
    triggers.add(t);
  }
  //  remove trigger
  boolean removeTrigger(String n) {
    for (Trigger t : triggers) {
      if (t.id.equals(n)) {
        triggers.remove(t);
        return true;
      }
    }
    return false;
  }

  //  adds to map images
  void addImage(MapImage m) {
    images.add(m);
  }
  //  removes image by name to map images
  //  returns true if successful
  boolean removeImage(String n) {
    for (MapImage m : images) {
      if (m.name.equals(n)) {
        images.remove(m);
        return true;
      }
    }
    return false;
  }

  //  adds to map objects
  void addObject(Object o) {
    objects.add(o);
  }
  //  removes named object from map objects
  boolean removeObject(String n) {
    for (Object o : objects) {
      if (o.name.equals(n)) {
        objects.remove(o);
        return true;
      }
    }
    return false;
  }    


  //  adds to map npcs
  void addNPC(MapCharacter npc) {
    npcs.add(npc);
    println(npc.name, npc.pos, npc.size, npc.sprite[0][0].width, npc.sprite[0][0].height);
    //  exit();
  }
  //  removes named npc from map npcs
  boolean removeNPC(String n) {
    for (MapCharacter npc : npcs) {
      if (npc.name.equals(n)) {
        npcs.remove(npc);
        return true;
      }
    }
    return false;
  }
  void moveInput() {
    /*
         //  arrows
     if (keyCode == LEFT)
     input[0] = false;
     if (keyCode == UP)
     input[1] = false;
     if (keyCode == RIGHT)
     input[2] = false;
     if (keyCode == DOWN)
     input[3] = false;
     }
     */
    //  get input
    float horizontalMovement = 0;
    float verticalMovement = 0;
    if (input[3])
      horizontalMovement--;
    if (input[5])
      horizontalMovement++;
    if (input[4])
      verticalMovement--;
    if (input[6])
      verticalMovement++;

    //  get moving status
    if (horizontalMovement != 0 || verticalMovement != 0)
      moving = true;
    else
      moving = false;

    //  move to new location
    //  check if diagonal or not
    if (abs(verticalMovement) == abs(horizontalMovement) && horizontalMovement != 0) {
      //  correct by multiplying by sqrt(2)/2
      horizontalMovement *= 0.7071068;
      verticalMovement *= 0.7071068;
      move(int(horizontalMovement*player.speed), int(verticalMovement*player.speed));
    } else
      move(int(horizontalMovement*player.speed), int(verticalMovement*player.speed));
  }

  //  move by the input
  void move(int ox, int oy) {
    //  restate x and y (this is needed for the turning if against an edge)
    int x = ox;
    int y = oy;
    //  check that there is movement
    if (x != 0 || y != 0) {
      //  check that the new place isn't out of bounds
      //  Hitbox newHitbox = characters.get(0).hitbox.copy();
      Hitbox newHitbox = new Hitbox(player.pos.copy(), player.hitbox.size);
      newHitbox.move(new PVector(x, y));
      boolean inBounds = !overlapping(newHitbox, listToArray(bounds));
      //  new step is in bounds
      if (inBounds) {
        player.pos = new PVector(player.pos.x+x, player.pos.y+y);
        player.hitbox = new Hitbox(player.pos.copy(), player.hitbox.size);
      }
      //  new step is out of bounds
      else {
        //  increment each of x and y while in bounds
        //  both
        if (x != 0 && y != 0) {
          newHitbox = player.hitbox.copy();
          //  x is a problem
          newHitbox.move(new PVector(x, 0));
          if (overlapping(newHitbox, listToArray(bounds)))
            while (overlapping(newHitbox, listToArray(bounds))) {
              //  decrement x position of new hitbox
              newHitbox.move(new PVector(-x/abs(x), 0));
              x -= x/abs(x);
            }
          //  y is a problem
          newHitbox.move(new PVector(0, y));
          if (overlapping(newHitbox, listToArray(bounds)))
            while (overlapping(newHitbox, listToArray(bounds))) {
              //  decrement y position of new hitbox
              newHitbox.move(new PVector(0, -y/abs(y)));
              y -= y/abs(y);
            }
        }
        //  x
        else if (x != 0) {
          newHitbox = player.hitbox.copy();
          newHitbox.move(new PVector(x, 0));
          while (overlapping(newHitbox, listToArray(bounds))) {
            //  decrement x position of new hitbox
            newHitbox.move(new PVector(-x/abs(x), 0));
            x -= x/abs(x);
          }
        }
        //  y
        else if (y != 0) {
          newHitbox = player.hitbox.copy();
          newHitbox.move(new PVector(0, y));
          while (overlapping(newHitbox, listToArray(bounds))) {
            //  decrement x position of new hitbox
            newHitbox.move(new PVector(0, -y/abs(y)));
            y -= y/abs(y);
          }
        }
        //  take step with new values
        if (x != 0 || y != 0)
          player.setTo(newHitbox.pos);
        //  change direction (even though step isn't taken)
        else if (x == 0 && y == 0) {
          player.adjustDirection(ox, oy);
        }
      }

      //  correct moving (chance for random encounter) to false if x == 0 and y == 0
      if (x == 0 && y == 0)
        //  stop moving
        moving = false;
    }

    //  update character positions
    println(player.pos);
  }

  //  resets offset
  void correctOffset() {
    //  adjust scrolling indent
    int indentLength = widthValue/2;
    int indentHeight = heightValue/2;
    while (player.pos.x + player.size.x - widthValue + indentLength > abs(offset.x) && abs(offset.x) + widthValue < size.x)
      offset.x--;
    while (player.pos.x - indentLength < abs(offset.x) && abs(offset.x) > 0)
      offset.x++;
    while (player.pos.y + player.size.y - heightValue + indentHeight > abs(offset.y) && abs(offset.y) + heightValue < size.y)
      offset.y--;
    while (player.pos.y - indentHeight < abs(offset.y) && abs(offset.y) > 0)
      offset.y++;
  }


  //  draw the map
  void drawState() {
    //  temp for testing
    background(255);

    //  fix offset
    correctOffset();

    translate(offset.x, offset.y);

    //  draw bottom images
    drawBottom();

    //  draw characters, npcs, and objects (from the smallest y to largest)
    drawCharacters();

    /*
    for (Hitbox h : bounds) {
     h.drawHitbox();
     h.drawHitbox(offset);
     }
     ellipse(characters.get(0).pos.x, characters.get(0).pos.y, 20, 20);
     for (Character c : characters) {
     c.drawObject(offset);
     c.hitbox.drawHitbox(offset);
     c.drawObject();
     c.hitbox.drawHitbox();
     }
     //  characters.get(0).hitbox.drawHitbox();
     */



    //  draw top images
    drawTop();



    //  println(offset);



    translate(-offset.x, -offset.y);
  }

  void drawCharacters() {
    //  create new arraylist for all characters and npcs and objects
    ArrayList<Object> allObjects = new ArrayList<Object>();
    allObjects.add(player);
    for (MapCharacter npc : npcs)
      allObjects.add(npc);
    for (Object o : objects)
      allObjects.add(o);
    //  sort new arraylist
    Collections.sort(allObjects);
    //  draw all objects in newly sorted arraylist
    for (Object o : allObjects) {
      o.drawObject();
      //  o.drawObject(offset);
    }
  }

  //  draw bottom images
  void drawBottom() {
    //  draw bottom images
    for (int i = 0; i < images.size(); i++) {
      MapImage image = images.get(i);
      if (!image.top())
        image.drawMapImage();
    }
  }

  //  draw top images
  void drawTop() {
    //  draw top images
    for (int i = 0; i < images.size (); i++) {
      MapImage image = images.get(i);
      if (image.top()) {
        //  println(image.getImageName());
        image.drawMapImage();
      }
    }
  }

  //  this will be run when an above state is popped and this state becomes the top again
  void resume() {
    //  fadeInSong(getSong("The Old Judge excerpt"), 2000);
  }

  //  returns npcs
  ArrayList<MapCharacter> getNPCs() {
    return npcs;
  }

  //  message (used by cutscenes)
  boolean message(String m) {
    //  split message
    String[] parts = m.split(", ");

    println("receiving message: ", m);

    //  check for a move statement
    if (parts[0].equals("move")) {
      //  get which
      if (parts[1].equals("all")) {
        move(int(parts[2]), int(parts[3]));
        return true;
      }
      //  get individual              //  deal with this later
      else {
        MapCharacter c = null;
        //  check player
        if (parts[1].equals("player"))
          c = player;
        //  go through npcs
        else
          for (MapCharacter npc : npcs)
            if (npc.name.equals(parts[1]))
              c = npc;
        if (c != null) {
          //  move individual
        }
      }
    }
    //  "move to, <character name>, <x>, <y>, <distance multiplier (float)>"
    else if (parts[0].equals("move to")) {
      //  create destination
      PVector dest = new PVector(int(parts[2]), int(parts[3]));
      //  get multiplier
      float mult = 1;
      if (parts.length == 5)
        mult = float(parts[4]);
      //  get which
      MapCharacter c = null;
      //  check player
      if (parts[1].equals("player"))
        c = player;
      //  go through npcs
      else
        for (MapCharacter npc : npcs)
          if (npc.name.equals(parts[1]))
            c = npc;
      if (c != null) {
        //  is close enough
        if (dist(c.pos.x, c.pos.y, dest.x, dest.y) <= mult) {
          //  set character to idle
          c.setIdle();
          //  return true
          return true;
        }
        //  only reachable if not close enough
        //  get direction
        PVector dir = dest.copy().sub(c.pos.copy());
        dir.normalize();
        if (mult != 1)
          dir.mult(mult);

        println("dest:", int(dest.x), int(dest.y), " pos:", int(c.pos.x), int(c.pos.y), " dir:", ceil(abs(dir.x))*dir.x/abs(dir.x), ceil(dir.y), " mult:", mult);
        println("dest:", int(dest.x), int(dest.y), " pos:", int(c.pos.x), int(c.pos.y), " dir:", ceil(abs(dir.x))*int(dir.x/abs(dir.x)), dir.y, " mult:", mult);
        println("dest:", int(dest.x), int(dest.y), " pos:", int(c.pos.x), int(c.pos.y), " dir:", dir.x, dir.y, " mult:", mult);

        //  move
        move(ceil(abs(dir.x))*int(dir.x/abs(dir.x)), ceil(abs(dir.y))*int(dir.y/abs(dir.y)));
        //  check again
        if (dist(c.pos.x, c.pos.y, dest.x, dest.y) <= mult) {
          //  set characters to idle
          c.setIdle();
          //  return true
          return true;
        }
        return false;
      }
    }
    //  left over case
    return false;
  }
}




class MapImage {

  //  basic info
  String name;
  PImage image;
  PVector pos = new PVector();
  PVector size;  //  optional, null by default

  //  top
  boolean top;

  //  location to find (used for saving)
  String file;

  //  default image size
  MapImage(String n, String i, float x, float y, boolean t) {
    name = n;
    file = i;
    image = loadImage(i);
    if (image == null) {
      println("image " + i + " failed to load");
      error(38);
    }
    pos.x = x;
    pos.y = y;
    top = t;
  }

  //  custom image size
  MapImage(String n, String i, float x, float y, float l, float h, boolean t) {
    name = n;
    file = i;
    image = loadImage(i);
    if (image == null) {
      println("image " + i + " failed to load");
      error(38);
    }
    pos.x = x;
    pos.y = y;
    if (l != 0 || h != 0)  //  loaded images may be stored with 0 for these 2 fields if it was null when saved
      size = new PVector(l, h);
    top = t;
  }

  void drawMapImage() {
    //  default size
    println(image == null, pos == null);
    if (size == null)
      image(image, pos.x, pos.y);
    //  custom size
    else
      image(image, pos.x, pos.y, size.x, size.y);
  }

  boolean top() {
    return top;
  }

  String getImageName() {
    return name;
  }
}







//  trigger class
class Trigger {

  String id;            //  id value used for sensors
  String type;          //  "door", "cutscene", "boss", "tutorial", "fight", "shop", "booliale"
  boolean enter;        //  if the enter button is needed to activate
  boolean within;       //  false = just touching hitbox, true = must be completely with hitbox
  boolean remove;       //  true = remove this trigger after activation, false = do not
  boolean[] direction;  //  direction player may be facing to active
  Hitbox hitbox;        //  hitbox for activation
  int value;            //  value for passing (number for map, cutscene, fight, or shop) (for booliales, 0 = false, 1 = true, 2 = switch)

  String nextDoor = "";  //  only used in Door subclass

  //  specific direction constructor with position
  Trigger(String i, String t, boolean e, boolean w, boolean r, boolean[] dir, Hitbox h, int v) {
    createTrigger(i, t, e, w, r, dir, h, v);
  }
  //  any direction constructor with position
  Trigger(String i, String t, boolean e, boolean w, boolean r, Hitbox h, int v) {
    boolean[] dir = {true, true, true, true};
    createTrigger(i, t, e, w, r, dir, h, v);
  }

  //  used to set all trigger values as there are so many constructors
  void createTrigger(String i, String t, boolean e, boolean w, boolean r, boolean[] dir, Hitbox h, int v) {
    id = i;
    type = t;
    enter = e;
    within = w;
    remove = r;
    direction = dir;
    hitbox = h;
    value = v;
  }

  //  checks if the input hitbox activates the trigger
  boolean checkTrigger(Hitbox h) {
    //  check for enter
    if (enter && !input[0])
      return false;
    //  check for direction
    if (!direction[player.direction])
      return false;
    //  check if hitbox is satisfied
    if ((within && within(h, hitbox)) || (!within && overlapping(h, hitbox))) {
      if (enter) {
        if (input[0] && !menuKeysTriggers[0]) {
          menuKeysTriggers[0] = true;
          return true;
        }
        return false;
      }
      return true;
    }
    //  return result
    return false;
  }
}


//  subclass of trigger class for doors
/*  all doors automatically are:
 within = true
 direction = [1, 1, 1, 1]
 enter is false
 remove = false by default, but may be passed to be set to true
 lead to another door (they will be in both the Tiggers list and a seperate Door list and will be selected by their IDs)
 only trigger when within was previously false (will need a global variable "within door" to reconsile this)
 
 the benefit of this system will be that a starting place PVector will no longer be needed as the player will be spawned in the same space as the leaded door proportionally
 */
class Door extends Trigger {

  Door(String i, boolean r, Hitbox h, int v, String vID) {
    super(i, "door", false, true, r, h, v);
    nextDoor = vID;
  }
  Door(String i, Hitbox h, int v, String vID) {
    super(i, "door", false, true, false, h, v);
    nextDoor = vID;
  }
}

//  menu state
class Menu extends State {

  //  tracker for buttons
  int menuTracker = 0;
  //  buttons
  RectButton[] buttons;

  //  mouse tracker
  PVector oldMousePos;

  Menu() {
    oldMousePos = new PVector(mouse.x, mouse.y);
    buttons = new RectButton[0];
  }

  void updateState() {
    //  go between buttons
    //  go up
    if ((input[3] && !menuKeysTriggers[3]) || (input[4] && !menuKeysTriggers[4])) {
      //  take care of triggers
      if (input[3] && !menuKeysTriggers[3])
        menuKeysTriggers[3] = true;
      else if (input[4] && !menuKeysTriggers[4])
        menuKeysTriggers[4] = true;
      //  move up
      if (menuTracker > 0)
        menuTracker--;
      else
        menuTracker = buttons.length - 1;
    }
    //  go down
    else if ((input[5] && !menuKeysTriggers[5]) || (input[6] && !menuKeysTriggers[6])) {
      //  take care of triggers
      if (input[5] && !menuKeysTriggers[5])
        menuKeysTriggers[5] = true;
      else if (input[6] && !menuKeysTriggers[6])
        menuKeysTriggers[6] = true;
      //  move up
      if (menuTracker < buttons.length - 1)
        menuTracker++;
      else
        menuTracker = 0;
    }

    //  mouse control
    if (mouse.x != oldMousePos.x || mouse.y != oldMousePos.y) {
      //  check if on any button
      for (int i = 0; i < buttons.length; i++)
        if (mouseIn(buttons[i].pos, buttons[i].size)) {
          //  set new button
          menuTracker = i;
          //  reset saved mouse position
          oldMousePos = new PVector(mouse.x, mouse.y);
          break;
        }
    }

    //  enter button
    if (input[0] && !menuKeysTriggers[0]) {
      menuKeysTriggers[0] = true;
      activateButton(menuTracker);
    }

    //  click button
    if (mousePressed && !mpress) {
      mpress = true;
      //  check if on any button
      for (int i = 0; i < buttons.length; i++)
        if (mouseIn(buttons[i].pos, buttons[i].size))
          activateButton(i);
    }
  }

  //  activates button at input location
  //  will be used in sub classes as well
  void activateButton(int i) {
    if (i == 0) {
      //  do something
    } else if (i == 0) {
      //  do something else
    }
    //  and so on...
  }

  //  draws the menu
  void drawState() {
    //  this will be different for each menu
    drawMenu();

    //  draw buttons
    for (RectButton b : buttons)
      b.drawButton();
    //  selected button
    buttons[menuTracker].drawButtonNegative();
  }

  //  draws the block of the menu
  //  used in subclasses
  void drawMenu() {
  }

  //  message function
  boolean message(String m) {
    return false;
  }
}
