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
  
  void setPixel(int led, byte val) {
    if(reverseRow) { // A und B Zeilen
      shiftAB(led, val);
    } else { // C und D Zeilen
      shiftCD(led, val);
    }
  }
  
  void shiftAB(int led, int val) {
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
  void shiftCD(int led, int val) {
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
  
  
  int invert(int led) {
    int rm = 0;
    rm = round(map(led, 0, 719, 719, 0));
    return rm;
  }
  
  int flip(int led) {
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
  
  void setRouter(int i, Pixelrouter r) {
    routers[i] = r;
  }
  
  void updateRouters() {
  }
  
  void send() {
    //println("sending data to pixelrouters on ports: "+ ports[0] + " + " + ports[1]);
    routers[0].send(port, leds[0]);
    routers[1].send(port, leds[1]);
    // this method pushes led values in correct order to the pixel routers
  }
  
  void reset() {
    
    leds = new byte[2][360];
  }
  
  byte[][] getLEDs() {
    return leds;
  }
  byte[] getLEDs(int i) {
    return leds[i];
  }
  
  
}
