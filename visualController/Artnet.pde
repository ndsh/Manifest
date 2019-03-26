void feedFrame(PImage p) {
  //image(p, 0, 0);
  p.loadPixels();
  for (int y = 0; y<totalRows; y++) {
    for(int x = 0; x<720; x++) {
      color c = p.pixels[y*p.width+x];
      rows.get(y).setPixel(x, (byte)lightGain((int)brightness(c)));
    }
  }
}



void send() {
  if(!offline) {
    for(int y = 0; y<totalRows; y++) {
      rows.get(y).send();
    }
  }
}
