class Genome {
  int[] genes = new int[genesPerGenome];
  
  Genome() {
    for (int i = 0; i < genes.length; i++) {
      genes[i] = hash((int)random(10000000));
    }
  }
  
  Genome(JSONArray geneData) {
    genes = new int[geneData.size()];
    for (int i = 0; i < geneData.size(); i++) {
      genes[i] = geneData.getInt(i);
    }
  }
  
  Genome(Genome genome1, Genome genome2) {
    for (int i = 0; i < genes.length; i++) {
      if (random(1) < 0.5) {
        genes[i] = genome1.genes[i];
      } else {
        genes[i] = genome2.genes[i];
      }
      
      //Random mutations are calculated here
      if (random(1000) < mutationRate) {
        //Change a single bit
        int bitToFlip = round(random(31));
        int bitToFlipValue = (genes[i] >> bitToFlip) & 1;
        if (bitToFlipValue == 0) {
          genes[i] += 1 << bitToFlip;
        } else {
          genes[i] -= 1 << bitToFlip;
        }
      }
    }
  }
  
  JSONArray toJSONArray() {
    JSONArray array = new JSONArray();
    
    for (int g: genes) {
      array.append(g);
    }
    
    return array;
  }
  
  String toString() {
    String returnString = "";
    for (int gene: genes) {
      byte sourceType = (byte)((gene >> 31) & 1);
      int sourceID = ((gene >> 24) & 0x7F);
      byte sinkType = (byte)((gene >> 23) & 1);
      int sinkID = ((gene >> 16) & 0x7F);
      short weightInt = (short)(gene & 0xFFFF);
      float weight = (float)weightInt / 8191f;
      
      if (sourceType == 1) {
        sourceID = sourceID % innerNeurons;
      } else {
        sourceID = sourceID % InputNodeNames.values().length;
      }
      
      if (sinkType == 1) {
        sinkID = sinkID % innerNeurons;
      } else {
        sinkID = sinkID % ActionNodeNames.values().length;
      }
      
      returnString += "From: [" + sourceType + ", " + sourceID + "], to: [" + sinkType + ", " + sinkID + "], with weight: " + weight + "\n";
    }
    
    return returnString;
  }
}
