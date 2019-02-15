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
float sliderBrightness = 255;
int sliderOptions = 0;
int sliderOptions2 = 0;

float rotationSpeed = 0.001;

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


void setup() {
  size(1000,600,P3D);
  colorMode(HSB, 360, 100, 255);
  smooth();
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
