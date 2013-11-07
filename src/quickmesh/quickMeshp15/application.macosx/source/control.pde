import controlP5.*;

ControlP5 cp5;
ControlWindow controlWindow;


Textlabel myTextlabelA;
public float XposCam = 0;
public float YposCam = 0;
public float ZposCam = 1;




int col = color(255);



  void setupControlWindow(){
    
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
     .setScrollSensitivity(1.1)
     .setValue(0)
     .moveTo(controlWindow)
      .setId(6);
     ;
  

  cp5.addNumberbox("XposCam")
     .setPosition(100,310)
     .setSize(100,14)
    // .setRange(0,200)
     .setScrollSensitivity(1.1)
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
     .setMultiplier(0.01) // set the sensitifity of the numberbox
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
   camera(-XposCam+width/2.0, -YposCam+height/2.0, ZposCam*((height/2.0) / tan(PI*60.0 / 360.0)),
                  -XposCam+ width/2.0, -YposCam+height/2.0, ZposCam,
                   0, 1, 0);
   }
}




void triangulate_F(boolean theFlag) {
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




