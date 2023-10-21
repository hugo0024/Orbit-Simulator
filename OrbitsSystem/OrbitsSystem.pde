import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;

SimCamera myCamera;
SimCamera myCamera2;
SimRay selectedPlanetRay;
SimpleUI myUI;
SimRect hudArea;
Robot robot;

Star sun;
Planet selectedPlanet;
Planet mercury;
Planet venus;
TextDisplayBox fpsLabel;

ArrayList<Planet> allPlanet = new ArrayList<Planet>();
ArrayList<Star> allStar = new ArrayList<Star>();
PVector cameraPos = new PVector(2691.7666, -658.442, 587.4097);
PVector cameraPosTopDown = new PVector(0, -5000, 1);
PVector cameraPos1 = new PVector(3894.076, -647.85504, -666.1627);
PVector forceToAdd = new PVector(5000, 0, 0);
PVector addForceRayDir, aty, atz;
PVector previousCameraPos, previousCameraLookAt, planetCameraPos;
PImage sunT, mercuryT, venusT, earthT, marsT, jupiterT, saturnT, uranusT, neptuneT, plutoT;
float angby=0, angbz=0, Zmag = 2;  
int newZmag = 0;
int currentPlanetnumber = 0;
String fps;

TextDisplayBox SelectedPlanetName;
TextDisplayBox SelectedPlanetDistance;
TextDisplayBox SelectedPlanetMass;
TextDisplayBox SelectedPlanetX;
TextDisplayBox SelectedPlanetY;
TextDisplayBox SelectedPlanetZ;
SimpleButton nextPlanet;
SimpleButton previousPlanet;
SimpleButton unfollowPlanet;
TextInputBox editForceToAdd;
Slider forceToAddSlider;

void setup() {
  ///////////////////////////////////////////////////////////////////////////////////////
  size(1600, 1000, P3D);
  myUI = new SimpleUI();
  hudArea = new SimRect(0, 300, 200, 600);
  myCamera = new SimCamera();
  myCamera.setPositionAndLookat(cameraPos, vec(0, 0, 0));
  myCamera.setSpeed(30);
  myCamera.isMoving = true;
  myCamera.setHUDArea(0, 0, 1600, 49);

  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
    exit();
  }

  ///////////////////////////////////////////////////////////////////////////////////////
  sunT = loadImage("sun.jpg");
  mercuryT = loadImage("mercury.jpg");
  venusT = loadImage("venus.jpg");
  earthT = loadImage("earth.jpg");
  marsT = loadImage("mars.jpg");
  jupiterT = loadImage("jupiter.jpg");
  saturnT = loadImage("saturn.jpg");
  uranusT = loadImage("uranus.jpg");
  neptuneT = loadImage("neptune.jpg");
  plutoT = loadImage("pluto.jpg");

  sun = new Star(vec(0, 0, 0), 200.0f, sunT);
  sun.setMass(5);
  allStar.add(sun);

  mercury = new Planet(vec(800, 0, 0), 8.0f, mercuryT, "Mercury");
  mercury.velocity = new PVector(0, 0, -250);
  allPlanet.add(mercury);

  venus = new Planet(vec(1300, 0, 0), 20.0f, venusT, "Venus");
  venus.velocity = new PVector(0, 0, 320);
  allPlanet.add(venus);

  addUI();
  frameRate(60);
}

void draw() {
  background(0);
  // draw the 3d stuff
  stroke(255, 255, 255);
  noStroke();

  fps = str(int(frameRate));

  sun.drawMe();
  mercury.attractBy(sun);
  venus.attractBy(sun);
  mercury.drawMe();
  venus.drawMe();
  myCamera.update();
  castAddForceRay();
  transAddForceRay();

  //drawMajorAxis(new PVector(0, 0, 0), 200);
  myCamera.startDrawHUD();

  fpsLabel.setText(fps);

  if (selectedPlanet != null) {
    fill(255, 255, 255, 100);
    rect( hudArea.left, hudArea.top, hudArea.getWidth(), hudArea.getHeight());
  }
  myUI.update();
  updateUI();
  myCamera.endDrawHUD();
}

void castAddForceRay() {
  if (selectedPlanet != null) {
    selectedPlanetRay = new SimRay( selectedPlanet.getOrigin(), PVector.add(selectedPlanet.getOrigin(), addForceRayDir));
    drawray(selectedPlanetRay, 500, 255, 0, 0);
    previousCameraPos =  myCamera.cameraPos;
    previousCameraLookAt = myCamera.cameraLookat;
    float selectedPlanetX = selectedPlanet.location.x;
    float selectedPlanetY = selectedPlanet.location.y - 1000;
    float selectedPlanetZ = selectedPlanet.location.z + 1000;

    myCamera.setPositionAndLookat(new PVector (selectedPlanetX, selectedPlanetY, selectedPlanetZ), selectedPlanet.location);
  }
}

void transAddForceRay() {
  addForceRayDir = forceToAdd.copy();
  rotatePVY(angby);
  rotatePVZ(angbz);
}

void rotatePVY(float angby) {
  aty = new PVector(forceToAdd.x, forceToAdd.z);
  aty.rotate(angby);
  aty.set(aty.x, forceToAdd.y, aty.y);
  aty.sub(forceToAdd);
  addForceRayDir.add(aty);
}

void rotatePVZ(float angbz) {
  atz = new PVector(forceToAdd.x, forceToAdd.y);
  atz.rotate(angbz);
  atz.set(atz.x, atz.y, forceToAdd.z);
  atz.sub(forceToAdd);
  addForceRayDir.add(atz);
}


void main_keyPressed(float e) {
  float speed = 0.056;
  if (keyPressed && key == 'y' ) { 
    angby += e * speed;
    if ( abs(angby) > TAU ) angby = 0;
    println(" key y: angby "+int(degrees(angby)));
  }
  if ( keyPressed && key == 'z' ) { 
    angbz += e * speed;
    if ( abs(angbz) > TAU ) angbz = 0;
    println(" key z: angbz "+int(degrees(angbz)));
  }
  if (  keyPressed && key == 'r' ) {
    angby=angbz=0;
    println("reset");
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if ( !keyPressed ) {
    float newZmag = event.getCount()/3.0; 
    Zmag += newZmag;
  }
  main_keyPressed(e);
}


void mousePressed() {
  if (mouseButton == RIGHT) return;
  SimRay mr =  myCamera.getMouseRay();

  for (int n = 0; n < allPlanet.size(); n++) {
    Planet thisPlanet = allPlanet.get(n);
    if ( mr.calcIntersection( thisPlanet)) {
      selectedPlanet = thisPlanet;
      return;
    } else {
      //selectedPlanet = null;
    }
  }
}

void keyPressed() {
  if (key == 'p') { 
    println("camera pos ", myCamera.cameraPos, " looKat ", myCamera.cameraLookat);
  }
  if (key == '1') { 
    myCamera.setPositionAndLookat(cameraPos, vec(0, 0, 0));
  }
  if (key == '2') { 
    myCamera.setPositionAndLookat(cameraPosTopDown, vec(0, 0, 0));
  }
  if (key == '3') { 
    myCamera.setPositionAndLookat(cameraPos1, vec(0, 0, 0));
  }
  if (key == ' ' && selectedPlanet != null) { 
    selectedPlanet.addForce(addForceRayDir);
  }
  if (key == 'q') {
  }
}

public void addUI() {  
  String[] menuItems = {"Free", "Top Down", "Follow"};
  Menu CameraMenu = myUI.addMenu("Cameras Menu", 20, 12, menuItems);
  CameraMenu.setWidgetDims(100, 27);
  CameraMenu.textSize = 12;

  ToggleButton OrbitTrailsBtn = myUI.addToggleButton("Orbit Trails", 200, 12);
  OrbitTrailsBtn.setWidgetDims(78, 27);
  OrbitTrailsBtn.setSelected(true);
  OrbitTrailsBtn.textSize = 12;

  ToggleButton DistanceTrailsBtn = myUI.addToggleButton("Distance Trails", 285, 12);
  DistanceTrailsBtn.setWidgetDims(95, 27);
  DistanceTrailsBtn.setSelected(true);
  DistanceTrailsBtn.textSize = 12;

  SimpleButton ClearTrailsBtn = myUI.addSimpleButton("Clear Trails", 388, 12);
  ClearTrailsBtn.setWidgetDims(95, 27);

  Slider SunMassSlider = myUI.addSlider("Sun Mass", 500, 11);
  SunMassSlider.setSliderValue(0.5);

  TextDisplayBox StarLabel = myUI.addTextDisplayBox("Star", 1350, 12, str(allStar.size()) );
  StarLabel.setWidgetDims(80, 27);
  StarLabel.textSize = 12;

  TextDisplayBox PlanetLabel = myUI.addTextDisplayBox("Planet", 1440, 12, str(allPlanet.size()));
  PlanetLabel.setWidgetDims(80, 27);
  PlanetLabel.textSize = 12;

  fpsLabel = myUI.addTextDisplayBox("FPS", 1530, 12, " " );
  fpsLabel.setWidgetDims(50, 27);
  fpsLabel.textSize = 12;

  SelectedPlanetName = myUI.addTextDisplayBox("Selected", 20, 310, "");
  SelectedPlanetName.setWidgetDims(160, 27);
  SelectedPlanetName.textSize = 12;
  SelectedPlanetName.setVisible(false);

  SelectedPlanetDistance = myUI.addTextDisplayBox("DTS", 20, 342, "");
  SelectedPlanetDistance.setWidgetDims(160, 27);
  SelectedPlanetDistance.textSize = 12;
  SelectedPlanetDistance.setVisible(false);

  SelectedPlanetMass = myUI.addTextDisplayBox("Mass", 20, 374, "");
  SelectedPlanetMass.setWidgetDims(160, 27);
  SelectedPlanetMass.textSize = 12;
  SelectedPlanetMass.setVisible(false);

  SelectedPlanetX = myUI.addTextDisplayBox("X", 20, 406, "");
  SelectedPlanetX.setWidgetDims(160, 27);
  SelectedPlanetX.textSize = 12;
  SelectedPlanetX.setVisible(false);

  SelectedPlanetY = myUI.addTextDisplayBox("Y", 20, 438, "");
  SelectedPlanetY.setWidgetDims(160, 27);
  SelectedPlanetY.textSize = 12;
  SelectedPlanetX.setVisible(false);

  SelectedPlanetZ = myUI.addTextDisplayBox("Z", 20, 470, "");
  SelectedPlanetZ.setWidgetDims(160, 27);
  SelectedPlanetZ.textSize = 12;
  SelectedPlanetZ.setVisible(false);

  nextPlanet = myUI.addSimpleButton(">", 1278, 12);
  nextPlanet.setWidgetDims(27, 27);

  previousPlanet = myUI.addSimpleButton("<", 1250, 12);
  previousPlanet.setWidgetDims(27, 27);

  unfollowPlanet = myUI.addSimpleButton("X", 1306, 12);
  unfollowPlanet.setWidgetDims(27, 27);

  editForceToAdd = myUI.addTextInputBox("Force To Add", 20, 511, "5000");  
  editForceToAdd.setWidgetDims(70, 27);
  editForceToAdd.setVisible(false);
  //editForceToAdd.showLabel(false);

  forceToAddSlider = myUI.addSlider("Force to Add", 20, 510);
  forceToAddSlider.setSliderValue(0.5);
  forceToAddSlider.setVisible(false);
}

void handleUIEvent(UIEventData  uied) {
  uied.print(0);

  if (uied.eventIsFromWidget("Orbit Trails") ) {
    for (int n = 0; n < allPlanet.size(); n++) {
      Planet thisPlanet = allPlanet.get(n);
      thisPlanet.showOrbitTrails = !thisPlanet.showOrbitTrails;
    }
  }

  if (uied.eventIsFromWidget("Distance Trails") ) {
    for (int n = 0; n < allPlanet.size(); n++) {
      Planet thisPlanet = allPlanet.get(n);
      thisPlanet.showDistanceTrails = !thisPlanet.showDistanceTrails;
    }
  }

  if (uied.eventIsFromWidget("Clear Trails") ) {
    for (int n = 0; n < allPlanet.size(); n++) {
      Planet thisPlanet = allPlanet.get(n);
      thisPlanet.trail.clear();
    }
  }

  if (uied.eventIsFromWidget("Sun Mass") ) {
    float amount = uied.sliderValue * 10;
    sun.setMass(amount);
  }

  if (uied.eventIsFromWidget(">") && currentPlanetnumber < allPlanet.size() -1) {
    selectedPlanet = allPlanet.get(currentPlanetnumber + 1);
    currentPlanetnumber = currentPlanetnumber + 1;
    println(currentPlanetnumber);
  }

  if (uied.eventIsFromWidget("<") && currentPlanetnumber != 0) {
    selectedPlanet = allPlanet.get(currentPlanetnumber - 1);
    currentPlanetnumber = currentPlanetnumber - 1;
    println(currentPlanetnumber);
  }

  if (uied.eventIsFromWidget("X")) {
    selectedPlanet = null;
  }

  if (uied.menuItem.equals("Free") ) {
    robot.keyPress(KeyEvent.VK_1);
    robot.keyRelease(KeyEvent.VK_1);
    selectedPlanet = null;
  }
  if (uied.menuItem.equals("Top Down") ) {
    robot.keyPress(KeyEvent.VK_2);
    robot.keyRelease(KeyEvent.VK_2);
    selectedPlanet = null;
  }
  if (uied.menuItem.equals("Follow") ) {
    selectedPlanet = allPlanet.get(0);
  }
  
  if (uied.eventIsFromWidget("Force to Add") ) {
    float amount = uied.sliderValue * 10000;
    //forceToAdd.x = amount;
  }
}

void updateUI() {

  String inputForceS = myUI.getText("Force To Add");
  Float inputForceF = float(inputForceS);

  if (selectedPlanet != null) {
    SelectedPlanetName.setVisible(true);
    SelectedPlanetName.setText(" " + selectedPlanet.planetName);
    SelectedPlanetDistance.setVisible(true);
    SelectedPlanetDistance.setText(" " + selectedPlanet.distance);
    SelectedPlanetMass.setVisible(true);
    SelectedPlanetMass.setText(" " + selectedPlanet.mass);
    SelectedPlanetX.setVisible(true);
    SelectedPlanetX.setText(" " + selectedPlanet.location.x);
    SelectedPlanetY.setVisible(true);
    SelectedPlanetY.setText(" " + selectedPlanet.location.y);
    SelectedPlanetZ.setVisible(true);
    SelectedPlanetZ.setText(" " + selectedPlanet.location.z);
    nextPlanet.setVisible(true);
    previousPlanet.setVisible(true);
    editForceToAdd.setVisible(true);
    //forceToAddSlider.setVisible(true);

    forceToAdd.x = inputForceF;
  } else {
    SelectedPlanetName.setVisible(false);
    SelectedPlanetDistance.setVisible(false);
    SelectedPlanetMass.setVisible(false);
    SelectedPlanetX.setVisible(false);
    SelectedPlanetY.setVisible(false);
    SelectedPlanetZ.setVisible(false);
    editForceToAdd.setVisible(false);
    forceToAddSlider.setVisible(false);
  }
}

void drawray(SimRay r, float rayLength, float R, float G, float B) {
  PVector farPoint = r.getPointAtDistance(rayLength);
  pushStyle();  
  stroke(R, G, B); 
  line(r.origin.x, r.origin.y, r.origin.z, farPoint.x, farPoint.y, farPoint.z);
  popStyle();
}
