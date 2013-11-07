/**
 * * octaneRenderer is a library to control octane from within Processing for single renderings or animations
 *
 * by Michael Muehlhaus - www.muehlseife.de
 * 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 */

//package muehlseife;

import java.io.*;
import muehlseife.*;
import processing.core.*;

public class octaneRenderer{
  
  public objExporter objWriter;
  
  PApplet p;
  boolean rendering = false;
  boolean octaneStarting = false;
  boolean octaneRunning = false;
  
  int framecountSketch = 0; //the global framecount of the sketch (maybe merge with framecount)
  int framecount = 0; //the current framenumber
  
  int startframe = 0; //after this frame rendering begins
  int frames; //amount of frames to render
  
  boolean bwriteObj = false;
  
  int calculationsPerPixel = 500;
  boolean bOctaneQuietMode = false;
  boolean bsetOctaneCam = false;
  boolean bsetOctaneCamFov = false;
  boolean bsetOctaneCamAperture = false;
  boolean bsetOctaneCamFocaldepth = false;
  PVector[] octaneCam = new PVector[2];  //[0] Position, [1] target
  float octaneCamAperture = 1;
  float octaneCamFov = 45; //field of view in degrees
  float octaneCamfocaldepth; // if not set manually calculated as the dist from cam to target
  
  String octaneExecutableLoctaion = "C:/OctaneRender/octane.exe";
  String ocsFile;
  String objFileFolder;
  String objFileName = "output";
  String octaneObjName = "output.obj";
  String picOutputFolder;
  String picName = "render";
  
  public octaneRenderer(PApplet parent) {
    this.p = parent;
    
    p.registerPre(this);
    p.registerPost(this);
    p.registerDraw(this);
    
    setOCS(p.sketchPath + "\\master.ocs"); //sets the default ocsFile to "sketch_folder\master.ocs"
    setObjFolder(p.sketchPath+ "\\"); // sets the default objFile folder to sketch_path
    setPicOutputFolder(p.sketchPath + "\\renderings\\");
  }
  
  
  /**
   * start rendering at a the first frame
   * 
   * @param fc set framecount
   */
  public void startRendering(int fc){
    createFolder(picOutputFolder);
    exportObj();
    rendering = true;
    framecount = 0;
    frames = fc;  
  }
  /**
   * start rendering at a specific frame 
   * 
   * @param sf set startframe
   * @param fc set framecount
   */
  public void startRendering(int sf,int fc){ //sf = startframe fc = framecount
    createFolder(picOutputFolder);
    exportObj();
    rendering = true;
    startframe = sf;
    framecount = startframe;
    frames = fc + startframe;  
  }
  
  
  
  //--------------------------------------------------------------------------
  //Vertex Settings-----------------------------------------------------------
  //--------------------------------------------------------------------------
  /**
   * Sets the Material of all following geometry
   * @param name
   */
  public void setMaterial(String name, int r, int g, int b, int a){
    objWriter.setMaterial(name,r,g,b,a);
  }
  public void setMaterial(String name){
    objWriter.setMaterial(name);
  }
  /**
   * Sets the group of all following geometry
   * @param name
   */
  public void setObject(String name){
    objWriter.setObject(name);
  }
  
  //--------------------------------------------------------------------------
  //Camera Settings-----------------------------------------------------------
  //--------------------------------------------------------------------------
  public void setOctaneCam(PVector pos, PVector target){
    bsetOctaneCam = true; //if true a cameraporition is given to octane
    octaneCam[0] = new PVector(); octaneCam[0].set(pos); //the position
    octaneCam[1] = new PVector(); octaneCam[1].set(target); //the target
    
    //set the values to match the objectfile
    octaneCam[0].mult(objWriter.scaleFactor);
    octaneCam[1].mult(objWriter.scaleFactor);
    if(objWriter.invertY){
      octaneCam[0].y *= -1;
      octaneCam[1].y *= -1;
    }
  }
  public void setOctaneCamFoV(float fov){
    bsetOctaneCamFov = true;
    octaneCamFov = fov;
  }
  public void setOctaneCamAperture(float ap){
    bsetOctaneCamAperture = true; //if true a cameraporition is given to octane
    octaneCamAperture = ap;
  }
  public void setOctaneCamFocaldepth(float fd){
    bsetOctaneCamFocaldepth = true; //if true a cameraporition is given to octane
    octaneCamfocaldepth = fd;
  }
  public void calculateFocaldepth(){
    bsetOctaneCamFocaldepth = true;
    PVector dist = new PVector();
    dist.set(octaneCam[0]);
    dist.sub(octaneCam[1]);
    float distance = dist.mag();
    octaneCamfocaldepth = distance;  
  }
  
  
  
  
  
  //--------------------------------------------------------------------------
  //Object Export-------------------------------------------------------------
  //--------------------------------------------------------------------------
  
  public void exportObj(){
    PApplet.println("exporting "+ objFileName +".obj");
    writeObj();
  }
  
  private void writeObj(){
    bwriteObj = true;
    objWriter = (objExporter)p.beginRaw("muehlseife.objExporter", objFileName);
    objWriter.setMaterials("manual");
    objWriter.setObjects("manual");
    objWriter.setScaleFactor((float)0.01);
    objWriter.setInvertY(true);
    //with this trick, everything is exportet to the right spot
    //!! don't use cameratransformation while rendering !!
    p.camera(0, 0, 500, 0, 0, 0, 0, 1, 0);
    objWriter.setZCorrection(500);
  }
  
  
  //--------------------------------------------------------------------------
  //Setup Settings -----------------------------------------------------------
  //--------------------------------------------------------------------------
  /**
   * Set how many samples per Pixel should be calculated
   * 
   * @param count samples per pixel
   */
  public void setCalculationsPerPixel(int count)
  {
    calculationsPerPixel = count;
  }
  
  /**
   * Set if octane should start in "quiet mode"
   * 
   * @param mode
   */
  public void setOctaneQuietMode(boolean mode){
    bOctaneQuietMode = mode;
  }
  
  /**
   * Set where the octanerender executable is located
   * defaut: "C:/OctaneRender/octane.exe"
   * 
   * @param path the path to octane.exe
   */
  public void setOctaneExecutableLoctaion(String path){
    octaneExecutableLoctaion = path;
  }
  
  /**
   * Set where the renderings should be saved
   * default: sketch_folder\renderings
   * 
   * @param path the folder where the renderings should be saved
   */
  public void setPicOutputFolder(String path){
    picOutputFolder = path;
  }
  
  /**
   * Set how your exported *.obj and *.mtl files should be called without "*.obj" or "*.mtl"
   * default: "output" 
   * 
   * @param name the name of exported object files
   */
  public void setObjName(String name){
    objFileName = name;
  }
  
  /**
   * Set the location where your octane *.ocs file is located
   * default: sketch_folder\master.ocs 
   * -> if you call your *.ocs file "master" and store it in your sketch_folder
   *     everything is fine with default settings!
   * 
   * @param location the location of your reconfigured *.ocs file
   */
  public void setOCS(String location){
    ocsFile = location;
  }
  
  /**
   * Set the location where your new *.obj files are saved
   * default: "sketch_folder\output.obj"
   * 
   * @param location the location of your reconfigured *.ocs file
   */
  public void setObjFolder(String location){
    objFileFolder = location;
  }

  /**
   * Set the name of your obj node in octane
   * default: "output.obj"
   * 
   * @param location the location of your reconfigured *.ocs file
   */
  public void setOctaneObjName(String name){
    octaneObjName = name;
  }
  
  /**
   * Set the names of your exported jpgs
   * default: "render"+framecount+".jpg"
   * 
   * @param the name of your renderings (without ".jpg")
   */
  public void setPicName(String name){
    picName = name;
  }
  
  //------------------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------
  //starts the octane rendering
  private void runOctane(){
    String OctaneCommand = createOctaneCommand();
    PApplet.println(OctaneCommand);
    execute(OctaneCommand);
  }
  
  //creates the executable with given parameters
  private String createOctaneCommand(){
    String OctaneCommand = "";
    //if (PApplet.platform == PApplet.WINDOWS) {
      OctaneCommand = octaneExecutableLoctaion;
        //}
        //else {
        //  OctaneCommand = "bash " + octaneExecutableLoctaion;  
        //}
    //String OctaneCommand = octaneExecutableLoctaion; //sets where the octane.exe can be found
    OctaneCommand += " -e"; //exit octane after rendering is done
    if(bOctaneQuietMode){OctaneCommand += " -q";} //set octane to quiet Mode
    OctaneCommand += " -r " + objFileFolder + objFileName+".obj"; //relink meshnode with thisone
    OctaneCommand += " -s " + calculationsPerPixel; //sets the callculations per Pixel
    OctaneCommand += " -m " + octaneObjName;  //sets the name of the Meshnode to render
    OctaneCommand += " -o " + picOutputFolder + picName + framecount+".jpg"; //sets the output filename
    
    if(bsetOctaneCam){//if true giva a camera to octane
      OctaneCommand += " --cam-pos-x " + octaneCam[0].x;
      OctaneCommand += " --cam-pos-y " + octaneCam[0].y; 
      OctaneCommand += " --cam-pos-z " + octaneCam[0].z;
      
      OctaneCommand += " --cam-target-x " + octaneCam[1].x;
      OctaneCommand += " --cam-target-y " + octaneCam[1].y; 
      OctaneCommand += " --cam-target-z " + octaneCam[1].z;
    }
    if(bsetOctaneCamFov){
      OctaneCommand += " --cam-fov " + octaneCamFov;
    }
    if(bsetOctaneCamAperture){
      OctaneCommand += " --cam-aperture " + octaneCamAperture;
    }
    if(bsetOctaneCamFocaldepth){
      OctaneCommand += " --cam-focaldepth " + octaneCamfocaldepth;
    }
      
    OctaneCommand += " " + ocsFile; //sets the ocs-File to render from
    
    return OctaneCommand;
  }
  
  //------------------------------------------------------------------------------------------
  //Automatically called functions------------------------------------------------------------
  //------------------------------------------------------------------------------------------
  /**
   * This is called before draw().
   * If octane is running an loop is started until octane is closed again and ready to receive the next frame.
   */
  public void pre(){
    //if rendering and Octane is running or starting go into a loop
    while(rendering && octaneStarting){
      if(isOctaneRunning()){octaneStarting = false; octaneRunning = true;}
    }
    while(rendering && octaneRunning){
      PApplet.println("Octane is rendering frame: " + framecount + " be patient...");
      if(isOctaneRunning() == false){octaneRunning = false;}
    }
    if(rendering && framecountSketch > startframe){
      writeObj();  
    }
  }
  
  /**
   * This is automatically called after draw() in the sketch.
   * Here the rendering in octane is started.
   */
  public void post(){
    
    if(framecount > frames){
      rendering = false;
      PApplet.println("rendering done");
    }
    if(rendering && framecountSketch > startframe ){octaneStarting = true; runOctane(); framecount++;}
    
    framecountSketch++;//each frame of the sketch is counted;
  }
  
  /**
   * This is automatically called at the end of draw() in the sketch.
   * This function finishes the *.obj export.
   */
  public void draw(){
    if(bwriteObj == true){
      PApplet.println("object written");
      p.endRaw();
      bwriteObj = false;
    }
  }
  
  //------------------------------------------------------------------------------------------
  //Helping funktions-------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------
  
  //creates a folder
  private void createFolder(String path){
    File f = new File(path);
    f.mkdir();
  }
  //checks if octane.exe is running
  private boolean isOctaneRunning(){
    boolean result = VBSUtils.isRunning("octane.exe");
    return result;
  }
  //executes a command
  private  void execute(String cmd) {
        try {  
            //Process p = Runtime.getRuntime().exec(cmd);
          PApplet.open(cmd);
        } catch (Exception e) {}
    }
}

