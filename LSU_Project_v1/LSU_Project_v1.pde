boolean press = false;
boolean mpress = false;
boolean release = false;  //  refers to mouse
boolean kpress = false;
boolean bpress = false;
boolean spress = false;
boolean epress = false;


//  fullscreen variables
boolean fullScreen = false;          //  fullscreen tracker
boolean fullPress = false;           //  tracker boolean
PVector indent = new PVector(0, 0);  //  screen indent
float screenSize = 0;                //  screen size multiplier
int widthValue = 600;
int heightValue = 600;


//  mouse
boolean drawCursor = true;
PVector mouse = new PVector(0, 0);
boolean refreshCursor = false;  //  this will be used to turn the cursor back on after 1 frame without showing it that frame (used in displayInfo function)


//  booliales
//  ArrayList<Booliale> booliales = new ArrayList<Booliale>();
JSONObject booliales = new JSONObject();


//  inputs
boolean[] input = new boolean[7];
KeySet[] keys = {
  new KeySet('c', 10), 
  new KeySet('x', 16), 
  new KeySet('z', 17), 
  new KeySet('a', 37), 
  new KeySet('w', 38), 
  new KeySet('d', 39), 
  new KeySet('s', 40)};  //  default controls, wasd (a, w, d, s)/arrows with enter = enter/z, cancel = shift/x, and menu = control/c
boolean[] menuKeysTriggers = {false, false, false, false, false, false, false};


//  font
PFont[] fonts;
int[] sizes;
int textSize;  //  tracker for text size



StateStack stateStack = new StateStack();


String playerName = "player";
MapCharacter player;




void setup() {

  size(600, 600);

  frameRate(60);

  widthValue = width;
  heightValue = height;


  //  set up booliales
  setupBooliales();


  //  create fonts
  sizes = new int[100];
  fonts = new PFont[sizes.length];
  for (int i = 0; i < sizes.length; i++) {
    sizes[i] = i+1;
    fonts[i] = createFont("Arial", sizes[i], true);
  }


  //  set all input as false
  for (int i = 0; i < input.length; i++)
    input[i] = false;


  //  player = new Player();


  //  stateStack.addState(new MainMenu());


  stateStack.addState(new Cutscene("test"));
}


void draw() {

  background(255);

  mouse = new PVector(mouseX, mouseY);

  stateStack.run();
}
