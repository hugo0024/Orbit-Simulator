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

class Planet extends SimSphere {

  Timer timer = new Timer();

  PVector location = new PVector(width/2, height/2);
  PVector velocity = new PVector(0, 0);
  PVector acceleration = new PVector(0, 0);
  PVector force;
  
  String planetName;

  float mass = 1;
  float attractorMass;
  float radius = 1;
  float G = 1;
  float frictionAmount = 0;
  float distance;
  float A, B, C;
  float destabilise = 0.15;
  float trailSize;

  boolean showOrbitTrails = true;
  boolean showDistanceTrails = true;
  boolean isSelected = false;

  ArrayList<PVector> trail;

  Planet(PVector startPos, float rad, PImage img, String planetName) {
    init(new PVector(0, 0, 0), rad, img);
    setTransformAbs(1, 0, 0, 0, startPos);
    this.planetName = planetName;
    location = getOrigin();
    setLevelOfDetail(50);
    trail = new ArrayList<PVector>();

    A = random(0, 255);
    B = random(0, 255);
    C = random(0, 255);
  }

  public void drawMe() {
    update();
    setTransformAbs(1, 0, 0, 0, location);
    super.drawMe();
  } 

  void attractBy(Star s) {
    force = PVector.sub(s.location, location);  
    float d = force.mag();
    distance = d;
    trailSize = 3.14 *2 * distance;
    //d = constrain(d, 5.0, 25.0);
    force.normalize();
    float strength = ((G * mass * s.mass) / (d * d))*10000;
    force.mult(strength);//.mult(10000);
    addForce(force);

    if (showOrbitTrails) {
      int trailLength;
      location = getOrigin();
      trail.add(location);
      trailLength = trail.size() - 2;

      for (int i = 0; i < trailLength; i++) {
        PVector currentTrail = trail.get(i);
        PVector previousTrail = trail.get(i + 1);
        PVector Trailsub = PVector.sub(previousTrail, currentTrail);
        float t = Trailsub.mag();

        SimRay rray = new SimRay( previousTrail, currentTrail);
        drawray(rray, t, A, B, C);
      }
      if (trailLength >= trailSize) {
        trail.remove(0);
      }
    }    
    if (!showOrbitTrails) {
      trail.clear();
    }
    if (showDistanceTrails) {
      SimRay ray = new SimRay( getOrigin(), PVector.add(getOrigin(), force));
      drawray(ray, distance, 255, 255, 255);
    }
  }

  void drawray(SimRay r, float rayLength, float R, float G, float B) {
    PVector farPoint = r.getPointAtDistance(rayLength);
    pushStyle();  
    stroke(R, G, B); 
    line(r.origin.x, r.origin.y, r.origin.z, farPoint.x, farPoint.y, farPoint.z);
    popStyle();
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
