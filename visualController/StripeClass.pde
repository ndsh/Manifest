class Stripe {
  
  PVector pos;
  float rotation = 0;
  boolean flip = false;
  int axisFlip = 0;
  
  int[] lights = new int[40];
  
  public Stripe(float x, float y, float z) {
    pos = new PVector(x, y, z);
  }
  
  public Stripe(float x, float y, float z, float r) {
    pos = new PVector(x, y, z);
    rotation = r;
  }
  
  public Stripe(float x, float y, float z, boolean f, int a) {
    pos = new PVector(x, y, z);
    flip = f;
    axisFlip = a;
  }
  
  public Stripe(float x, float y, float z, float r, boolean f, int a) {
    pos = new PVector(x, y, z);
    rotation = r;
    flip = f;
    axisFlip = a;
  }
  
  void update() {
    
  }
  
  void setPixel(int index, int value) {
    lights[index] = value;
  }
  
  void setRotation(float radiant) {
    
  }
  
  void display() {
    pushMatrix();
    pushStyle();
    
    // transformations
    translate(pos.x, pos.y, pos.z);
    
    rotateY(radians(rotation));
    
    // texture
    pushMatrix();
    pushStyle();
    
    if(!flip) translate(-25, -0.9, 1.8);
    else  {
      translate(25, -0.9, -1.8);
      if(axisFlip == 0) ; //rotateX(radians(180)); 
      else if(axisFlip == 1) rotateY(radians(180));
      else if(axisFlip == 2) rotateZ(radians(180));
    }
    if(axisFlip == 2) translate(0, -1.8, 0);
    noStroke();
    for(int i = 0; i<40; i++) {
      fill(0, 0, lights[i]);
      //fill(240);
      rect(i*1.25, 0, 1.25, 1.8);
    }
    
    //rect(0, 0, 50, 1.8);
    
    popStyle();
    popMatrix();
    
    if(flip) {
      if(axisFlip == 0) rotateX(radians(180)); 
      else if(axisFlip == 1) rotateY(radians(180));
      else if(axisFlip == 2) rotateZ(radians(180));
    }
    // profile
    fill(10);
    //box(50,1.8,2.6);
    box(50,1.8,2.4);
    
    popStyle();
    popMatrix();
  }
}
