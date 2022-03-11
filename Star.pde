// Complete Mover class
// This mover class accelerates according to the force accumulated over TIME
// MASS is taken into consideration by using F=MA (or acceleation = force/mass)
// Mass is represented by the surface area of the ball
// 
// The system works thus:-
// within each FRAME of the system
// 1/ calculate the cumulative acceleration (by acceleration += force/mass) by adding all the forces, including friction
// 2/ scale the acceleration by the elapsed time since the last frame (will be about 1/60th second)
// 3/ Add this acceleration to the velocity
// 5/ Move the ball by the velocity scaled by the elapsed time since the last frame
// 5/ Set the acceleration back to zero again
// repeat

class Star extends SimSphere {

  Timer timer = new Timer();

  PVector location = new PVector(width/2, height/2);
  PVector velocity = new PVector(0, 0);
  PVector acceleration = new PVector(0, 0);
  float mass = 1;
  float radius = 1;
  float frictionAmount = 1;

  PImage img;
  PShape globe;

  Star(PVector startPos, float rad, PImage img) {
    init(new PVector(0, 0, 0), rad, img);
    setTransformAbs(1, 0, 0, 0, startPos);
    location = getOrigin();
    setLevelOfDetail(50);

    noStroke();
    noFill();
    img = loadImage("sun.jpg");
    globe = createShape(SPHERE, rad);
    globe.setTexture(img);
  }

  void attractBy(Planet p) {
    float G = 1;
    
    PVector force = PVector.sub(p.location, location);  
    float d = force.mag();
    //d = constrain(d, 5.0, 25.0);
    force.normalize();
    float strength = ((G * this.mass * p.mass) / (d * d))*10000;
    force.mult(strength);//.mult(10000);
    addForce(force);
  }

  public void drawMe() {
    update();

    setTransformAbs(1, 0, 0, 0, location);
    super.drawMe();
  } 

  void setMass(float m) {
    // converts mass into surface area
    mass=m;
    radius = 60 * sqrt( mass/ PI );
  }

  void update() {
    float ellapsedTime = timer.getElapsedTime();

    applyFriction();

    // scale the acceleration by time elapsed
    PVector accelerationOverTime = PVector.mult(acceleration, ellapsedTime);
    velocity.add(accelerationOverTime);

    // scale the movement by time elapsed
    PVector distanceMoved = PVector.mult(velocity, ellapsedTime);
    location.add(distanceMoved);

    // now that you have "used" your accleration it needs to be re-zeroed
    acceleration = new PVector(0, 0);

    checkForBounceOffEdges();
  }

  void addForce(PVector f) {
    // use F= MA or (A = F/M) to calculated acceleration caused by force
    PVector accelerationEffectOfForce = PVector.div(f, mass);
    acceleration.add(accelerationEffectOfForce);
  }

  void display() {
    stroke(0);
    strokeWeight(2);
    fill(127);

    ellipse(location.x, location.y, radius*2, radius*2);
  }



  void applyFriction() {
    // modify the acceleration by applying
    // a force in the opposite direction to its velociity
    // to simulate friction
    PVector reverseForce = PVector.mult( velocity, -frictionAmount );
    addForce(reverseForce);
  }


  void checkForBounceOffEdges() {
  }
}
