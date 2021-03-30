//  State Stack class that operates the stack
class StateStack {

  //  points to the bottom of the stack
  State bottom = null;
  //  points to the top of the stack
  State top = null;

  StateStack() {
  }

  void addState(State s) {
    //  check if stack is empty (has no bottom)
    if (bottom == null) {
      //  sets both top and bottom as s
      bottom = s;
      top = s;
    } else {
      //  replaces the top
      top.setNext(s);
      top = s;
    }
  }

  //  adds input state just under current state
  void addStateSecond(State s) {
    //  check if stack is empty (has no bottom)
    if (bottom == null) {
      //  sets both top and bottom as s
      bottom = s;
      top = s;
    } else {
      //  pops and stores the top
      State t = pop();
      //  adds new state
      addState(s);
      //  adds top back on
      addState(t);
    }
  }

  //  runs all states by drawing all from the tail up and updating only the head
  void run() {
    //  checks that there are states to draw (doing this a second is necessary due to if the base state is removed in updateState, it will cause a crash
    if (bottom != null) {
      //  draw all states from the bottom up
      State tracker = bottom;
      while (tracker != null) {
        //  println("Here");
        //  println(top == bottom);
        //  draw state
        tracker.superDrawState();
        //  move on
        tracker = tracker.getNext();
      }
      //  checks that there is a state to run
      if (bottom != null) {
        //  update top state
        top.superUpdateState();
      }
    }
    /*
    //  trace
     println();
     trace();
     println();
     */
  }

  //  returns top state from stack (without removing it)
  State peek() {
    return top;
    //  yep, pretty simple
  }
  //  returns second top state from stack (without removing it)
  State peekSecond() {
    State s = pop();
    State temp = peek();
    addState(s);
    return temp;
  }

  //  removes top state from stack and returns it
  State pop() {
    //  checks the number of states
    //  empty stack
    if (bottom == null)
      return null;
    //  single member of stack
    else if (bottom == top) {
      State s = top;
      top = null;
      bottom = null;
      return s;
    }
    //  more than 1 state
    else {
      //  reference top state
      State s = top;
      //  remove by getting to the state directly under it
      State tracker = bottom;
      while (tracker.getNext() != top)
        tracker = tracker.getNext();
      tracker.setNext(null);  //  replace it's next with null
      top = tracker;
      //  run resume() incase any is needed
      top.resume();
      //  return old top state
      return s;
    }
  }

  //  removes top state from stack if is it the input state
  void pop(State s) {
    //  checks that s isn't null and that it is the top state
    if (s != null && s == top) {
      //  remove it
      pop();
    }
  }

  //  removes the state below the top
  State popSecond() {
    State s = pop();
    State s2 = pop();
    addState(s);
    return s2;
  }

  //  sends a message to the top state
  boolean message(String m) {
    return top.message(m);
  }

  //  sends a message to the state directly under the top
  boolean messageNext(String m) {
    //  get state directly under it
    State tracker = bottom;
    while (tracker.getNext() != top)
      tracker = tracker.getNext();
    //  tracker now equals state under top
    return tracker.message(m);
  }

  //  prints trace of all states from bottom up
  void trace() {
    State s = bottom;
    while (s != null) {
      print(s.getClass().getName() + ", ");
      s = s.getNext();
    }
    println();
  }

  //  replaces the first found map state (there should only be one) with the input map state
  void replaceMap(Map m) {
    State s = bottom;
    while (s != null) {
      //  get Map state
      //  String[] stateNameParts = s.getClass().getName().split("$");    //  needed because getClass().getName() will give "<program name>$<class name>" and we just want the class name
      //  ^ didn't split for some reason ^
      String portion = s.getClass().getName().substring(s.getClass().getName().length()-3);
      if (portion.equals("Map")) {
        //  get state below
        if (s == bottom) {
          bottom = m;
        } else {
          State s2 = bottom;
          while (s2.getNext() != s)
            s2 = s2.getNext();
          s2.setNext(m);           //  set next for lower state
        }
        m.setNext(s.getNext());  //  set next for m
        //  s is now dropped
        return;                  //  exit
      }
      s = s.getNext();
    }
  }

  //  returns the first found map state (for saving purposes)
  Map getMap() {
    State s = bottom;
    while (s != null) {
      //  get Map state
      //  String[] stateNameParts = s.getClass().getName().split("$");    //  needed because getClass().getName() will give "<program name>$<class name>" and we just want the class name
      //  ^ didn't split for some reason ^
      //  String portion = s.getClass().getName().substring(s.getClass().getName().length()-3);
      //  if (portion.equals("Map"))
      if (s instanceof Map)
        return s.mapVersion();
      s = s.getNext();
    }
    return null;
  }

  //  creates an instance of the Display class (found at bottom of Fight tab)
  void display(String t, int d, float s, float x, float y) {
    top.display(t, d, s, x, y);
  }
}




//  parent class of all states
class State {

  //  the next State in the stack
  State next;

  //  arrayList of current display notifications
  ArrayList<Display> displays = new ArrayList<Display>();

  //  dummy constructor
  State() {
  }

  //  draws the state
  void drawState() {
    error(10);
  }
  void superDrawState() {
    //  draw regular
    drawState();
    //  draw displays
    for (int i = 0; i < displays.size(); i++)
      displays.get(i).drawDisplay();
  }

  //  updates the state
  void updateState() {
    error(11);
  }
  void superUpdateState() {
    //  draw regular
    updateState();
    //  draw displays
    for (int i = 0; i < displays.size(); i++)
      displays.get(i).updateDisplay();
  }

  //  this will be run when an above state is popped and this state becomes the top again
  //  this may be used by state subclasses to perhaps unpause or switch back changed music
  void resume() {
    //  empty
  }

  //  sets input State as next
  void setNext(State s) {
    next = s;
  }

  //  gets the next State in the stack
  State getNext() {
    return next;
  }

  //  receives a message
  boolean message(String m) {
    return false;
  }


  //  alternate to Map function (returns null here)
  ArrayList<MapCharacter> getNPCs() {
    return null;
  }

  //  alternative to Map function (used for saving)
  int id() {
    return 0;
  }

  //  overriden in Map to get Map from the stack rather than State
  Map mapVersion() {
    println("This should never be called");
    error(35);
    return null;
  }



  //  display stuff

  //  creates an instance of the Display class (found at bottom of Fight tab)
  void display(String t, int d, float s, float x, float y) {
    println("display:");
    println(t);

    PVector p = new PVector(x, y);
    //  add display
    displays.add(new Display(t, d, s, p));
  }


  //  a small class that shows a display for a time then is deleted
  class Display {

    //  text
    String text;
    float size;
    PVector pos;

    //  clock
    int duration;

    //  create
    Display(String t, int d, float s, PVector p) {
      text = t;
      duration = d;
      size = s;
      pos = p;

      println("new display: " + pos, size, text, duration);
    }

    void updateDisplay() {
      //  clock
      duration--;
      if (duration <= 0)
        deleteDisplay(this);
    }

    void drawDisplay() {
      //  random offset
      int offX = int(random(4));
      int offY = int(random(4));

      //  display
      setTextSize(size);
      fill(0);
      text(text, (pos.x + offX-2), (pos.y + offY-2));
    }
  }

  //  removes the input display from displays from state
  void deleteDisplay(Display d) {
    displays.remove(d);
  }
}
