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



void keyPressed() {

  if (key == 'd') tri = true; 
  if (key == 'a') ajout = true; 
  
  if (key == 'l') model(250);
  if (key == 's') record = true;   
  if (key == 'e') {erase(); triangulate = false;}
  if (key == 'r') frame.setSize(img.width, img.height); 
   if (key == 'i') {
  selectInput("qouoi", "fileSelected") ; 
  img = loadImage(lefile);
  }
  if (key == 'w') subd = true;
  

 
 if (key == CODED) {
   if (keyCode == ALT) altlocked = true;
   if (keyCode == 157) shiftlocked = true;
  
   if (keyCode == UP) YposCam += 10;
   if (keyCode == DOWN) YposCam -= 10;
   if (keyCode == LEFT) XposCam += 10;
   if (keyCode == RIGHT) XposCam -= 10;
   

   camera(-XposCam+width/2.0, -YposCam+height/2.0, ZposCam*((height/2.0) / tan(PI*60.0 / 360.0)),
          -XposCam+ width/2.0, -YposCam+height/2.0, 0,
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



void keyReleased(){
  if (key == CODED) {
    if (keyCode == ALT) altlocked = false; 
    if (keyCode == 157) shiftlocked = false;
  }
}


