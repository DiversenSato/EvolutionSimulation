class SelectionCriteria {
  boolean[][] safeArea;
  
  SelectionCriteria() {
    safeArea = new boolean[worldSize.x][worldSize.y];
  }
  
  //If the simulation is being loaded from a save,
  //this constructor will run which can import
  //the layout from a string of "1" and "0" where
  //"1" is safe and "0" is not safe.
  SelectionCriteria(String data) {
    //Set the size to the correct world size,
    //however this will cause problems if
    //this selection criteria is made before
    //the world data is loaded.
    safeArea = new boolean[worldSize.x][worldSize.y];
    
    String[] dataBits = data.split("");
    
    //Loops through tiles and compares it to the corresponding
    //character in the save data.
    for (int y = 0; y < safeArea[0].length; y++) {
      for (int x = 0; x < safeArea.length; x++) {
        int i = x + y*safeArea.length;
        
        safeArea[x][y] = dataBits[i].equals("1");
      }
    }
  }
  
  //Function for adding a rectangle of safe area.
  void addRectangle(int leftEdge, int topEdge, int w, int h) {
    for (int x = leftEdge; x < leftEdge + w && x < safeArea.length; x++) {
      for (int y = topEdge; y < topEdge + h && y < safeArea[0].length; y++) {
        safeArea[x][y] = true;
      }
    }
  }
  
  //Function for adding a circle of safe area.
  void addCircle(int circleX, int circleY, int radius) {
    for (int y = 0; y < safeArea[0].length; y++) {
      for (int x = 0; x < safeArea.length; x++) {
        if (sqrt((circleX-x)*(circleX-x) + (circleY-y)*(circleY-y)) <= radius) {
          safeArea[x][y] = true;
        }
      }
    }
  }
  
  boolean isPointInSafeArea(IVector point) {
    if (point.x >= safeArea.length) {
      return false;
    }
    if (point.y >= safeArea[0].length) {
      return false;
    }
    
    return safeArea[point.x][point.y];
  }
  
  String toJSONString() {
    String formattedString = "";
    for (int y = 0; y < safeArea[0].length; y++) {
      for (int x = 0; x < safeArea.length; x++) {
        formattedString += safeArea[x][y] ? "1" : "0";
      }
    }
    
    return formattedString;
  }
  
  void show() {
    noStroke();
    fill(0, 255, 0, 60);
    for (int y = 0; y < safeArea[0].length; y++) {
      for (int x = 0; x < safeArea.length; x++) {
        if (safeArea[x][y]) {
          rect(x*6, y*6, 6, 6);
        }
      }
    }
  }
}
