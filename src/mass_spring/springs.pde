float max_v = 10; // max velocity
float kv = 0;  // viscuous damping coefficient.
vector g = v(0, 9.8); // gravitational force downwards.
float e = .0000000000001; // not quite 0, for division by 0.
int rest_spring_width = 4;
float ks = 5;       // default spring constant.
float kd = .5;  // default spring damping constant


class point_mass {
  point p;   // position
  vector v;  // velocity
  float m;   // mass
  vector F;  // force
  String id;
  float kf;       // friction coefficient. We are using a simplified model of friction as a damping force for points that are in contact with the ground.
  friction fo;    // friction oscillator
  
  point_mass() {
    p = p();
    v = v();
    v = clamp(0, v, max_v);
    F = v();
  }
  
  point_mass(String id, point p, vector v, float m, float kf) {
    this();
    if (p != null) this.p = p;
    if (v != null) this.v = v;
    this.m = m;
    this.id = id;
    this.kf = kf;
  }
  
  point_mass(point p) {
    this("", p, v(), 1, 0);
  }
  
  point_mass(point p, float m) {
    this("", p, v(), m, 0);
  }
  
  point_mass(point p, float m, float kf) {
    this("", p, v(), m, kf);
  }
  
  point_mass(point p, float m, friction fo) {
    this("", p, v(), m, 0);
    this.fo = fo;
  }
  
  void draw() {
    stroke(white);
    fill(white);
    circle(p.x, p.y, 12);
    textSize(12);
    fill(black);
    text(id, p.x - 3, p.y + 5);
    F = v(); // Reset F after every draw so that it can be recalculated at each update.
  }
  
  void update() {
    F = sum(F, g); // gravitational pull
    F = sum(F, prod(v, -kv));   // damping
    if (ground_y - p.y < 3) F.x = F.x + v.x*-kf();     // If grounded, apply friction in the x direction.
    
    vector a = prod(F, m); // acceleration F = ma
    v = sum(v, prod(a, dt));
    v = clamp(0, v, max_v);
    if (abs(m(v)) < .1) v = v();
    p = sum(p, prod(v, dt));
    if (p.y > ground_y) {
      float t = (p.y - ground_y)/v.y; // time traveled "through" the ground.
      p.y = ground_y - v.y*t;         // bounce back up.
    }
    if (p.x < 0) p.x = 0;
    if (p.x > max_x) p.x = max_x;
  }
  
  float kf() {
    if (fo != null) return fo.kf();
    return kf;
  }
}

class spring {
  point_mass a;
  point_mass b;
  float L;        // rest length
  float k;        // spring constant
  float d;        // spring damping constant
  oscillator o;
  String id = "";
  
  spring() {
    a = new point_mass();
    b = new point_mass();
    L = 0;
    k = ks;
    d = kd;
  }
  
  spring(point_mass a, point_mass b, oscillator o) {
    this();
    if (a != null) {this.a = a; this.id += a.id;}
    if (b != null) {this.b = b; this.id += b.id;}
    this.o = o;
  }
  
  spring(point_mass a, point_mass b, float L) {
    this();
    if (a != null) {this.a = a; this.id += a.id;}
    if (b != null) {this.b = b; this.id += b.id;}
    this.L = L;
  }
  
  spring(point_mass a, point_mass b, float L, float ks) {
    this(a, b, L);
    this.k = ks;
  }
  
  spring(point_mass a, point_mass b, oscillator o, float ks) {
    this(a, b, o);
    this.k = ks;
  }
  
  spring(point_mass a, point_mass b) {
    this(a, b, d(a, b));
  }
  
  float L() {
    if (o != null) return o.L();
    return L;
  }
  
  void draw() {
    stroke(white);
    line(a.p, b.p);
    a.draw();
    b.draw();
  }
  
  void update() {
    // Damped spring force for a:
    // D = a.p - b.p   V = a.v - b.v
    // spring force Fs = -k(|D| - L)  
    // damping force Fd = -kd(V . D) / |D|
    // damped spring force Fds = (Fs + Fd) * u(D)
    // From Sticky Feet: Evolution in a Multi-Creature Physical Simulation https://gatech.instructure.com/courses/179608/files/21490663?wrap=1
    vector D = sum(v(a.p), i(v(b.p)));       // a.p - b.p
    vector V = sum(a.v, i(b.v));             // a.v - b.v        
    float Fs = -(k * (m(D) - L()));            // -k(|D| - L)
    float Fd = -d * dot(V, D) / (m(D) > 0? m(D) : e);   // -kd(V . D) / |D|
    vector Fds = prod((m(D) > 0? u(D) : v(e, e)), Fs + Fd);        // (Fs + Fd) * u(D) 
    
    // Add spring force to existing point forces.
    a.F = sum(a.F, Fds);
    b.F = sum(b.F, prod(Fds, -1));
  }
}

class oscillator {
  float L;       // original length
  float a;       // amplitude
  float f;       // frequency
  float p;       // phase
  
  oscillator(float L, float a, float f, float p) {
    this.L = L;
    this.a = a;
    this.f = f;
    this.p = p;
  }
  
  // L = L(1 + asin(ft + 2PIp))
  // From Sticky Feet: Evolution in a Multi-Creature Physical Simulation https://gatech.instructure.com/courses/179608/files/21490663?wrap=1
  float L() {
    return L * (1 + a * sin((f * t) + p));
  }
}

class friction {
  float min; // min kf
  float max; // max kf
  float f;   // frequency
  float p;   // phase
  
  friction(float min, float max, float f, float p) {
    this.min = min;
    this.max = max;
    this.f = f;
    this.p = p;
  }
  
  // switch between min and max without interpolation.
  float kf() {
    if (cos((f * t) + p) > 0) return max;
    return min;
  }
}

oscillator o(float L, float a, float f, float p) {
  return new oscillator(L, a, f, p);
}

friction f(float min, float max, float f, float p) {
  return new friction(min, max, f, p);
}

float d(point_mass a, point_mass b){
  return d(a.p, b.p);
}

point_mass pm(String id, point p, vector v, float m, float kf) {
  return new point_mass(id, p, v, m, kf);
}

point_mass pm(point p) {
  return new point_mass(p);
}
  
point_mass pm(point p, float m) {
  return new point_mass(p, m);
}

point_mass pm(point p, float m, float kf) {
  return new point_mass(p, m, kf);
}

point_mass pm(point p, float m, friction fo) {
  return new point_mass(p, m, fo);
}

spring s(point_mass a, point_mass b, oscillator o) {
  return new spring(a, b, o);
}

spring s(point_mass a, point_mass b, float L) {
  return new spring(a, b, L);
}

spring s(point_mass a, point_mass b) {
  return new spring(a, b);
}

spring s (point_mass a, point_mass b, float L, float ks) {
  return new spring(a, b, L, ks);
}
  
spring s(point_mass a, point_mass b, oscillator o, float ks) {
  return new spring(a, b, o, ks);
}
