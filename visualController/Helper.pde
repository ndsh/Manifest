int mousePressedLocation = 0;

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
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
  float factor = s.height / destination.height;
  int c = 0;
  destination.beginDraw();
  for(int y = 0; y<s.height; y+=factor) {
      PImage p = s.get(0,y, 720, 1);
      //destination.image(s, 0, c, 720, 1, 0, y, 720, 1);
      destination.image(p, 0, c, 720, 1);
      c++;
  }
  destination.endDraw();
  
  return destination;
}

void transformWrapper() {
  boolean useDifference = false;
  PImage transformed = transformFrame(currentFrame);
  manifest.setFrame(transformed);
  if(useDifference) {
    PImage prev = createImage(MANIFEST_WIDTH, MANIFEST_HEIGHT, RGB); // falls differenz nicht gebraucht wird

    // routine um differenz pixel ausfindig zu machen
    if(previousFrame != null) {
      prev = transformFrame(previousFrame);
      prev.loadPixels();
      transformed.loadPixels();
      updatedPixels = new boolean[30][720];
      updatedRows = new boolean[30];
      
      int count = 0;
      changedPixels = false;
      for(int y = 0; y<transformed.height; y++) {
        for(int x = 0; x<transformed.width; x++) {
          color c1 = transformed.pixels[y*transformed.width+x];
          color c2 = prev.pixels[y*transformed.width+x];
          if (!isSame(c1, c2)) {
            if(!changedPixels) changedPixels = true;
            updatedPixels[y][x] = true;
            updatedRows[y] = true;
            count++;
          }
        }
      }
      //println("hallo" + updatedRows.size() + " : "+ updatedRows);
      //println("---");
      //println(count); // how many pixels have changed inbetween the previous and current framesx
    }
    
  }  
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
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

int lightGain(float val) {
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

int lightGain(int h, int s, int b) {
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
 
  sliderBrightness = settings.getFloat("sliderBrightness");
  
  MANIFEST_WIDTH = settings.getInt("MANIFEST_WIDTH");
  MANIFEST_HEIGHT = settings.getInt("MANIFEST_HEIGHT");

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


void getMovieFrame() {
  if(movie.available()) {
    movie.read();
    if(play && state == NONE) currentFrame = movie;
  }
}


void movieEvent(Movie m) {
  m.read();
  if(play && state == NONE) {    
    currentFrame = movie;
  }
}
