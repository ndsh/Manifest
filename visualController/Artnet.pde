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

void feedFrame(PImage p) {
  //image(p, 0, 0);
  p.loadPixels();
  for (int y = 0; y<totalRows; y++) {
    for(int x = 0; x<720; x++) {
      color c = p.pixels[y*p.width+x]; //.get(x,y);
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
void mapPixels(int x, int y, int brightness) {
  if(x >= 0 && x < universalSize) {
    dmxA[y][x] = (byte)brightness;
    dmxB[y][x] = (byte)brightness;
  }
}

void reset() {
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

void send() {
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
