enum InputNodeNames {
  LX, //0 to 1 depending on the location of the creature
  LY,
  BDX, //0 to 1 depending on the distance to the world border
  BDY,
  RND, //Random value
  AGE, //Steps since birth from 0-1
  LPF //Looks at the tile in front, so this node is either 0 or 1
}

enum ActionNodeNames {
  MN, //Move north
  MS, //Move south
  ME, //Move east
  MW, //Move west
  MF, //Move forward
  MR, //Move right
  ML, //Move left
  MRN //Move random
}
