import saito.objloader.*;
OBJModel model ;



void model(float yscale) {
  erase();
  model = new OBJModel(this, selectInput(), "absolute", TRIANGLES);
  model.enableDebug();
  model.scale(250, yscale, 250);
  model.translate(new PVector(-(width/2.), -(height/2.), 0));  
 
  for (int i = 0; i < model.getVertexCount(); i++) {
    model.getVertex(i);
    points.add(model.getVertex(i));
  }
  
}

 void sauve() {  
   
   String pathExport = selectOutput();
   oct.setObjName(pathExport);
   oct.exportObj();
   //oct.objWriter.setInvertY(true); 
   oct.objWriter.setScaleFactor(.004);
    
  /* camera(-XposCam+width/2.0, -YposCam+height/2.0, ZposCam*((height/2.0) / tan(PI*60.0 / 360.0)),
          -XposCam+ width/2.0, -YposCam+height/2.0, 0,
          0, 1, 0);*/
   //  camera();
   }
   
   void erase() {
    points.clear();
    triangles.clear();
    overBox = false;
    erase = false;
   }


  
