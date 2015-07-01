MW-lite (Mesh Warp Lite) is a fork from the great MeshWarp Server by Maybites
v30
this is the Yopla version : an adaptation in order to make quick test in theatre research for example



added : 

1/ 
graphical user interface change : 
add modules, minimize, drag and drop them in there own windows
save the content of them and the graphical organization (quick autosave or on another fie)
the save file consider as relative the file which are in the same folder and subdfolders as the app file. So it's possible to copy all the folder and keep the paths with the arborescence of your choice.


2/ 
QuickMesh
i've a made a little modelisation tool : quickMesh-2D creator to make some *.obj grids without blender. 
it's only export tri, so the subdivsion doesn't work
quickMesh.app must be in the /quickmesh folder to be load from MW-l


3/ 
video server + client 
osc-bonjour for recongintion
multiscreener from Zack Poff for synchro


3/ 
videos from another patch : use a specific context to send a video from patch to MW-L

4/ 
original softedge and mask removed. Just use another mesh with blendMode and a gradient texture.

5/ 
no osc remote… but why not a time line sync in the future

6/
cornerpin modifier around mesh is possible, Excellent : move the anchor inside of the plane ! (osx only)

7/
send mesh as texture to another mesh