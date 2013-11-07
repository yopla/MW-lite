boolean overBox = false;
boolean locked = false;
int quiOver = -1;
float cirum = 10;
boolean clicforTri = false; 
   
void getOver(){  //
   quidedans();
   if (overBox){
     PVector p = (PVector)points.get(quiOver);
     if (nvMouse.getX() < p.x-cirum || nvMouse.getX() > p.x+cirum || nvMouse.getY() < p.y-cirum || nvMouse.getY() > p.y+cirum)  { 
       overBox = false; 
     }
    
   }
}

      

void mousePressed(MouseEvent e) {
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

void mouseReleased() {
  locked = false;
}


void mouseDragged(){
   if(locked) {
      quidedans();
      points.set(quiOver, new PVector (nvMouse.getX(), nvMouse.getY(), 0));
     }
     
}
  
void mouseMoved(){

if (altlocked){
  
    ZposCam += .05*(mouseY - pmouseY);
    
  }
  if (shiftlocked){
    XposCam += (mouseX - pmouseX);
    YposCam += (mouseY - pmouseY);
}

     camera(-XposCam+width/2.0, -YposCam+height/2.0, ZposCam*((height/2.0) / tan(PI*60.0 / 360.0)),
          -XposCam+ width/2.0, -YposCam+height/2.0, 0,
          0, 1, 0);
}

void quidedans(){
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


