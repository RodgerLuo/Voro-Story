int transparency;
int strokeColor;
int strokeWeight;

void drawVoro(){
  
  for(int i=0; i<meshNumber; i++){
    PVector p0 = points[i][0];
    PVector p1 = points[i][1];
    PVector p2 = points[i][2];
    PVector p6 = points[i][3];
            
    float tempDistOne = p0.dist(p1);
    float tempDistTwo = p1.dist(p2);
    float tempDistThree = p2.dist(p6);
    float tempDistFour = p6.dist(p0);
    
    if(tempDistOne < tempDistTwo && tempDistOne < tempDistThree && tempDistOne < tempDistFour){
      p0 = p6;
    }
    
    else if(tempDistTwo < tempDistOne && tempDistTwo < tempDistThree && tempDistTwo < tempDistFour){
      p1 = p6;
    }
    
    else if(tempDistThree < tempDistOne && tempDistThree < tempDistTwo && tempDistThree < tempDistFour){
      p2 = p6;
    }
    
    PVector p2p0 = PVector.sub(p2,p0);
    PVector p1p0 = PVector.sub(p1,p0);
    float t = (p2p0.dot(p1p0))/(p1p0.dot(p1p0));
    PVector temp = PVector.mult(p1p0,t);
    PVector p3 = PVector.add(temp,p0);
    PVector p4 = PVector.sub(PVector.add(p0,p2),p3);
    PVector p5 = PVector.sub(PVector.add(p1,p2),p3);
    
    images[i] = preImages[i%imageNumber];
    float imageWH = float(images[i].width)/float(images[i].height);
    float imageHW = float(images[i].height)/float(images[i].width); 
    
    disHeight = PVector.dist(p0,p4); 
    disWidth = PVector.dist(p1,p0);
    
    //noStroke();
    strokeWeight(strokeWeight);
    stroke(strokeColor);
    tint(255, transparency);
        
    pushMatrix();
    //make it more random and spread out
    translate(randomX[i],randomY[i],randomZ[i]);

      beginShape();
      texture(images[i]);
      if(disHeight/disWidth > imageWH){
        vertex(p0.x,p0.y,p0.z,0,disWidth*images[i].width/disHeight);
        vertex(p1.x,p1.y,p1.z,0,0);
        vertex(p5.x,p5.y,p5.z,images[i].width,0);
        vertex(p4.x,p4.y,p4.z,images[i].width,disWidth*images[i].width/disHeight);
        tx = 0;
        ty = 0;
        tw = images[i].width;
        th = disWidth*images[i].width/disHeight;
      }
      else if(disHeight/disWidth <= imageWH && disHeight/disWidth > imageHW){
        vertex(p0.x,p0.y,p0.z,0,0);
        vertex(p1.x,p1.y,p1.z,0,images[i].height);
        vertex(p5.x,p5.y,p5.z,disWidth*images[i].height/disHeight,images[i].height);
        vertex(p4.x,p4.y,p4.z,disWidth*images[i].height/disHeight, 0);
        tx = 0;
        ty = 0;
        tw = disWidth*images[i].height/disHeight;
        th = images[i].height;
      } 
      else if(disHeight/disWidth <= imageHW){
        vertex(p0.x,p0.y,p0.z,0,0);
        vertex(p1.x,p1.y,p1.z,images[i].width,0);
        vertex(p5.x,p5.y,p5.z,images[i].width,disHeight*images[i].width/disWidth);
        vertex(p4.x,p4.y,p4.z,0,disHeight*images[i].width/disWidth);
        tx = 0;
        ty = 0;
        tw = images[i].width;
        th = disHeight*images[i].width/disWidth;
      }
      endShape();
    
    popMatrix();         
  }
}
