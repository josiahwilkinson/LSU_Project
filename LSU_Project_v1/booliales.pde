

//  sets up the booliales with their default values (for a new game)
void setupBooliales() {
  booliales = new JSONObject();
  //  absolute
  booliales.setBoolean("true", true);
  booliales.setBoolean("false", false);
  //  relative
  booliales.setBoolean("spare1", false);
  booliales.setBoolean("spare2", false);
  booliales.setBoolean("spare3", false);
  booliales.setBoolean("spare4", false);
  println("booliales created: ", booliales.size());
}


//  gets the booliales of name n
JSONObject getBooliale(String n) {
  println("searching for booliale object: " + n);
  if (booliales.hasKey(n)) {
    println(n + " found");
    return booliales.getJSONObject(n);
  }
  println(n + " NOT found");
  error(18);
  return null;
}

//  sets the boolean of booliales of name n to boolean b
//  This function should ONLY be modifying existing booliales, and so will trigger an error if an unrecognised neam comes through
void setBooliale(String n, boolean b) {

  println("setting booliale", n, "to", b);

  //  check not absolutes
  if (n.equals("true") || n.equals("false")) {
    println("Cannot change value of absolute " + n);
  } else if (booliales.hasKey(n)) {
    println(n + " found");
    booliales.setBoolean(n, b);
  } else {
    println(n + " NOT found");
    error(18);
  }
}

//  gets the boolean value of the booliales by name n
boolean getBoolialeValue(String n) {
  println("searching for booliale value: " + n);
  if (booliales.hasKey(n)) {
    println(n + " found");
    return booliales.getBoolean(n);
  }
  println(n + " NOT found");
  error(18);
  return false;
}


//  load the state of all booliales from the saved file
//  booliales will be passed through as a JSON object
//  for now, assume that it is only passing the booliales from the save file, not the whole thing
void loadBooliales(JSONObject b) {

  b = JSONObject.parse(b.toString());  //  remaking b as a copy
  JSONObject b2 = JSONObject.parse(booliales.toString());  //  making a copy of booliales
  String[] keys = (String[]) b.keys().toArray(new String[b.size()]);  //  keys from save file
  for (int i = 0; i < keys.length; i++) {
    //  check if key is in booliales
    if (booliales.hasKey(keys[i])) {
      setBooliale(keys[i], b.getBoolean(keys[i]));
      b2.remove(keys[i]);  //  remove from booliales copy
    } else {
      println("booliale " + keys[i] + " in save file not found in booliales");
      error(19);
    }
    //  check that all booliales were removed from booliales copy (raise error if not)
    if (b2.size() > 0) {
      println((String[]) b.keys().toArray(new String[b.size()]) + " not found in save file");
      error(19);
    }
    //  otherwise, successful load
    else
      println("save file loaded");
  }
}



//  saving of booliales will be handled in the general save function
