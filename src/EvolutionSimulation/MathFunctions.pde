int hash(int seed) {
  seed ^= 0xA3C59AC3;
  seed *= 0x9E3779B9;
  seed ^= seed >> 16;
  seed *= 0x9B5555AD;
  seed ^= seed >> 16;
  seed *= 0x9B5555AD;
  
  return seed;
}

int clamp(int a, int min, int max) {
  return max(min, min(a, max));
}
