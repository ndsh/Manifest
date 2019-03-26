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

void createDemos() {
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

String getStateName(int state) {
  return stateNames[state];
}

void stateMachine(int state) {
  
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
 
  void update() {
    if(play && currentFrame != null) {
      //manifest.setFrame(transformFrame(currentFrame));
      //feedFrame(transformFrame(currentFrame));
      transformWrapper();
      //send();
    }
  }
  
  void display() {

  }
  void displayY() {
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
  
  PImage getDisplay() {
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
      float inputLevel = map(mouseY, 0, pg.height, 1.0, 0.0);
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
      pg.ellipse(0,0,5,10);
      pg.popMatrix();
      pg.endDraw();
    }
  
    void borders() {
      if (position.x < -r) position.x = pg.width+r;
      if (position.y < -r) position.y = pg.height+r;
      if (position.x > pg.width+r) position.x = -r;
      if (position.y > pg.height+r) position.y = -r;
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

// Wellen
class Demo8 {
  float position = 0;
  PGraphics pg;
  
  public Demo8() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.colorMode(HSB, 360, 100, 255);
  }
  
  void update() {
    if(play) {
    }
  }
  
  void display() {
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
      position += v0 / 255.0 / Math.PI;
    }
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
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
  
  void update() {
    if(play) {
    }
  }
  
  void display() {
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
      position += v0 / 255.0 / Math.PI;
    }
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
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
  
  color black = color(0, 0, 0);
  color white = color(0, 0, 255);
  color gray = color(0, 0, 125);
  
  int position = 0;
  
  boolean reset = false;
  
  
  public Demo10() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
    pg.beginDraw();
    pg.colorMode(HSB, 360, 100, 255);
    pg.endDraw();
  }
  
  void update() {
    if(play) {
        if(millis() - prevMillis < sliderOptions) return;
        prevMillis = millis();
        position-=sliderOptions2;
        position%=MANIFEST_HEIGHT;
      }
  }
  
  void display() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      setGradient(0, position, MANIFEST_WIDTH, MANIFEST_HEIGHT, black, white, Y_AXIS);
      //setGradient(0, position+261, MANIFEST_WIDTH, MANIFEST_HEIGHT*2, white, black, Y_AXIS);
      //setGradient(0, MANIFEST_HEIGHT, MANIFEST_WIDTH, position, gray, white, X_AXIS);
      pg.endDraw();
    }
  }
  
  void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {
    noFill();
  
    if (axis == Y_AXIS) {  // Top to bottom gradient
      for (int i = y; i <= y+h; i++) {
        float inter = map(i, y, y+h, 0, 1);
        color c = lerpColor(c1, c2, inter);
        pg.stroke(c);
        pg.line(x, i, x+w, i);
      }
    }  
    else if (axis == X_AXIS) {  // Left to right gradient
      for (int i = x; i <= x+w; i++) {
        float inter = map(i, x, x+w, 0, 1);
        color c = lerpColor(c1, c2, inter);
        pg.stroke(c);
        pg.line(i, y, i, y+h);
      }
    }
  }

  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {

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
  
  void initList() {
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
  
  void setImage(int i) {
    i = i % files.size();
    if (i < 0) i += files.size();
    pointer = i;
    getImage();
  }
  
  void nextImage() {
    setImage(pointer+1);
  }
  
  void getImage() {
    println("loading file: "+ files.get(pointer));
    if(!external) p = loadImage(sketchPath("") +"data/"+path+"/"+files.get(pointer));
    else p = loadImage(externalPath+"img/"+files.get(pointer));
    
    
  }
 
  
  void reset() {
    
  }
}
