class InnerNode extends Node {
  InnerNode(int i, int t) {
    super(i, t);
  }
  
  float getValue() {
    value = 0;
    for (Connection c: connectedNodes) {
      if (c.node.type == 1 && c.node.ID == ID) {
        value += c.weight;
        continue;
      } else {
        value += c.node.getValue() * c.weight;
      }
    }
    
    float newValue = (float)Math.tanh(value);
    if (Float.isNaN(newValue)) {
      return 0;
    }
    return newValue;
  }
}
