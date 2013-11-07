// mouse with zoom
//subdivide

import org.processing.wiki.triangulate.*;
//import muehlseife.*;
//import processing.opengl.*;


PImage img;
String im = "gris.jpg";//selectInput();
FVector nvMouse;

octaneRenderer oct;

ArrayList triangles = new ArrayList();
ArrayList points = new ArrayList();
ArrayList<Integer> removeTri = new ArrayList<Integer>();

float circumG = 10;
String lefile = "po";


void setup() { 
  
 //size(500, 500, P3D);
  smooth();
 
  img = loadImage(im);// loadImage("moi4.JPG");
  size(img.width, img.height, P3D);  // if size < 1024 !!
  frame.setResizable(true);

  oct = new octaneRenderer(this); 
 selectOutput("ou", "fileSelected");
 // setupControlWindow();

//javax.swing.JOptionPane.showMessageDialog(null, "Hello World");

}


 
void draw() {
 
  background(200);
 
  image(img, 0, 0);
  tint (255, 100);
  
  nvMouse = getMouseGroundPlaneIntersection(-XposCam+width/2.0, -YposCam+height/2.0, ZposCam*((height/2.0) / tan(PI*60.0 / 360.0)),
                  -XposCam+ width/2.0, -YposCam+height/2.0, 0,
                   0, 1, 0);
  

  if (triangulate) {
  if (points.size() != 0) triangles = Triangulate.triangulate(points);
  }
  
  
 
  // draw points as red dots     
  noStroke();
  fill(255, 0, 0);
  
  for (int i = 0; i < points.size(); i++) {
    PVector p = (PVector)points.get(i);
    ellipse(p.x, p.y, 8.5, 8.5);
  }
  
  getOver();
  
  
  
 if (triLocked){
    Triangle t = (Triangle)triangles.get(quiTriLocked);
 
    beginShape(TRIANGLES);  // dessine le rollover
    texture(img);
    stroke(255, 250,0);
    strokeWeight(4);
    vertex(t.p1.x, t.p1.y, t.p1.x, t.p1.y);
    vertex(t.p2.x, t.p2.y, t.p2.x, t.p2.y);
    vertex(t.p3.x, t.p3.y, t.p3.x, t.p3.y);
    stroke(10, 140);
    endShape();

        if (tri) {
          boolean peutecrir = true;
          for (int j=0; j < removeTri.size(); j++) {
           if (quiTriLocked == removeTri.get(j)) peutecrir = false;
          }
           if (peutecrir) removeTri.add(quiTriLocked);
            tri = false;  
          }
        
        
        if (ajout) {
          ajout = false;
          for (int j=0; j < removeTri.size(); j++) {
             if (quiTriLocked == removeTri.get(j)) removeTri.remove(j);
          }
        }   

    float xG = (t.p1.x + t.p2.x + t.p3.x)/3;
    float yG = (t.p1.y + t.p2.y + t.p3.y)/3;
    

    
    if (nvMouse.getX() < xG-circumG || nvMouse.getX() > xG+circumG 
    || nvMouse.getY() < yG-circumG || nvMouse.getY() > yG+circumG) { 
       triLocked = false; 
    }
    
    
    
 }else {
   for (int i = 0; i < triangles.size(); i++) { 
      Triangle t = (Triangle)triangles.get(i);
      float xG = (t.p1.x + t.p2.x + t.p3.x)/3;
      float yG = (t.p1.y + t.p2.y + t.p3.y)/3;
     
       if (subd){
         points.add (new PVector(xG, yG));
       }
      
       fill(10, 10, 10, 25);   // dessine zone de survol
       //tint (255, 5);
       strokeWeight(0);
       ellipse(xG, yG, circumG*2,circumG*2);
       
      
      if (nvMouse.getX() > xG-circumG && nvMouse.getX() < xG+circumG 
      && nvMouse.getY() > yG-circumG && nvMouse.getY() < yG+circumG) { 
        triLocked = true;
        quiTriLocked = i;
           
      }
   }
   subd = false;   
 }

    

    for (int i=triangles.size(); i>0; i--){       //si le tri est celui des "enlève", alors enleve
      for (int j=0; j < removeTri.size(); j++) {
        int hop = (int)removeTri.get(j);
        if (hop == i-1)triangles.remove(hop);
      } 
    }

  if (record) {
    record = false;
    sauve();
  }
  
  
  beginShape(TRIANGLES);    // draw the mesh of triangles
     texture(img);
     fill(255, 255);
     stroke(10, 140);
     strokeWeight(1);
     tint (255, 150);
      for (int i = 0; i < triangles.size(); i++) {
        Triangle t = (Triangle)triangles.get(i);
        vertex(t.p1.x, t.p1.y, t.p1.x,  t.p1.y);
        vertex(t.p2.x, t.p2.y, t.p2.x,  t.p2.y);
        vertex(t.p3.x, t.p3.y, t.p3.x,  t.p3.y); 
      }
  endShape();
  tint (255, 100);
 
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    lefile = selection.getAbsolutePath();
  }
}


