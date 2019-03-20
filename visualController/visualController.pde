// Zeilenabstand am Muster von Unterkante zu Oberkante: 4 Profile + 0,9cm = 8,1cm
import peasy.*;
import ch.bildspur.artnet.*;
import controlP5.*;
import processing.sound.*;
import java.util.*;

// linux video
//import gohai.glvideo.*;
//GLMovie movie;

// osx video
import processing.video.*;
Movie movie;

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


color bg = color(50);
color object = color(40);

// runtime / volatile variables
PImage currentFrame;
PImage previousFrame;
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
String fileName = "";
int sliderOptions = 0;
int sliderOptions2 = 0;
int sliderOptions3 = 0;
int sliderOptions4 = 0;

float rotationSpeed = 0.001;

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

void setup() {
  size(1280,800,P3D);
  colorMode(HSB, 360, 100, 255);
  smooth();
  
  
  
  if(OS.equals("macosx")) externalPath = "/Volumes/INHALTE/";
  else externalPath = "/media/thegreeneyl/INHALTE/";  
  String filePath = "";
  if(fileExists("settings.json", externalPath, false)) {
   loadSettings(externalPath+"settings.json");
   filePath = externalPath+"content/"+fileName;
   externalSettings = true;
   println("[success] loaded settings.json from external");
  } else{
   loadSettings("data/settings.json");
   filePath = "demos/"+fileName;
   println("[fail] loaded settings.json from internal");
  }
  
  manifest = new Manifest(object);

  camera = new PeasyCam(this, 100);
  setupCamera();  
  
  cp5 = new ControlP5(this);
  constructGUI();
  
  initUDP();

  // osx
  if(!externalSettings && !fileExists(fileName, "demos/", true)) {
    println("[error] the following file from internal settings couldn't be loaded from /data folder: " + fileName);
    println("[warning] the sketch will close now");
  } else if(externalSettings && !fileExists(fileName, externalPath, false)) {
    println("[error] the following file from external settings couldn't be loaded from external media: " + fileName);
    println("[warning] the sketch will close now");
  }
  movie = new Movie(this, filePath);
  //movie = new Movie(this, "demos/test19_bl.mp4");
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

void draw() {
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
