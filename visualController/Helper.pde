int mousePressedLocation = 0;

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      prevDemo(1);
    } else if (keyCode == RIGHT) {
      nextDemo(1);
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

int lightGain(int val) {
  if(invert) val = (int)map(val, 0, 255, 255, 0);
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

int lightGain(float val) {
  if(invert) val = (int)map(val, 0, 255, 255, 0);
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

int lightGain(int h, int s, int b) {
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

void loadSettings(String s) {
  JSONObject settings = loadJSONObject(s);
  play = settings.getBoolean("play");
  flip = settings.getBoolean("flip");
  offline = settings.getBoolean("offline");
  debug = settings.getBoolean("debug");
  rotate = settings.getBoolean("rotate");
  redraw = settings.getBoolean("redraw"); 
  invert = settings.getBoolean("invert");
 
  sliderBrightness = settings.getFloat("sliderBrightness");
  tempBrightness = sliderBrightness;
  
  introDuration = settings.getInt("introDuration")*1000;
  
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
  
  json.setFloat("sliderBrightness", sliderBrightness);
  
  json.setInt("MANIFEST_WIDTH", MANIFEST_WIDTH);
  json.setInt("MANIFEST_HEIGHT", MANIFEST_HEIGHT);
  json.setInt("state", state);
  json.setInt("originX", originX);
  
  json.setInt("introDuration", (int)introDuration/1000);
  
  json.setString("fileName", fileName);
  json.setString("lastModification", printTime());
  
  if(fileExists("settings.json", externalPath, false)) saveJSONObject(json, externalPath+"settings.json" );
  // folgende zeile später auskommentieren weil system dann nur noch read-only ist. eventuell wirft das fehler
  saveJSONObject(json, "data/settings.json");
  println("saved current settings to file");
}

int getLogGamma(int in) {
  return gamma8[in]; 
}
int gamma8[] = {
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,
    1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,
    2,  3,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  5,  5,  5,
    5,  6,  6,  6,  6,  7,  7,  7,  7,  8,  8,  8,  9,  9,  9, 10,
   10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16,
   17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25,
   25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36,
   37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50,
   51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68,
   69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89,
   90, 92, 93, 95, 96, 98, 99,101,102,104,105,107,109,110,112,114,
  115,117,119,120,122,124,126,127,129,131,133,135,137,138,140,142,
  144,146,148,150,152,154,156,158,160,162,164,167,169,171,173,175,
  177,180,182,184,186,189,191,193,196,198,200,203,205,208,210,213,
  215,218,220,223,225,228,231,233,236,239,241,244,247,249,252,255
};

boolean isSame(color c1, color c2) {
  float r1 = c1 >> 16 & 0xFF;
  float b1 = c1 & 0xFF;
  float g1 = c1 >> 8 & 0xFF;
  
 
  float r2 = c2 >> 16 & 0xFF;
  float b2 = c1 & 0xFF;
  float g2 = c2 >> 8 & 0xFF;
 
  return r1 == r2 && b1 ==b2 && g1 == g2;
}


void movieEvent(Movie m) {
  m.read();
  if(play && (state == NONE || state == INTRO)) {    
    if(introFinished) nextFrame = movie; // setCurrentFrame(m);
    else nextFrame = introMov; //setCurrentFrame(m);
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
