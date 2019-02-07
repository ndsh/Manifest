int universeSizeA = 120;
int universeSizeB = 40;
int univerSizeMax = universeSizeA+universeSizeB;

int universalSize = 80; // später 360 weil 9 streifen * 40 leds

int maxLEDs = 120;
// byte[zeilen][spalten]
byte[][] dmxA = new byte[4][120];
byte[][] dmxB = new byte[4][universalSize];
int universes = 4; // manifest wird 60 universen haben

byte[][] pixelTemp = new byte[60][360];

// PIXEL ROUTER
// 0 = ACAC

static final String router1 = "2.12.4.83";
static final String router2 = "2.161.30.223";

void feedFrame(PImage p) {
  //image(p, 0, 0);
  p.loadPixels();
  for (int y = 0; y<4; y++) {
    for(int x = 0; x<720; x++) {
      color c = p.pixels[y*p.width+x]; //.get(x,y);
      mapPixels(x,y, lightGain((int)brightness(c)));
    }
  }
}

/*
void mapPixels(int x, int y, int brightness) {
  if(x >= 0 && x <= 39) {
    dmxB[y][x] = (byte)brightness;
  } else if(x > 39 && x <= 120) { 
    //int remapped = (int)map(x, 0, 120, 80, 0);
    int remapped = 120-x;
    dmxA[y][remapped] = (byte)brightness;
  }
}
*/

void mapPixels(int x, int y, int brightness) {
  if(x >= 0 && x <= 79) {
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

void send() {
  if(!offline) {
    for(int u = 0; u < universes; u++) {
      //artnet.unicastDmx(router1, 0, u, dmxA[u]);
      artnet.unicastDmx(router2, 0, u, dmxB[u]);
    }
  }
}
