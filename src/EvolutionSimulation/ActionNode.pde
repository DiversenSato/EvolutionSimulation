class ActionNode extends Node {
  ActionNode(int i, int t) {
    super(i, t);
  }
  
  @Override
  float getValue() {
    value = 0;
    for (Connection c: connectedNodes) {
      value += c.node.getValue() * c.weight;
    }
    
    float newValue = (float)Math.tanh(value);
    if (Float.isNaN(newValue)) {
      return 0;
    }
    return newValue;
  }
}
