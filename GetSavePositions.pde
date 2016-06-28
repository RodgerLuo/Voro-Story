void getPositions(){
  output = createWriter("data/positions.txt");  
    
  long key=0;
  
  for(int i=0;i<numcells;i++){
    if(i == numcells-1){
      HE_Vertex v= cells[i].getVertexByKey(key);
      HE_Face f= cells[i].getFaceByKey(key);
    
      //println();
      //println("# vertices: "+cells[i].getNumberOfVertices());
      HE_VertexIterator vItr=new HE_VertexIterator(cells[i]);
      while (vItr.hasNext ()) {
        v=vItr.next();
        //println(v);
      }
      
      //println();
      //println("# faces: "+cells[i].getNumberOfFaces());
      HE_FaceIterator fItr=new HE_FaceIterator(cells[i]);
      while (fItr.hasNext ()) {
        f=fItr.next();
        //println(f);
      }
      
      //println();
      //println("Vertices of face: "+f);
      HE_FaceVertexCirculator fvCrc=new HE_FaceVertexCirculator(f);
      while (fvCrc.hasNext ()) {
       v=fvCrc.next();
       output.println(v);
       output.flush();
       //println(v);
      }
    }
  } 
}

void savePositions(){
  
    String[] positions = loadStrings("positions.txt");
    for(int n=0; n<positions.length; n++){ 
      String[] list = splitTokens(positions[n]);
      for(int i=3; i<6; i++){
        String[] list2 = split(list[i], '=');
        String[] list3 = split(list2[1], ',');
        String[] list4 = split(list3[0], ']');
        tempCoor[n][i-3] = float(list4[0]);
      }
    }
    
    for(int i=0;i<tempCoor.length;i++){
      OneMeshPoints[i] = new PVector(tempCoor[i][0],tempCoor[i][1],tempCoor[i][2]);
      //println("position: " + OneMeshPoints[i].x + " " + OneMeshPoints[i].y + " " + OneMeshPoints[i].z);
    }
  
}
