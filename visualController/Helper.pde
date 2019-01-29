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
  
  int factor = s.height / destination.height;
  int c = 0;
  destination.beginDraw();
  for(int y = 0; y<s.height; y+=factor) {
      PImage p = s.get(0,y, 720, 1);
      destination.image(s, 0, c, 720, 1, 0, y, 720, 1);
      //image(s, 0, c, 720, 1, 0, y, 720, 1);
      destination.image(p, 0, c, 720, 1);
      
      c++;
  }
  destination.endDraw();
  
  return destination;
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
  return (int)map(val, 0, 255, 0, (int)sliderBrightness );
}

int lightGain(float val) {
  return (int)map(val, 0, 255, 0, (int)sliderBrightness );
}

int lightGain(int h, int s, int b) {
  return (int)map(color(h,s,b), 0, 255, 0, (int)sliderBrightness );
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
  sliderBrightness = settings.getFloat("sliderBrightness");
  MANIFEST_WIDTH = settings.getInt("MANIFEST_WIDTH");
  MANIFEST_HEIGHT = settings.getInt("MANIFEST_HEIGHT");

}
