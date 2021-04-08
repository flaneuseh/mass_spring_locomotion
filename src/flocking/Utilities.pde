class vector {
  float x;
  float y;
  
  vector() {
    this.x = 0;
    this.y = 0;
  }
  
  vector(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class point extends vector {
  float x;
  float y;
  
  point() {
    this.x = 0;
    this.y = 0;
  }
  
  point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

vector v() {
  return new vector();
}

point p() {
  return new point();
}

vector v(float x, float y) {
  return new vector(x, y);
}

point p(float x, float y) {
  return new point(x, y);
}

point p(vector v) {
  return p(v.x, v.y);
}

vector v(point p) {
  return v(p.x, p.y);
}

// Unit vector.
vector u(vector v) {
  float m = m(v);
  return v(v.x/m, v.y/m);
}

// Magnitude of vector.
float m(vector v) {
  return sqrt(sq(v.x) + sq(v.y));
}

// Inverse of vector.
vector i(vector v) {
  return v(-v.x, -v.y);
}

// vector rotated by a, in radians.
// https://matthew-brett.github.io/teaching/rotation_2d.html
vector r(vector v, float a) {
  float cos = cos(a);
  float sin = sin(a);
  float x = cos * v.x - sin * v.y; // x2=cosβx1−sinβy1
  float y = sin * v.x + cos * v.y; // y2=sinβx1+cosβy1
  return v(x, y);
}

// Distance between a and b.
float d(point a, point b) {
  float d = sqrt(sq(a.x - b.x) + sq(a.y - b.y));
  if (Float.isNaN(d) || Float.isInfinite(d) || d <= 0 ) {
    return .0000001; // Return a small number that will be treated as a minimum distance.
  }
  return d;
}

// Multiply v by m.
vector prod(vector v, float m) {
  return v(v.x * m, v.y * m);
}

vector sum(vector a, vector b) {
  return v(a.x + b.x, a.y + b.y);
}

point sum(point p, vector v) {
  return p(p.x + v.x, p.y + v.y);
}
