int mousePressedLocation = 0;

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      prevDemo(1);
    } else if (keyCode == RIGHT) {
      nextDemo(1);
    } else if (keyCode == UP && state == 11) {
      demo11.prevImage();
    } else if (keyCode == DOWN && state == 11) {
      demo11.nextImage();
    }
  } else {
    if (key == 'r' || key == 'R' ) {
      rotate = !rotate;
      float r[] = {rotate?1f:0f};
      rotateCheckbox.setArrayValue(r);
    } else if (key == 'd' || key == 'D' ) {
      redraw = !redraw;
      float r[] = {redraw?1f:0f};
      redrawCheckbox.setArrayValue(r);
    } else if (key == 'o' || key == 'O' ) {
      offline = !offline;
      float r[] = {offline?1f:0f};
      offlineCheckbox.setArrayValue(r);
    } else if (key == 'i' || key == 'I' ) {
      invert = !invert;
      float r[] = {invert?1f:0f};
      invertCheckbox.setArrayValue(r);
    } else if (key == 's' || key == 'S' ) {
      saveSettings();
    }
    
    
  }
}

PImage transformFrame(PImage s) {
  PGraphics destination;
  destination = createGraphics(720,30);
  destination.beginDraw();
  destination.colorMode(HSB, 360, 100, 255);
  destination.background(0);
  destination.endDraw();
  s.loadPixels();
  float factor = float((s.height-1) / destination.height);
  
  factor = 8.7;
  //factor = 8.6666666666666666666666666667;
  //factor = 9;
  // von zeile 0 zu zeile 1 = 9 pixel
  // 9 * 29 (für zwischenräume) = 261
  
  //int c = 0;
  destination.beginDraw();
  //for(float y = 0; y<s.height; y+=factor) {
  for(float y = 0; y<30; y++) {
      int f = round(y*factor);
      PImage p = s.get(0, f, 720, 1);
      //destination.image(s, 0, c, 720, 1, 0, y, 720, 1);
      destination.image(p, 0, y, 720, 1);
      //println("row" + y + " = " + round(y));
      //c++;
  }
  //println("--");
  //noLoop();
  destination.endDraw();
  
  return destination;
}

void setCurrentFrame(PImage p) {
  PGraphics pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
  if(originX > 0) {
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    //pg.image(p, originX, 0, MANIFEST_WIDTH-originX, MANIFEST_HEIGHT);
    PImage p1 = p.get(originX, 0, MANIFEST_WIDTH-originX, MANIFEST_HEIGHT);
    PImage p2 = p.get(0, 0, originX-1, MANIFEST_HEIGHT);
    //pg.image(p1, MANIFEST_WIDTH-originX, 0, MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.image(p1, 0, 0, MANIFEST_WIDTH-originX, MANIFEST_HEIGHT);
    pg.image(p2, originX-1, 0, originX, MANIFEST_HEIGHT);
    pg.endDraw();
    currentFrame = pg;
  } else currentFrame = p;
}

void transformWrapper() {
  PImage transformed = transformFrame(currentFrame);
  manifest.setFrame(transformed);
  feedFrame(transformed);
}



void dragging() {
  // ist noch ein bisschen schräg programmiert mit dem draggen
  if(mouseX < 200) {
    if(mousePressed) mousePressedLocation = mouseX;
    else mousePressedLocation = -1;
    camera.setLeftDragHandler(null);    
  } else {
    if(mousePressedLocation == -1 && !mousePressed) {
      camera.setLeftDragHandler(camera.getRotateDragHandler());
    }
  }
}

void init_d() {
  if(fileExists("manifest.ini", externalPath, false)) debug = false;
  else if(fileExists("manifest.ini", "", true) && !deployed) debug = false;
  else debug = true;
}

int lightGain(int val) {
  if(debug && random(0, 100) > 80) val = (int)random(0, 255);
  if(invert) val = (int)map(val, 0, 255, 255, 0);
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

int lightGain(float val) {
  if(debug && random(0, 100) > 80) val = (int)random(0, 255);
  if(invert) val = (int)map(val, 0, 255, 255, 0);
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

int lightGain(int h, int s, int b) {
  if(debug && random(0, 100) > 80) b = (int)random(0, 255);
  if(invert) b = (int)map(b, 0, 255, 255, 0);
  int calc = round(map(color(h,s,b), 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

void setupCamera() {
  camera.setMinimumDistance(0);
  camera.setMaximumDistance(1500);
  camera.setDistance(500);
  camera.setYawRotationMode();
  camera.setWheelScale(0.1);
  camera.setResetOnDoubleClick(false);
  camera.setLeftDragHandler(null);  
  camera.setCenterDragHandler(null);  
  camera.setRightDragHandler(null); 
}
void loadRouters(String s) {
  int c = 0;
  JSONArray arr = loadJSONArray(s);
  for(int i = 0; i<arr.size(); i++) {
    JSONObject set = arr.getJSONObject(i);
    boolean active = set.getBoolean("active");
    if(active) {
      routerIPs[c] = set.getString("router0");
      c++;
      routerIPs[c] = set.getString("router1");
      c++;
    }
  }
}
void loadSettings(String s) {
  JSONObject settings = loadJSONObject(s);
  play = settings.getBoolean("play");
  flip = settings.getBoolean("flip");
  offline = settings.getBoolean("offline");
  debug = settings.getBoolean("debug");
  rotate = settings.getBoolean("rotate");
  redraw = settings.getBoolean("redraw"); 
  invert = settings.getBoolean("invert");
  deployed = settings.getBoolean("deployed");
 
  sliderBrightness = settings.getFloat("sliderBrightness");
  tempBrightness = sliderBrightness;
  
  introDuration = settings.getInt("introDuration")*1000;
  introAmount = settings.getInt("introAmount");
  
  originX = settings.getInt("originX");
  MANIFEST_WIDTH = settings.getInt("MANIFEST_WIDTH");
  MANIFEST_HEIGHT = settings.getInt("MANIFEST_HEIGHT");
  state = settings.getInt("state");
  tempState = state;
  
  fileName = settings.getString("fileName");
}
// serialize variables and save them to settings.json on path
void saveSettings() {
  JSONObject json;
  json = new JSONObject();

  json.setBoolean("play", play);
  json.setBoolean("flip", flip);
  json.setBoolean("offline", offline);
  json.setBoolean("debug", debug);
  json.setBoolean("rotate", rotate);
  json.setBoolean("redraw", redraw);
  json.setBoolean("invert", invert);
  json.setBoolean("deployed", deployed);
  
  json.setFloat("sliderBrightness", sliderBrightness);
  
  json.setInt("MANIFEST_WIDTH", MANIFEST_WIDTH);
  json.setInt("MANIFEST_HEIGHT", MANIFEST_HEIGHT);
  json.setInt("state", state);
  json.setInt("originX", originX);
  json.setInt("introAmount", introAmount);
  
  json.setInt("introDuration", (int)introDuration/1000);
  
  json.setString("fileName", fileName);
  json.setString("lastModification", printTime());
  
  if(fileExists("settings.json", externalPath, false)) saveJSONObject(json, externalPath+"settings.json" );
  if(deployed) saveJSONObject(json, "data/settings.json");
  println("saved current settings to file");
}

void movieEvent(Movie m) {
  m.read();
  if(play && (state == NONE || state == INTRO)) {    
    if(introFinished) nextFrame = movie;
    else nextFrame = introMov;
  }
}

String printTime() {
  return day() +"."+ month() +"."+ year() +", "+ hour() +":"+ minute() +":"+ second();
}

boolean fileExists(String filename, String externalPath, boolean internal) {
  File tempFile;
  if(!internal) tempFile = new File(dataPath(externalPath+filename));
  else tempFile = new File(dataPath(externalPath+filename));
  if (tempFile.exists()) return true;
  else return false;
}

void loadIntro() {
  String path = "intros";
  File tempFile = new File(dataPath(externalPath+path));
  File folder;

  if (tempFile.exists()) {
    folder = dataFile(externalPath+path);
   println("\tintros folder: external");
  } else{
    folder = dataFile(path);
   println("\tintros folder: internal");
  }
  println(folder);
  int rIntro = (int)random(0, introAmount-1);
  introMov = new Movie(this, folder+"/"+ rIntro +".mp4");
  introMov.loop();
}
