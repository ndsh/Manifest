class Manifest {
  ArrayList<Stripe> stripes = new ArrayList<Stripe>();
  
  color object = color(40);
  PImage p;
  PGraphics pg;
  
  boolean isUpdatable = false;
  int frameType = 0;
  
  float distance = 23.3;
   
  public Manifest(color o) {
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
  
  void setFrame(PImage _p) {
    p = _p;
    frameType = 1;
    isUpdatable = true;
    //println("setFrame for PImage");
  }
  
  void setFrame(PGraphics _pg) {
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
  
  void update() {
    if(redraw) {
      if(isUpdatable && frameType > 0) {
        reset();
        if(frameType == 1) {
           p.loadPixels();
           for(int x = 0; x<720; x++) {
             for(int y = 0; y<30; y++) {
               color c = p.pixels[y*p.width+x];//color c = p.get(x,y);
               setPixel(x,y, lightGain((int)brightness(c)));
             }
           }
        } else if(frameType == 2) {
        }
        
        isUpdatable = false;
      }
    }
  }
  
  void display() {
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
        box(390.5, 15, 40.5);
      popMatrix();
      
      pushMatrix();
        translate(-175, -145, 0);
        for (Stripe stripe : stripes) {
          stripe.display();
        }
      popMatrix();
    }
  }
  
  void setPixel(int x, int y, int value) {
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
  
  void reset() {
    //println("reset of stripe pixels");
    for(int x = 0; x<720; x++) {
      for(int y = 0; y<30; y++) {
        setPixel(x, y, 0);
      }
    }
  }
}
