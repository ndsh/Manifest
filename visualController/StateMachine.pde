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
void createDemos() {
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

String getStateName(int state) {
  return stateNames[state];
}

void stateMachine(int state) {
  
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
  
  void update() {
    if(play) {
      val = (exp(sin(millis()/2000.0*(PI/2))) - 0.36787944)*108.0;
    }
  }
  
  void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      pg.background(lightGain(val));
      position += 50 / 255.0 / Math.PI;
      pg.endDraw();
    }
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
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
  
  void update() {
    if(play) {
      interval = round(map(sliderOptions2, 0, 100, 200, 0));
      if(millis() - lastMillis > interval) {
        lastMillis = millis();
        position++;
        if(position > x_limit) position = 0;
      }  
    }
  }
  
  void display() {
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
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
    
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
  
  void update() {
    if(play) {
        if(millis() - prevMillis < sliderOptions) return;
        prevMillis = millis();
        row --;
        if(row < 0) row = MANIFEST_HEIGHT;
      }
  }
  
  void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      pg.fill(0,0,lightGain(255));
      pg.rect(0, row, 720, 10);
      pg.endDraw();
    }
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
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
  
  void update() {
    if(play) {
      float inputLevel = map(mouseY, 0, height, 1.0, 0.0);
      input.amp(inputLevel);
    
      // loudness.analyze() return a value between 0 and 1. To adjust
      // the scaling and mapping of an ellipse we scale from 0 to 0.5
      float volume = loudness.analyze();
      size = round(map(volume, 0, 0.5, 0, 255));
    }
  }
  
  void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      pg.background(lightGain(size));
      pg.endDraw();
    }
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
    position = 0;
  }
}

// Perlin
class Demo5 {
  // based on: https://processing.org/examples/noise3d.html
  PGraphics pg;
 
  float increment = 0.01;
  // The noise function's 3rd argument, a global variable that increments once per cycle
  float zoff = 0.0;  
  // We will increment zoff differently than xoff and yoff
  float zincrement = 0.02; 
  
  public Demo5() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
  }
  
  void update() {
    if(play) {
      // Optional: adjust noise detail here
      int octave = round(map(sliderOptions, 0, 100, 8, 0));
      float falloff = map(sliderOptions2, 0, 100, 0.0f, 1.0f);
      noiseDetail(octave,falloff);
      
      pg.loadPixels();
      pg.beginDraw();
    
      float xoff = 0.0; // Start xoff at 0
      
      // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
      for (int x = 0; x < pg.width; x++) {
        xoff += increment;   // Increment xoff 
        float yoff = 0.0;   // For every xoff, start yoff at 0
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
  
  void display() {
    
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
    
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
  
  void update() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      pg.endDraw();
      flock.run();
    }
  }
  
  
  void display() {
    if(play) {
      
    }
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
  }
  
  class Flock {
    ArrayList<Boid> boids; // An ArrayList for all the boids
    Flock() {
      boids = new ArrayList<Boid>(); // Initialize the ArrayList
    }
    void run() {
      for (Boid b : boids) {
        b.run(boids);  // Passing the entire list of boids to each boid individually
      }
    }
    void addBoid(Boid b) {
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
      r = 2.0;
      maxspeed = 2;
      maxforce = 0.03;
    }
  
    void run(ArrayList<Boid> boids) {
      flock(boids);
      update();
      borders();
      render();
    }
  
    void applyForce(PVector force) {
      acceleration.add(force);
    }
  
    void flock(ArrayList<Boid> boids) {
      PVector sep = separate(boids);   // Separation
      PVector ali = align(boids);      // Alignment
      PVector coh = cohesion(boids);   // Cohesion
      sep.mult(1.5);
      ali.mult(1.0);
      coh.mult(1.0);
      applyForce(sep);
      applyForce(ali);
      applyForce(coh);
    }
  
    void update() {
      velocity.add(acceleration);
      velocity.limit(maxspeed);
      position.add(velocity);
      acceleration.mult(0);
    }
  
    PVector seek(PVector target) {
      PVector desired = PVector.sub(target, position);
      desired.setMag(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);  // Limit to maximum steering force
      return steer;
    }
  
    void render() {
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
  
    void borders() {
      if (position.x < -r) position.x = width+r;
      if (position.y < -r) position.y = height+r;
      if (position.x > width+r) position.x = -r;
      if (position.y > height+r) position.y = -r;
    }
  
    PVector separate (ArrayList<Boid> boids) {
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
  
    PVector align (ArrayList<Boid> boids) {
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
  
    PVector cohesion (ArrayList<Boid> boids) {
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
  
  void update() {
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
  
  void display() {
    pg.beginDraw();
    pg.background(0);
    pg.noStroke();
    pg.fill(lightGain(0,0,255));
    int thick = round(map(sliderOptions, 0, 100, 1, 100));
    pg.rect(position, 0, thick, pg.height);
    pg.endDraw();
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
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
  
  void update() {
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
  
  void display() {
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
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
  }
  
  class Particle {
    PVector dir = new PVector(0, 0);
    PVector vel = new PVector(0, 0);
    PVector pos;
    float speed = 0.4;
    
    public Particle(float x, float y) {
      pos = new PVector(x, y);
    }
  
    void move () {
      float angle = noise(pos.x/noiseScale, pos.y/noiseScale)*TWO_PI*noiseScale;
      dir.x = cos(angle);
      dir.y = sin(angle);
      vel = dir.copy();
      vel.mult(speed);
      pos.add(vel);
    }
  
    void checkEdge(){
      if(pos.x > width || pos.x < 0 || pos.y > height || pos.y < 0){
        pos.x = random(50, width);
        pos.y = random(50, height);
      }
    }
  
    void display(float r){
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
  
  void initList() {
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
      
      cp5.get(ScrollableList.class, "images").addItems(l).setPosition(14, 160);
      getImage();
      
    }
  }
  
  void update() {
    if(play) {
      
    }
  }
  
  void display() {
    pg.beginDraw();
    pg.background(0);
    pg.noStroke();
    pg.image(p, 0, 0);
    pg.endDraw();
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void setImage(String s) {
    for(int i = 0; i<files.size(); i++) {
       if(files.get(i).equals(s)) {
         pointer = i;
         getImage();
         return;
       }
    }
  }
  
  void getImage() {
    println("loading file: "+ files.get(pointer));
    p = loadImage(sketchPath("") +"data/"+path+"/"+files.get(pointer));
  }
 
  
  void reset() {
    
  }
}
