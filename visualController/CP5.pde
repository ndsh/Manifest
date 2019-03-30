Textlabel stateTitle;
Textlabel stateLabel;
Textlabel frameRateLabel;
Textlabel inputLabel;
Textlabel brightnessInPercLabel;
CheckBox playCheckbox;
CheckBox offlineCheckbox;
CheckBox rotateCheckbox;
CheckBox redrawCheckbox;
CheckBox invertCheckbox;
ScrollableList imageList;


void constructGUI() {
  // change the original colors
  color black = color(0, 0, 0);
  color white = color(0, 0, 255);
  color gray = color(0, 0, 125);
  cp5.setAutoDraw(false);

  cp5.addSlider("sliderBrightness")
    .setRange(0, 255)
    .setPosition(15, 110)
    .setValue(255)
    .setSize(100, 8)
    .setColorValue(black)
    ;
  cp5.addSlider("rotationSpeed")
    .setRange(0, 0.05)
    .setPosition(15, 120)
    .setValue(0.01)
    .setSize(100, 8)
    .setColorValue(black)
    ;
  cp5.addSlider("theFrameRate")
    .setRange(0, 100)
    .setPosition(15, 130)
    .setValue(theFrameRate)
    .setSize(100, 8)
    .setColorValue(black)
    ;
  cp5.addSlider("linePixelPitch")
    .setRange(0, 10)
    .setPosition(15, 140)
    .setValue(linePixelPitch)
    .setSize(100, 8)
    .setColorValue(black)
    ;
  cp5.addSlider("sliderOptions3")
    .setRange(0, 128)
    .setPosition(15, 150)
    .setValue(128)
    .setSize(100, 8)
    .setColorValue(black)
    ;
    cp5.addSlider("sliderOptions4")
    .setRange(0, 128)
    .setPosition(15, 160)
    .setValue(128)
    .setSize(100, 8)
    .setColorValue(black)
    ;
    
  stateTitle = cp5.addTextlabel("label1")
    .setText("Current state: ")
    .setPosition(10, 10)
    ;
  stateLabel = cp5.addTextlabel("label2")
    .setText("A single ControlP5 textlabel")
    .setPosition(70, 10)
    .setColorValue(0xffffff00)
    ;
  frameRateLabel = cp5.addTextlabel("label3")
    .setText("frameRate")
    .setPosition(10, 20)
    ;
  inputLabel = cp5.addTextlabel("label4")
    .setText("2D TEXTURE VIEW")
    .setPosition(10, height-140)
    ;
    
  brightnessInPercLabel = cp5.addTextlabel("label5")
    .setText("BRIGHTNESS: %")
    .setPosition(12, 100)
    ;



  playCheckbox = cp5.addCheckBox("playCheckbox")
    .setPosition(14, 30)
    .setSize(32, 8)
    .addItem("play", 1)
    ;
  offlineCheckbox = cp5.addCheckBox("offlineCheckbox")
    .setPosition(14, 40)
    .setSize(32, 8)
    .addItem("offline", 1)
    ;
  rotateCheckbox = cp5.addCheckBox("rotateCheckbox")
    .setPosition(14, 50)
    .setSize(32, 8)
    .addItem("rotate", 1)
    ;
  redrawCheckbox = cp5.addCheckBox("redrawCheckbox")
    .setPosition(14, 60)
    .setSize(32, 8)
    .addItem("redraw", 1)
    ;
  invertCheckbox = cp5.addCheckBox("invertCheckbox")
    .setPosition(14, 70)
    .setSize(32, 8)
    .addItem("invert", 1)
    ;
  cp5.addButton("prevDemo")
    .setValue(0)
    .setLabel("prev")
    .setPosition(14, 80)
    .setSize(32, 16)
    ;
  cp5.addButton("nextDemo")
    .setValue(0)
    .setLabel("next")
    .setPosition(50, 80)
    .setSize(32, 16)
    ;
    
  imageList = cp5.addScrollableList("imageList")
     .setPosition(14, 190)
     .setSize(160, 400)
     .setBarHeight(20)
     .setItemHeight(20)
     .setType(ControlP5.LIST)
     ;

  checkImageDropdown();
  cp5.setColorForeground(gray);
  cp5.setColorBackground(black);
  cp5.setColorActive(white);
  
  // settings.json werte einpassen
  // checkboxes
  float[] y = {1f};
  float[] n = {0f};
  
  playCheckbox.setArrayValue((play?y:n));
  offlineCheckbox.setArrayValue((offline?y:n));
  rotateCheckbox.setArrayValue((rotate?y:n));
  redrawCheckbox.setArrayValue((redraw?y:n));
  
  cp5.getController("sliderBrightness").setValue(tempBrightness);
  cp5.getController("theFrameRate").setValue(tempFrameRate);
  cp5.getController("linePixelPitch").setValue(linePixelPitch);
}

void updateGUI() {
  if (!(stateLabel.getStringValue().equals(getStateName(state)))) stateLabel.setText(getStateName(state));
  frameRateLabel.setText("Framerate: "+ frameRate);
}

void drawGUI() {
  camera.beginHUD();
  pushStyle();
  fill(0, 50);
  noStroke();
  rect(0, 0, 200, height);
  popStyle();
  
  image(marke, width-120, height-40);

  // 2d texture preview
  if (currentFrame!= null) {
    float f = 3.6; // currentFrame.with / 200 pixel breite vom menü
    pushStyle();
    stroke(0);
    //if(previousFrame != null) image(previousFrame.get(0, 0, previousFrame.width, previousFrame.height), 0, height-220, previousFrame.width/f, previousFrame.height/f);
    image(currentFrame.get(0, 0, currentFrame.width, currentFrame.height), 0, height-120, currentFrame.width/f, currentFrame.height/f);
    popStyle();
  }
  cp5.draw();
  camera.endHUD();
}

void sliderBrightness(int in) {
  float br = map(in, 0, 255, 0, 100);
  sliderBrightness = in;
  if(brightnessInPercLabel != null) brightnessInPercLabel.setText("BRIGHTNESS: "+ round(br) +"%");
}

void theFrameRate(int in) {
  theFrameRate = in;
  frameDelta = theFrameRate == 0 ? 0 : 1000.0 / theFrameRate;
  println("set theFrameRate: "+theFrameRate);
}

void playCheckbox(float[] a) {
  if (a[0] == 1f) play = true;
  else play = false;
}

void offlineCheckbox(float[] a) {
  if (a[0] == 1f) offline = true;
  else offline = false;
}
 
void rotateCheckbox(float[] a) {
  if (a[0] == 1f) rotate = true;
  else rotate = false;
}

void redrawCheckbox(float[] a) {
  if (a[0] == 1f) redraw = true;
  else redraw = false;
}

void nextDemo(int theValue) {
  state++;
  if (state > MAX_STATES-1) state = 0;
  checkImageDropdown();
}

void prevDemo(int theValue) {
  state--;
  if (state < 0) state = MAX_STATES-1;
  checkImageDropdown();
}

void imageList(int n) {
  String s = (String)cp5.get(ScrollableList.class, "imageList").getItem(n).get("text");
  // check if this is a valid image?
  if(s.length() > 0) demo11.setImage(s);
  else println("[#] ERROR : the image is not valid. string size is low or equal than 0");
}

void checkImageDropdown() {
  if(imageList != null) {
    if(state == 11) cp5.get(ScrollableList.class, "imageList").show();
    else cp5.get(ScrollableList.class, "imageList").hide();
  }
}
