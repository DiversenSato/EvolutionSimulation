class NeuralNetwork {
  Node[] inputNodes, internalNodes, actionNodes;
  Genome geneticData;
  
  NeuralNetwork(Genome genome) {
    geneticData = genome;
    
    inputNodes = new Node[InputNodeNames.values().length];
    for (int i = 0; i < inputNodes.length; i++) {
      inputNodes[i] = new InputNode(i, 0);
    }
    
    internalNodes = new Node[innerNeurons];
    for (int i = 0; i < internalNodes.length; i++) {
      internalNodes[i] = new InnerNode(i, 0);
    }
    
    actionNodes = new Node[ActionNodeNames.values().length];
    for (int i = 0; i < actionNodes.length; i++) {
      actionNodes[i] = new ActionNode(i, 0);
    }
    
    //When all nodes/neurons are defined, connect them according to the genetic data/genome
    for (int i = 0; i < genome.genes.length; i++) {
      int g = genome.genes[i];
      byte sourceType = (byte)((g >> 31) & 1);
      byte sourceID = (byte)((g >> 24) & 0x7F);
      byte sinkType = (byte)((g >> 23) & 1);
      byte sinkID = (byte)((g >> 16) & 0x7F);
      short weightInt = (short)(g & 0xFFFF);
      float weight = (float)weightInt / 8191f;
      
      if (sourceType == 1 || sinkType == 1) {
        sinkType = 0;
        genome.genes[i] -= 0x800000;
        if (internalNodes.length == 0) {
          sourceType = 0;
          genome.genes[i] -= 0x80000000;
        }
      }
      
      Connection newConnection;
      if (sourceType == 0) {
        newConnection = new Connection(inputNodes[sourceID % inputNodes.length], weight);
      } else {
        newConnection = new Connection(internalNodes[sourceID % internalNodes.length], weight);
      }
      

      if (sinkType == 1) { //Sink is internal node
        if (internalNodes.length == 0) {
          genome.genes[i] -= 0x800000;
          actionNodes[sinkID % actionNodes.length].connectedNodes.add(newConnection);
        } else {
          internalNodes[sinkID % internalNodes.length].connectedNodes.add(newConnection);
        }
      } else {
        actionNodes[sinkID % actionNodes.length].connectedNodes.add(newConnection);
      }
    }
  }
  
  //Opens a picture of this neuralnetwork
  void visualize() {
    PGraphics image = createGraphics(1200, 800);
    image.beginDraw();

    image.background(200);
    
    //Draw lines to action nodes
    for (int n = 0; n < actionNodes.length; n++) {
      for (Connection c: actionNodes[n].connectedNodes) {
        if (c.weight >= 0) {
          image.stroke(0, 255, 0);
        } else {
          image.stroke(255, 0, 0);
        }
        image.strokeWeight(map(abs(c.weight), 0, 4, 0, 6));
        
        int nodeX = 0;
        if (c.node.getClass().getSimpleName().equals("InputNode")) {
          //Line from input node to action node
          for (int i = 0; i < inputNodes.length; i++) {
            if (c.node == inputNodes[i]) {
              nodeX = image.width/(inputNodes.length+1)*(i+1);
            }
          }
          image.line(image.width/(actionNodes.length+1)*(n+1), 700, nodeX, 100);
        } else {
          //Line from internal node to action node
          for (int i = 0; i < internalNodes.length; i++) {
            if (c.node == internalNodes[i]) {
              nodeX = image.width/(internalNodes.length+1)*(i+1);
            }
          }
          image.line(image.width/(actionNodes.length+1)*(n+1), 700, nodeX, 400);
        }
      }
    }
    
    //Draw lines to internal nodes
    for (int n = 0; n < internalNodes.length; n++) {
      for (Connection c: internalNodes[n].connectedNodes) {
        if (c.weight >= 0) {
          image.stroke(0, 255, 0, 255);
        } else {
          image.stroke(255, 0, 0, 255);
        }
        image.strokeWeight(map(abs(c.weight), 0, 4, 0, 6));
        
        int nodeX = 0;
        if (c.node.getClass().getSimpleName().equals("InputNode")) {
          //Line from input node to internal node
          for (int i = 0; i < inputNodes.length; i++) {
            if (c.node == inputNodes[i]) {
              nodeX = image.width/(inputNodes.length+1)*(i+1);
            }
          }
          image.line(image.width/(internalNodes.length+1)*(n+1), 400, nodeX, 100);
        } else {
          //Line from internal node to internal node
          for (int i = 0; i < internalNodes.length; i++) {
            if (c.node == internalNodes[i]) {
              nodeX = image.width/(internalNodes.length+1)*(i+1);
            }
          }
          image.line(image.width/(internalNodes.length+1)*(n+1), 400, nodeX, 700);
        }
      }
    }
    
    //
    //Draw nodes
    //
    image.textSize(30);
    image.textAlign(CENTER, CENTER);
    image.stroke(255);
    image.strokeWeight(5);
    
    //Draw input nodes
    int nodeX = 0;
    for (int i = 0; i < inputNodes.length; i++) {
      nodeX = image.width/(inputNodes.length+1)*(i+1);
      image.fill(225, 225, 255);
      image.circle(nodeX, 100, 80);
      
      image.fill(0);
      image.text(InputNodeNames.values()[i].toString(), nodeX, 100);
    }
    
    //Draw internal nodes
    for (int i = 0; i < internalNodes.length; i++) {
      nodeX = image.width/(internalNodes.length+1)*(i+1);
      image.fill(225);
      image.circle(nodeX, 400, 80);
      
      image.fill(0);
      image.text(i, nodeX, 400);
    }
    
    //Draw action nodes
    for (int i = 0; i < actionNodes.length; i++) {
      nodeX = image.width/(actionNodes.length+1)*(i+1);
      image.fill(255, 225, 225);
      image.circle(nodeX, 700, 80);
      
      image.fill(0);
      image.text(ActionNodeNames.values()[i].toString(), nodeX, 700);
    }
    
    image.endDraw();
    String savePath = "data\\images\\brains\\" + hex(geneticData.genes[0]) + ".png";
    image.save(savePath);
    launch("explorer", savePath(savePath));
  }
}
