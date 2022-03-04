class Creature {
  IVector position = new IVector(round(random(worldSize.x-1)), round(random(worldSize.y-1)));
  IVector forwardDirection;
  Genome genome;
  NeuralNetwork brain;
  
  color col = color(0);
  int age = 0;
  boolean isAlive = true;
  
  float tolerance = 0.5;
  
  Creature() {
    while(isInhabited[position.x][position.y]) {
      position.x = round(random(worldSize.x-1));
      position.y = round(random(worldSize.y-1));
    }
    isInhabited[position.x][position.y] = true;
    
    forwardDirection = new IVector(round(random(-1, 1)), round(random(-1, 1)));
    while (forwardDirection.x == 0 && forwardDirection.y == 0) {
      forwardDirection.x = round(random(-1, 1));
      forwardDirection.y = round(random(-1, 1));
    }
    genome = new Genome();
    brain = new NeuralNetwork(genome);
    
    generateColor(); //<>//
  }
  
  Creature(Creature parent1, Creature parent2) {
    isInhabited[position.x][position.y] = true;
    
    forwardDirection = new IVector(round(random(-1, 1)), round(random(-1, 1)));
    while (forwardDirection.x == 0 && forwardDirection.y == 0) {
      forwardDirection.x = round(random(-1, 1));
      forwardDirection.y = round(random(-1, 1));
    }
    
    genome = new Genome(parent1.genome, parent2.genome);
    brain = new NeuralNetwork(genome);
    
    generateColor();
  }
  
  Creature(JSONObject creatureData) {
    position.x = creatureData.getInt("posX");
    position.y = creatureData.getInt("posY");
    
    forwardDirection = new IVector();
    forwardDirection.x = creatureData.getInt("forwardX");
    forwardDirection.y = creatureData.getInt("forwardY");
    age = creatureData.getInt("age");
    
    genome = new Genome(creatureData.getJSONArray("genes"));
    brain = new NeuralNetwork(genome);
    
    generateColor();
  }
  
  void step() {
    if (!isAlive) {
      return;
    }
    
    setInputSensors();
    age++;
    
    float MNValue = brain.actionNodes[ActionNodeNames.MN.ordinal()].getValue();
    float MSValue = brain.actionNodes[ActionNodeNames.MS.ordinal()].getValue();
    float MEValue = brain.actionNodes[ActionNodeNames.ME.ordinal()].getValue();
    float MWValue = brain.actionNodes[ActionNodeNames.MW.ordinal()].getValue();
    float MFValue = brain.actionNodes[ActionNodeNames.MF.ordinal()].getValue();
    float MRValue = brain.actionNodes[ActionNodeNames.MR.ordinal()].getValue();
    float MLValue = brain.actionNodes[ActionNodeNames.ML.ordinal()].getValue();
    float MRNValue = brain.actionNodes[ActionNodeNames.MRN.ordinal()].getValue();
    float KILLValue = brain.actionNodes[ActionNodeNames.KILL.ordinal()].getValue();
    
    float highestValue = max(max(max(max(MNValue, MSValue, MEValue), MWValue, MFValue), MRValue, MLValue), MRNValue);
    
    boolean setForwardDirection = true;
    
    //Check if this creature should kill a creature in front of it. The long if statement is to avoid NullPointerExceptions
    if (KILLValue > tolerance && position.x+forwardDirection.x >= 0 && position.x+forwardDirection.x < worldSize.x &&
                                 position.y+forwardDirection.y >= 0 && position.y+forwardDirection.y < worldSize.y) {
      if (isInhabited[position.x+forwardDirection.x][position.y+forwardDirection.y]) {
        //A creature exists in front of this creature that needs to die. First get said creature, then kill it
        Creature doomedCreature = getClosestCreatureToPosition(position.x+forwardDirection.x, position.y+forwardDirection.y);
        doomedCreature.die();
      }
    }
    
    IVector newPosition = position.copy();
    if (highestValue > tolerance) {
      if (MNValue == highestValue) {
        newPosition.y -= 1;
      } else if (MSValue == highestValue) {
        newPosition.y += 1;
      } else if (MEValue == highestValue) {
        newPosition.x += 1;
      } else if (MWValue == highestValue) {
        newPosition.x -= 1;
      } else if (MFValue == highestValue) {
        newPosition.add(forwardDirection);
      } else if (MRValue == highestValue) {
        newPosition.add(forwardDirection.y, forwardDirection.x);
        setForwardDirection = false;
      } else if (MLValue == highestValue) {
        newPosition.add(forwardDirection.y, -forwardDirection.x);
        setForwardDirection = false;
      } else if (MRNValue == highestValue) {
        int randomConfiguration = round(random(8));
        newPosition.x += ((randomConfiguration + ((randomConfiguration > 3) ? 1 : 0)) % 3) - 1;
        newPosition.y += ((randomConfiguration + ((randomConfiguration > 3) ? 1 : 0)) / 3) - 1;
      }
    }
    
    //Clamp new move to neighbor tiles
    newPosition.x = clamp(newPosition.x, position.x-1, position.x+1);
    newPosition.y = clamp(newPosition.y, position.y-1, position.y+1);
    
    //Clamp to world borders
    newPosition.x = clamp(newPosition.x, 0, worldSize.x-1);
    newPosition.y = clamp(newPosition.y, 0, worldSize.y-1);
    
    //Check if spot is occupied
    if (!isInhabited[newPosition.x][newPosition.y]) {
      isInhabited[position.x][position.y] = false;
      
      //Sometimes we don't want to set the forward direction which is specified by setForwardDirection
      //E.g. if the creature is stepping to the right, the forward direction shouldn't change
      if (setForwardDirection) {
        forwardDirection = IVector.sub(newPosition, position);
      }
      position = newPosition;
      isInhabited[position.x][position.y] = true;
    }
  }
  
  void setInputSensors() {
    int worldSizeX = worldSize.x;
    int worldSizeY = worldSize.y;
    brain.inputNodes[InputNodeNames.LX.ordinal()].value = (float)position.x / (float)worldSizeX;
    brain.inputNodes[InputNodeNames.LY.ordinal()].value = (float)position.y / (float)worldSizeY;
    brain.inputNodes[InputNodeNames.BDX.ordinal()].value = (float)min(position.x, worldSizeX-position.x) / (float)worldSizeX * 2;
    brain.inputNodes[InputNodeNames.BDY.ordinal()].value = (float)min(position.y, worldSizeY-position.y) / (float)worldSizeY * 2;
    
    brain.inputNodes[InputNodeNames.RND.ordinal()].value = random(1);
    brain.inputNodes[InputNodeNames.AGE.ordinal()].value = (float)age / (float)stepsPerGen;
    
    Node LPFNode = brain.inputNodes[InputNodeNames.LPF.ordinal()];
    try {
      LPFNode.value = (isInhabited[position.x + forwardDirection.x][position.y + forwardDirection.y]) ? 0 : 1;
    } catch (Exception e) {
      LPFNode.value = 0;
    }
  }
  
  void generateColor() {
    //Generate creatures color
    int r = 0, g = 0, b = 0;
    int genesAmount = genome.genes.length;
    for (int gene: genome.genes) {
      r += gene >> 23 & 0xFF;
      g += gene >> 15 & 0xFF;
      b += gene >> 6 & 0xFF;
    }
    r /= genesAmount;
    g /= genesAmount;
    b /= genesAmount;
    col = color(r, g, b, 255);
  }
  
  JSONObject toJSONObject() {
    JSONObject object = new JSONObject();
    
    object.setInt("posX", position.x);
    object.setInt("posY", position.y);
    object.setInt("forwardX", forwardDirection.x);
    object.setInt("forwardY", forwardDirection.y);
    object.setInt("age", age);
    object.setJSONArray("genes", genome.toJSONArray());
    
    return object;
  }
  
  void die() {
    isAlive = false;
    isInhabited[position.x][position.y] = false;
  }
  
  void show() {
    if (!isAlive) {
      return;
    }
    
    stroke(col);
    strokeWeight(width / worldSize.x);
    point((position.x+0.5) * width / worldSize.x, (position.y+0.5) * height / worldSize.y);
  }
}
