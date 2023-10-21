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
