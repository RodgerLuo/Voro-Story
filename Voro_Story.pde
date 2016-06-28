/*
A software to generate 3d voronoi shape with image textured
by Jieliang(Rodger) Luo, May 2015

Please read this carefully before running the code:
1. The code requires four essential libraries for running:
  (1) Hemesh2014: http://hemesh.wblut.com/
  (2) Peasy Cam: http://mrfeinberg.com/peasycam/
 
2. Image Setup
  (1) copy the images to the data folder.
  (2) rename images. For example, if you have five image with jpg format, rename them as "0.jpg", "1.jpg", ... , "4.jpg".
  (3) Change parameters in "Setup Parameters" below, section 2. 
      the "imageNumbers" is the number of images put in the data folder.
      the "iamgeType" is the format of the image. Please remember it's case senstive.
    
3. Setup parameters in "Setup Paremeters"
  (1) Voronoi Container is for setting up boundaries of the 3d shape. 
  (2) Images in the Data folder is mentioned in the above step.
  (3) Valve determines how many panels to construct the 3d shape.
      Warning: If you are testing with large size of image with large valve, the program may crash due to the memory limitation.     
  (4) Range controls the decentralized level of the panels. The larger the value is, the more decentralized it is.
 
4. Interactivities
   (1) "r" to export obj files and textures.
   (2) "s" to save screenshots 
*/

//************************************************

//------------------------------------
//Setup Parameters
//------------------------------------

String settingsFileName = "settings.txt";
int screenWidth, screenHeight;
int bgColor;

boolean record = false;

//1. Voronoi Container
int cubeWidth;
int cubeHeight;
int cubeDepth;

//2. images in the data folder
int imageNumber;
String imageType;

//3. the number of images showing on the screen
int meshNumber; 

//4. how much do you want the voronoi shape to be separated. The larger, the more decentralized
int range;

//************************************************

import peasy.*;
PeasyCam cam;

import javax.media.opengl.*; 
import processing.opengl.*;
import processing.pdf.*;

//Generating Voronoi Shape
import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;

final float depth = 1500;

PImage[] preImages;
PImage[] images;
PImage[] savedImages;
float[][] tempPoint;
PrintWriter output;

//for voronoi shape
HE_Mesh container;
HE_Mesh[] cells;
WB_Render render;
int numcells;

//coordinates
float[][] tempCoor;
PVector[] OneMeshPoints;
PVector[][] points;
float disHeight, disWidth;

int factor; //reduce cut off effect
float[] randomX,randomY,randomZ;

//save texture
boolean save = false;
float tx,ty,tw,th;

void setup() {
  
  loadSettings();
  
  size(screenWidth, screenHeight, OPENGL);
  cam = new PeasyCam(this, width/2, height/2, 0, depth);
  
  meshNumber += 1;
  
  container=new HE_Mesh(new HEC_Box().setWidth(cubeWidth).setHeight(cubeHeight).setDepth(cubeDepth));
  
  preImages = new PImage[imageNumber];
  images = new PImage[meshNumber];
  savedImages = new PImage[meshNumber];
  tempPoint = new float[2][3];
  tempCoor = new float[6][3];
  OneMeshPoints = new PVector[6];
  points = new PVector[meshNumber][6];
  
  randomX = new float[meshNumber];
  randomY = new float[meshNumber];
  randomZ = new float[meshNumber];
  
  for(int i=0;i<meshNumber;i++){
    randomX[i] = random(-range*2,range*2);
    randomY[i] = random(-range*2,range*2);
    randomZ[i] = random(-range*2,range*2);
  }
  
  //load images in setup so it will run smoothly in draw function
  for(int i=0;i<imageNumber;i++){
    preImages[i] = loadImage(i+ "." + imageType);
    println("Image " + i + " is loaded!");
  }
  
  for(int i=0;i<meshNumber;i++) {
    tempPoint[0][0]=random(-cubeWidth/2,cubeWidth/2);
    tempPoint[0][1]=random(-cubeHeight/2,cubeHeight/2);
    tempPoint[0][2]=random(-cubeDepth/2,cubeDepth/2);      

    // generate voronoi cells
    HEMC_VoronoiCells multiCreator=new HEMC_VoronoiCells();
    multiCreator.setPoints(tempPoint);
    multiCreator.setContainer(container);// cutoff mesh for the voronoi cells, complex meshes increase the generation time
    cells=multiCreator.create();
    numcells=cells.length;
    render=new WB_Render(this);
    getPositions();
    savePositions();
    
    for (int idx = 0; idx < 6; idx++) {
      points[i][idx] = OneMeshPoints[idx].get();
    }
  }
  
  factor = int(random(0,3));
  
}

void draw(){
  
  //For PDF Export
  if (record) {
    beginRecord(PDF, "frame-####.pdf");
  }
  
  background(bgColor);
  translate(width/2, height/2, 0);    
  
  drawVoro();
  
  //Second part of PDF Export
  if (record) {
    endRecord();
    record = false;
  }
}

void loadSettings(){
  String[] settings = loadStrings(settingsFileName);
  
  // iterate over each line in the settings file and find the appropriate ones
  for (int l = 0; l < settings.length; l++) {
    
    // skip blank lines
    if (settings[l].length() < 3);
    
    // skip comments
    else if (settings[l].substring(0, 2).equals("//"));
    
    else {
      String settingName = settings[l].substring(0, settings[l].indexOf("="));
      String settingValueString = settings[l].substring(settings[l].indexOf("=")+1, settings[l].length());
      
      if (settingName.equals("CUBE_WIDTH"))
        cubeWidth = new Integer(settingValueString);
      else if (settingName.equals("CUBE_HEIGHT"))
        cubeHeight = new Integer(settingValueString);
      else if (settingName.equals("CUBE_DEPTH"))
        cubeDepth = new Integer(settingValueString);
      else if (settingName.equals("IMAGE_NUM"))
        imageNumber = new Integer(settingValueString);
      else if (settingName.equals("IMAGE_TYPE"))
        imageType = new String(settingValueString);
      else if (settingName.equals("MESH_NUM"))
        meshNumber = new Integer(settingValueString) - 1;
      else if (settingName.equals("RANGE"))
        range = new Integer(settingValueString);
      else if (settingName.equals("SCREEN_WIDTH"))
        screenWidth = new Integer(settingValueString) - 1;
      else if (settingName.equals("SCREEN_HEIGHT"))
        screenHeight = new Integer(settingValueString);
      else if (settingName.equals("TRANSPARENCY"))
        transparency = new Integer(settingValueString);
      else if (settingName.equals("STROKE_COLOR"))
        strokeColor = new Integer(settingValueString) - 1;
      else if (settingName.equals("STROKE_WEIGHT"))
        strokeWeight = new Integer(settingValueString);
      else if (settingName.equals("BG_COLOR"))
        bgColor = new Integer(settingValueString);
    }
  }
}



