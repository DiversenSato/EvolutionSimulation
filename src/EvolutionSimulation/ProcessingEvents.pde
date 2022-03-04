void mousePressed() {
  //Return the genome of the creature closest to the mouse
  Creature closestCreature = getClosestCreatureToPosition(mouseX*worldSize.x/width, mouseY*worldSize.y/height);
  
  if (closestCreature != null) {
    print("\n--------------------------------\nCreature position: ");
    println(closestCreature.position.toString());
    print(closestCreature.genome.toString());
  }
}

void keyPressed() {
  if (keyCode == 32 /*the same as ' '*/) {
    paused = !paused;
  } else if (keyCode == UP) {
    showSteps = !showSteps;
  } else if (keyCode == 83 /*the same as 'S'*/) {
    saveCreatures = true; //Set save tracker
  } else if (keyCode == RIGHT && paused) {
    for (Creature c: creatures) {
      c.step();
    }
    steps++;
  } else if (keyCode == 76 /*the same as 'L'*/) {
    selectInput("Select the file to load from:", "selectedLoadFile");
  } else if (keyCode == 86) {
    getClosestCreatureToPosition(mouseX*worldSize.x/width, mouseY*worldSize.y/height).brain.visualize();
  }
}
