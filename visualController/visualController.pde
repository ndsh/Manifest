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

color bg = color(50);
color object = color(40);

// runtime / volatile variables
PImage currentFrame;
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


// DEFINE SOURCE DIMENSIONS
int MANIFEST_WIDTH = 720;
int MANIFEST_HEIGHT = 240;

AudioIn input;
Amplitude loudness;


void setup() {
  size(1000,600,P3D);
  colorMode(HSB, 360, 100, 255);
  smooth();
  //println(sliderBrightness);
  loadSettings("data/settings.json");
  //println(sliderBrightness);
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
  
}

void draw() {
  background(bg);
  dragging();   
  stateMachine(state);
  if(rotate) camera.rotateY(rotationSpeed);
  //getMovieFrame();
  manifest.update();
  manifest.display();
  
  updateGUI();
  drawGUI();
}

void getMovieFrame() {
  if(movie.available()) {
    movie.read();
    if(play && state == NONE) currentFrame = movie;
  }
}


void movieEvent(Movie m) {
  m.read();
  if(play && state == NONE) currentFrame = movie;
}
