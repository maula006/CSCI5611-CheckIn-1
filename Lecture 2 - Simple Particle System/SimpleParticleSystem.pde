//Simulation-Driven Animation
//CSCI 5611 Example - Bouncing Balls [Exercise]
// Stephen J. Guy <sjguy@umn.edu>

//NOTE: The simulation starts paused! Press space to run it.

//TODO:
//  1. The balls start red, make them blue instead.
//  2. Randomize the initial particle velocities so that xVel starts in the range (30,90),
//     and yVel starts in the range (-190, -200)
//  3. There is currently a small cap on the number of particles that can be spawned. 
//     Raise it up to 400.
//  4. Currently, pressing the 'r' key prints that it's resetting the particle system,
//     but it doesn’t actually reset anything yet. Fix that by having the simulation
//     reset when the user presses 'r'.
//  5. Pressing the arrow keys will move the big red ball, but sometimes we would like
//     to move it faster. Adjust the code so that holding 'shift' while an arrow key
//     is pressed will make the red ball move twice as fast.
//  6. The red ball only moves up/down/left/right. Change the code so that is two keys
//     are pressed simultaneously the red ball will move diagonally.
//  7. A common pitfall in games is that the diagonal motion is actually faster than
//     horizontal motion (because you just add the vectors). Make sure your code solving Step 6 does not have that issue, and that the red ball moves diagonally at the same speed it move horizontally or vertically.
//  8. The small blue balls (particles) have momentum, but they are missing the effect
//     of acceleration due to gravity. Add gravity to the simulation. 
//     Two things to consider in your implementation:
//        -Check to make sure that your particles move in a smooth, clear parabolic arc.
//        -When choosing the magnitude of your gravity vector think very carefully about
//         what the units mean. Don’t just pick 9.8 for gravity unless you are sure it
//         makes sense in the units of the scene you are simulated (hint: how many meters
//         long do you envision a pixel is in your scene).
//  9. The current code for bouncing the particles off of the red ball assumes the red
///    ball is stationary. If the ball is moving (e.g., controlled by the user) it should
//     impart some momentum on the particles. Update the collision response to capture this
//     effect in some way. There is no perfect answer here, but try to find something that
//     looks natural.

//Challenge:
//  1. Delete particles which have been around too long (and allow new ones to be created)
//  2. Change the color of the particles over time
//  3. Change the color of the particles as a function of the bounce 



//Simulation paramaters
static int maxParticles = 400; //inceased particle cap
Vec2 spherePos = new Vec2(300,400);
float sphereRadius = 60;
float r = 5;
float genRate = 20;
float obstacleSpeed = 200;
float COR = 0.7;
Vec2 gravity = new Vec2(0,400);

//Initalalize variable
Vec2 pos[] = new Vec2[maxParticles];
Vec2 vel[] = new Vec2[maxParticles];
int numParticles = 0;

void setup(){
  size(640,480);
  surface.setTitle("Particle System [CSCI 5611 Example]");
  strokeWeight(2); //Draw thicker lines 
}

Vec2 obstacleVel = new Vec2(0,0);

void update(float dt){
  float toGen_float = genRate * dt;
  int toGen = int(toGen_float);
  float fractPart = toGen_float - toGen;
  if (random(1) < fractPart) toGen += 1;
  for (int i = 0; i < toGen; i++){
    if (numParticles >= maxParticles) break;
    pos[numParticles] = new Vec2(20+random(20),200+random(20));
    vel[numParticles] = new Vec2(30+random(60),-190 - random(10));//randomize velocity 
    numParticles += 1;
  }
  
  
  obstacleVel = new Vec2(0,0);
  Vec2 direction = new Vec2(0,0);
  if (leftPressed) direction.add(new Vec2(-1,0));
  if (rightPressed) direction.add(new Vec2(1,0));
  if (upPressed) direction.add(new Vec2(0,-1));
  if (downPressed) direction.add(new Vec2(0,1));
  obstacleVel = shiftPressed? direction.times(2*obstacleSpeed) : direction.times(obstacleSpeed); //if shiftpressed (?) 2*obstacle speed. Else (:) obstacle speed.
  spherePos.add(obstacleVel.times(dt));
  
  for (int i = 0; i <  numParticles; i++){
    
    Vec2 acc = gravity; //Gravity
    
    pos[i].add(vel[i].times(dt)); //Update position based on velocity
    vel[i].add(acc.times(dt)); //add gravity to the velocity, scaled to dt.
    
    if (pos[i].y > height - r){
      pos[i].y = height - r;
      vel[i].y *= -COR;
    }
    if (pos[i].y < r){
      pos[i].y = r;
      vel[i].y *= -COR;
    }
    if (pos[i].x > width - r){
      pos[i].x = width - r;
      vel[i].x *= -COR;
    }
    if (pos[i].x < r){
      pos[i].x = r;
      vel[i].x *= -COR;
    }
    
    if (pos[i].distanceTo(spherePos) < (sphereRadius+r)){ //TODO: Insert code of reflection here.
      Vec2 normal = (pos[i].minus(spherePos)).normalized();
      pos[i] = spherePos.plus(normal.times(sphereRadius+r).times(1.01));
      Vec2 velNormal = normal.times(dot(vel[i],normal)); //N(V[dot]N)
      vel[i].subtract(velNormal.times(1 + COR)); //V-N(V[dot]N) * Coeff of Restitution(V[dot]N) = V-(N+COR)(V[dot]N)   . Instead of 2, as 2 assumes perfect reflection not damped.
      //Now to add the velocity of the obstacle to the particle.
      //How: Add to the particles velocity the Obstacle velocity * (projectile's (normalized) velocity dot with normal).
      //dot product determines the difference in the direction. 
      //If the velocity of the obstacle is parallel to the particle (dot = 1), all the velocity of the obstacle  will be added to the particle.
      //If the velocity of the obstacle is perpendicular to the particle (dot = 0), the obstacle will not affect the velocity of the particle.
      //vel[i].add(obstacleVel.times(dot(vel[i].normalized(),normal)));
            //Poor.The above can have a dragging effect if the ball hits the back of the obstacle.
            //instead, make a projection of the obstacle's velocity on the normal of the object. 
            //This makes the most sense, as it adds the obstacle's velocity based on where it was hit.
      vel[i].add(projAB(obstacleVel,normal));
      
    }
  }
  
}

void delParticles(){
  //The code is data-oriented, not object oriented. Two arrays store the data of each particle, rather than each particle represented as an object.
  //The Draw code consults these arrays to determine where to draw the particles, and how many.
  //No arrays or numParticles = no particles drawn.
  //Note: Emptying arrays are not necessary, only numParticles=0. This is because adding a particle re-sets the value in the array anyway.
  for (Vec2 obj : pos){ //delete particles
    obj = null;
  }
  for (Vec2 obj : vel){
    obj = null;
  }
  numParticles = 0;
}

boolean leftPressed, rightPressed, upPressed, downPressed, shiftPressed;
void keyPressed(){
  if (keyCode == LEFT) leftPressed = true;
  if (keyCode == RIGHT) rightPressed = true;
  if (keyCode == UP) upPressed = true; 
  if (keyCode == DOWN) downPressed = true;
  if (keyCode == SHIFT) shiftPressed = true;
  if (key == ' ') paused = !paused;
}

void keyReleased(){
  if (key == 'r'){
    println("Reseting the System");
    delParticles();
  }
  if (keyCode == LEFT) leftPressed = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (keyCode == UP) upPressed = false; 
  if (keyCode == DOWN) downPressed = false;
  if (keyCode == SHIFT) shiftPressed = false;
}


boolean paused = true;
void draw(){
  if (!paused) update(1.0/frameRate);
  
  background(255); //White background
  stroke(0,0,0);
  fill(120,20,20); //Change particle color!
  for (int i = 0; i < numParticles; i++){
    circle(pos[i].x, pos[i].y, r*2); //(x, y, diameter)
  }
  
  fill(40,60,180);//color the ball blue
  circle(spherePos.x, spherePos.y, sphereRadius*2); //(x, y, diameter)
}






// Begin the Vec2 Libraray

//Vector Library
//CSCI 5611 Vector 2 Library [Example]
// Stephen J. Guy <sjguy@umn.edu>

public class Vec2 {
  public float x, y;
  
  public Vec2(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x+ "," + y +")";
  }
  
  public float length(){
    return sqrt(x*x+y*y);
  }
  
  public Vec2 plus(Vec2 rhs){
    return new Vec2(x+rhs.x, y+rhs.y);
  }
  
  public void add(Vec2 rhs){
    x += rhs.x;
    y += rhs.y;
  }
  
  public Vec2 minus(Vec2 rhs){
    return new Vec2(x-rhs.x, y-rhs.y);
  }
  
  public void subtract(Vec2 rhs){
    x -= rhs.x;
    y -= rhs.y;
  }
  
  public Vec2 times(float rhs){
    return new Vec2(x*rhs, y*rhs);
  }
  
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
  }
  
  public void clampToLength(float maxL){
    float magnitude = sqrt(x*x + y*y);
    if (magnitude > maxL){
      x *= maxL/magnitude;
      y *= maxL/magnitude;
    }
  }
  
  public void setToLength(float newL){
    float magnitude = sqrt(x*x + y*y);
    x *= newL/magnitude;
    y *= newL/magnitude;
  }
  
  public void normalize(){
    float magnitude = sqrt(x*x + y*y);
    x /= magnitude;
    y /= magnitude;
  }
  
  public Vec2 normalized(){
    float magnitude = sqrt(x*x + y*y);
    return new Vec2(x/magnitude, y/magnitude);
  }
  
  public float distanceTo(Vec2 rhs){
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    return sqrt(dx*dx + dy*dy);
  }
}

Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}
