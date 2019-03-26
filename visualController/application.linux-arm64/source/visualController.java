import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import peasy.*; 
import ch.bildspur.artnet.*; 
import controlP5.*; 
import processing.sound.*; 
import java.util.*; 
import processing.video.*; 
import hypermedia.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class visualController extends PApplet {

// Zeilenabstand am Muster von Unterkante zu Oberkante: 4 Profile + 0,9cm = 8,1cm






// linux video
//import gohai.glvideo.*;
//GLMovie movie;

// osx video

Movie movie;
Movie introMov;

PeasyCam camera;
ControlP5 cp5; 

Manifest manifest;
// declare all routers
ArrayList<Pixelrouter> routers = new ArrayList<Pixelrouter>();
String[] routerIPs = {  // A/C + B/D router = 4 rows of LEDs
//  "2.12.4.83", "2.161.30.223", // prototyping routers

  "2.12.4.124", "2.161.30.223", // prototyping routers + leihrouter
  "2.12.4.155", "2.12.4.156", // prototyping routers + leihrouter

//  "2.12.4.114", "2.12.4.111", // Zeilen: 0 – 3
//  "2.12.4.112", "2.12.4.118", // Zeilen: 4 – 7
  "2.12.4.121", "2.12.4.122", // Zeilen: 8 – 11
  "2.12.4.110", "2.12.4.116", // Zeilen: 12 – 15
  "2.12.4.83",  "2.12.4.117", // Zeilen: 16 – 19
  
  "2.12.4.123", "2.12.4.119", // Zeilen: 20 – 23
  "2.12.4.115", "2.12.4.120", // Zeilen: 24 – 27
  "2.12.4.113", "0.0.0.0"  // Zeilen: 28 - 29
  
  //"2.12.4.114", "2.12.4.118", // prototyping routers
  
};

// declare all rows
ArrayList<LEDRow> rows = new ArrayList<LEDRow>();
int totalRows = 30;


int bg = color(50);
int object = color(40);

// runtime / volatile variables
PImage currentFrame;
PImage nextFrame;
PImage marke;
boolean play = true;
boolean flip = true;
boolean offline = true;
boolean debug = false;
boolean rotate = false;
boolean redraw = true;
boolean invert = true;
boolean externalSettings = false;
float sliderBrightness = 255;
float tempBrightness = 0;
int state = 11;
int tempState = 0;
String fileName = "";
int sliderOptions = 0;
int sliderOptions2 = 0;
int sliderOptions3 = 0;
int sliderOptions4 = 0;

int originX = 0;

boolean introFinished = false;
long introDuration = 0;
long introPrevMillis = 0;

float rotationSpeed = 0.001f;

// put correct path to extern settings file here. it should be auto-mounted. if not found there is a fall back
// on mac
//String externalPath = "/Volumes/INHALTE/";
String externalPath = "/media/thegreeneyl/INHALTE/";

// we want to keep tabs on updated pixels so that later on we only send out
// the updated universes! O P T I M I T A Z A T I O N
boolean changedPixels = false;
boolean[][] updatedPixels = new boolean[30][720];
boolean[] updatedRows = new boolean[30]; // oder als arraylist?

// DEFINE SOURCE DIMENSIONS
int MANIFEST_WIDTH = 720;
int MANIFEST_HEIGHT = 261;

AudioIn input;
Amplitude loudness;

final String OS = platformNames[platform];
String mainMovieFilePath = "";

public void setup() {
  
  colorMode(HSB, 360, 100, 255);
  
  
  if(OS.equals("macosx")) externalPath = "/Volumes/INHALTE/";
  else externalPath = "/media/thegreeneyl/INHALTE/";
  
  if(fileExists("settings.json", externalPath, false)) {
   loadSettings(externalPath+"settings.json");
   mainMovieFilePath = externalPath+"content/"+fileName;
   externalSettings = true;
   println("[success] loaded settings.json from external");
  } else{
   loadSettings("data/settings.json");
   mainMovieFilePath = "demos/"+fileName;
   println("[fail] loaded settings.json from internal");
  }
  
  manifest = new Manifest(object);

  camera = new PeasyCam(this, 100);
  setupCamera();  
  
  cp5 = new ControlP5(this);
  constructGUI();
  state = tempState;
  
  initUDP();

  if(!externalSettings && !fileExists(fileName, "demos/", true)) {
    println("[error] the following file from internal settings couldn't be loaded from /data folder: " + fileName);
    println("[warning] the sketch will close now");
  } else if(externalSettings && !fileExists(fileName, externalPath, false)) {
    println("[error] the following file from external settings couldn't be loaded from external media: " + fileName);
    println("[warning] the sketch will close now");
  }
  int rIntro = (int)random(0, 5);
  introMov = new Movie(this, "intros/"+ rIntro +".mp4");
  introMov.loop();
  
  movie = new Movie(this, mainMovieFilePath);
  movie.loop();
  
  createDemos();
  nextFrame = createImage(MANIFEST_WIDTH, MANIFEST_HEIGHT, RGB);
  
  // let's add some routers and led rows
  // - - - - - - - - - - - - - - - - - - - - - -
  for(int i = 0; i<routerIPs.length; i++) {
    routers.add(new Pixelrouter(routerIPs[i]));
  }
  
  int currentRouter = 0;
  int counter = 0;
  for(int i = 0; i<totalRows; i++) {
    rows.add(new LEDRow(i, routers.get(currentRouter), routers.get(currentRouter+1)));
    counter++;
    if(counter > 3)  {
      counter = 0;
      currentRouter += 2;
    }
  }
  // - - - - - - - - - - - - - - - - - - - - - -
  marke = loadImage("tge.png");
  introPrevMillis = millis();
}

public void draw() {
  background(bg);
  dragging();
  if(!introFinished) {
    state = 0;
    if(millis() - introPrevMillis < introDuration) {
      if(play && nextFrame != null) {
        setCurrentFrame(nextFrame);
        transformWrapper();
      }
    } else {
      introMov.noLoop();
      introFinished = true;       
    }
  } else {
    stateMachine(state);
  }
  send();
  if(rotate) camera.rotateY(rotationSpeed);
  
  manifest.update();
  manifest.display();
 
  
  updateGUI();
  drawGUI();
  updateUDP();
  
}
int universeSizeA = 120;
int universeSizeB = 40;
int univerSizeMax = universeSizeA+universeSizeB;

int universalSize = 360; // später 360 weil 9 streifen * 40 leds

int maxLEDs = 120;
// byte[zeilen][spalten]
byte[][] dmxA = new byte[4][universalSize];
byte[][] dmxB = new byte[4][universalSize];
int universes = 4; // manifest wird 60 universen haben

// alter code
static final String router1 = "2.12.4.83";
static final String router2 = "2.161.30.223";
// alter code ende

public void feedFrame(PImage p) {
  //image(p, 0, 0);
  p.loadPixels();
  for (int y = 0; y<totalRows; y++) {
    for(int x = 0; x<720; x++) {
      int c = p.pixels[y*p.width+x]; //.get(x,y);
      //mapPixels(x,y, lightGain((int)brightness(c))); // direkte manipulation
      rows.get(y).setPixel(x, (byte)lightGain((int)brightness(c))); // mit router klasse
    }
  }
}


// neue feedFrame methode mit * EXPERIMENTAL *
/*
void feedFrame(PImage p) {
  p.loadPixels();
  color c = 0;
  
  //for(int y = 0; y<updatedRows.length; y++) {
    for(int y = 0; y<totalRows; y++) {
    if(updatedRows[y]) {
      for(int x = 0; x<updatedPixels[y].length; x++) {
        if(updatedPixels[y][x]) {
          c = p.pixels[y*p.width+x]; //.get(x,y);
          rows.get(y).setPixel(x, (byte)lightGain((int)brightness(c)));
        }
        
      }
    }
    // updatedPixels = new boolean[30][720];
    // updatedRows = new boolean[30];  
  
      //color c = p.pixels[y*p.width+x]; //.get(x,y);
      //mapPixels(x,y, lightGain((int)brightness(c)));
    
  }
}
*/
public void mapPixels(int x, int y, int brightness) {
  if(x >= 0 && x < universalSize) {
    dmxA[y][x] = (byte)brightness;
    dmxB[y][x] = (byte)brightness;
  }
}

public void reset() {
  for(int u = 0; u<universes; u++) {
    for(int a = 0; a<universeSizeA; a++) {
      dmxA[u][a] = (byte)0;
    }
    for(int b = 0; b<universeSizeB; b++) {
      dmxB[u][b] = (byte)0;
    }
  }
}
/* // klassische methode
void send() {
  if(!offline) {
    for(int u = 0; u < universes; u++) {
      artnet.unicastDmx(router1, 0, u, dmxA[u]);
      artnet.unicastDmx(router2, 0, u, dmxB[u]);
    }
  }
}
*/

public void send() {
  if(!offline) {
    for(int y = 0; y<totalRows; y++) {
      rows.get(y).send();
    }
  }
}


// only send "updatables"  * EXPERIMENTAL *
/*
void send() {
  if(!offline) {
    for(int y = 0; y<totalRows; y++) {
      if(updatedRows[y]) {
        rows.get(y).send();
      }
    }
    
  }
}
*/
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


public void constructGUI() {
  // change the original colors
  int black = color(0, 0, 0);
  int white = color(0, 0, 255);
  int gray = color(0, 0, 125);
  cp5.setAutoDraw(false);

  cp5.addSlider("sliderBrightness")
    .setRange(0, 255)
    .setPosition(15, 110)
    .setValue(255)
    .setSize(100, 8)
    .setColorValue(black)
    ;
  cp5.addSlider("rotationSpeed")
    .setRange(0, 0.05f)
    .setPosition(15, 120)
    .setValue(0.01f)
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
     .setSize(160, 100)
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
  

}

public void updateGUI() {
  if (!(stateLabel.getStringValue().equals(getStateName(state)))) stateLabel.setText(getStateName(state));
  frameRateLabel.setText("Framerate: "+ frameRate);
}

public void drawGUI() {
  camera.beginHUD();
  pushStyle();
  fill(0, 50);
  noStroke();
  rect(0, 0, 200, height);
  popStyle();
  
  image(marke, width-120, height-40);

  // 2d texture preview
  if (currentFrame!= null) {
    float f = 3.6f; // currentFrame.with / 200 pixel breite vom menü
    pushStyle();
    stroke(0);
    //if(previousFrame != null) image(previousFrame.get(0, 0, previousFrame.width, previousFrame.height), 0, height-220, previousFrame.width/f, previousFrame.height/f);
    image(currentFrame.get(0, 0, currentFrame.width, currentFrame.height), 0, height-120, currentFrame.width/f, currentFrame.height/f);
    popStyle();
  }
  cp5.draw();
  camera.endHUD();
}

public void sliderBrightness(int in) {
  float br = map(in, 0, 255, 0, 100);
  sliderBrightness = in;
  if(brightnessInPercLabel != null) brightnessInPercLabel.setText("BRIGHTNESS: "+ round(br) +"%");
}

public void playCheckbox(float[] a) {
  if (a[0] == 1f) play = true;
  else play = false;
}

public void offlineCheckbox(float[] a) {
  if (a[0] == 1f) offline = true;
  else offline = false;
}
 
public void rotateCheckbox(float[] a) {
  if (a[0] == 1f) rotate = true;
  else rotate = false;
}

public void redrawCheckbox(float[] a) {
  if (a[0] == 1f) redraw = true;
  else redraw = false;
}

public void nextDemo(int theValue) {
  state++;
  if (state > MAX_STATES-1) state = 0;
  checkImageDropdown();
}

public void prevDemo(int theValue) {
  state--;
  if (state < 0) state = MAX_STATES-1;
  checkImageDropdown();
}

public void imageList(int n) {
  String s = (String)cp5.get(ScrollableList.class, "imageList").getItem(n).get("text");
  // check if this is a valid image?
  if(s.length() > 0) demo11.setImage(s);
  else println("[#] ERROR : the image is not valid. string size is low or equal than 0");
}

public void checkImageDropdown() {
  if(imageList != null) {
    if(state == 11) cp5.get(ScrollableList.class, "imageList").show();
    else cp5.get(ScrollableList.class, "imageList").hide();
  }
}
int mousePressedLocation = 0;

public void keyPressed() {
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

public PImage transformFrame(PImage s) {
  PGraphics destination;
  destination = createGraphics(720,30);
  destination.beginDraw();
  destination.colorMode(HSB, 360, 100, 255);
  destination.background(0);
  destination.endDraw();
  s.loadPixels();
  float factor = PApplet.parseFloat((s.height-1) / destination.height);
  
  factor = 8.7f;
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

public void setCurrentFrame(PImage p) {
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

public void transformWrapper() {
  PImage transformed = transformFrame(currentFrame);
  manifest.setFrame(transformed);
  feedFrame(transformed);
}



public void dragging() {
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

public int lightGain(int val) {
  if(invert) val = (int)map(val, 0, 255, 255, 0);
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

public int lightGain(float val) {
  if(invert) val = (int)map(val, 0, 255, 255, 0);
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

public int lightGain(int h, int s, int b) {
  if(invert) b = (int)map(b, 0, 255, 255, 0);
  int calc = round(map(color(h,s,b), 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

public void setupCamera() {
  camera.setMinimumDistance(0);
  camera.setMaximumDistance(1500);
  camera.setDistance(500);
  camera.setYawRotationMode();
  camera.setWheelScale(0.1f);
  camera.setResetOnDoubleClick(false);
  camera.setLeftDragHandler(null);  
  camera.setCenterDragHandler(null);  
  camera.setRightDragHandler(null); 
}

public void loadSettings(String s) {
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
public void saveSettings() {
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

public int getLogGamma(int in) {
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

public boolean isSame(int c1, int c2) {
  float r1 = c1 >> 16 & 0xFF;
  float b1 = c1 & 0xFF;
  float g1 = c1 >> 8 & 0xFF;
  

  float r2 = c2 >> 16 & 0xFF;
  float b2 = c1 & 0xFF;
  float g2 = c2 >> 8 & 0xFF;
 
  return r1 == r2 && b1 ==b2 && g1 == g2;
}

public void movieEvent(Movie m) {
  m.read();
  if(play && (state == NONE || state == INTRO)) {    
    if(introFinished) nextFrame = movie;
    else nextFrame = introMov;
  }
}

public String printTime() {
  return day() +"."+ month() +"."+ year() +", "+ hour() +":"+ minute() +":"+ second();
}

public boolean fileExists(String filename, String externalPath, boolean internal) {
  File tempFile;
  if(!internal) tempFile = new File(dataPath(externalPath+filename));
  else tempFile = new File(dataPath(externalPath+filename));
  if (tempFile.exists()) return true;
  else return false;
}
class LEDRow {
  // this class accepts pixel values from 0–719
  // the class LEDRow maps pixels into the right order for the led stripes
  // this includes flipping and also the shifting by -1 led stripe so that
  // an image starts at the corner of the manifest
  
  Pixelrouter[] routers = new Pixelrouter[2];
  int id;
  boolean reverseRow = false;
  int[] ports = {0,0};
  int port = 0;
  byte[][] leds = new byte[2][360];
  boolean special = false;
  
  LEDRow(int _id, Pixelrouter r0, Pixelrouter r1, int u0) {
    id = _id;
    if(id % 2 == 0) reverseRow = true;
    routers[0] = r0;
    routers[1] = r1;
    port = u0;
  }
  
  LEDRow(int _id, Pixelrouter r0, Pixelrouter r1) {
    id = _id;
    if(id % 2 == 0) reverseRow = true;
    routers[0] = r0;
    routers[1] = r1;
    port = id % 4;
    if(r1.getIP().equals("0.0.0.0")) special = true;

  }
  
  public void setPixel(int led, byte val) {
    if(reverseRow) { // A und B Zeilen
      shiftAB(led, val);
    } else { // C und D Zeilen
      shiftCD(led, val);
    }
  }
  
  public void shiftAB(int led, int val) {
    //print("input: "+ led + " --> ");
    // physical shifter for A/B row
    int rm  = 0; // remapped value
    int u = 0;
    if(led >= 0 && led < 280) {
      rm = round(map(led, 0, 279, 279, 0));
      u = 1;
    } else if(led >= 280 && led < 640) {
      rm = round(map(led, 280, 639, 359, 0));
      u = 0;
    } else if(led >= 640 && led < 720) {
      rm = round(map(led, 640, 719, 359, 280));
      u = 1;
    }
    //println("mapped: ["+ u + "][" + rm +"]="+(byte)val);
    leds[u][rm] = (byte)val;
  }
  public void shiftCD(int led, int val) {
    // physical shifter for C/D row
    // split the row into three parts and remap values
    int rm  = 0; // remapped value
    int u = 0;
    //print("input: "+ led + " --> ");
    if(led >= 0 && led < 40) {
      rm = round(map(led, 0, 39, 320, 359));
      u = 1;
    } else if(led >= 40 && led < 400) {
      rm = round(map(led, 40, 399, 0, 359));
      u = 0;
    } else if(led >= 400 && led < 720) {
      rm = round(map(led, 400, 719, 0, 319));
      u = 1;
    }    
    //println("mapped: ["+ u + "][" + rm +"]="+(byte)val);
    leds[u][rm] = (byte)val;
  }
  
  
  public int invert(int led) {
    int rm = 0;
    rm = round(map(led, 0, 719, 719, 0));
    return rm;
  }
  
  public int flip(int led) {
    int rm = 0;
    // gets an input led and maps it accordingly to a correct C/D row
    if(led >= 0 && led < 280) { // segment one from b6 – b0
      rm = (int)map(led, 0, 279, 279, 0);
    } else if(led >= 280 && led < 640) { // segment one from a8 – a0
      rm = (int)map(led, 280, 639, 639, 280);
    } else if(led >= 640 && led < 720) { // segment one from b8 – b7
      rm = (int)map(led, 640, 719, 719, 640);
    }
    return rm;
  }
  
  public void setRouter(int i, Pixelrouter r) {
    routers[i] = r;
  }
  
  public void updateRouters() {
  }
  
  public void send() {
    //println("sending data to pixelrouters on ports: "+ ports[0] + " + " + ports[1]);
    if(!special) {
      routers[0].send(port, leds[0]);
      routers[1].send(port, leds[1]);
    } else {
      if(id%2 == 0) {
        // id == 28
        routers[0].send(0, leds[0]);
        routers[0].send(1, leds[1]);
      } else if(id%2 == 1) {
        // id == 29
        routers[0].send(2, leds[0]);
        routers[0].send(3, leds[1]);
      }
    }
    // this method pushes led values in correct order to the pixel routers
  }
  
  public void reset() {
    
    leds = new byte[2][360];
  }
  
  public byte[][] getLEDs() {
    return leds;
  }
  public byte[] getLEDs(int i) {
    return leds[i];
  }
  
  
}
class Manifest {
  ArrayList<Stripe> stripes = new ArrayList<Stripe>();
  
  int object = color(40);
  PImage p;
  PGraphics pg;
  
  boolean isUpdatable = false;
  int frameType = 0;
  
  float distance = 23.3f;
   
  public Manifest(int o) {
    object = o;
    p = createImage(720, 30, RGB);
    pg = createGraphics(720, 30);
    pg.beginDraw();
    pg.background(0);
    pg.endDraw();
    
    // Construct LED Stripes for the ArrayList
    for(int y = 0; y < 30; y++) {
      for(int x = 0; x < 18; x++) {
        if(x >= 0 && x < 8) stripes.add(new Stripe(x*50,y*10,distance));
        else if(x == 8) stripes.add(new Stripe(8*50-distance-3,y*10,0, 90));
        else if(x > 8 && x <= 16) stripes.add(new Stripe((x%8)*50,y*10,-distance, true, 1));
        else if(x == 17) stripes.add(new Stripe(0*50-distance, y*10, 0, 90, true, 2));
      }
    }
  
    println("Anzahl LED Streifen: "+ stripes.size());
  }
  
  public void setFrame(PImage _p) {
    p = _p;
    frameType = 1;
    isUpdatable = true;
    //println("setFrame for PImage");
  }
  
  public void setFrame(PGraphics _pg) {
    pg = _pg;
    frameType = 2;
    isUpdatable = true;
    //println("setFrame for PGraphics");
  }
  
  /*
  void feedFrame(PImage p) {
  p.loadPixels();
  for (int y = 0; y<4; y++) {
    for(int x = 0; x<720; x++) {
      color c = p.pixels[x+y*p.height]; //.get(x,y);
      mapPixels(x,y, lightGain((int)c));
    }
  }
}
  */
  
  public void update() {
    if(redraw) {
      if(isUpdatable && frameType > 0) {
        reset();
        if(frameType == 1) {
           p.loadPixels();
           for(int x = 0; x<720; x++) {
             for(int y = 0; y<30; y++) {
               int c = p.pixels[y*p.width+x];//color c = p.get(x,y);
               setPixel(x,y, lightGain((int)brightness(c)));
             }
           }
        } else if(frameType == 2) {
        }
        
        isUpdatable = false;
      }
    }
  }
  
  public void display() {
    if(redraw) {
      fill(object);
      stroke(0,0,0);
      //box(390.5, 290, 40.5); // original inner cube
      pushMatrix();
        translate(0,0,20);
        box(5, 290, 5);
        translate(0,0,-40);
        box(5, 290, 5);
        translate(-195,0,0);
        box(5, 290, 5);
        translate(0,0,40);
        box(5, 290, 5);
        translate(390,0,0);
        box(5, 290, 5);
        translate(0,0,-40);
        box(5, 290, 5);
        translate(-195,120,20);
        box(390.5f, 15, 40.5f);
      popMatrix();
      
      pushMatrix();
        translate(-175, -145, 0);
        for (Stripe stripe : stripes) {
          stripe.display();
        }
      popMatrix();
    }
  }
  
  public void setPixel(int x, int y, int value) {
    int _x = 0;
    int _y = 0;
    
    // 720 × 30 auflösung / 18 streifen in x-achse / 30 reihen/pixel in y-achse
    // 40 LEDs á streifen
    // ( 18*30*40 || 720 * 30 ) = 21.600 LEDs total 
    
    _x = x%720;
    _y = y*18;
    int ledNr = _x%40;
    int stripe = (x/40)+_y;
    
    if(stripe%18 > 8 && stripe%18 < 16) {    
      stripe = round(map(stripe%18, 9, 15, 15, 9));
      stripe += _y;    
    } else if(stripe%18 == 16) {
      // baustelle ??
    }
    stripes.get(stripe).setPixel(ledNr, value);
  }
  
  public void reset() {
    //println("reset of stripe pixels");
    for(int x = 0; x<720; x++) {
      for(int y = 0; y<30; y++) {
        setPixel(x, y, 0);
      }
    }
  }
}
class Pixelrouter {
  // the pixelrouter only sends out signals via artnet
  String ip;
  boolean online = true; // später überprüfen ob wirklich online
  ArtNetClient artnet;

  Pixelrouter() {
  }

  Pixelrouter(String _ip) {
    ip = _ip;
    artnet = new ArtNetClient(null);
    artnet.start();
  }
  
  public String getIP() {
    return ip;
  }

  public void isOnline() {
    // try-catch block zum testen ob ein pixelrouter online ist
  }

  public void send(int port, byte[] data) {
    //println("sending data to router: " + ip + " / " + port + " / " + data);
    //for(int i = 0; i<360; i++) print(data[i] + ", ");
    artnet.unicastDmx(ip, 0, port, data);
  }
}
// FSM
static final int NONE = 0;
static final int DEMO1 = 1;
static final int DEMO2 = 2;
static final int DEMO3 = 3;
static final int DEMO4 = 4;
static final int DEMO5 = 5;
static final int DEMO6 = 6;
static final int DEMO7 = 7;
static final int DEMO8 = 8;
static final int DEMO9 = 9;
static final int DEMO10 = 10;
static final int DEMO11 = 11;

static final int INTRO = 99;

static final int MAX_STATES = 12;

// Demo Objects
Intro intro;
Demo1 demo1;
Demo2 demo2;
Demo3 demo3;
Demo4 demo4;
Demo5 demo5;
Demo6 demo6;
Demo7 demo7;
Demo8 demo8;
Demo9 demo9;
Demo10 demo10;
Demo11 demo11;

public void createDemos() {
  intro = new Intro();
  demo1 = new Demo1();
  demo2 = new Demo2();
  demo3 = new Demo3();
  demo4 = new Demo4(this);
  demo5 = new Demo5();
  demo6 = new Demo6();
  demo7 = new Demo7();
  demo8 = new Demo8();
  demo9 = new Demo9();
  demo10 = new Demo10();
  demo11 = new Demo11();
}


static final String[] stateNames = {
  "Video Loop", "Atmen", "Lichtstreifen",
  "Hochwandern", "Soundreaktiv", "Perlin",
  "Flocking", "PingPong", "H. Wellen",
  "V. Wellen", "Aufwaerts", "Statische Bilder"
};

public String getStateName(int state) {
  return stateNames[state];
}

public void stateMachine(int state) {
  
   switch(state) {
    case NONE:
      // feed the manifest with data
      if(play && nextFrame != null) {
        //manifest.setFrame(transformFrame(currentFrame));
        //feedFrame(transformFrame(currentFrame));
        setCurrentFrame(nextFrame);
        transformWrapper();
        //send();
      }
    break;
    
    case DEMO1:
      demo1.update();
      demo1.display();
      setCurrentFrame(demo1.getDisplay()); 
      transformWrapper();
      //send();
    break;
    
    case DEMO2:
      demo2.update();
      demo2.display();
      setCurrentFrame(demo2.getDisplay()); 
      transformWrapper();
      //send();
    break;
    
    case DEMO3:
      demo3.update();
      demo3.display();
      setCurrentFrame(demo3.getDisplay()); 
      transformWrapper();
    break;
    
    case DEMO4:
      demo4.update();
      demo4.display();
      setCurrentFrame(demo4.getDisplay()); 
      transformWrapper();
    break;
   
    case DEMO5:
      demo5.update();
      //demo5.display();
      setCurrentFrame(demo5.getDisplay()); 
      transformWrapper();
    break;
    
    case DEMO6:
      demo6.update();
      //demo5.display();
      setCurrentFrame(demo6.getDisplay()); 
      transformWrapper();
    break;
    
    case DEMO7:
      demo7.update();
      demo7.display();
      setCurrentFrame(demo7.getDisplay()); 
      transformWrapper();
    break;
    
    case DEMO8:
      demo8.update();
      demo8.display();
      setCurrentFrame(demo8.getDisplay()); 
      transformWrapper();
    break;
    
    case DEMO9:
      demo9.update();
      demo9.display();
      setCurrentFrame(demo9.getDisplay()); 
      transformWrapper();
    break;
    
    case DEMO10:
      demo10.update();
      demo10.display();
      setCurrentFrame(demo10.getDisplay()); 
      transformWrapper();
    break;
    
    
    
    case DEMO11:
      demo11.update();
      demo11.display();
      setCurrentFrame(demo11.getDisplay()); 
      transformWrapper();
    break;
    
    }
}

class Intro {
  PGraphics pg;
  float growth = 15;
  float radius = 0;
  boolean bordered = false;
  boolean black = false;
  
  int flag = 0;
  
  public Intro() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.noStroke();
    pg.rectMode(CENTER);
    pg.ellipseMode(CENTER);
    pg.endDraw();
    
  }
 
  public void update() {
    if(play && currentFrame != null) {
      //manifest.setFrame(transformFrame(currentFrame));
      //feedFrame(transformFrame(currentFrame));
      transformWrapper();
      //send();
    }
  }
  
  public void display() {

  }
  public void displayY() {
    if(play) {
      pg.beginDraw();
      pg.noStroke();
      if(bordered) {
        bordered = false;
        radius = 0;
        black = !black;
        flag++;
      }
      if(black) pg.fill(0);
      else pg.fill(255);
      if(flag == 0) {
        pg.ellipse(160,130, radius, radius);
        pg.ellipse(520,130, radius, radius);
      } else if(flag == 1) {
        pg.rect(160,130, radius, radius);
        pg.rect(520,130, radius, radius);
      } else if(flag == 2) {
        
        pg.pushMatrix();
        pg.translate(160, 130);
        pg.rotate(radians(180));
        pg.scale(radius/60);
        pg.triangle(-30, 30, 0, -30, 30, 30); 
        pg.popMatrix();
        
        pg.pushMatrix();
        pg.translate(520, 130);
        pg.rotate(radians(180));
        pg.scale(radius/60);
        pg.triangle(-30, 30, 0, -30, 30, 30); 
        pg.popMatrix();
      } else if(flag == 3) {
        pg.background(0,0,0,240);
      }
      pg.endDraw();
      radius += growth;
      if(radius > pg.width) bordered = true;
    }
  }
  
  public PImage getDisplay() {
    return pg;
  }
}

// Breathe
class Demo1 {
  float position = 0;
  PGraphics pg;
  float val = 0;
  
  public Demo1() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
  }
  
  public void update() {
    if(play) {
      val = (exp(sin(millis()/2000.0f*(PI/2))) - 0.36787944f)*108.0f;
    }
  }
  
  public void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      pg.background(lightGain(val));
      position += 50 / 255.0f / Math.PI;
      pg.endDraw();
    }
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {
    position = 0;
  }
}

// Lichstreifen
class Demo2 {
  PGraphics pg;
  int position = 0;
  long lastMillis = 0;
  long interval = 10;
  
  int val = 0;
  int x_limit = 720;
  
  public Demo2() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
  }
  
  public void update() {
    if(play) {
      interval = round(map(sliderOptions2, 0, 100, 200, 0));
      if(millis() - lastMillis > interval) {
        lastMillis = millis();
        position++;
        if(position > x_limit) position = 0;
      }  
    }
  }
  
  public void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      pg.noStroke();
      pg.fill(lightGain(0,0,255));
      int thick = round(map(sliderOptions, 0, 100, 1, 100));
      pg.rect(position, 0, thick, pg.height);
      pg.endDraw();
    }
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {
    
  }
}

// Hochwandern
class Demo3 {
  PGraphics pg;
  int row = 3;
  int val = 0;
  boolean direction = true;
  int position = 0;
  long prevMillis = 0;
  long delay = 10;
  
  public Demo3() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
  }
  
  public void update() {
    if(play) {
        if(millis() - prevMillis < sliderOptions) return;
        prevMillis = millis();
        row --;
        if(row < 0) row = MANIFEST_HEIGHT;
      }
  }
  
  public void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      pg.fill(0,0,lightGain(255));
      pg.rect(0, row, 720, 10);
      pg.endDraw();
    }
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {
    position = 0;
  }
}

// Soundreaktiv
class Demo4 {
  PGraphics pg;
  int row = 3;
  int val = 0;
  boolean direction = true;
  int position = 0;
  int size = 0;
  PApplet pa;
  
  public Demo4(PApplet _pa) {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
    pa = _pa;
    input = new AudioIn(pa, 0);
    input.start();
    loudness = new Amplitude(pa);
    loudness.input(input);
  }
  
  public void update() {
    if(play) {
      float inputLevel = map(mouseY, 0, pg.height, 1.0f, 0.0f);
      input.amp(inputLevel);
    
      // loudness.analyze() return a value between 0 and 1. To adjust
      // the scaling and mapping of an ellipse we scale from 0 to 0.5
      float volume = loudness.analyze();
      size = round(map(volume, 0, 0.5f, 0, 255));
    }
  }
  
  public void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      pg.background(lightGain(size));
      pg.endDraw();
    }
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {
    position = 0;
  }
}

// Perlin
class Demo5 {
  // based on: https://processing.org/examples/noise3d.html
  PGraphics pg;
 
  float increment = 0.01f;
  // The noise function's 3rd argument, a global variable that increments once per cycle
  float zoff = 0.0f;  
  // We will increment zoff differently than xoff and yoff
  float zincrement = 0.02f; 
  
  public Demo5() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
  }
  
  public void update() {
    if(play) {
      // Optional: adjust noise detail here
      int octave = round(map(sliderOptions, 0, 100, 8, 0));
      float falloff = map(sliderOptions2, 0, 100, 0.0f, 1.0f);
      noiseDetail(octave,falloff);
      
      pg.loadPixels();
      pg.beginDraw();
    
      float xoff = 0.0f; // Start xoff at 0
      
      // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
      for (int x = 0; x < pg.width; x++) {
        xoff += increment;   // Increment xoff 
        float yoff = 0.0f;   // For every xoff, start yoff at 0
        for (int y = 0; y < pg.height; y++) {
          yoff += increment; // Increment yoff
          float bright = noise(xoff,yoff,zoff)*255;          
          pg.pixels[x+y*pg.width] = color(0,0,bright);
        }
      }
      pg.updatePixels();
      pg.endDraw();
      zoff += zincrement; // Increment zoff
    }
  }
  
  public void display() {
    
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {
    
  }
}

// Flock

class Demo6 {
  // based on: https://processing.org/examples/flocking.html
  PGraphics pg;
  Flock flock;
  
  public Demo6() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
    
    flock = new Flock();
    // Add an initial set of boids into the system
    for (int i = 0; i < 150; i++) {
      flock.addBoid(new Boid(pg.width/2,pg.height/2));
    }
  }
  
  public void update() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      pg.endDraw();
      flock.run();
    }
  }
  
  
  public void display() {
    if(play) {
      
    }
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {
  }
  
  class Flock {
    ArrayList<Boid> boids; // An ArrayList for all the boids
    Flock() {
      boids = new ArrayList<Boid>(); // Initialize the ArrayList
    }
    public void run() {
      for (Boid b : boids) {
        b.run(boids);  // Passing the entire list of boids to each boid individually
      }
    }
    public void addBoid(Boid b) {
      boids.add(b);
    }
  }
  
  class Boid {
    PVector position;
    PVector velocity;
    PVector acceleration;
    float r;
    float maxforce;    // Maximum steering force
    float maxspeed;    // Maximum speed
  
    Boid(float x, float y) {
      acceleration = new PVector(0, 0);  
      float angle = random(TWO_PI);
      velocity = new PVector(cos(angle), sin(angle));
      position = new PVector(x, y);
      r = 2.0f;
      maxspeed = 2;
      maxforce = 0.03f;
    }
  
    public void run(ArrayList<Boid> boids) {
      flock(boids);
      update();
      borders();
      render();
    }
  
    public void applyForce(PVector force) {
      acceleration.add(force);
    }
  
    public void flock(ArrayList<Boid> boids) {
      PVector sep = separate(boids);   // Separation
      PVector ali = align(boids);      // Alignment
      PVector coh = cohesion(boids);   // Cohesion
      sep.mult(1.5f);
      ali.mult(1.0f);
      coh.mult(1.0f);
      applyForce(sep);
      applyForce(ali);
      applyForce(coh);
    }
  
    public void update() {
      velocity.add(acceleration);
      velocity.limit(maxspeed);
      position.add(velocity);
      acceleration.mult(0);
    }
  
    public PVector seek(PVector target) {
      PVector desired = PVector.sub(target, position);
      desired.setMag(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);  // Limit to maximum steering force
      return steer;
    }
  
    public void render() {
      float theta = velocity.heading2D() + radians(90);
      pg.beginDraw();
      pg.fill(0,0, 255);
      pg.noStroke();
      pg.pushMatrix();
      pg.translate(position.x, position.y);
      pg.ellipse(0,0,5,10);
      pg.popMatrix();
      pg.endDraw();
    }
  
    public void borders() {
      if (position.x < -r) position.x = pg.width+r;
      if (position.y < -r) position.y = pg.height+r;
      if (position.x > pg.width+r) position.x = -r;
      if (position.y > pg.height+r) position.y = -r;
    }
  
    public PVector separate (ArrayList<Boid> boids) {
      float desiredseparation = 25.0f;
      PVector steer = new PVector(0, 0, 0);
      int count = 0;
      for (Boid other : boids) {
        float d = PVector.dist(position, other.position);
        if ((d > 0) && (d < desiredseparation)) {
          PVector diff = PVector.sub(position, other.position);
          diff.normalize();
          diff.div(d);        // Weight by distance
          steer.add(diff);
          count++;            // Keep track of how many
        }
      }
      if (count > 0) {
        steer.div((float)count);
      }
  
      if (steer.mag() > 0) {  
        steer.normalize();
        steer.mult(maxspeed);
        steer.sub(velocity);
        steer.limit(maxforce);
      }
      return steer;
    }
  
    public PVector align (ArrayList<Boid> boids) {
      float neighbordist = 50;
      PVector sum = new PVector(0, 0);
      int count = 0;
      for (Boid other : boids) {
        float d = PVector.dist(position, other.position);
        if ((d > 0) && (d < neighbordist)) {
          sum.add(other.velocity);
          count++;
        }
      }
      if (count > 0) {
        sum.div((float)count);
        sum.setMag(maxspeed);
        PVector steer = PVector.sub(sum, velocity);
        steer.limit(maxforce);
        return steer;
      } 
      else {
        return new PVector(0, 0);
      }
    }
  
    public PVector cohesion (ArrayList<Boid> boids) {
      float neighbordist = 50;
      PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
      int count = 0;
      for (Boid other : boids) {
        float d = PVector.dist(position, other.position);
        if ((d > 0) && (d < neighbordist)) {
          sum.add(other.position); // Add position
          count++;
        }
      }
      if (count > 0) {
        sum.div(count);
        return seek(sum);
      } 
      else {
        return new PVector(0, 0);
      }
    }
  }
}

// PingPong
class Demo7 {
  PGraphics pg;
  int position;
  boolean direction;
  long lastMillis;
  int interval;

  public Demo7() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
    
    position = 0;
    direction = true;
    lastMillis = 0;
    interval = 1;
  }
  
  public void update() {
    if(play) {
        interval = round(map(sliderOptions2, 0,100, 50, 0));
        if(millis() - lastMillis < interval) return;
        lastMillis = millis();
        
        int speed = round(map(sliderOptions2, 0,100, 5, 20));
        if(direction) position+= speed;
        else position-= speed;
        
        if(position > MANIFEST_WIDTH) {
          position = MANIFEST_WIDTH;
          direction = false;
        } else if(position < 0) {
          position = 0;
          direction = true;
        }
      }
  }
  
  public void display() {
    pg.beginDraw();
    pg.background(0);
    pg.noStroke();
    pg.fill(lightGain(0,0,255));
    int thick = round(map(sliderOptions, 0, 100, 1, 100));
    pg.rect(position, 0, thick, pg.height);
    pg.endDraw();
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {
    position = 0;
  }
}

// Wellen
class Demo8 {
  float position = 0;
  PGraphics pg;
  
  public Demo8() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.colorMode(HSB, 360, 100, 255);
  }
  
  public void update() {
    if(play) {
    }
  }
  
  public void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      float v0 = map(sliderOptions, 0, 100, 0, 255);
      float v1 = map(sliderOptions2, 0, 100, 0, 255);
      float v2 = map(sliderOptions3, 0, 100, 0, 128);
      float v3 = map(sliderOptions4, 0, 100, 0, 127);
      
      for (int x=0; x<=MANIFEST_WIDTH; x++) {
        float p = position + x * map(v1, 0, 255, 0, PI/2);
        float val = max(0, map(sin(p), -1, 1, -(128-v2)*10, v3*2));
        pg.stroke(lightGain(0,0,(int)val));
        pg.line(x, 0, x, MANIFEST_HEIGHT);
      }
      pg.endDraw();
      position += v0 / 255.0f / Math.PI;
    }
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {
    position = 0;
  }
}

// Invertierte Wellen
class Demo9 {
  float position = 0;
  PGraphics pg;
  
  public Demo9() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.colorMode(HSB, 360, 100, 255);
  }
  
  public void update() {
    if(play) {
    }
  }
  
  public void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      float v0 = map(sliderOptions, 0, 100, 0, 255);
      float v1 = map(sliderOptions2, 0, 100, 0, 255);
      float v2 = map(sliderOptions3, 0, 100, 0, 128);
      float v3 = map(sliderOptions4, 0, 100, 0, 127);
      
      for (int y=0; y<=MANIFEST_HEIGHT; y++) {
        float p = position + y * map(v1, 0, 255, 0, PI/2);
        float val = max(0, map(sin(p), -1, 1, -(128-v2)*10, v3*2));
        pg.stroke(lightGain(0,0,(int)val));
        pg.line(0, y, MANIFEST_WIDTH, y);
      }
      pg.endDraw();
      position += v0 / 255.0f / Math.PI;
    }
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {
    position = 0;
  }
}

// Aufwärts
class Demo10 {
  PGraphics pg;
  long prevMillis = 0;
  long delay = 10;
    
  int Y_AXIS = 1;
  int X_AXIS = 2;
  
  int black = color(0, 0, 0);
  int white = color(0, 0, 255);
  int gray = color(0, 0, 125);
  
  int position = 0;
  
  boolean reset = false;
  
  
  public Demo10() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
  }
  
  public void update() {
    if(play) {
        if(millis() - prevMillis < sliderOptions) return;
        prevMillis = millis();
        position-=sliderOptions2;
        position%=MANIFEST_HEIGHT;
      }
  }
  
  public void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      setGradient(0, position, MANIFEST_WIDTH, MANIFEST_HEIGHT, black, white, Y_AXIS);
      //setGradient(0, position+261, MANIFEST_WIDTH, MANIFEST_HEIGHT*2, white, black, Y_AXIS);
      //setGradient(0, MANIFEST_HEIGHT, MANIFEST_WIDTH, position, gray, white, X_AXIS);
      pg.endDraw();
    }
  }
  
  public void setGradient(int x, int y, float w, float h, int c1, int c2, int axis ) {
    noFill();
  
    if (axis == Y_AXIS) {  // Top to bottom gradient
      for (int i = y; i <= y+h; i++) {
        float inter = map(i, y, y+h, 0, 1);
        int c = lerpColor(c1, c2, inter);
        pg.stroke(c);
        pg.line(x, i, x+w, i);
      }
    }  
    else if (axis == X_AXIS) {  // Left to right gradient
      for (int i = x; i <= x+w; i++) {
        float inter = map(i, x, x+w, 0, 1);
        int c = lerpColor(c1, c2, inter);
        pg.stroke(c);
        pg.line(i, y, i, y+h);
      }
    }
  }

  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {

  }
}


// Bild
class Demo11 {
  PGraphics pg;
  PImage p;
  // image importer
  String path = "img";
  File folder = dataFile(path);
  String[] filenames;
  StringList files = new StringList();
  boolean foundFiles = false;
  int pointer = 0;
  boolean external = false;
  
  public Demo11() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
    
    // import images
    File tempFile = new File(dataPath(externalPath+"img")); 
    if (tempFile.exists()) {
      folder = dataFile(externalPath+"img");
      external = true;
     //filePath = externalPath+"content/"+fileName;
     println("[success] found image folder on external");
    } else{
      folder = dataFile(path);
//     filePath = "demos/"+fileName;
     println("[fail] couldn't find image folder on external");
    }

    initList();
  }
  
  public void initList() {
    File[] pics = folder.listFiles();
    filenames = new String[pics.length];
    for (int i = 0; i < pics.length; filenames[i] = pics[i++].getPath());
    if(filenames.length > 0) {
      foundFiles = true;
      
      for(int i = 0; i< filenames.length; i++) {
        String[] splitter = split(filenames[i], '.');
        if(splitter[1].equals("jpg") || splitter[1].equals("JPG") || splitter[1].equals("png") || splitter[1].equals("PNG")) { 
          String[] absolutePath = split(filenames[i], '/');
          files.append(absolutePath[absolutePath.length-1]);
        }
      }
    }
    if(foundFiles) {
      for (int i = files.size() - 1; i >= 0; i--) if (files.get(i).equals(".DS_Store")) files.remove(i);
      List l = new ArrayList();
      for (String f : files) {
        l.add(f);
      }
      
      cp5.get(ScrollableList.class, "imageList").addItems(l).setPosition(14, 190);
      getImage();
      
    }
  }
  
  public void update() {
    if(play) {
      
    }
  }
  
  public void display() {
    pg.beginDraw();
    pg.background(0);
    pg.noStroke();
    pg.image(p, 0, 0);
    pg.endDraw();
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void setImage(String s) {
    for(int i = 0; i<files.size(); i++) {
       if(files.get(i).equals(s)) {
         pointer = i;
         getImage();
         return;
       }
    }
  }
  
  public void setImage(int i) {
    i = i % files.size();
    if (i < 0) i += files.size();
    pointer = i;
    getImage();
  }
  
  public void nextImage() {
    setImage(pointer+1);
  }
  
  public void getImage() {
    println("loading file: "+ files.get(pointer));
    if(!external) p = loadImage(sketchPath("") +"data/"+path+"/"+files.get(pointer));
    else p = loadImage(externalPath+"img/"+files.get(pointer));
    
    
  }
 
  
  public void reset() {
    
  }
}
class Stripe {
  
  PVector pos;
  float rotation = 0;
  boolean flip = false;
  int axisFlip = 0;
  
  int[] lights = new int[40];
  
  public Stripe(float x, float y, float z) {
    pos = new PVector(x, y, z);
  }
  
  public Stripe(float x, float y, float z, float r) {
    pos = new PVector(x, y, z);
    rotation = r;
  }
  
  public Stripe(float x, float y, float z, boolean f, int a) {
    pos = new PVector(x, y, z);
    flip = f;
    axisFlip = a;
  }
  
  public Stripe(float x, float y, float z, float r, boolean f, int a) {
    pos = new PVector(x, y, z);
    rotation = r;
    flip = f;
    axisFlip = a;
  }
  
  public void update() {
    
  }
  
  public void setPixel(int index, int value) {
    lights[index] = value;
  }
  
  public void setRotation(float radiant) {
    
  }
  
  public void display() {
    pushMatrix();
    pushStyle();
    
    // transformations
    translate(pos.x, pos.y, pos.z);
    
    rotateY(radians(rotation));
    
    // texture
    pushMatrix();
    pushStyle();
    
    if(!flip) translate(-25, -0.9f, 1.8f);
    else  {
      translate(25, -0.9f, -1.8f);
      if(axisFlip == 0) ; //rotateX(radians(180)); 
      else if(axisFlip == 1) rotateY(radians(180));
      else if(axisFlip == 2) rotateZ(radians(180));
    }
    if(axisFlip == 2) translate(0, -1.8f, 0);
    noStroke();
    for(int i = 0; i<40; i++) {
      fill(0, 0, lights[i]);
      //fill(240);
      rect(i*1.25f, 0, 1.25f, 1.8f);
    }
    
    //rect(0, 0, 50, 1.8);
    
    popStyle();
    popMatrix();
    
    if(flip) {
      if(axisFlip == 0) rotateX(radians(180)); 
      else if(axisFlip == 1) rotateY(radians(180));
      else if(axisFlip == 2) rotateZ(radians(180));
    }
    // profile
    fill(10);
    //box(50,1.8,2.6);
    box(50,1.8f,2.4f);
    
    popStyle();
    popMatrix();
  }
}
// import UDP library


UDP udp;  // define the UDP object
long pingTimestamp;
int pingInterval = 1000;
int pingPort = 4000;
String pingIP = "localhost";
String pingMessage = "ping\n";
/**
 * init
 */
public void initUDP() {

  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 6100 );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
  pingTimestamp = millis();
}


/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) {       // <-- default handler
public void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  
  
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);
  String message = new String( data );
  
  if (message.contains("Manifest,On/Off")) {
    sliderBrightness = 0;
    cp5.getController("sliderBrightness").setValue(sliderBrightness);
  } else if (message.contains("Manifest,Left")) {
    sliderBrightness = sliderBrightness -1 < 0 ? 0 : sliderBrightness - 1;
    println("sliderBrightness: " + sliderBrightness);
    cp5.getController("sliderBrightness").setValue(sliderBrightness);
  } else if (message.contains("Manifest,Right")) {
    sliderBrightness = sliderBrightness +1 > 255 ? 255 : sliderBrightness + 1;
    println("sliderBrightness: " + sliderBrightness);
    cp5.getController("sliderBrightness").setValue(sliderBrightness);
  } else if (message.contains("Manifest,Av1")) {
    prevDemo(1);
  } else if (message.contains("Manifest,Av2")) {
    nextDemo(1);
  } else if (message.contains("Manifest,VGA")) {
    switch(state) {
      case DEMO11:
        demo11.nextImage();
      break;
      case DEMO1:
      break;
    }
  } else if (message.contains("Manifest,Menu")) {
    saveSettings();
  } 
    
  
  // print the result
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
}

public void updateUDP() {
  if (millis() - pingTimestamp  > pingInterval) {
    udp.send( pingMessage, pingIP, pingPort );
    pingTimestamp = millis();
  }
}
  public void settings() {  size(1080,600,P3D);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "visualController" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
