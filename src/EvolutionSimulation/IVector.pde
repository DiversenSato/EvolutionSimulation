static class IVector {
  int x, y;
  
  //Constructor. Sets the initial properties of this integer vector
  IVector(int x, int y) {
    this.x = x;
    this.y = y;
  }
  IVector() {
    x = 0;
    y = 0;
  }
  
  //Adds the vector with another vector or components
  IVector add(int x, int y) {
    this.x += x;
    this.y += y;
    
    return this;
  }
  IVector add(IVector m) {
    this.x += m.x;
    this.y += m.y;
    
    return this;
  }
  
  static IVector sub(IVector t, IVector o) {
    return new IVector(t.x-o.x, t.y-o.y);
  }
  
  //Multiplies the properties of this vector
  IVector mult(float m) {
    x *= m;
    y *= m;
    
    return this;
  }
  
  //Returns a new instance of this IVector
  IVector copy() {
    return new IVector(x, y);
  }
  
  //Returns a PVector version of this IVector
  PVector toPVector() {
    return new PVector(x, y);
  }
  
  //Returns the IVectors components in a string
  String toString() {
    return "[ " + x + ", " + y + " ]";
  }
  
  //Linearly interpolates between vector a and b using t as a percent.
  static IVector lerp(IVector a, IVector b, float t) {
    return new IVector((int)(a.x + (b.x - a.x) * t), (int)(a.y + (b.y - a.y) * t));
  }
  
  //Returns the distance between two IVectors
  static float dist(IVector a, IVector b) {
    float x = (float)a.x - (float)b.x;
    float y = (float)(a.y - b.y);
    return sqrt(x*x + y*y);
  }
  
  //Returns whether the vectors are equal
  static boolean CompareEquals(IVector a, IVector b) {
    return a.x == b.x && a.y == b.y;
  }
}
