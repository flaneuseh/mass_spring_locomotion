class Creature {
  
}

class point_mass {
  point p;   // position
  vector v;  // velocity
  float m;   // mass
  vector f;  // force
  vector a;  // acceleration
  
  void draw() {
    circle(p.x, p.y, m);
  }
  
  void update() {
    a = prod(f, m);
    v = sum(v, prod(a, dt));
    p = sum(p, prod(v, dt));
  }
}

class spring {
  point_mass p1;
  point_mass p2;
  float L;        // rest length
  float k;        // spring constant
}
