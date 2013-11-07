/**
 * * OBJExport - Exports obj files from processing with beginRaw and endRaw
 *
 * modified and extended by Michael Muehlhaus - www.muehlseife.de
 * added: groups, materials, uv-support
 * 
 * original code by Louis-Rosenberg - http://n-e-r-v-o-u-s.com/tools/obj.php
 * ##copyright##
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

// package muehlseife;

import java.io.*;
import java.util.HashMap;
import processing.core.*;


public class objExporter extends PGraphics3D {
  
  // myParent is a reference to the parent sketch
  String mtlname;
  File file_obj;
  File file_mtl;
  PrintWriter writer_obj;
  PrintWriter writer_mtl;
  PVector[] pts;
  int[][] lines;
  int[][] faces_groups_materials;
  int lineCount;
  int faceCount;
  int objectMode = 0;
  HashMap<String,String> ptMap;
  PVector[] uv;
  HashMap<String,String> uvMap;
  
  float scaleFactor = (float)0.01;
  
  boolean invertY = false;
  
  boolean exportUV = true;
  
  boolean useObjects = false;
  boolean manualObjects = false;
  boolean autoObjects = false;
  boolean materialsFromMaterial = false;
  boolean materialsFromFill = true;
  boolean useMaterials = true;
  int objectcounter = 0;
  
  String[] object_name; //[names]
  String[] materials_name;//[names]
  float[][] materials_data; //[index][r,g,b,a]
  int current_material;
  
  float zCorrection = 0;
  
  
  public objExporter() {
  }
  
  /**
   * Specifies how the model should be scaled
   * <p>
   * the default scale is 0.01 
   * 
   * @param factor the scale
   */
  public void setScaleFactor(float factor)
  {scaleFactor = factor;}
  
  public void setZCorrection(float cz){
    zCorrection = cz;
  }
  
  /**
   * Specifies if the y-Axis should be Inverted
   * <p>
   * many Applications use Inverted Y-Axis, so this might be usefull
   * 
   * @param bol true or false
   */
  public void setInvertY(boolean bol){
    if(bol){invertY=true;}else{invertY=false;}
  }
  
  /**
   * Here the way how faces are grouped is specified.
   * <p>
   * "none" - the faces will not be grouped
   * <p>
   * "manual" - In this mode {@see setObject} is used to specify the group. All Shapes drawn after a {@see setObject} will be part of this group
   * <p>
   * "automatic" - not supported for now
   * 
   * @param mode "none", "manual", "automatic (not supported for now)"
   */
  public void setObjects(String mode){
    if(mode == "none"){
      useObjects = true;
      manualObjects = true;
      autoObjects = false;
    }
    if(mode == "manual"){
      useObjects = true;
      manualObjects = true;
      autoObjects = false;
    }
    if(mode == "automatic"){
      PApplet.println("setObjects automatic is not implemented atm");
    }
  }
  
  /**
   * Here the way the materials are generated is specified.
   * <p>
   * "none" - no materials will be exported, the model will be covered with one default material
   * <p>
   * "manual" - In this mode {@see setMaterial} is used to specify the color. Its used like fill()
   * <p>
   * "automatic" - the fill() statements are used to create Materials. they are named: Mat0, Mat1, etc
   *               only usefull if you don't call stroke() in your sketch, its better to set materials manual!!
   * 
   * @param mode "none", "manual", "automatic"
   */
  public void setMaterials(String mode){
    if(mode == "none"){
      useMaterials = false;
      materialsFromMaterial = false;
      materialsFromFill = false;
    }
    if(mode == "manual"){
      useMaterials = true;
      materialsFromMaterial = true;
      materialsFromFill = false;
    }
    if(mode == "automatic"){
      useMaterials = true;
      materialsFromMaterial = false;
      materialsFromFill = true;
    }
  }

  public void setPath(String path) {
      this.path = path;
      if (path != null) {
        file_obj = new File(path+".obj");
        if (!file_obj.isAbsolute()) file_obj = null;
        file_mtl = new File(path+".mtl");
        if (!file_mtl.isAbsolute()) file_mtl = null;
      }
      if (file_obj == null) {
        throw new RuntimeException("OBJExport requires an absolute path " +
          "for the location of the output file.");
      }
      if (file_mtl == null) {
      throw new RuntimeException("OBJExport requires an absolute path " +
        "for the location of the output file.");
    }
      mtlname = ""+path+".mtl";
  }
  
  protected void allocate() {
  }

  public void dispose() {
    writer_obj.flush();
    writer_obj.close();
    writer_obj = null;
    writer_mtl.flush();
    writer_mtl.close();
    writer_mtl = null;
  }
  
  public boolean displayable() {
      return false;  // just in case someone wants to use this on its own
  }
  
  public void beginDraw() {
    
    vertices = new float[512][VERTEX_FIELD_COUNT];
      // have to create file object here, because the name isn't yet
      // available in allocate()
      if (writer_obj == null) {
        try {
          writer_obj = new PrintWriter(new FileWriter(file_obj));
        } 
        catch (IOException e) {
          throw new RuntimeException(e);
        }
        try {
          writer_mtl = new PrintWriter(new FileWriter(file_mtl));
        } 
        catch (IOException e) {
          throw new RuntimeException(e);
        }
        pts = new PVector[512];
        lines = new int[512][];
        faces_groups_materials = new int[512][];
        lineCount = 0;
        faceCount = 0;
        ptMap = new HashMap<String,String>();
        
        uv = new PVector[512];
        uvMap = new HashMap<String,String>();
        
        object_name = new String[0];
        materials_name = new String[0];//[names]
        materials_data = new float[0][0];//[index][r,g,b,a]
        current_material = -1;
     }
  }
  
  public void endDraw() {
      //write vertices and initialize ptMap
    writeheader();
      writeVertices();
      writeUV();
      writeLines();
      writeFaces();
      //Write the mtl file
      writeMtl_File();
  }
  
  private void writeheader(){
    String output = "#Exportet with Processing objExporter_ version 0.1";
    writer_obj.println(output);
    output = "#lines, normals and uv coordiantes are not supportet in this version";
    writer_obj.println(output);
    output = "#The Model contains  " + ptMap.size() + "  verices";
    writer_obj.println(output);
    output = "#The Model contains  " + materials_name.length + "  different Materials";
    writer_obj.println(output);
    output = "mtllib "+ mtlname;
    writer_obj.println(output);
  }
  
  private void writeVertices() {
      for(int i=0;i<ptMap.size();++i) {
        PVector v = pts[i];
        //invert vertices if instructed so
        if(invertY)v.y *= -1;
        writer_obj.println("v " + v.x*scaleFactor + " " + v.y*scaleFactor + " " + (v.z+zCorrection)*scaleFactor);
      }
  }
  
  private void writeUV() {
      for(int i=0;i<uvMap.size();++i) {
        PVector t_uv = uv[i];
        //invert vertices if instructed so
        if(invertY)t_uv.y *= -1;
        writer_obj.println("vt " + t_uv.x + " " + t_uv.y);
      }
  }
    
  private void writeLines() {
      for(int i=0;i<lineCount;++i) {
        int[] l = lines[i];
        String output = "l";
        for(int j=0;j<l.length;++j) {
          output += " " + l[j];
        }
        writer_obj.println(output);
      }
  }

  private void writeFaces() {
    //a face with only one vertex is a change in Material!
      for(int i=0;i<faceCount;++i) {
        int[] f = faces_groups_materials[i];
        if(f.length == 1){//materials are faces with 1 vertex
          String output = "usemtl " + materials_name[f[0]];
          writer_obj.println(output);
          output = "s off";
          writer_obj.println(output);
        }else if(f.length == 2){ //objects are faces with 2 vertices
          String output = "o " + object_name[f[0]];
          writer_obj.println(output);
        }else{
          if(!exportUV){
            String output = "f";
            for(int j=0;j<f.length;++j) {
              output += " " + f[j];
            }
            writer_obj.println(output);
          }else{
            String output = "f";
            
            int[] fv = new int[f.length/2];
            int[] fvt = new int[f.length/2];
            PApplet.arrayCopy(f, 0, fv, 0, f.length/2);
            PApplet.arrayCopy(f, f.length/2, fvt, 0, f.length/2);
            
            for(int j=0;j<f.length/2;++j) {
            output += " " + fv[j] + "/" + fvt[j];
            }
            writer_obj.println(output);
          }
        }
      }
  }
  
  private void writeMtl_File(){
    String output = "#Exportet with Processing objExporter_ version 0.1";
    writer_mtl.println(output);
    output = "#only colors and alphavalue are supportet at the moment";
    writer_mtl.println(output);
    output = "#The Model contains  " + materials_name.length + "  different Materials";
    writer_mtl.println(output);
    for(int i = 0; i<materials_name.length; i++){
      float value_r = materials_data[i][0];
      float value_g = materials_data[i][1];
      float value_b = materials_data[i][2];
      float value_a = materials_data[i][3];
      output = "";
      writer_mtl.println(output);
      output = "newmtl " + materials_name[i];
      writer_mtl.println(output);
      output = "Ns 100.0000"; //shininess 
      writer_mtl.println(output);
      output = "Ka 0.000000 0.000000 0.000000"; //ambient color 
      writer_mtl.println(output);
      output = "Kd " + value_r/255 + " " + value_g/255 + " " + value_b/255; //diffuse color 
      writer_mtl.println(output);
      output = "Ks 0.500000 0.500000 0.500000"; //ambient color 
      writer_mtl.println(output);
      output = "Ks 0.500000 0.500000 0.500000"; //specular  color 
      writer_mtl.println(output);
      output = "Ni 1.000000"; // index of refraction
      writer_mtl.println(output);
      output = "d " + value_a/255; // alpha value
      writer_mtl.println(output);
      output = "illum 2"; //  illumination model
      writer_mtl.println(output);
    }
    
    output = "";
    writer_mtl.println(output);  
  }
  

    public void beginShape(int kind) {
      shape = kind;
      vertexCount = 0;
    }

    public void vertex(float x, float y) {
      vertex(x,y,0);
    }

    public void vertex(float x, float y,float z) {
        float vertex[] = vertices[vertexCount];
        //write verticesMap
        if(!ptMap.containsKey(x+"_"+y+"_"+z)) {
          if(ptMap.size() >= pts.length) {
          PVector newPts[] = new PVector[pts.length*2];
          System.arraycopy(pts,0,newPts,0,pts.length);
          pts = newPts;
          }
          pts[ptMap.size()] = new PVector(x,y,z);
          ptMap.put(x+"_"+y+"_"+z,""+(ptMap.size()+1));
        }
        //write uvMap
        if(exportUV){
          if(!uvMap.containsKey(textureU+"_"+textureV)) {
              if(uvMap.size() >= uv.length) {
              PVector newuv[] = new PVector[uv.length*2];
              System.arraycopy(uv,0,newuv,0,uv.length);
              uv = newuv;
              }
              uv[uvMap.size()] = new PVector(textureU,textureV);
              uvMap.put(textureU+"_"+textureV,""+(uvMap.size()+1));
            }
        }
        
        
        
        
        vertex[X] = x;  // note: not mx, my, mz like PGraphics3
        vertex[Y] = y;
        vertex[Z] = z;
  
        if (fill) {
          
          vertex[R] = fillR;
          vertex[G] = fillG;
          vertex[B] = fillB;
          vertex[A] = fillA;
        }
  
        if (stroke) {
          vertex[SR] = strokeR;
          vertex[SG] = strokeG;
          vertex[SB] = strokeB;
          vertex[SA] = strokeA;
          vertex[SW] = strokeWeight;
        }
  
        //if (textureImage != null) {  // for the future?
        if (exportUV) {
          vertex[U] = textureU;
          vertex[V] = textureV;
        }
      //check Materials
      if (fill) {
            setMaterialFromFill((float)vertex[R],(float)vertex[G],(float)vertex[B],(float)vertex[A]);
          }
        
        vertexCount++;
    }
    
    
      
    
    public void vertex(float x, float y,float z,float u, float v) {
      
      vertexTexture( u,  v);
      vertex( x,  y, z);
      
    }
    
    protected void vertexTexture(float u, float v) {
     
        textureU = u;
        textureV = v;
      
    }
      
    public void endShape(int mode) {
      //if(stroke) endShapeStroke(mode);
      //if(fill) endShapeFill(mode);
      endShapeFill(mode);
   }
    
    public void endShapeFill(int mode) {
        switch(shape) {
        case TRIANGLES:
          {
          int stop = vertexCount-2;
            for (int i = 0; i < stop; i += 3) {
              if(!exportUV){  
                int[] f = new int[3];
                f[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                f[1] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                f[2] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
                addFace(f);
              }else{
                int[] f = new int[6];
                f[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                f[3] = PApplet.parseInt(uvMap.get(vertices[i][U]+"_"+vertices[i][V]));
                f[1] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                f[4] = PApplet.parseInt(uvMap.get(vertices[i+1][U]+"_"+vertices[i+1][V]));
                f[2] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
                f[5] = PApplet.parseInt(uvMap.get(vertices[i+2][U]+"_"+vertices[i+2][V]));
                addFace(f);
              }
            }
          }
          break;
        case TRIANGLE_STRIP:
        {
            int stop = vertexCount - 2;
            for (int i = 0; i < stop; i++) {
              // have to switch between clockwise/counter-clockwise
              // otherwise the feller is backwards and renderer won't draw
              if(!exportUV){
                if ((i % 2) == 0) {
                  int[] f = new int[3];
                  f[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                  f[1] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
                  f[2] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                  addFace(f);
                } else {
                  int[] f = new int[3];
                  f[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                  f[1] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                  f[2] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
                  addFace(f);
                }
              }else{
                if ((i % 2) == 0) {
                  int[] f = new int[6];
                  f[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                  f[3] = PApplet.parseInt(uvMap.get(vertices[i][U]+"_"+vertices[i][V]));
                  f[1] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
                  f[4] = PApplet.parseInt(uvMap.get(vertices[i+2][U]+"_"+vertices[i+2][V]));
                  f[2] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                  f[5] = PApplet.parseInt(uvMap.get(vertices[i+1][U]+"_"+vertices[i+1][V]));
                  addFace(f);
                } else {
                  int[] f = new int[6];
                  f[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                  f[3] = PApplet.parseInt(uvMap.get(vertices[i][U]+"_"+vertices[i][V]));
                  f[1] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                  f[4] = PApplet.parseInt(uvMap.get(vertices[i+1][U]+"_"+vertices[i+1][V]));
                  f[2] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
                  f[5] = PApplet.parseInt(uvMap.get(vertices[i+2][U]+"_"+vertices[i+2][V]));
                  addFace(f);
                }
              }
            }
        }
        break;
        case POLYGON:
        {
          int[] f;
          boolean closed = vertices[0][X]!=vertices[vertexCount-1][X] || vertices[0][Y]!=vertices[vertexCount-1][Y] || vertices[0][Z]!=vertices[vertexCount-1][Z];
          if(!exportUV){
            if(closed) {
             f = new int[vertexCount];
            } else {
             f = new int[vertexCount-1];
            }
            int end = vertexCount;
            if(!closed) end--;
            for(int i=0;i<end;++i) {
              f[i] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
            }
            addFace(f);
          }else{
            if(closed) {
              f = new int[vertexCount*2];
          } else {
            f = new int[(vertexCount-1)*2];
          }
          int end = vertexCount;
          if(!closed) end--;
          for(int i=0;i<end;++i) {
            f[i] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
            f[i+vertexCount] = PApplet.parseInt(uvMap.get(vertices[i][U]+"_"+vertices[i][V]));
          }
          addFace(f);
          }
        }
        break;
        case QUADS:
        {
          int stop = vertexCount-3;
          if(!exportUV){
            for (int i = 0; i < stop; i += 4) {
                int[] f = new int[4];
                f[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                f[1] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                f[2] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
                f[3] = PApplet.parseInt(ptMap.get(vertices[i+3][X]+"_"+vertices[i+3][Y]+"_"+vertices[i+3][Z]));
                addFace(f);
            }
          }else{
            for (int i = 0; i < stop; i += 4) {
              int[] f = new int[8];
              f[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
              f[4] = PApplet.parseInt(uvMap.get(vertices[i][U]+"_"+vertices[i][V]));
              f[1] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
              f[5] = PApplet.parseInt(uvMap.get(vertices[i+1][U]+"_"+vertices[i+1][V]));
              f[2] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
              f[6] = PApplet.parseInt(uvMap.get(vertices[i+2][U]+"_"+vertices[i+2][V]));
              f[3] = PApplet.parseInt(ptMap.get(vertices[i+3][X]+"_"+vertices[i+3][Y]+"_"+vertices[i+3][Z]));
              f[7] = PApplet.parseInt(uvMap.get(vertices[i+3][U]+"_"+vertices[i+3][V]));
              addFace(f);
            }
          }
        }
        break;

        case QUAD_STRIP:
        {
          int stop = vertexCount-3;
          for (int i = 0; i < stop; i += 2) {
            if(!exportUV){
                int[] f = new int[4];
                f[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                f[1] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                f[3] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
                f[2] = PApplet.parseInt(ptMap.get(vertices[i+3][X]+"_"+vertices[i+3][Y]+"_"+vertices[i+3][Z]));
                addFace(f);  
            }else{
                int[] f = new int[8];
                f[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                f[4] = PApplet.parseInt(uvMap.get(vertices[i][U]+"_"+vertices[i][V]));
                f[1] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                f[5] = PApplet.parseInt(uvMap.get(vertices[i+1][U]+"_"+vertices[i+1][V]));
                f[3] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
                f[7] = PApplet.parseInt(uvMap.get(vertices[i+2][U]+"_"+vertices[i+2][V]));
                f[2] = PApplet.parseInt(ptMap.get(vertices[i+3][X]+"_"+vertices[i+3][Y]+"_"+vertices[i+3][Z]));
                f[6] = PApplet.parseInt(uvMap.get(vertices[i+3][U]+"_"+vertices[i+3][V]));
                addFace(f);                
            }
          }
        }
        break;
        case TRIANGLE_FAN:
        {
          int stop = vertexCount - 1;
          for (int i = 1; i < stop; i++) {
            if(!exportUV){
              int f[] = new int[3];
                f[0] = PApplet.parseInt(ptMap.get(vertices[0][X]+"_"+vertices[0][Y]+"_"+vertices[0][Z]));
                f[1] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                f[2] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                addFace(f);
            }else{
              int f[] = new int[6];
                f[0] = PApplet.parseInt(ptMap.get(vertices[0][X]+"_"+vertices[0][Y]+"_"+vertices[0][Z]));
                f[3] = PApplet.parseInt(uvMap.get(vertices[0][U]+"_"+vertices[0][V]));
                f[1] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                f[4] = PApplet.parseInt(uvMap.get(vertices[i][U]+"_"+vertices[i][V]));
                f[2] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                f[5] = PApplet.parseInt(uvMap.get(vertices[i+1][U]+"_"+vertices[i+1][V]));
                addFace(f);              
            }
          }
        }
        break;
      }    
    }
    
    //unused as of now
    /*
    public void endShapeStroke(int mode) {
        switch(shape) {
        case LINES:
          {
          int stop = vertexCount-1;
          for (int i = 0; i < stop; i += 2) {
                int[] l = new int[2];
                l[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
                l[1] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
                addLine(l);;
            }
          }
          break;
        case TRIANGLES:
          {
          int stop = vertexCount-2;
            for (int i = 0; i < stop; i += 3) {
              int[] l = new int[4];
              l[0] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
              l[1] = PApplet.parseInt(ptMap.get(vertices[i+1][X]+"_"+vertices[i+1][Y]+"_"+vertices[i+1][Z]));
              l[2] = PApplet.parseInt(ptMap.get(vertices[i+2][X]+"_"+vertices[i+2][Y]+"_"+vertices[i+2][Z]));
              l[3] = l[0];
              addLine(l);;
            }
          }
        
        break;
        case POLYGON:
        {
          int[] l;
          boolean closed = mode == CLOSE && (vertices[0][X]!=vertices[vertexCount-1][X] || vertices[0][Y]!=vertices[vertexCount-1][Y] || vertices[0][Z]!=vertices[vertexCount-1][Z]);
          if(closed) {
           l = new int[vertexCount+1];
          } else {
           l = new int[vertexCount];
          }
          for(int i=0;i<vertexCount;++i) {
            l[i] = PApplet.parseInt(ptMap.get(vertices[i][X]+"_"+vertices[i][Y]+"_"+vertices[i][Z]));
          }
          if(closed) l[vertexCount] = l[0];
          addLine(l);;
        }
        break;
      }
    }
    */
    
    private void addFace(int[] f) {
     if(faceCount >= faces_groups_materials.length) {
      int newfaces[][] = new int[faces_groups_materials.length*2][];
      System.arraycopy(faces_groups_materials,0,newfaces,0,faces_groups_materials.length);
      faces_groups_materials = newfaces;
     }
     faces_groups_materials[faceCount++] = f;
    }
    
    /*
    private void addLine(int[] l) {
     if(lineCount >= lines.length) {
      int newLines[][] = new int[lines.length*2][];
      System.arraycopy(lines,0,newLines,0,lines.length);
      lines = newLines;
     }
     lines[lineCount++] = l;
    }
    */
  
  /*private void autoSetObject(String name) //doesn't work this way :(
  {
    object_name = (String[])PApplet.append(object_name, name);
    int current_oject = object_name.length-1;
    int[] f = new int[2];
      f[0] = current_oject;
      addFace(f);
  }*/
  
    
  /**
   * set the Group for the following drawings
   * 
   * @param name "a name for the Group"
   */
  public void setObject(String name)
  {
    if(useObjects == true &&  manualObjects == true)
    {
      object_name = (String[])PApplet.append(object_name, name);
      int current_oject = object_name.length-1;
      int[] f = new int[2];
        f[0] = current_oject;
        addFace(f);
    }
  }
    
    
  /**
   * set the Material for the following drawings, this is used like fill(), just with the possibility to specify a name
   * <p>
   * if a material with the same name already exist, this material will be used!
   * <p>
   * @param name "a name for the Material"
   * @param r "the red value 0-255"
   * @param g "the green value 0-255"
   * @param b "the blue value 0-255"
   * @param a "the alpha value 0-255"
   */    
  public void setMaterial(String name, int r, int g, int b, int a)
  {
    if(useMaterials && materialsFromMaterial){
         if(materials_name.length == 0)
         {
           float[] mat = {(float)r,(float)g,(float)b,(float)a};
           materials_name = (String[])PApplet.append(materials_name,name);
           materials_data = (float[][])PApplet.append(materials_data,mat);
           current_material = materials_name.length-1;
         }else{
          boolean newMat = true;
           for(int i = 0; i<materials_name.length; i++)
           {
             if(materials_name[i] == name)
             {
               current_material = i;
               newMat = false;
               break;
             }
           }
             if(newMat){
               float[] mat = {(float)r,(float)g,(float)b,(float)a};
               materials_name = (String[])PApplet.append(materials_name,name);
             materials_data = (float[][])PApplet.append(materials_data,mat);
             current_material = materials_name.length-1;
              
             }
           }
         
         
         int[] f = new int[1];
         f[0] = current_material;
         addFace(f);
    }
         
  }
  /**
   * set the Material for the following drawings, this is used like fill(), just with the possibility to specify a name
   * <p>
   * if a material with the same name already exist, this material will be used!
   * <p>
   * the alpha value will be set to 255
   * 
   * @param name "a name for the Material"
   * @param r "the red value 0-255"
   * @param g "the green value 0-255"
   * @param b "the blue value 0-255"
   */  
  public void setMaterial(String name, int r, int g, int b){
    setMaterial(name,r,g,b,255);
  }
  /**
   * set the Material for the following drawings, this is used like fill(), just with the possibility to specify a name
   * <p>
   * if a material with the same name already exist, this material will be used!
   * <p>
   * the color will be black - (0,0,0)
   * the alpha value will be set to 255
   * 
   * 
   * @param name "a name for the Material"
   */  
  public void setMaterial(String name)
  {
    setMaterial(name,0,0,0,255);
  }
  
    
    private void setMaterialFromFill(float r, float g, float b, float a)
    {
      if(useMaterials && materialsFromFill){
        
        boolean newMat = true;
        int temp_current = current_material;
        
           if(materials_data.length == 0)
           {
             float[] mat = {r,g,b,a};
             materials_name = (String[])PApplet.append(materials_name,"Mat0");
             materials_data = (float[][])PApplet.append(materials_data,mat);
             current_material = 0;
           }else{
            
             for(int i = 0; i<materials_data.length; i++)
             {
               if(materials_data[i][0] == r && materials_data[i][1] == g && materials_data[i][2] == b && materials_data[i][3] == a)
               {
                 current_material = i;
                 newMat = false;
                 break;
               }
             }
             if(newMat){
                  float[] mat = {r,g,b,a};
               materials_data = (float[][])PApplet.append(materials_data,mat);
               current_material = materials_data.length-1;
               materials_name = (String[])PApplet.append(materials_name,"Mat"+current_material);
             }
           }
           
           
           if(newMat || temp_current!=current_material){
             int[] f = new int[1];
             f[0] = current_material;
             addFace(f);
           }
      }
           
    }
    
    
}


