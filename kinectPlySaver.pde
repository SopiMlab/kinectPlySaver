//
//Created by: Miguel Valero Espada, Koray Tahiroglu, Nuno Correia, SOPI research group, Aalto University
// 
//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.

// BASED ON THE FOLLOWING CODE
/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
 * date:  02/16/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 */
 
import SimpleOpenNI.*;
SimpleOpenNI context;

float  zoomF =0.15f;
float  rotX = radians(180);                        
float  rotY = radians(0);
PVector[] realWorldMap;
int[]   depthMap;

int   steps = 6;
boolean saveFrame = false;
void setup()
{

  size(800, 600, P3D);
  //context = new SimpleOpenNI(this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  context = new SimpleOpenNI(this);
  context.setMirror(false);

  // enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }

  perspective(radians(45), 
  float(width)/float(height), 
  10, 150000);

  stroke(255, 255, 255);
}

void draw()
{
  // update the cam
  context.update();
  background(0, 0, 0);
  depthMap = context.depthMap();

  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
  translate(0, 0, -2000); 

  realWorldMap = context.depthMapRealWorld();

  for (int y=0;y < context.depthHeight();y+=steps)
  {
    for (int x=0;x < context.depthWidth();x+=steps)
    {
      int index = x + y * context.depthWidth();
      if (depthMap[index] > 0)
      { 
        PVector realWorldPoint = context.depthMapRealWorld()[index];
        point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
      }
    }
  }
  if (saveFrame) {
   
    int n = 0;
    for (int y=0;y < context.depthHeight();y+=1)
    {
      for (int x=0;x < context.depthWidth();x+=1)
      {
        int index = x + y * context.depthWidth();
        PVector realWorldPoint = context.depthMapRealWorld()[index];
        if(realWorldPoint.z > 0)
          n += 1;
      }
    }
    saveFrame = false;
    String fileName = "snapshot.ply";
    PrintWriter output;
    output = createWriter(fileName);
    output.println("ply");
    output.println("format ascii 1.0");
    output.println("comment : created from Kinect user tracker");
    output.println("element vertex "+ n);
    
    output.println("property float x");
    output.println("property float y");
    output.println("property float z");
    output.println("end_header");
    for (int y=0;y < context.depthHeight();y+=1)
    {
      for (int x=0;x < context.depthWidth();x+=1)
      {
        int index = x + y * context.depthWidth();
        PVector realWorldPoint = context.depthMapRealWorld()[index];
        if(realWorldPoint.z > 0){
          point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
          String s = realWorldPoint.x + " " 
           + realWorldPoint.y + " " + 
           realWorldPoint.z;
          output.println(s); 
        }
      }
    }
    output.close();
    
    
    
   
    
  }
  context.drawCamFrustum();
}


void keyPressed()
{
  if (key == ' ') 
    saveFrame = true;
  
  switch(keyCode)
  {
  case LEFT:
    rotY += 0.1f;
    break;
  case RIGHT:
    // zoom out
    rotY -= 0.1f;
    break;
  case UP:
    if (keyEvent.isShiftDown())
      zoomF += 0.02f;
    else
      rotX += 0.1f;
    break;
  case DOWN:
    if (keyEvent.isShiftDown())
    {
      zoomF -= 0.02f;
      if (zoomF < 0.01)
        zoomF = 0.01;
    }
    else
      rotX -= 0.1f;
    break;
  }
}
