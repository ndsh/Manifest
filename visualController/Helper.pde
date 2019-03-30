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
    } else if (key == 'd') {
      draw = !draw;
    } else if (key == 'D' ) {
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
    } else if (key == 'f' || key == 'F' ) {
      println("frameRate: "+frameRate);
    } else if (key == 's' || key == 'S' ) {
      saveSettings();
    }
    
    
  }
}

PImage transformFrame(PImage s) {
  PImage destination = createImage(720, 30, ALPHA);
  /*
  destination = createGraphics(720,30);
  
  destination.beginDraw();
  destination.colorMode(HSB, 360, 100, 255);
  destination.background(0);
  destination.endDraw();
  destination.loadPixels();
  s.loadPixels();
  */
  
  //int c = 0;
  //destination.beginDraw();
  //for(float y = 0; y<s.height; y+=factor) {
  for(int y = 0; y<destination.height && y*linePixelPitch < s.height; y++) {
      int f = y*linePixelPitch;
      arrayCopy(s.pixels, f*s.width, destination.pixels, y*destination.width, s.width);
  }
  
  //destination.endDraw();
  destination.updatePixels();
  return destination;
}

void setCurrentFrame(PImage p) {
  
  if(originX > 0 && originX < MANIFEST_WIDTH) {
    PImage pg = createImage(MANIFEST_WIDTH, MANIFEST_HEIGHT, ALPHA);
    p.loadPixels();
    int cut = MANIFEST_WIDTH-originX < p.width ? MANIFEST_WIDTH-originX : p.width;
    for (int i=0; i<p.height; i++) {
      arrayCopy(p.pixels, i*p.width, pg.pixels, originX+i*pg.width, cut);
      if (cut < p.width) arrayCopy(p.pixels, i*p.width+cut, pg.pixels, i*pg.width, p.width-cut);
    }
    pg.updatePixels();
    currentFrame = pg;
  } else currentFrame = p;
}

void transformWrapper() {
  PImage transformed = linePixelPitch > 0 ? transformFrame(currentFrame) : currentFrame;
  if (draw && redraw) manifest.setFrame(transformed);
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
  //print("invert "+invert+": "+val);
  if(invert) val = (int)map(val, 0, 255, 255, 0);
  //print(", "+val);
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //println(", "+calc);
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
  draw = settings.getBoolean("draw"); 
  redraw = settings.getBoolean("redraw"); 
  invert = settings.getBoolean("invert");
  deployed = settings.getBoolean("deployed");
 
  sliderBrightness = settings.getFloat("sliderBrightness");
  tempBrightness = sliderBrightness;
  
  introDuration = settings.getInt("introDuration")*1000;
  introAmount = settings.getInt("introAmount");
  theFrameRate = settings.getInt("frameRate");
  //frameRate(theFrameRate);
  tempFrameRate = theFrameRate;
  frameDelta = theFrameRate == 0 ? 0 : 1000.0 / theFrameRate;
  
  originX = settings.getInt("originX");
  MANIFEST_WIDTH = settings.getInt("MANIFEST_WIDTH");
  MANIFEST_HEIGHT = settings.getInt("MANIFEST_HEIGHT");
  linePixelPitch = settings.getInt("linePixelPitch");
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
  json.setBoolean("draw", draw);
  json.setBoolean("redraw", redraw);
  json.setBoolean("invert", invert);
  json.setBoolean("deployed", deployed);
  
  json.setFloat("sliderBrightness", sliderBrightness);
  
  json.setInt("MANIFEST_WIDTH", MANIFEST_WIDTH);
  json.setInt("MANIFEST_HEIGHT", MANIFEST_HEIGHT);
  json.setInt("linePixelPitch", linePixelPitch);
  json.setInt("state", state);
  json.setInt("originX", originX);
  json.setInt("introAmount", introAmount);
  json.setInt("frameRate", theFrameRate);
  
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
