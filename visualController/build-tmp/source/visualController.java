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

PeasyCam camera;
ArtNetClient artnet;
ControlP5 cp5; 

Manifest manifest;
// declare all routers
ArrayList<Pixelrouter> routers = new ArrayList<Pixelrouter>();
String[] routerIPs = {  // A/C + B/D router = 4 rows of LEDs
  "2.12.4.83", "2.161.30.223", // prototyping routers
  
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13", // dummy
  
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13", // dummy
  
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13", // dummy
  "2.0.0.13", "2.0.0.13" // dummy
  
};

// declare all rows
ArrayList<LEDRow> rows = new ArrayList<LEDRow>();
int totalRows = 15;


int bg = color(50);
int object = color(40);

// runtime / volatile variables
PImage currentFrame;
PImage previousFrame;
boolean play = true;
boolean flip = true;
boolean offline = true;
boolean debug = false;
boolean rotate = false;
boolean redraw = true;
float sliderBrightness = 255;
int sliderOptions = 0;
int sliderOptions2 = 0;

float rotationSpeed = 0.001f;

// we want to keep tabs on updated pixels so that later on we only send out
// the updated universes! O P T I M I T A Z A T I O N
boolean changedPixels = false;
boolean[][] updatedPixels = new boolean[30][720];
boolean[] updatedRows = new boolean[30]; // oder als arraylist?

// DEFINE SOURCE DIMENSIONS
int MANIFEST_WIDTH = 720;
int MANIFEST_HEIGHT = 240;

AudioIn input;
Amplitude loudness;


public void setup() {
  
  colorMode(HSB, 360, 100, 255);
  
  loadSettings("data/settings.json");
  manifest = new Manifest(object);

  camera = new PeasyCam(this, 100);
  setupCamera();

  // create artnet client without buffer (no receving needed)
  artnet = new ArtNetClient(null);
  artnet.start();
  
  
  cp5 = new ControlP5(this);
  constructGUI();
  
  
  // osx
  movie = new Movie(this, "demos/test19_bl.mp4");
  // linux movie = new GLMovie(this, "demos/test19.mp4");
  movie.loop();
  
  createDemos();
  previousFrame = createImage(MANIFEST_WIDTH, MANIFEST_HEIGHT, RGB);
  
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
}

public void draw() {
  background(bg);
  dragging();   
  stateMachine(state);
  send();
  if(rotate) camera.rotateY(rotationSpeed);
  //getMovieFrame();
  manifest.update();
  manifest.display();
  
  if(currentFrame != null) {
    previousFrame.copy(currentFrame, 0, 0, currentFrame.width, currentFrame.height, 0, 0, currentFrame.width, currentFrame.height); //previousFrame = currentFrame;
  }
  
  updateGUI();
  drawGUI();
  
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
    
  imageList = cp5.addScrollableList("imageList")
     .setPosition(14, 160)
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
  
  cp5.getController("sliderBrightness").setValue(sliderBrightness);

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

public PImage transformFrame(PImage s) {
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

public void transformWrapper() {
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
          int c1 = transformed.pixels[y*transformed.width+x];
          int c2 = prev.pixels[y*transformed.width+x];
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
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

public int lightGain(float val) {
  int calc = round(map(val, 0, 255, 0, (int)sliderBrightness));
  //calc = getLogGamma(calc);
  return calc;
}

public int lightGain(int h, int s, int b) {
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
 
  sliderBrightness = settings.getFloat("sliderBrightness");
  
  MANIFEST_WIDTH = settings.getInt("MANIFEST_WIDTH");
  MANIFEST_HEIGHT = settings.getInt("MANIFEST_HEIGHT");

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


public void getMovieFrame() {
  if(movie.available()) {
    movie.read();
    if(play && state == NONE) currentFrame = movie;
  }
}


public void movieEvent(Movie m) {
  m.read();
  if(play && state == NONE) {    
    currentFrame = movie;
  }
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
      //print(" c1 --> ");
      rm = round(map(led, 0, 279, 279, 0));
      u = 1;
    } else if(led >= 280 && led < 640) {
      //print(" c2 --> ");
      rm = round(map(led, 280, 639, 359, 0));
      //print(" == float: " + round(map(led, 280, 639, 359, 0)) + " == ");
      u = 0;
    } else if(led >= 640 && led < 720) {
      //print(" c3 --> ");
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
      //print(" c1 --> ");
      rm = round(map(led, 0, 39, 320, 359));
      u = 1;
    } else if(led >= 40 && led < 400) {
      //print(" c2 --> ");
      rm = round(map(led, 40, 399, 0, 359));
      u = 0;
    } else if(led >= 400 && led < 720) {
      //print(" c3 --> ");
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
    routers[0].send(port, leds[0]);
    routers[1].send(port, leds[1]);
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

  Pixelrouter() {
  }

  Pixelrouter(String _ip) {
    ip = _ip;
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
int state = 0;
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

static final int MAX_STATES = 12;

// Demo Objects
Demo1 demo1;
Demo2 demo2;
Demo3 demo3;
Demo4 demo4;
Demo5 demo5;
Demo6 demo6;
Demo7 demo7;
Demo10 demo10;
Demo11 demo11;
public void createDemos() {
  demo1 = new Demo1();
  demo2 = new Demo2();
  demo3 = new Demo3();
  demo4 = new Demo4(this);
  demo5 = new Demo5();
  demo6 = new Demo6();
  demo7 = new Demo7();
  demo10 = new Demo10();
  demo11 = new Demo11();
}
/*
Demo2 demo2 = new Demo2();
Demo3 demo3 = new Demo3();
Demo4 demo4 = new Demo4();
Demo5 demo5 = new Demo5();
Demo7 demo7 = new Demo7();
Demo8 demo8 = new Demo8();
Demo9 demo9 = new Demo9();
Demo10 demo10 = new Demo10();
*/

static final String[] stateNames = {
  "Video Loop", "Atmen", "Lichtstreifen",
  "Hochwandern", "Soundreaktiv", "Perlin",
  "Flocking", "PingPong", "Wellen",
  "Invertierte Wellen", "Perlin2", "Statische Bilder"
};

public String getStateName(int state) {
  return stateNames[state];
}

public void stateMachine(int state) {
  
   switch(state) {
    case NONE:
      // feed the manifest with data
      if(play && currentFrame != null) {
        //manifest.setFrame(transformFrame(currentFrame));
        //feedFrame(transformFrame(currentFrame));
        transformWrapper();
        //send();
      }
    break;
    
    case DEMO1:
      demo1.update();
      demo1.display();
      currentFrame = demo1.getDisplay(); 
      transformWrapper();
      //send();
    break;
    
    case DEMO2:
      demo2.update();
      demo2.display();
      currentFrame = demo2.getDisplay(); 
      transformWrapper();
      //send();
    break;
    
    case DEMO3:
      demo3.update();
      demo3.display();
      currentFrame = demo3.getDisplay(); 
      transformWrapper();
    break;
    
    case DEMO4:
      demo4.update();
      demo4.display();
      currentFrame = demo4.getDisplay(); 
      transformWrapper();
    break;
   
    case DEMO5:
      demo5.update();
      //demo5.display();
      currentFrame = demo5.getDisplay(); 
      transformWrapper();
    break;
    
    case DEMO6:
      demo6.update();
      //demo5.display();
      currentFrame = demo6.getDisplay(); 
      transformWrapper();
    break;
    
    case DEMO7:
      demo7.update();
      demo7.display();
      currentFrame = demo7.getDisplay(); 
      transformWrapper();
    break;
    
    case DEMO10:
      demo10.update();
      demo10.display();
      currentFrame = demo10.getDisplay(); 
      transformWrapper();
    break;
    
    case DEMO11:
      demo11.update();
      demo11.display();
      currentFrame = demo11.getDisplay(); 
      transformWrapper();
    break;
    
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
      float inputLevel = map(mouseY, 0, height, 1.0f, 0.0f);
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
      pg.ellipse(0,0,6,6);
      pg.popMatrix();
      pg.endDraw();
    }
  
    public void borders() {
      if (position.x < -r) position.x = width+r;
      if (position.y < -r) position.y = height+r;
      if (position.x > width+r) position.x = -r;
      if (position.y > height+r) position.y = -r;
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


// Perlin2
class Demo10 {
  PGraphics pg;
  ArrayList<Particle> particles_a = new ArrayList<Particle>();
  ArrayList<Particle> particles_b = new ArrayList<Particle>();
  ArrayList<Particle> particles_c = new ArrayList<Particle>();
  
  int nums = 500;
  int noiseScale = 800;

  public Demo10() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT, P3D);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
    
    for(int i = 0; i < nums; i++){
      particles_a.add(new Particle(random(0, width),random(0,height)));
      particles_b.add(new Particle(random(0, width),random(0,height)));
      particles_c.add(new Particle(random(0, width),random(0,height)));
    }
    
  }
  
  public void update() {
    if(play) {

      
      float alpha;
      for(int i = 0; i<nums; i++) {
        alpha = map(i,0,nums,0,250);
        Particle a = particles_a.get(i);
        Particle b = particles_b.get(i);
        Particle c = particles_c.get(i);
        
        a.move();
        a.checkEdge();
        b.move();
        b.checkEdge();
        c.move();
        c.checkEdge();
      }
    }
  }
  
  public void display() {
    if(play) {
      float radius;
      
      pg.beginDraw();
      pg.background(0);
      for(int i = 0; i<nums; i++) {
        radius = map(i,0,nums,1,2);
        Particle a = particles_a.get(i);
        Particle b = particles_b.get(i);
        Particle c = particles_c.get(i);
        
        a.display(radius);
        b.display(radius);
        c.display(radius);
      }
      
   
      pg.endDraw();
    }
  }
  
  public PImage getDisplay() {
    return pg;
  }
  
  public void reset() {
  }
  
  class Particle {
    PVector dir = new PVector(0, 0);
    PVector vel = new PVector(0, 0);
    PVector pos;
    float speed = 0.4f;
    
    public Particle(float x, float y) {
      pos = new PVector(x, y);
    }
  
    public void move () {
      float angle = noise(pos.x/noiseScale, pos.y/noiseScale)*TWO_PI*noiseScale;
      dir.x = cos(angle);
      dir.y = sin(angle);
      vel = dir.copy();
      vel.mult(speed);
      pos.add(vel);
    }
  
    public void checkEdge(){
      if(pos.x > width || pos.x < 0 || pos.y > height || pos.y < 0){
        pos.x = random(50, width);
        pos.y = random(50, height);
      }
    }
  
    public void display(float r){
      pg.fill(0,0,255);
      pg.ellipse(pos.x, pos.y, r, r);
    }
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
  
  public Demo11() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();

    initList();
  }
  
  public void initList() {
    File[] pics = folder.listFiles();
    filenames = new String[pics.length];
    for (int i = 0; i < pics.length; filenames[i] = pics[i++].getPath());
    if(filenames.length > 0) {
      foundFiles = true;
      for(int i = 0; i< filenames.length; i++) {
        String[] absolutePath = split(filenames[i], '/');
        files.append(absolutePath[absolutePath.length-1]);
      }
    }
    if(foundFiles) {
      for (int i = files.size() - 1; i >= 0; i--) if (files.get(i).equals(".DS_Store")) files.remove(i);
      List l = new ArrayList();
      for (String f : files) {
        l.add(f);
      }
      
      cp5.get(ScrollableList.class, "imageList").addItems(l).setPosition(14, 160);
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
  
  public void getImage() {
    println("loading file: "+ files.get(pointer));
    p = loadImage(sketchPath("") +"data/"+path+"/"+files.get(pointer));
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
  public void settings() {  size(1000,600,P3D);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "visualController" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
