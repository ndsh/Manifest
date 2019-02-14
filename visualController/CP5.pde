Textlabel stateTitle;
Textlabel stateLabel;
Textlabel frameRateLabel;
Textlabel inputLabel;
Textlabel brightnessInPercLabel;
CheckBox playCheckbox;
CheckBox offlineCheckbox;
CheckBox rotateCheckbox;
CheckBox redrawCheckbox;
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
  cp5.addSlider("sliderOptions")
    .setRange(0, 100)
    .setPosition(15, 130)
    .setValue(255)
    .setSize(100, 8)
    .setColorValue(black)
    ;
  cp5.addSlider("sliderOptions2")
    .setRange(0, 100)
    .setPosition(15, 140)
    .setValue(255)
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
  cp5.addButton("prevDemo")
    .setValue(0)
    .setLabel("prev")
    .setPosition(14, 70)
    .setSize(32, 16)
    ;
  cp5.addButton("nextDemo")
    .setValue(0)
    .setLabel("next")
    .setPosition(50, 70)
    .setSize(32, 16)
    ;
    
  cp5.addScrollableList("images")
     .setPosition(14, 160)
     .setSize(160, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .setType(ControlP5.DROPDOWN)
     
     //.addItems(l)
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
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
  println(sliderBrightness);
  cp5.getController("sliderBrightness").setValue(sliderBrightness);

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

  if (currentFrame!= null) {
    pushStyle();
    stroke(0);
    //image(currentFrame.get(0, 0, currentFrame.width, currentFrame.height), 0, height-120, width/8, height/8);
    float f = 3.6; // currentFrame.with / 200 pixel breite vom menü

    image(currentFrame.get(0, 0, currentFrame.width, currentFrame.height), 0, height-120, currentFrame.width/f, currentFrame.height/f);
    popStyle();
  }
  cp5.draw();

  // source material
  //image(movie.get(0,0, 320, 300), 0, 0);
  //image(movie.get(320,0, 40, 300), 0, 0);
  //image(movie.get(360,0, 320, 300), 0, 0);
  //image(movie.get(680,0, 40, 300), 0, 0);


  camera.endHUD();
}

void sliderBrightness(int in) {
  float br = map(in, 0, 255, 0, 100);
  sliderBrightness = in;
  brightnessInPercLabel.setText("BRIGHTNESS: "+ round(br) +"%");
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

void images(int n) {
  String s = (String)cp5.get(ScrollableList.class, "images").getItem(n).get("text");
  // check if this is a valid image?
  if(s.length() > 0) demo11.setImage(s);
  else println("[#] ERROR : the image is not valid. string size is low or equal than 0");
}

void checkImageDropdown() {
  if(state == 11) cp5.get(ScrollableList.class, "images").show();
  else cp5.get(ScrollableList.class, "images").hide();
}
