import processing.core.*; 
import processing.xml.*; 

import org.processing.wiki.triangulate.*; 
import ludo.objexport.*; 
import controlP5.*; 
import saito.objloader.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class quickMeshp15 extends PApplet {

// mouse with zoom
//subdivide


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

public void setup() { 
  
 //size(500, 500, P3D);
  smooth();
 
  img = loadImage(im);// loadImage("moi4.JPG");
  size(img.width, img.height, P3D);  // if size < 1024 !!
  frame.setResizable(true);

  oct = new octaneRenderer(this); 
 
 // setupControlWindow();

//javax.swing.JOptionPane.showMessageDialog(null, "Hello World");

}


 
public void draw() {
 
  background(200);
 
  image(img, 0, 0);
  tint (255, 100);
  
  nvMouse = getMouseGroundPlaneIntersection(-XposCam+width/2.0f, -YposCam+height/2.0f, ZposCam*((height/2.0f) / tan(PI*60.0f / 360.0f)),
                  -XposCam+ width/2.0f, -YposCam+height/2.0f, 0,
                   0, 1, 0);
  

  if (triangulate) {
  if (points.size() != 0) triangles = Triangulate.triangulate(points);
  }
  
  
 
  // draw points as red dots     
  noStroke();
  fill(255, 0, 0);
  
  for (int i = 0; i < points.size(); i++) {
    PVector p = (PVector)points.get(i);
    ellipse(p.x, p.y, 8.5f, 8.5f);
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

    

    for (int i=triangles.size(); i>0; i--){       //si le tri est celui des "enl\u00e8ve", alors enleve
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


boolean overBox = false;
boolean locked = false;
int quiOver = -1;
float cirum = 10;
boolean clicforTri = false; 
   
public void getOver(){  //
   quidedans();
   if (overBox){
     PVector p = (PVector)points.get(quiOver);
     if (nvMouse.getX() < p.x-cirum || nvMouse.getX() > p.x+cirum || nvMouse.getY() < p.y-cirum || nvMouse.getY() > p.y+cirum)  { 
       overBox = false; 
     }
    
   }
}

      

public void mousePressed(MouseEvent e) {
 //if ((e.getButton()==MouseEvent.BUTTON3) && (points.size() > 3)) tri = true;
 //if (e.getClickCount()==2) print ("double");
 if (overBox) {  
    locked = true;
    if ((e.getButton()==MouseEvent.BUTTON3) && (points.size() > 3)) {
        //removeTri.clear(); 
        points.remove(quiOver);
         locked = false;
         overBox = false;
    }
  } else { 
     //removeTri.clear(); 
     points.add(new PVector(nvMouse.getX(), nvMouse.getY(), 0));
     locked = false; 
     tri = false;  //au mieux c'est si le nouveau point change le triangle...
  } 
}

public void mouseReleased() {
  locked = false;
}


public void mouseDragged(){
   if(locked) {
      quidedans();
      points.set(quiOver, new PVector (nvMouse.getX(), nvMouse.getY(), 0));
     }
     
}
  
public void mouseMoved(){

if (altlocked){
  
    ZposCam += .05f*(mouseY - pmouseY);
    
  }
  if (shiftlocked){
    XposCam += (mouseX - pmouseX);
    YposCam += (mouseY - pmouseY);
}

     camera(-XposCam+width/2.0f, -YposCam+height/2.0f, ZposCam*((height/2.0f) / tan(PI*60.0f / 360.0f)),
          -XposCam+ width/2.0f, -YposCam+height/2.0f, 0,
          0, 1, 0);
}

public void quidedans(){
  for (int i = 0; i < points.size(); i++) {
    
    
    
    
  PVector p = (PVector)points.get(i);
    

  
      if (nvMouse.getX() > p.x-cirum && nvMouse.getX() < p.x+cirum && nvMouse.getY() > p.y-cirum && nvMouse.getY() < p.y+cirum) {  
        overBox = true;    
        quiOver = i;       
        fill(0, 255, 0);
        ellipse(p.x, p.y, 10, 10);
      }   
   }
}




ControlP5 cp5;
ControlWindow controlWindow;


Textlabel myTextlabelA;
public float XposCam = 0;
public float YposCam = 0;
public float ZposCam = 1;




int col = color(255);



  public void setupControlWindow(){
    
  cp5 = new ControlP5(this);
  
  controlWindow = cp5.addControlWindow("controlP5window", 100, 100, 400, 500)
    .hideCoordinates()
    .setBackground(color(40))
    ;
    
  
     cp5.addTextlabel("label")
    .setMultiline(true) 
    .setText("quickMesh-2D creator")
    .setPosition(40,10)
    .setColorValue(0xffffff00)
    .setSize(250, 180)
     .setFont(createFont("Georgia",20))
    .moveTo(controlWindow)
    ;
    
    cp5.addTextlabel("label2")
    .setMultiline(true) 
    .setText("clic for add point, right-clic for remove point, qM-2D only make triangles :( don't work with MWS subdivisions ):")
    .setPosition(40,50)
    .setColorValue(0xffffff00)
    .setSize(270, 180)
     // .setFont(createFont("Georgia",20))
    .moveTo(controlWindow)
    ;


  cp5.addTextlabel("label3")
    .setMultiline(true) 
    .setText("rollover a triangle center to select it / (F) to create faces by triangulation  / (D) to delete tri / (A) to add tri ")
    .setPosition(40,120)
    .setColorValue(0xffffff00)
    .setSize(310, 180)
   // .setFont(createFont("Georgia",20))
    .moveTo(controlWindow)
    ;
   
   
   
    cp5.addToggle("triangulate_F")
     .setPosition(40,80)
     .setSize(50,20)
     .moveTo(controlWindow)
     .setId(6);
     ;
     
     cp5.addButton("subdivise_W")
     .setPosition(200,80)
     .setSize(80,20)
     .moveTo(controlWindow)
     .setId(10);
     ;
     
      cp5.addButton("load image - I")
     .setValue(100)
     .setPosition(40,150)
     .setSize(140,20)
     .moveTo(controlWindow)
     .setId(3);
     ;
     
      cp5.addButton("resize sketch - R")
     .setValue(100)
     .setPosition(200,150)
     .setSize(80,20)
     .moveTo(controlWindow)
     .setId(4);
     ;

   
     cp5.addButton("load vertex from obj - L")
     .setValue(100)
     .setPosition(40,190)
     .setSize(140,20)
     .moveTo(controlWindow)
     .setId(1);
     ;
     
     
     cp5.addButton("Save obj - S")
     .setValue(100)
     .setPosition(200,190)
     .setSize(80,20)
     .moveTo(controlWindow)
     .setId(2);
     ;
     
    
     
     cp5.addButton("eraseAll - E")
     .setValue(100)
     .setPosition(40,230)
     .setSize(80,20)
     .moveTo(controlWindow)
     .setId(5);
     ;
     
   
     
   cp5.addNumberbox("YposCam")
     .setPosition(100,280)
     .setSize(100,14)
     .setScrollSensitivity(1.1f)
     .setValue(0)
     .moveTo(controlWindow)
      .setId(6);
     ;
  

  cp5.addNumberbox("XposCam")
     .setPosition(100,310)
     .setSize(100,14)
    // .setRange(0,200)
     .setScrollSensitivity(1.1f)
    // .setMultiplier(0.1) // set the sensitifity of the numberbox
     .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(0)
     .moveTo(controlWindow)
     .setId(7); 
     ;
     
   cp5.addNumberbox("ZposCam")
     .setPosition(100,340)
     .setSize(100,14)
     .setRange(0,200)
     .setMultiplier(0.01f) // set the sensitifity of the numberbox
     //.setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(1)
     .moveTo(controlWindow)
     .setId(8); 
     ;
     
      cp5.addTextlabel("label4")
    .setMultiline(true) 
    .setText("CMD for shifting, ALT for zooming")
    .setPosition(40,380)
    .setColorValue(0xffffff00)
    .setSize(350, 200)
   // .setFont(createFont("Georgia",20))
    .moveTo(controlWindow)
    ;
     
  }



public void controlEvent(ControlEvent theEvent) {
  if (theEvent.controller().id() == 1) model(250);
  if (theEvent.controller().id() == 2) record = true;  
  if (theEvent.controller().id() == 3) img = loadImage(selectInput());
  if (theEvent.controller().id() == 4) frame.setSize(img.width, img.height);
  if (theEvent.controller().id() == 5) {erase(); triangulate = false;} 
  if (theEvent.controller().id() == 10) subd = true;

  if ((theEvent.controller().id() == 6) || 
   (theEvent.controller().id() == 7) || 
   (theEvent.controller().id() == 8))  {
   camera(-XposCam+width/2.0f, -YposCam+height/2.0f, ZposCam*((height/2.0f) / tan(PI*60.0f / 360.0f)),
                  -XposCam+ width/2.0f, -YposCam+height/2.0f, ZposCam,
                   0, 1, 0);
   }
}




public void triangulate_F(boolean theFlag) {
  if(theFlag==true) {
    triangulate = true; 
    col = color(255);
  } else {
    triangulate = false;
    triangles.clear();
    removeTri.clear();
    col = color(100);
  }
}




boolean erase = false;
boolean record = false;
boolean tri = false;
boolean ajout = false;
boolean triangulate = false;
boolean subd = false;

boolean triLocked = false;
int quiTriLocked = -1;

boolean altlocked = false;
boolean shiftlocked = false;

String path;



public void keyPressed() {

  if (key == 'd') tri = true; 
  if (key == 'a') ajout = true; 
  
  if (key == 'l') model(250);
  if (key == 's') record = true;   
  if (key == 'e') {erase(); triangulate = false;}
  if (key == 'r') frame.setSize(img.width, img.height); 
  if (key == 'i') img = loadImage(selectInput());
  if (key == 'w') subd = true;
  

 
 if (key == CODED) {
   if (keyCode == ALT) altlocked = true;
   if (keyCode == 157) shiftlocked = true;
  
   if (keyCode == UP) YposCam += 10;
   if (keyCode == DOWN) YposCam -= 10;
   if (keyCode == LEFT) XposCam += 10;
   if (keyCode == RIGHT) XposCam -= 10;
   

   camera(-XposCam+width/2.0f, -YposCam+height/2.0f, ZposCam*((height/2.0f) / tan(PI*60.0f / 360.0f)),
          -XposCam+ width/2.0f, -YposCam+height/2.0f, 0,
          0, 1, 0);
 }



  if (key == 'f') {
    if (!triangulate) {
      triangulate = true; 
    } else {
     // triangulate_F.setState(false);
      triangulate = false;
      triangles.clear();
      removeTri.clear();
    }
  }
}



public void keyReleased(){
  if (key == CODED) {
    if (keyCode == ALT) altlocked = false; 
    if (keyCode == 157) shiftlocked = false;
  }
}



OBJModel model ;



public void model(float yscale) {
  erase();
  model = new OBJModel(this, selectInput(), "absolute", TRIANGLES);
  model.enableDebug();
  model.scale(250, yscale, 250);
  model.translate(new PVector(-(width/2.f), -(height/2.f), 0));  
 
  for (int i = 0; i < model.getVertexCount(); i++) {
    model.getVertex(i);
    points.add(model.getVertex(i));
  }
  
}

 public void sauve() {  
   
   String pathExport = selectOutput();
   oct.setObjName(pathExport);
   oct.exportObj();
   //oct.objWriter.setInvertY(true); 
   oct.objWriter.setScaleFactor(.004f);
    
  /* camera(-XposCam+width/2.0, -YposCam+height/2.0, ZposCam*((height/2.0) / tan(PI*60.0 / 360.0)),
          -XposCam+ width/2.0, -YposCam+height/2.0, 0,
          0, 1, 0);*/
   //  camera();
   }
   
   public void erase() {
    points.clear();
    triangles.clear();
    overBox = false;
    erase = false;
   }


  


public FVector getMouseGroundPlaneIntersection(float eyeX, float eyeY, float eyeZ,
			float centerX, float centerY,
			float centerZ, float upX, float upY, float upZ) {
  //generate the required vectors
  FVector eye = new FVector(eyeX, eyeY, eyeZ);
  FVector center = new FVector(centerX, centerY, centerZ);
  FVector look = (center.subtract(eye)).normalize();
  FVector up = new FVector(upX, upY, upZ).normalize();
  FVector left = up.crossProduct(look.normalize());

  //calculate the distance between the mouseplane and the eye
  float distanceEyeMousePlane = (height / 2) / tan(PI / 6);

  //calculate the vector, that points from the eye
  //to the clicked point, the mouse is on
  FVector mousePoint = look.multiply(distanceEyeMousePlane);
  mousePoint=mousePoint.add(left.multiply((float)((mouseX-width/2)*-1)));
  mousePoint=mousePoint.add(up.multiply((float)(mouseY-height/2)) );

  FVector intersection = new FVector(3);
  if (mousePoint.getZ() != 0) { //avoid zero division
    //calculate the value, the vector that points to the mouse
    //must be multiplied with to reach the XY-plane
    float multiplier = -eye.getZ() / mousePoint.getZ();
    //do not calculate intersections behind the camera
    if (multiplier > 0) { 
	//add the multiplied mouse point vector
	intersection = eye.add(mousePoint.multiply(multiplier));  
    }
  }
  return intersection;
 
} 






//FVector.pde by David Huebner  (2005|06|05)
//last changes                  (2005|06|21)
//modify and use in any way

//Vector class with N float elements. Built for Processing 0.90.
//To get it working in Java you need the core.jar library from processing or delete/change the methods using matrices.

//This vector class ist not limited to a 3D vector, although some of the methods only work with 3 dimensions.

//Most methods have a second variant.
//The normal one like multiply() returns a new vector with the calculations applied to.
//The one with "Me" in its name like multiplyMe() applies the calculations to this vector.

//Please report any bugs and additions to David@millbridge.de

//import processing.core.*; // for class PMatrix

public class FVector {

	public static final float TOL = 0.00001f;
	
	private int N;		//the number of elements of this vector
	public float e[]; 	//the array which contains all the elements of this vector
	
	//constructor for creating a null-vector with n elements 
	public FVector(int n) {
		N = n;
		e = new float[N];
		for( int i=0; i<N; i++ )
			e[i] = 0;
	}
	
	//constructor for creating a vector from a given array of float values	
	public FVector(float[] ee) {
		N = ee.length;
		e = new float[N]; 
		for( int i=0; i<N; i++ )
			e[i] = ee[i]; 
	}
	
	//constructor for creating a vector with the same elements of another vector v1. Similar to cloning a vector.	
	public FVector(FVector v2) {
		N = v2.e.length;
		e = new float[N]; 
		for( int i=0; i<N; i++ )
			e[i] = v2.e[i]; 
	}
	
	//constructor for creating a 3D vector with specified values _x, _y and _z	
	public FVector(float _x, float _y, float _z) {
		N = 3;
		e = new float[3]; 
		e[0] = _x;
		e[1] = _y;
		e[2] = _z;
	}
	
	//returns the magnitude of this vector
	public float magnitude() {
		float sum = 0.0f;
		for ( int i=0; i<N; i++ )
			sum = sum + e[i] * e[i];
		return (float)Math.sqrt( sum<TOL?TOL:sum );	 
	}
	
	//returns the squared magnitude of this vector
	public float magnitudeSqr() {
		float sum = 0.0f;
		for ( int i=0; i<N; i++ )
			sum = sum + e[i] * e[i];
		return (float)sum<TOL?TOL:sum;	 
	}
	
	//returns a new vector as a result of adding another vector v2 to this vector
	public FVector add(FVector v2) {
		FVector product = new FVector(N);
		if( N == v2.N )
			for ( int i=0; i<N; i++ )
				product.e[i] = e[i] + v2.e[i];
		else
			System.err.println( "FVector.add(): FVectors differ in dimension!" );
		return product;
	}
	
	//adds another vector v2 to this vector
	public void addMe(FVector v2) {
		if( N == v2.N )
			for ( int i=0; i<N; i++ )
				e[i] += v2.e[i];
		else
			System.err.println( "FVector.add(): FVectors differ in dimension!" );
	}
	
	//returns a new vector as a result of subtracting another vector v2 from this vector
	public FVector subtract(FVector v2) {
		FVector product = new FVector(N);
		if( N == v2.N )
			for ( int i=0; i<N; i++ )
				product.e[i] = e[i] - v2.e[i];
		else
			System.err.println( "FVector.subtract(): FVectors differ in dimension!" );
		return product;
	}
	
	//subtracts another vector v2 from this vector
	public void subtractMe(FVector v2) {
		if( N == v2.N )
			for ( int i=0; i<N; i++ )
				e[i] -= v2.e[i];
		else
			System.err.println( "FVector.subtract(): FVectors differ in dimension!" );
	}
	
	//returns a new vector as a result of multiplying this vector with a given float value v
	public FVector multiply(float v) {
		FVector product = new FVector(N);
		for ( int i=0; i<N; i++ )
			product.e[i] = e[i] * v;
		return product;
	}
	
	//multiplies this vector with a given float value v
	public void multiplyMe(float v) {
		for ( int i=0; i<N; i++ )
			e[i] *= v;
	}
	
	//returns a new vector as a result of dividing this vector by a given float value v
	public FVector divide(float v) {
		v = (v < TOL)?TOL:v;
		FVector product = new FVector(N);
		for ( int i=0; i<N; i++ )
			product.e[i] = e[i] / v;
		return product;
	}
	
	//divides this vector by a given float value v
	public void divideMe(float v) {
		v = (v < TOL)?TOL:v;
		for ( int i=0; i<N; i++ )
			e[i] /=	v;
	}
	
	//returns a new vector with the same direction of this vector, but with a length of 1
	public FVector normalize() {
		return divide(magnitude());
	}
	
	//makes this vector to have a length of 1
	public void normalizeMe() {
		FVector norm = new FVector(divide(magnitude()));
		for ( int i=0; i<N; i++ )
			e[i] = norm.e[i];
	}
	
	//returns the crossproduct of this vector and a given vector v2. see math book for description of the crosproduct
	public FVector crossProduct(FVector v2)
	{
		FVector crossProduct = new FVector(3);
		if (N == 3	&&	v2.N == 3) //cross product only defined in R3
		{
			crossProduct.e[0] = e[1] * v2.e[2] - e[2] * v2.e[1];
			crossProduct.e[1] = e[2] * v2.e[0] - e[0] * v2.e[2];
			crossProduct.e[2] = e[0] * v2.e[1] - e[1] * v2.e[0];
		}
		else
			System.err.println("FVector.crossProduct(): FVectors are not both in R3!");
		return crossProduct;
	}
	
	//returns the dotproduct of this vector and a given vector v2. see math book for description of the dotproduct
	public float dotProduct (FVector v2)
	{
		float sum = 0;
		if (N == v2.N)
			for ( int i=0; i<N; i++ )
				sum += e[i] * v2.e[i];
		else
			System.err.println("FVector.dotProduct(): FVectors differ in dimension!");
		return sum;
	}
	
	//returns true, if this vector equals a null-vector
	public boolean isZero() {
		boolean zero = true;
		for ( int i=0; i<N; i++ )
			if (e[i] != 0.0f) {
				zero = false;
				break;
			}
		return zero;
	}
	
	//returns true, if this vector equals a given vector v2
	public boolean equals(FVector v2) {
		boolean same = true;
		if (N == v2.N) {
			for ( int i=0; i<N; i++ )
				if (e[i] != v2.e[i]) {
					same = false;
					break;
				}
		}
		else {
			System.err.println("FVector.equals(): FVectors differ in dimension!");
			same = false;
		}
		return same;
	}
	
	//returns a new vector as a result of rotating this vector around the x-axis by a given float value val (in radians)
	public FVector rotateX(float val) {
		FVector result = new FVector(this);
		if (N > 2) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1 = e[1]*cosval - e[2]*sinval;
			double tmp2 = e[1]*sinval + e[2]*cosval;
		
			result.e[1] = (float)tmp1;
			result.e[2] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateX(): FVector is not in R3 or higher");
	
		return result;
	}
	
	//rotates this vector around the x-axis by a given float value val (in radians)
	public void rotateMeX(float val) {
		if (N > 2) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1 = e[1]*cosval - e[2]*sinval;
			double tmp2 = e[1]*sinval + e[2]*cosval;
		
			e[1] = (float)tmp1;
			e[2] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateMeX(): FVector is not in R3 or higher");
	}
	
	//returns a new vector as a result of rotating this vector around the y-axis by a given float value val (in radians)
	public FVector rotateY(float val) {
		FVector result = new FVector(this);
		if (N > 2) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1	 = e[0]*cosval - e[2]*sinval;
			double tmp2	 = e[0]*sinval + e[2]*cosval;
		
			result.e[0] = (float)tmp1;
			result.e[2] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateY(): FVector is not in R3 or higher");
	
		return result;
	}
	
	//rotates this vector around the y-axis by a given float value val (in radians)
	public void rotateMeY(float val) {
		if (N > 2) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1	 = e[0]*cosval - e[2]*sinval;
			double tmp2	 = e[0]*sinval + e[2]*cosval;
		
			e[0] = (float)tmp1;
			e[2] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateMeY(): FVector is not in R3 or higher");
	}
	
	//returns a new vector as a result of rotating this vector around the z-axis by a given float value val (in radians)
	//can be used for 2D Vectors too
	public FVector rotateZ(float val) {
		FVector result = new FVector(this);
		if (N > 1) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1	 = e[0]*cosval - e[1]*sinval;
			double tmp2	 = e[0]*sinval + e[1]*cosval;
		
			result.e[0] = (float)tmp1;
			result.e[1] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateMeZ(): FVector is not in R2 or higher");
		
		return result;
	}
	
	//rotates this vector around the z-axis by a given float value val (in radians)
	//can be used for 2D Vectors too
	public void rotateMeZ(float val) {
		if (N > 1) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1	 = e[0]*cosval - e[1]*sinval;
			double tmp2	 = e[0]*sinval + e[1]*cosval;
			
			e[0] = (float)tmp1;
			e[1] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateMeZ(): FVector is not in R2 or higher");
	}
	
	//rotates this vector around a given axis v2 by a given float value val (in radiens)
	public FVector rotateAxis(float val, FVector v2) {
		FVector result = new FVector(this);
		
		if (N == 3 && v2.N == 3) {
			PMatrix3D rotateMatrix = new PMatrix3D();
			rotateMatrix.rotate(val, v2.e[0], v2.e[1], v2.e[2]);
			
			float in[]	= {e[0], e[1], e[2], 0};
			float out[]	= {0, 0, 0, 0};
			rotateMatrix.mult(in,out);
			
			result.e[0] = out[0];
			result.e[1] = out[1];
			result.e[2] = out[2];
		}
		else
			System.err.println("FVector.rotateAxis(): FVectors are not both in R3");
		
		return result;
	}
	
	//returns a new vector as a result of rotating this vector around a given axis v2 by a given float value val (in radiens)
	public void rotateAxisMe(float val, FVector v2) {
		if (N == 3 && v2.N == 3) {
			PMatrix3D rotateMatrix = new PMatrix3D();
			rotateMatrix.rotate(val, v2.e[0], v2.e[1], v2.e[2]);
			
			float in[]	= {e[0], e[1], e[2], 0};
			float out[]	= {0, 0, 0, 0};
			rotateMatrix.mult(in,out);
			
			e[0] = out[0];
			e[1] = out[1];
			e[2] = out[2];
		}
		else
			System.err.println("FVector.rotateAxisMe(): FVectors are not both in R3");
	}
	
	//returns the value of the 1st element of this vector
	public float getX() {
		return e[0];
	}
	
	//returns the value of the 2nd element of this vector
	public float getY() {
		return e[1];
	}
	
	//returns the value of the 3rd element of this vector
	public float getZ() {
		return e[2];
	}
	
	//sets the 1st element to a given value newX
	public void setX(float newX) {
		e[0] = newX;
	}
	
	//sets the 2nd element to a given value newY
	public void setY(float newY) {
		e[1] = newY;
	}
	
	//sets the 3rd element to a given value newZ
	public void setZ(float newZ) {
		e[2] = newZ;
	}
	
	//changes the elements of this vector to the values of another vector
	public void set(FVector v2)
	{
		for ( int i=0; i<Math.min(N,v2.N); i++ )
			e[i] = v2.e[i];
	}
	
	//changes the first three elements of this vector to the given values x, y, z
	public void set(float x, float y, float z)
	{
		if (N > 2) {
			e[0] = x;
			e[1] = y;
			e[2] = z;
		}		
		else
			System.err.println("FVector.set(): FVector's dimension is too small");
	}
	
	//changes the elements of this vector to the values of a given float array
	public void set(float x[])
	{
		for ( int i=0; i<Math.min(N,x.length); i++ )
			e[i] = x[i];
	}

	//returns a new vector with the same elements the this vector
	public FVector cloneMe() {
		return new FVector(this);
	}

} //end of class FVector


  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "quickMeshp15" });
  }
}
