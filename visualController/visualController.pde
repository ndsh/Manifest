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
Movie introMov;

PeasyCam camera;
ControlP5 cp5; 

Manifest manifest;
// declare all routers
ArrayList<Pixelrouter> routers = new ArrayList<Pixelrouter>();
String[] routerIPs = new String[16];

// declare all rows
ArrayList<LEDRow> rows = new ArrayList<LEDRow>();
int totalRows = 30;

color bg = color(50);
color object = color(40);

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
boolean deployed = false;
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
int introAmount = 0;

float rotationSpeed = 0.001;
String externalPath = "/media/thegreeneyl/INHALTE/";

// DEFINE SOURCE DIMENSIONS
int MANIFEST_WIDTH = 720;
int MANIFEST_HEIGHT = 261;

AudioIn input;
Amplitude loudness;

final String OS = platformNames[platform];
String mainMovieFilePath = "";

void setup() {
  size(1080,600,P3D);
  colorMode(HSB, 360, 100, 255);
  smooth();
  
  println("* * * * * * * * * * * * * * * * * * * * * * * * * * * * ");
  println("Manifest setup() information");
  if(OS.equals("macosx")) {
    println("\trunning on OSX");
    externalPath = "/Volumes/INHALTE/";
  } else {
    println("\t running on Linux");
    externalPath = "/media/thegreeneyl/INHALTE/";
  }
  
  if(fileExists("settings.json", externalPath, false)) {
   loadSettings(externalPath+"settings.json");
   mainMovieFilePath = externalPath+"content/"+fileName;
   externalSettings = true;
   println("\tsettings.json: external");
  } else{
   loadSettings("data/settings.json");
   mainMovieFilePath = "content/"+fileName;
   println("\tsettings.json: internal");
  }
  
  
  if(fileExists("settings.json", externalPath, false)) {
   loadRouters(externalPath+"routers.json");
   println("\trouters.json: external");
  } else {
   loadRouters("data/routers.json");
   println("\trouters.json: internal");
  }
  
  manifest = new Manifest(object);

  camera = new PeasyCam(this, 100);
  setupCamera();  
  
  cp5 = new ControlP5(this);
  constructGUI();
  state = tempState;
  
  initUDP();

  if(!externalSettings && !fileExists(fileName, "content/", true)) {
    println("\t[error] the following file from internal settings couldn't be loaded from content/ folder: " + fileName);
    println("\t[warning] the sketch will close now");
  } else if(externalSettings && !fileExists(fileName, externalPath, false)) {
    println("\t[error] the following file from external settings couldn't be loaded from external media: " + fileName);
    println("\t[warning] the sketch will close now");
  }
  
  loadIntro();
  
  movie = new Movie(this, mainMovieFilePath);
  
  
  createDemos();
  nextFrame = createImage(MANIFEST_WIDTH, MANIFEST_HEIGHT, RGB);
  println("* * * * * * * * * * * * * * * * * * * * * * * * * * * * ");
  
  for(int i = 0; i<routerIPs.length; i++) routers.add(new Pixelrouter(routerIPs[i]));  
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
  marke = loadImage("tge.png");
  introPrevMillis = millis();
}

void draw() {
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
      movie.loop();
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
