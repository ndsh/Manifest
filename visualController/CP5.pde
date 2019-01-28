Textlabel stateTitle;
Textlabel stateLabel;
Textlabel frameRateLabel;
Textlabel inputLabel;
CheckBox playCheckbox;
CheckBox offlineCheckbox;
CheckBox rotateCheckbox;


void constructGUI() {
  // change the original colors
  color black = color(0, 0, 0);
  color white = color(0, 0, 255);
  color gray = color(0, 0, 125);
  cp5.setAutoDraw(false);

  cp5.addSlider("sliderBrightness")
    .setRange(0, 255)
    .setPosition(15, 100)
    .setValue(255)
    .setSize(100, 8)
    .setColorValue(black)
    ;
  cp5.addSlider("sliderOptions")
    .setRange(0, 255)
    .setPosition(15, 110)
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

  cp5.addButton("prevDemo")
    .setValue(0)
    .setLabel("prev")
    .setPosition(14, 60)
    .setSize(32, 16)
    ;
  cp5.addButton("nextDemo")
    .setValue(0)
    .setLabel("next")
    .setPosition(50, 60)
    .setSize(32, 16)
    ;


  cp5.setColorForeground(gray);
  cp5.setColorBackground(black);
  //cp5.setColorLabel(0xffdddddd);
  //  cp5.setColorValue(0xffff88ff);
  cp5.setColorActive(white);
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

    image(currentFrame.get(0, 0, currentFrame.width, currentFrame.height), 0, height-120, width/5, height/5);
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
  sliderBrightness = in;
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

public void nextDemo(int theValue) {
  state++;
  if (state > MAX_STATES-1) state = 0;
}

public void prevDemo(int theValue) {
  state--;
  if (state < 0) state = MAX_STATES-1;
}
