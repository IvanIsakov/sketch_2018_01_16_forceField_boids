float delta = 1.5;
int index = 0;
int partSize = 15;
ArrayList<Particle> particles = new ArrayList<Particle>();

void setup() {
  size(640,640);
  //loadPixels();
  //noLoop();
  for (int i = 0; i < 500; i++) {
    //color col1 = color(50+random(205),random(255),50+random(205));
    color col1 = color(255);
    //color col1 = color(255);
    Particle p = new Particle(random(width),random(height),col1,1);
    //Particle p = new Particle(width/2+random(-2,2),height/2+random(-2,2),height/2+random(-2,2),col1,1);
    p.velocity = new PVector(random(-3,3),random(-3,3));
    //p.velocity = new PVector(0,0);
    particles.add(p);
    //strokeWeight(3);
  }
  /*
  for (int i = 0; i < 3; i++) {
    color col1 = color(random(255),100+random(155),255);
    //color col1 = color(255);
    //Particle p = new Particle(random(width),random(height),random(height),col1,20);
    Particle p = new Particle(random(width),random(height),col1,20);
    //p.velocity = new PVector(random(-3,3),random(-3,3));
    p.velocity = new PVector(0,0);
    particles.add(p);
  }*/
  rectMode(CENTER);
  background(0);
}

void draw() {
  //lights();
  //background(0);
  //camera(-width/2 + mouseX,height/2,height/2 + mouseY,
 ////        width/2,height/2,0,
  //       0,1,0);
  //background(random(20),random(20),0);

  //noFill();
  //stroke(255);
  /*
  for (int i = 0; i < 10; i++) {
    stroke(random(155),random(155),30);
    float k = width*noise(index*0.005+i*2);
    line(k,0,k,height);
  }
  for (int i = 0; i < 10; i++) {
    stroke(random(155),random(155),30);
    float k = height*noise(index*0.005+i*3);
    line(0,k,width,k);
  }
  */
  noStroke();
  for (Particle p : particles) {
    p.applyForce(force(p.position.x, p.position.y, width/2 - 100, height/2 - 100),force(p.position.x, p.position.y, width/2 + 100, height/2 + 100));
   // p.applyViscosity();
    p.findNeighbour();
    p.update();
    p.display();
  }
  

  index++;
  /*
  for (int j = 0; j < height; j++) {
    //line(j,0,j,height/2 + 200*force(index,j).y);   
    for (int i = 0; i < width; i++) {
      pixels[i + j*width] = color(0, 100 + 100*force(i,j).y,0);
    }
  }
  updatePixels();
  index += 3;
  */
  //saveFrame("video3/flocking-3-####.tiff");
  
  if (keyPressed) {
    if (key == ' ') {
      saveFrame("force-field-still-####.png");
    }
  }
}

class Particle {
  PVector position,velocity,acceleration;
  color col;
  float mass;
  
  Particle(float x, float y, color c, float mass1) {
    position = new PVector(x,y);
    col = c;
    mass = mass1;
  }
  
  void update() {
    velocity.limit(10);
    
    PVector nois = PVector.random2D();
    nois.mult(0.3);
    velocity.add(nois);
    
    position.add(velocity);
    /*
    // Bounce of the wall
    if (position.x > width) {
      velocity.x = -velocity.x;
    } else if (position.x < 0) {
      velocity.x = -velocity.x;
    }
    if (position.y > height) {
      velocity.y = -velocity.y;
    } else if (position.y < 0) {
      velocity.y = -velocity.y;
    }
    */
    // Periodic boundary conditions:
    
     if (position.x > width) {
      position.x = 0;
    } else if (position.x < 0) {
      position.x = width;
    }
    if (position.y > height) {
      position.y = 0;
    } else if (position.y < 0) {
      position.y = height;
    }
    
  }
  
  void applyForce(PVector force, PVector force2) {
    if (red(col) > 127) {
      velocity.add(force);
    }
    if (blue(col) > 127) {
      velocity.add(force2);
    }
  }
  void applyViscosity() {
    PVector visc = new PVector();
    visc = PVector.mult(velocity,-0.005);
    velocity.add(visc);
  }
  
  void display() {
    stroke(100+75*velocity.x,100+75*velocity.mag(),155-75*velocity.y,50);
    //rect(position.x,position.y,partSize*0.5*sqrt(mass),partSize*0.5*sqrt(mass));
    line(position.x,position.y,position.x+0.2*partSize*velocity.x,position.y+0.2*partSize*velocity.y);
    //point(position.x,position.y);
    //3D
    //pushMatrix();
    //translate(position.x,position.y,position.z);
    //box(partSize*0.5*sqrt((mass)));
    //popMatrix();
  }
  
  void findNeighbour() {
    for (Particle p : particles) {
      PVector su = PVector.sub(position,p.position);
      if (su.mag() < 2*partSize && su.mag() != 0) {
        affectNeighbour(p);
        affectNeighbourDistance(p);
      }
    }
  }
  
  void affectNeighbour(Particle p) {
    PVector velOther = PVector.sub(p.velocity,velocity);
    PVector posOther = PVector.sub(p.position,position);
    if (posOther.mag() > partSize*0.3) {
      velocity.add(velOther.mult(0.04));
    } else {
      velocity.sub(velOther.mult(0.1));
    }
  }
  
  void affectNeighbourDistance(Particle p) {
    PVector velOther = PVector.sub(p.velocity,velocity);
    PVector posOther = PVector.sub(p.position,position);
    float r = posOther.mag();
    PVector attraction = PVector.mult(posOther,p.mass*1/sq(r)/mass);
    PVector repulsion = PVector.mult(posOther,0.01*p.mass/sq(r)/sq(r)/mass);
    //if (posOther.mag() > 0.5*partSize) {
    //  velocity.add(attraction);
    //  velocity.sub(repulsion);
    //} else
    if (posOther.mag() < 1*partSize) {
      PVector aux = p.velocity;
      p.velocity = velocity;
      velocity = aux;
      velocity.mult(p.mass/mass);
      p.velocity.mult(mass/p.mass);
    }
  }
}

PVector force(float x, float y, int attractorX, int attractorY) {
  PVector force;
  // Attractors:
  float FxX = 1/(sq(0.02*(y - attractorY)) + sq(delta));
  float FxY = -2*(x-attractorX)/sq(sq(0.02*(x - attractorX)) + sq(delta));
  float FyX = 1/(sq(0.02*(x - attractorX)) + sq(delta));
  float FyY = -2*(y-attractorY)/sq(sq(0.02*(y - attractorY)) + sq(delta));
  // Rings:
  force = new PVector(FxX*FxY,FyY*FyX);
  //force = new PVector(FxX*FxY,0.1);
  return force.mult(0.1);
}