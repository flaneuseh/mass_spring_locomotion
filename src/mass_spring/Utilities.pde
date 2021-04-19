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

class point {
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

point p(point p) {
  return p(p.x, p.y);
}

point p(vector v) {
  return p(v.x, v.y);
}

vector v(vector v) {
  return v(v.x, v.y);
}

vector v(point p) {
  return v(p.x, p.y);
}

vector v(point a, point b) {
  return sum(v(b), i(v(a)));
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
  float dx = a.x - b.x;
  float d_wrap_x = max_x - dx;
  dx = min(dx, d_wrap_x);
  float dy = a.y - b.y;
  float d_wrap_y = max_y - dy;
  dx = min(dx, d_wrap_y);
  float d = sqrt(sq(dx) + sq(dy));
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

float dot(vector a, vector b) {
  return a.x * b.x + a.y * b.y;
}

point sum(point p, vector v) {
  return p(p.x + v.x, p.y + v.y);
}

// Clamp a vector between a min and a max magnitude.
vector clamp(float min, vector v, float max) {
  float m = m(v);
  if (m < min) return prod(u(v), min);
  else if (m > max) return prod(u(v), max);
  return v;
}

point wrap(point min, point p, point max) {
  point w = p(p);
  if (p.x < min.x) w.x = max.x - (min.x - p.x);
  else if (p.x > max.x) w.x = min.x + (p.x - max.x);
  if (p.y < min.y) w.y = max.y - (min.y - p.y);
  else if (p.y > max.y) w.y = min.y + (p.y - max.y);
  return w;
}

void line(point a, point b) {
  line(a.x, a.y, b.x, b.y);
}
