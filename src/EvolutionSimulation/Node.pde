//Super class of all nodes
//Contains a value which ofther nodes can read using the getValue() function.
//In some cases, the values of a node is a little more complex than
//just returning 'value'.
class Node {
  int ID, type;
  
  float value = 0;
  ArrayList<Connection> connectedNodes = new ArrayList<Connection>();
  
  Node(int i, int t) {
    ID = i;
    type = t;
  }
  
  float getValue() {
    return value;
  }
}
