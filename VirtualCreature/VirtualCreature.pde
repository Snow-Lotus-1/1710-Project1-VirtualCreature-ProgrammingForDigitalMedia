//position of creature, position of background, the target point 
PVector position, position2, target, position_satellite;
//the actual creature
PImage creature;
//lightning effect that strikes it
PImage lightning;
//the target creature chases after
PImage spark;
//the energy surrounding creature after getting spark
PImage energy[];
PImage bg;

//arrays to house the images of the gifs
PImage[] bgFrame = new PImage[4];
PImage[] creatureFrame = new PImage[4];
PImage[] rCreatureFrame = new PImage[5];
PImage[] energyFrame = new PImage[6];
PImage[] sparkFrame = new PImage[12];
PImage[] lightningFrame = new PImage[15];
float margin = 50, targetX, targetY;

//checks if everything is running, used this to pause everything for a bit to simulate rest
boolean isRunning = true;

//energy related variables
float angle_satellit;
int collectedNum = 0;

//trigger distances for the crature that chases after the target
float triggerDistance1 = 100;
float triggerDistance2 = 5;
float movementSpeed = 0.02;

float randomness = 1;
//determines the rest time
boolean resting = false;
int restingCounter = 0;

//counters for animations
float aniBgCounter = 0;
float aniCreatureCounter = 0;
float aniRCreatureCounter = 0;
float aniSparkCounter = 0;
float aniEnergyCounter = 0;
float aniLightningCounter = 0;

//keep track of the frames of the gifs
int aniBgFrame = 0;
int aniCreatureFrame = 0;
int aniRCreatureFrame = 0;
int aniSparkFrame = 0;
int aniEnergyFrame = 0;
int aniLightningFrame = 0;

//useful tool to check ranges
boolean debug = false;

void setup() { 
  frameRate(60);
  size(800, 600, P2D);
  
  position = new PVector(width/2, height/2);
  position2 = new PVector(width/2, height/2);
  position_satellite = new PVector(0.0, 0.0);
  angle_satellit = 0.0;
  pickTarget();
  
  //load all the animation frames
  loadBgImages();
  loadSparkImages();
  loadCreatureImages();
  loadEnergyImages();
  loadLightningImages();
  
  //everything is based off of corner except for the background, only switching to corner when needed
  ellipseMode(CENTER);
  rectMode(CENTER);
  imageMode(CENTER);
}

void draw() {
  energy = new PImage[collectedNum];
  
  aniBgCounter++;
  aniCreatureCounter++;
  aniRCreatureCounter++;
  aniSparkCounter++;
  aniEnergyCounter++;
  
  if (aniBgCounter >= 15)
  {
    aniBgCounter = 0;
    aniBgFrame++;
  }
  
  if (aniCreatureCounter >= 5)
  {
    aniCreatureCounter = 0;
    aniCreatureFrame++;
  }
  
  if (aniRCreatureCounter >= 6)
  {
    aniRCreatureCounter = 0;
    aniRCreatureFrame++;
  }
  
  if (aniSparkCounter >= 13)
  {
    aniSparkCounter = 0;
    aniSparkFrame++;
  }
  
  if (aniEnergyCounter >= 7)
  {
    aniEnergyCounter = 0;
    aniEnergyFrame++;
  }
  
  if (isRunning == true) 
  {  
    background(140, 206, 49);
    
    switchBgFrame();
    
    position2 = position.lerp(target, movementSpeed);
    position = position.lerp(target, movementSpeed).add(new PVector(random(-randomness, randomness), random(-randomness, randomness)));  
    
    if (position.dist(target) < triggerDistance2) 
    {
      if (collectedNum >= random(1,5))
      {
         isRunning = false;
    
      }
      pickTarget();    
      collectedNum++;
      randomness += 0.5;
    }
  
  position.y += sin(millis()) / 2;
  
  imageMode(CORNER);
  image(bg, -position2.x, -position2.y);
  imageMode(CENTER);
    
  if(mousePressed)
  {
    PVector mousePos = new PVector(mouseX, mouseY);       
    position2 = position.lerp(mousePos, movementSpeed);
    position = position.lerp(mousePos, movementSpeed).add(new PVector(random(-randomness, randomness), random(-randomness, randomness))); 
    
    noFill();
    stroke(127, 0, 0);
    strokeWeight(6);
    line(mousePos.x, mousePos.y, position.x, position.y);
    
  }
  if(target.x < position.x)
  {
    switchCreatureFrame();
    image(creature, position.x, position.y);
  }
  else if(target.x >= position.x)
  {   
    switchCreatureFrame();
    //https://stackoverflow.com/questions/17759396/how-do-you-flip-a-image-horizontally-using-processing-js/17760023 looked at this website on how to flip an image
    pushMatrix();
    scale(-1.0, 1.0);
    image(creature, -position.x, position.y);
    popMatrix();
  }
 
  for(int i=0; i<energy.length; i++){
    float num = i+1;
    angle_satellit += (0.1*num);
    position_satellite.x = position.x + 90*cos(angle_satellit);
    position_satellite.y = position.y + 90*sin(angle_satellit);
    
    if (aniEnergyFrame > 5)
    {
       aniEnergyFrame = 0; 
    }
    for(int j=0; j<energyFrame.length; j++){
      if(aniEnergyFrame == j) 
      {
         energy[i] = energyFrame[j];         
      }
    }  
    image(energy[i], position_satellite.x, position_satellite.y);
  }
  
  switchSparkFrame();
  image(spark, targetX, targetY);
  }
  else
  {       
    if(!resting)
    {
      background(0);
      collectedNum = 0;
      randomness = 1;
      aniLightningCounter++;
      if(aniLightningCounter > 4)
      {
         aniLightningCounter = 0;
         aniLightningFrame++;
      }    
      
      //switch lightning image
      if (aniLightningFrame > 14)
      {
        //loops back to first frame
         aniLightningFrame = 0; 
      }
      //for every frame check it with aniKightningFrame 
      for(int i=0; i<lightningFrame.length; i++){
        if(aniLightningFrame == i)
        {  
           //loads the images
           lightning = lightningFrame[i];
        }
      } 
      
      image(lightning, position.x, position.y);
      
      if (lightning == lightningFrame[14])
      {
         resting = true; 
      }
    }
    
    if(resting)
    {
      switchBgFrame();
      restingCounter++;
      imageMode(CORNER);
      image(bg, -position2.x, -position2.y);
      imageMode(CENTER);
      
      switchRCreatureFrame();
      image(creature, position.x, position.y);
      if(restingCounter >= random(500, 1000))
      {
         restingCounter = 0;
         resting = false;
         isRunning = true; 
      }
    }
    
  }
  if (debug) {
    noFill();
    stroke(0, 255, 0);
    ellipse(position.x, position.y, triggerDistance1*2, triggerDistance1*2);
    ellipse(position.x, position.y, triggerDistance2*2, triggerDistance2*2);
    line(target.x, target.y, position.x, position.y);
    stroke(255, 0, 0);
    rect(target.x, target.y, 10, 10);
  }
}


void pickTarget() {
  targetX = random(margin, width-margin);
  targetY = random(margin, height-margin);
  target = new PVector(targetX, targetY);
}

void loadBgImages()
{
  //gif link
  //https://forums.rpgmakerweb.com/data/attachments/101/101696-0c29ce073e3bbc94bf77fb127ed9bdfd.jpg
  bgFrame[0] = loadImage("background/background1.png");
  bgFrame[1] = loadImage("background/background2.png");
  bgFrame[2] = loadImage("background/background3.png");
  bgFrame[3] = loadImage("background/background4.png");
  
  for(int i=0; i<creatureFrame.length; i++){
    bgFrame[i].resize(bgFrame[i].width*3, bgFrame[i].height*3);
  }
}

void switchBgFrame()
{
  if (aniBgFrame > 3)
  {
     aniBgFrame = 0; 
  }
  for(int i=0; i<bgFrame.length; i++){
    if(aniBgFrame == i) 
    {
      bg = bgFrame[i];      
    }
  }
}

void loadCreatureImages()
{
  //gif link
  //https://i.pinimg.com/originals/13/6a/e0/136ae07e424e878636575ff42406853e.gif
  creatureFrame[0] = loadImage("creature/creature1.png");
  creatureFrame[1] = loadImage("creature/creature2.png");
  creatureFrame[2] = loadImage("creature/creature3.png");
  creatureFrame[3] = loadImage("creature/creature4.png");
  
  for(int i=0; i<creatureFrame.length; i++){
    creatureFrame[i].resize(creatureFrame[i].width/3, creatureFrame[i].height/3);
  }
  //////////////////////////////////////////////////////
  //gif link
  //https://i.pinimg.com/originals/71/b7/aa/71b7aab38cb5d346a973edfae8e0f9e2.gif
  rCreatureFrame[0] = loadImage("resting/resting1.png");
  rCreatureFrame[1] = loadImage("resting/resting2.png");
  rCreatureFrame[2] = loadImage("resting/resting3.png");
  rCreatureFrame[3] = loadImage("resting/resting4.png");
  rCreatureFrame[4] = loadImage("resting/resting5.png");
  
  for(int i=0; i<rCreatureFrame.length; i++){
    rCreatureFrame[i].resize(rCreatureFrame[i].width/4, rCreatureFrame[i].height/4);
  }
}

void loadLightningImages()
{
  //gif link
  //https://co.pinterest.com/pin/466896686360677966/
  lightningFrame[0] = loadImage("lightning/lightning1.png");
  lightningFrame[1] = loadImage("lightning/lightning2.png");
  lightningFrame[2] = loadImage("lightning/lightning3.png");
  lightningFrame[3] = loadImage("lightning/lightning4.png");
  lightningFrame[4] = loadImage("lightning/lightning5.png");
  lightningFrame[5] = loadImage("lightning/lightning6.png");
  lightningFrame[6] = loadImage("lightning/lightning7.png");
  lightningFrame[7] = loadImage("lightning/lightning8.png");
  lightningFrame[8] = loadImage("lightning/lightning9.png");
  lightningFrame[9] = loadImage("lightning/lightning10.png");
  lightningFrame[10] = loadImage("lightning/lightning11.png");
  lightningFrame[11] = loadImage("lightning/lightning12.png");
  lightningFrame[12] = loadImage("lightning/lightning13.png");
  lightningFrame[13] = loadImage("lightning/lightning14.png");
  lightningFrame[14] = loadImage("lightning/lightning15.png"); 
}

void switchCreatureFrame()
{
  if (aniCreatureFrame > 3)
  {
     aniCreatureFrame = 0; 
  }
  for(int i=0; i<creatureFrame.length; i++){
    if(aniCreatureFrame == i) 
    {
      creature = creatureFrame[i];      
    }
  }
}

void switchRCreatureFrame()
{
  if (aniRCreatureFrame > 4)
  {
     aniRCreatureFrame = 0; 
  }
  for(int i=0; i<rCreatureFrame.length; i++){
    if(aniRCreatureFrame == i) 
    {
      creature = rCreatureFrame[i];      
    }
  }
}



void loadSparkImages()
{
  //gif link
  //https://www.herculeanpixel.com/images/news/ppb_shock.gif
  sparkFrame[0] = loadImage("spark/spark1.png");
  sparkFrame[1] = loadImage("spark/spark2.png");
  sparkFrame[2] = loadImage("spark/spark3.png");
  sparkFrame[3] = loadImage("spark/spark4.png");
  sparkFrame[4] = loadImage("spark/spark5.png");
  sparkFrame[5] = loadImage("spark/spark6.png");
  sparkFrame[6] = loadImage("spark/spark7.png");
  sparkFrame[7] = loadImage("spark/spark8.png");
  sparkFrame[8] = loadImage("spark/spark9.png");
  sparkFrame[9] = loadImage("spark/spark10.png");
  sparkFrame[10] = loadImage("spark/spark11.png");
  sparkFrame[11] = loadImage("spark/spark12.png");
}

void loadEnergyImages()
{
  //uses same gif as spark
  energyFrame[0] = loadImage("energy/energy1.png");
  energyFrame[1] = loadImage("energy/energy2.png");
  energyFrame[2] = loadImage("energy/energy3.png");
  energyFrame[3] = loadImage("energy/energy4.png");
  energyFrame[4] = loadImage("energy/energy5.png");
  energyFrame[5] = loadImage("energy/energy6.png");
  
  for(int i=0; i<energyFrame.length; i++){
    energyFrame[i].resize(energyFrame[i].width/3, energyFrame[i].height/3);
  }
}

void switchSparkFrame()
{
  if (aniSparkFrame > 11)
  {
     aniSparkFrame = 0; 
  }
  for(int i=0; i<sparkFrame.length; i++){
    if(aniSparkFrame == i) 
    {
      spark = sparkFrame[i]; 
    }
  }
}
