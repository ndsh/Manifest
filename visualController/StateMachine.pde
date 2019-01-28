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

static final int MAX_STATES = 11;

// Demo Objects
Demo1 demo1;
Demo3 demo3;
void createDemos() {
  demo1 = new Demo1();
  demo3 = new Demo3();
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
  "Video Loop",
  "Atmen", "Lichtstreifen", "Hochwandern",
  "Soundreaktiv", "Zickzack", "Video",
  "PingPong", "Wellen", "Invertierte Wellen",
  "Zeilen"
};

String getStateName(int state) {
  return stateNames[state];
}

void stateMachine(int state) {
   switch(state) {
    case NONE:
      // feed the manifest with data
      if(play && currentFrame != null) {
        manifest.setFrame(transformFrame(currentFrame));
        reset();
        feedFrame(transformFrame(currentFrame));
        send();
      }
    break;
    
    case DEMO1:
      demo1.update();
      currentFrame = demo1.getDisplay(); 
      manifest.setFrame(transformFrame(currentFrame));
      
      feedFrame(transformFrame(currentFrame));
      send();
    break;
    
    case DEMO3:
      demo3.update();
      currentFrame = demo3.getDisplay(); 
      manifest.setFrame(transformFrame(currentFrame));
      
      feedFrame(transformFrame(currentFrame));
      send();
    break;
   }
}

// Breathe
class Demo1 {
  float position = 0;
  PGraphics pg;
  
  public Demo1() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
  }
  
  void update() {
    if(play) {
      pg.beginDraw();
      pg.background(0);
      float val = (exp(sin(millis()/2000.0*(PI/2))) - 0.36787944)*108.0;
      pg.background(lightGain(val));
      position += 50 / 255.0 / Math.PI;
      pg.endDraw();

    }
  }
  
  void display() {
    
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
    position = 0;
  }
}

// Hochwandern
class Demo3 {
  int row = 3;
  int val = 0;
  boolean direction = true;
  int position = 0;
  PGraphics pg;
  
  public Demo3() {
    pg = createGraphics(MANIFEST_WIDTH, MANIFEST_HEIGHT);
  }
  
  void update() {
    if(play) {
        pg.beginDraw();
        pg.background(0);
        //for (int x = 0; x<720; x++) {
          //dmxA[row][a] = (byte)val;
          pg.fill(0,0,lightGain(val));
          pg.rect(0, row, 720, 10);
          //mapPixels(x, row, lightGain(val));
        //}
        
        if(direction) val += sliderOptions;
        else val -= sliderOptions;
        
        if(val > 255) {
          direction = false;
          val = 255;
        } else if(val < 0) {
          direction = true;
          val = 0;
          row--;
          if(row < 0) row = 29;
          println("row switch:" + row);
        }
        pg.endDraw();
      }
  }
  
  void display() {
    
  }
  
  PImage getDisplay() {
    return pg;
  }
  
  void reset() {
    position = 0;
  }
}
