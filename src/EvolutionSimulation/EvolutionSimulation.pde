Creature[] creatures;
boolean[][] isInhabited;
SelectionCriteria SC;

boolean logData = false;
boolean dataLoggingPathIsSpecified = false;
Table log;
String logPath = "";

boolean paused = true;
boolean showSteps = true; //if it should show steps in between generations. Slower if true
boolean saveCreatures = false; //Tracker for the loop so it knows to save or not.
boolean loadSaveFile = false;
String saveFilePath = "";

void setup() {
  creatures = new Creature[population];
  isInhabited = new boolean[worldSize.x][worldSize.y];
  
  SC = new SelectionCriteria();
  
  size(768, 768);
  surface.setAlwaysOnTop(true);
  frameRate(30);
  
  for (int i = 0; i < creatures.length; i++) {
    creatures[i] = new Creature();
  }
  
  SC.addRectangle(64, 0, 64, 128);
  
  if (logData) {
    selectInput("Select the output file for the data: ", "fileSelected");
  } else {
    dataLoggingPathIsSpecified = true;
  }
}

int generations = 0;
int steps = 0;
void draw() {
  if (!dataLoggingPathIsSpecified) {
    return;
  }
  
  if (!paused) {
    for (int i = 0; (i < stepsPerGen && !showSteps) || i == 0; i++) {
      for (Creature c: creatures) {
        c.step();
      }
      steps++;
      
      //Check whether to save or not
      if (saveCreatures) {
        saveCreatures = false;
        paused = true;
        
        //Convert sim to JSON and save it
        JSONObject simSnapshot = new JSONObject();
        simSnapshot.setInt("steps", steps);
        simSnapshot.setInt("generation", generations);
        simSnapshot.setString("safeAreas", SC.toJSONString());
        simSnapshot.setInt("population", population);
        simSnapshot.setInt("stepsPerGen", stepsPerGen);
        simSnapshot.setInt("genesPerGenome", genesPerGenome);
        simSnapshot.setInt("innerNeurons", innerNeurons);
        simSnapshot.setFloat("mutationRate", mutationRate);
        
        JSONArray creatureArray = new JSONArray();
        for (Creature c: creatures) {
          creatureArray.append(c.toJSONObject());
        }
        
        simSnapshot.setJSONArray("creatures", creatureArray);
        saveJSONObject(simSnapshot, "data/saves/" + day() + "_" + month() + "_" + second() + "_" + minute() + "_" + hour() + ".json");
      }
      
      if (loadSaveFile) {
        paused = true;
        loadSaveFile = false;
  
        JSONObject saveFile = loadJSONObject(saveFilePath);
        steps = saveFile.getInt("steps");
        generations = saveFile.getInt("generation");
        String safeAreas = saveFile.getString("safeAreas");
        population = saveFile.getInt("population");
        stepsPerGen = saveFile.getInt("stepsPerGen");
        genesPerGenome = saveFile.getInt("genesPerGenome");
        innerNeurons = saveFile.getInt("innerNeurons");
        mutationRate = saveFile.getFloat("mutationRate");
        
        SC = new SelectionCriteria(safeAreas);
        
        JSONArray newCreatures = saveFile.getJSONArray("creatures");
        creatures = new Creature[newCreatures.size()];
        for (int c = 0; c < newCreatures.size(); c++) {
          creatures[c] = new Creature(newCreatures.getJSONObject(c));
        }
      }
    }
  }
  
  if (generations % 1 == 0) {
    background(170);
    SC.show();
    
    for (Creature c: creatures) {
      c.show();
    }
  }
  
  if (steps >= stepsPerGen) {
    steps = 0;
    println("-------------------------\nGeneration: " + generations);
    ArrayList<Creature> selectedCreatures = new ArrayList<Creature>();
    for (Creature c: creatures) {
      if (!c.isAlive) {
        continue;
      }
      
      if (SC.isPointInSafeArea(c.position)) { //Add the creature if it meets the selection criteria
        selectedCreatures.add(c);
      }
    }
    println("Survivors: " + selectedCreatures.size());
    float survivalRate = (float)selectedCreatures.size() / (float)population * 100f;
    println("Survival rate: " + survivalRate + "%");
    
    //Calculate diversity by finding the average color
    //and the average divergence, then do some fancy math
    //to get a number between 0 and 1
    int highestColor = creatures[0].col;
    int lowestColor = highestColor;
    long colorSum = creatures[0].col;
    for (int i = 1; i < creatures.length; i++) {
      colorSum += creatures[i].col;
      if (creatures[i].col > highestColor) {
        highestColor = creatures[i].col;
      }
      if (creatures[i].col < lowestColor) {
        lowestColor = creatures[i].col;
      }
    }
    int averageColor = (int)(colorSum / creatures.length);
    
    
    float diversity = 1 - (float)highestColor / (float)averageColor;
    println("Diversity: " + diversity);
      
    //
    //Log data
    //
    if (logData) {
      TableRow newRow = log.addRow();
      newRow.setInt("generation", generations);
      newRow.setFloat("survivalRate", survivalRate);
      newRow.setFloat("diversity", diversity);
      
      saveTable(log, logPath);
    }
    
    //Mix selected creatures if there are enough survivors of course
    if (selectedCreatures.size() > 1) {
      ArrayList<Creature> children = new ArrayList<Creature>();
      int selectedLength = selectedCreatures.size();
      selectedLength -= selectedLength % 2;
      
      while (children.size() < population) {
        for (int i = 0; i < selectedLength && children.size() < population; i += 2) {
          //Make new creature from parent creatures
          children.add(new Creature(selectedCreatures.get(i), selectedCreatures.get(i+1)));
        }
      }
      
      creatures = new Creature[children.size()];
      isInhabited = new boolean[worldSize.x][worldSize.y];
      for (int c = 0; c < creatures.length; c++) {
        creatures[c] = children.get(c);
      }
    } else {
      println("Species died out");
      noLoop();
    }
    
    generations++;
  }
}



Creature getClosestCreatureToPosition(int x, int y) {
  if (creatures.length <= 0) {
    return null;
  }
  
  float closestDistance = sqrt(pow(x - creatures[0].position.x, 2) + pow(y - creatures[0].position.y, 2));
  Creature closestCreature = creatures[0];
  
  for (Creature c: creatures) {
    float dist = sqrt(pow(x - c.position.x, 2) + pow(y - c.position.y, 2));
    if (dist < closestDistance) {
      closestDistance = dist;
      closestCreature = c;
    }
  }
  
  return closestCreature;
}

void fileSelected(File selection) {
  if (selection == null) {
    logData = false;
    dataLoggingPathIsSpecified = true;
    return;
  }
  
  //Check if filetype is csv
  String pathName = selection.getAbsolutePath();
  if (!fileType(pathName).equals("csv")) {
    selectInput("Select the output file for the data with the .csv extension: ", "fileSelected");
    return;
  }
  
  dataLoggingPathIsSpecified = true;
  log = new Table();
  
  log.addColumn("generation");
  log.addColumn("survivalRate");
  log.addColumn("diversity");
  
  saveTable(log, pathName);
  logPath = pathName;
}

void selectedLoadFile(File selection) {
  if (selection == null) {
    return;
  }
  String pathName = selection.getAbsolutePath();
  if (!fileType(pathName).equals("json")) {
    return;
  }
  
  loadSaveFile = true;
  saveFilePath = selection.getAbsolutePath();
}

String fileType(String filePath) {
  String[] sections = split(filePath, ".");
  if (sections.length == 0) {
    return null;
  }
  
  return sections[sections.length-1].toLowerCase();
}
