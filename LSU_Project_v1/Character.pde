//  class that allows for Collections.sort(Comparable) used in spell book creation
import java.util.Collections;

//  class for objects on the map
class Object implements Comparable<Object> {

  String name;  //  serves as id

  PVector pos;
  PVector size;

  int speed = 1;

  PImage[][] sprite;

  //  direction the character is facing
  int direction = 0;
  /*
  0 = up
   1 = right
   2 = down
   3 = left
   */

  //  sprite clock
  int spriteCounter = 0;
  int frameCounter = 0;
  int frameTime = 20;  //  10;

  //  storing for saving
  String spriteName = "";
  PVector spriteInfo = new PVector(0, 0, 0);

  //  image offset
  PVector offset;

  //  hitbox
  Hitbox hitbox;

  //  holds the Shape that casts the shadow
  Shadow shadow;


  //  Character super constructor
  Object(String n, int x, int y, int ox, int oy, int l, int h, int sw, int sh) {
    makeObject(n, x, y, ox, oy, l, h, sw, sh);
  }
  //  used by constructor
  void makeObject(String n, int x, int y, int ox, int oy, int l, int h, int sw, int sh) {
    name = n;
    pos = new PVector(x, y);
    size = new PVector(sw, sh);
    offset = new PVector(ox, oy);
    hitbox = new Hitbox(x, y, l, h);
  }

  void setSprite(String s, int sLength, int l, int h) {
    //  save info
    spriteName = s;
    spriteInfo = new PVector(l, h, sLength);

    sprite = new PImage[4][];
    sprite[0] = new PImage[sLength];
    //  set sprite
    PImage psheet = loadImage(s);
    for (int d = 0; d < 4; d++) {
      sprite[d] = new PImage[sLength];
      //  set sprite
      for (int i = 0; i < sLength; i++)
        sprite[d][i] = psheet.get(l*i, h*d, l, h);
    }
  }

  //  attaches a sound to the object (better then having it be a seperate sound object on the map incase the object is moved)
  void setSound() {
    boolean makeFunction;
  }

  //  draws the object (with screen offset)
  void drawObject(PVector screenOffset) {
    //  frame clock
    if (frameCounter >= frameTime) {
      spriteCounter++;
      frameCounter = 0;
    }
    if (spriteCounter >= sprite[0].length)
      spriteCounter = 0;
    frameCounter++;

    //  draw
    image(sprite[direction][spriteCounter], pos.x-offset.x+screenOffset.x, pos.y-offset.y+screenOffset.y);
  }

  //  draws the object
  void drawObject() {
    //  frame clock
    if (frameCounter >= frameTime) {
      spriteCounter++;
      frameCounter = 0;
    }
    if (spriteCounter >= sprite[0].length)
      spriteCounter = 0;
    frameCounter++;

    //  draw
    image(sprite[direction][spriteCounter], pos.x-offset.x, pos.y-offset.y);
  }

  //  sets the object at a new position without changing the sprite
  void setTo(PVector newPos) {
    //  set new position
    pos = newPos;
    hitbox.changePlace(int(pos.x), int(pos.y));
  }

  //  this method makes this class comparable (used for the purpose of sorting)
  //  returns -1 if higher than (and therefore behind of) other character
  //  returns 1 if lower than (and therefore infront of) other character
  public int compareTo(Object other) {
    //  compare using global sorting method
    if (pos.y < other.pos.y) return 1;
    else return -1;
  }
}








//  class for characters on the map
class MapCharacter extends Object {

  //  sprites
  /*
  the character will have a 2d sprite array
   the first dimension will refer to the direction they are facing
   the second direction will refer to the frame of that row
   the draw function will always draw sprite[x][y], with an update function will set sprite to be either equal to idle or walk
   an additional function can be called to set sprite to special
   when sprite is set as special, instead of repeating or switching to idle, it will simply hold the final frame unless/until movement is detected
   */
  PImage[][] idle;
  PImage[][] walk;
  PImage[][] special;

  String specialSpriteName = "";
  PVector specialSpriteInfo = new PVector(0, 0, 0);
  boolean repeatSpecial = false;  //  if set to true, will repeat the special animation; if false, will switch back to the idle animation when finished

  MapCharacter(String n, int x, int y, int ox, int oy, String s, int l, int h, int sl, int sw, int sh) {
    super(n, x, y, ox, oy, l, h, sw, sh);

    setSprite(s, sl, sw, sh);
  }

  //  this will be used for npcs
  MapCharacter(String n, int x, int y, int ox, int oy, String s, int l, int h, int sl, int sw, int sh, int dir) {
    super(n, x, y, ox, oy, l, h, sw, sh);

    direction = dir;

    setSprite(s, sl, sw, sh);
  }

  void setSprite(String s, int sLength, int w, int h) {
    spriteName = s;
    spriteInfo = new PVector(w, h, sLength);
    idle = new PImage[4][];
    walk = new PImage[4][];
    //  get sheet
    PImage psheet = new PImage();//   = loadImage(s);
    psheet = loadImage(s);
    for (int d = 0; d < 4; d++) {
      idle[d] = new PImage[sLength];
      walk[d] = new PImage[sLength];
      //  set sprite
      for (int i = 0; i < sLength; i++) {
        idle[d][i] = psheet.get(w*i, h*d, w, h);
        walk[d][i] = psheet.get(w*i, h*d+h*4, w, h);
        println(d, i, idle[d][i].width);
      }
    }

    //  set sprite to be idle
    sprite = idle;
  }

  //  shorthand for setting normal (idle/walk) sprites (sprite length of  4 is assumed here)
  void setSprite(String s) {
    spriteName = s;
    spriteInfo = new PVector(int(size.x), int(size.y), 4);
    setSprite(s, 4, int(size.x), int(size.y));
  }

  void setSpecialSprite(String s, int sLength, int w, int h) {
    specialSpriteName = s;
    specialSpriteInfo = new PVector(w, h, sLength);
    special = new PImage[4][];
    //  get sheet
    PImage psheet = loadImage(s);
    for (int d = 0; d < 4; d++) {
      special[d] = new PImage[sLength];
      //  set sprite
      for (int i = 0; i < sLength; i++)
        special[d][i] = psheet.get(w*i, h*d, w, h);
    }
  }


  //  draws the character (this function will continue to update the sprite)
  void drawObject(PVector screenOffset) {
    //  frame clock
    if (frameCounter >= frameTime) {
      spriteCounter++;
      frameCounter = 0;
    }
    //  println(direction);
    //  println(sprite[direction].length);
    if (spriteCounter >= sprite[direction].length) {
      spriteCounter = 0;
      if (sprite == special && !repeatSpecial)  //  if sprite is special and NOT to repeat
        setIdle();
    }
    frameCounter++;

    //  draw
    //  println(pos.x, pos.y);
    //  println(direction, spriteCounter);
    image(sprite[direction][spriteCounter], pos.x-offset.x+screenOffset.x, pos.y-offset.y+screenOffset.y);

    //   println(name, pos, pos.x-offset.x+screenOffset.x, pos.y-offset.y+screenOffset.y);
  }
  //  draws the character (this function will continue to update the sprite)
  void drawObject() {
    //  frame clock
    if (frameCounter >= frameTime) {
      spriteCounter++;
      frameCounter = 0;
    }
    //  println(direction);
    //  println(sprite[direction].length);
    //  if (spriteCounter >= sprite[direction].length)
    if (spriteCounter >= 4)
      if (sprite != special)  //  check that it isn't special
        spriteCounter = 0;
    frameCounter++;

    //  draw
    //  println(pos.x, pos.y);
    //  println(direction, spriteCounter);
    image(sprite[direction][spriteCounter], pos.x-offset.x, pos.y-offset.y);
  }


  //  checks the movements for the character
  void moveTo(PVector newPos) {
    //  check that the position has changed
    //  same
    if (newPos.x == pos.x && newPos.y == pos.y) {
      //  set sprite
      if (sprite != idle)
        newSprite(idle);
    }
    //  different
    else {
      //  adjust direction for new step
      adjustDirection(int(newPos.x-pos.x), int(newPos.y-pos.y));

      //  set new position
      pos = newPos;
      hitbox.changePlace(int(pos.x), int(pos.y));

      //  set sprite
      if (sprite != walk)
        newSprite(walk);
    }
  }

  //  sets the sprite to idle
  void setIdle() {
    newSprite(idle);
  }

  //  adjusts the direction according to the input ints
  void adjustDirection(int x, int y) {
    //  set new direction
    boolean[] dirCheck = {false, false, false, false};
    //  going right
    if (x > 0)
      dirCheck[1] = true;
    //  going left
    else if (x < 0)
      dirCheck[3] = true;
    //  going down
    if (y > 0)
      dirCheck[2] = true;
    //  going up
    else if (y < 0)
      dirCheck[0] = true;
    //  check if the current direction is NOT a direction that is in the new direction, and if not, then set a new direction
    if (!dirCheck[direction]) {
      if (dirCheck[0])
        direction = 0;
      else if (dirCheck[2])
        direction = 2;
      else if (dirCheck[1])
        direction = 1;
      else if (dirCheck[3])
        direction = 3;
    }
  }

  //  call to do the special sprite
  void special(boolean repeat) {
    //  set sprite
    newSprite(special);
    repeatSpecial = repeat;
    spriteCounter = 0;
    frameCounter = 0;
  }

  //  sets the input sprite as the new sprite and restarts the sprite clock
  void newSprite(PImage[][] s) { 
    sprite = s;
    spriteCounter = 0;
    frameCounter = 0;
  }

  //  sets the character to be idle
  void beStill() {
    sprite = idle;
  }
}



class Player extends MapCharacter {

  //  temp dummy player
  Player() {
    //  MapCharacter(String n, int x, int y, int ox, int oy, String s, int l, int h, int sl, int sw, int sh) {
    super(playerName, 0, 0, 0, 0, "", 50, 100, 4, 50, 100);
  }
}



class NPC extends MapCharacter {

  //  distance player must be to be able to interact
  int minDist = 75;
  //  cutscene played when they are interacted with
  //  default of "" will cause no cutscene to be triggered (".txt" will automatically be added)
  String cutscene = "";

  NPC(String n, int x, int y, int ox, int oy, String s, int l, int h, int sl, int sw, int sh, int dir) {
    super(n, x, y, ox, oy, s, l, h, sl, sw, sh, dir);
  }
  NPC(String n, int x, int y, int ox, int oy, String s, int l, int h, int sl, int sw, int sh, int dir, String cut) {
    super(n, x, y, ox, oy, s, l, h, sl, sw, sh, dir);
    cutscene = cut;
  }
}

































class Hitbox {

  PVector pos;  //  top left corner
  PVector size;

  Hitbox(PVector p, PVector s) {
    pos = p;
    size = s;
  }

  Hitbox(int x, int y, int l, int h) {
    pos = new PVector(x, y);
    size = new PVector(l, h);
  }

  boolean overlapping(Hitbox other) {
    //  safety check
    if (other == null || other.pos == null)
      return false;
    //  check if its outside possible bounds and return false; else return true
    if (other.pos.x+other.size.x < pos.x || other.pos.x > pos.x+size.x || other.pos.y+other.size.y < pos.y || other.pos.y > pos.y+size.y)
      return false;
    return true;
  }

  void drawHitbox(PVector screenOffset) {
    fill(0, 255, 0, 100);
    rect(pos.x+screenOffset.x, pos.y+screenOffset.y, size.x, size.y);
  }

  void drawHitbox() {
    fill(0, 255, 0, 100);
    rect(pos.x, pos.y, size.x, size.y);
  }

  //  for setting the hitbox in a new place
  void changePlace(int x, int y) {
    //  pos = new PVector(x, y);
    pos.x = x;
    pos.y = y;
  }

  //  for setting the hitbox to a new size by dimensions
  void changeSize(int x, int y) {
    size.x = x;
    size.y = y;
  }

  //  for setting the hitbox to a new size by a factor
  void size(float f) {
    size.x *= f;
    size.y *= f;
  }

  //  to move the player position and hitbox
  void move(PVector m) {
    pos.x += m.x;
    pos.y += m.y;
  }

  //  returns a copy of the Hitbox
  Hitbox copy() {
    return new Hitbox(pos, size);
  }

  //  returns true if the input hitbox is the same position and dimensions as this one
  boolean equals(Hitbox h) {
    return (h.pos.x == pos.x && h.pos.y == pos.y && h.size.x == size.x && h.size.y == h.size.y);
  }

  //  returns a JSONObject of the hitbox
  JSONObject jsonobject() {
    JSONObject hitbox = new JSONObject();
    hitbox.setFloat("posx", pos.x);
    hitbox.setFloat("posy", pos.y);
    hitbox.setFloat("sizex", size.x);
    hitbox.setFloat("sizey", size.y);
    return hitbox;
  }
}

//  returns true if hitboxs are overlapping
boolean overlapping(Hitbox a, Hitbox b) {
  //  safety check
  if (a == null || a.pos == null)
    return false;
  return a.overlapping(b);
}

//  returns true if hitbox a is overlapping with any of the hitboxes b
boolean overlapping(Hitbox[] a, Hitbox b) {
  return overlapping(b, a);
}
//  returns true if hitbox a is overlapping with any of the hitboxes b
boolean overlapping(Hitbox a, Hitbox[] b) {
  //  safety check
  if (a == null || a.pos == null)
    return false;
  boolean overlapping = false;
  for (Hitbox bHitbox : b)
    if (a.overlapping(bHitbox)) {
      overlapping = true;
      break;
    }
  return overlapping;
}
//  returns true if any of the hitboxes a are overlapping with any of the hitboxes b
boolean overlapping(Hitbox[] a, Hitbox[] b) {
  //  safety check
  if (a == null)
    return false;
  boolean overlapping = false;
  for (Hitbox aHitbox : a)
    if (overlapping(aHitbox, b)) {
      overlapping = true;
      break;
    }
  return overlapping;
}

//  returns true if hitbox is overlapping with input circle
boolean overlapping(Hitbox h, PVector pos, float r) {
  return overlapping(h, pos.x, pos.y, r);
}

//  returns true if hitbox is overlapping with input circle
boolean overlapping(Hitbox h, float x, float y, float r) {
  //  safety check
  if (h == null)
    return false;
  //  calculate
  //  return a.overlapping(b);

  //      :                 :
  //   c  :        y        :  c
  //  ....:_________________:....
  //      |                 |
  //      |                 |
  //   x  |                 |  x
  //      |                 |
  //  ....|_________________|....
  //      :                 :
  //   c  :        y        :  c
  //      :                 :


  //  y
  if (x > h.pos.x && x < h.pos.x+h.size.x && y+r/2 > h.pos.y && y-r/2 < h.pos.y+h.size.y)
    return true;

  //  x
  else if (x+r/2 > h.pos.x && x-r/2 < h.pos.x+h.size.x && y > h.pos.y && y < h.pos.y+h.size.y)
    return true;

  //  c
  //  not complete
  else {
    //  find corner
    //    ________
    //    |
    //    |
    //    
    if (dist(x, y, h.pos.x, h.pos.y) <= r/2)
      return true;
    //    ________
    //           |
    //           |
    //    
    else if (dist(x, y, h.pos.x+h.size.x, h.pos.y) <= r/2)
      return true;
    //   |
    //   |
    //   |________
    //    
    else if (dist(x, y, h.pos.x, h.pos.y+h.size.y) <= r/2)
      return true;
    //           |
    //           |
    //    _______|
    //    
    else if (dist(x, y, h.pos.x+h.size.x, h.pos.y+h.size.y) <= r/2)
      return true;
  }

  //  otherwise
  return false;
}


//  returns true if the hitbox a is completely within b
boolean within(Hitbox a, Hitbox b) {
  return (b.pos.x <= a.pos.x && b.pos.y <= a.pos.y && b.pos.x+b.size.x >= a.pos.x+a.size.x && b.pos.y+b.size.y >= a.pos.y+a.size.y);
}

//  returns an array of Hitboxes in place of arrayList
Hitbox[] listToArray(ArrayList<Hitbox> list) {
  Hitbox[] hitboxes = new Hitbox[list.size()];
  for (int i = 0; i < hitboxes.length; i++)
    hitboxes[i] = list.get(i);
  return hitboxes;
}

//  returns a hitbox based on the input JSONObject
Hitbox hitbox(JSONObject j) {
  return new Hitbox(new PVector(j.getFloat("posx"), j.getFloat("posy")), new PVector(j.getFloat("sizex"), j.getFloat("sizey")));
}
