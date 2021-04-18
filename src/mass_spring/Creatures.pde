float max_v = 10; // max velocity
float kd = 0;  // viscuous damping coefficient.
vector g = v(0, 9.8); // gravitational force downwards.
float e = .0000000000001; // not quite 0, for division by 0.

class Creature {
  ArrayList<spring> springs;
  ArrayList<point_mass> points;
  
  Creature() {
    springs = new ArrayList<spring>();
    points = new ArrayList<point_mass>();
  }
  
  Creature(ArrayList<spring> springs) {
    this();
    if (springs != null) this.springs = springs;
  }
  
  Creature(spring[] springs) {
    this();
    for (spring s: springs) {
      add_spring(s);
    }
  }
  
  void draw() {
    for (spring s: springs) {
      s.draw();
    }
  }
  
  void update() {
    for (spring s: springs) {
      s.update();
    }
    for (point_mass p: points) {
      p.update();
    }
  }
  
  void add_point(point_mass p) {
    if (!points.contains(p)) points.add(p);
  }
  void add_spring(spring s) {
    if (!springs.contains(s)) springs.add(s);
    if (!points.contains(s.a)) points.add(s.a);
    if (!points.contains(s.b)) points.add(s.b);
  }
}

class point_mass {
  point p;   // position
  vector v;  // velocity
  float m;   // mass
  vector F;  // force
  
  point_mass() {
    p = p();
    v = v();
    //v = v(random(-max_v, max_v), random(-max_v, max_v));
    v = clamp(0, v, max_v);
    F = v();
  }
  
  point_mass(point p, vector v, float m) {
    this();
    if (p != null) this.p = p;
    if (v != null) this.v = v;
    this.m = m;
  }
  
  void draw() {
    stroke(white);
    fill(white);
    circle(p.x, p.y, 10);
    F = v(); // Reset F after every draw so that it can be recalculated at each update.
  }
  
  void update() {
    F = sum(F, g); // gravitational pull
    F = sum(F, prod(v, -kd));   // damping
    
    vector a = prod(F, m); // acceleration F = ma
    v = sum(v, prod(a, dt));
    v = clamp(0, v, max_v);
    if (abs(m(v)) < .1) v = v();
    p = sum(p, prod(v, dt));
    if (p.y > ground_y) p.y = ground_y;
    p = wrap(p(0, 0), p, p(max_x, max_y));
  }
}

int rest_spring_width = 4;
float fk = .5;       // default spring constant.
float fd = .01; //.0001; // default spring damping constant
class spring {
  point_mass a;
  point_mass b;
  float L;        // rest length
  float k;        // spring constant
  float d;        // spring damping constant
  oscillator o;
  
  spring() {
    a = new point_mass();
    b = new point_mass();
    L = 0;
    k = fk;
    d = fd;
  }
  
  spring(point_mass a, point_mass b, oscillator o) {
    this();
    if (a != null) this.a = a;
    if (b != null) this.b = b;
    this.o = o;
  }
  
  spring(point_mass a, point_mass b, float L) {
    this();
    if (a != null) this.a = a;
    if (b != null) this.b = b;
    this.L = L;
  }
  
  float L() {
    if (o != null) return o.L();
    return L;
  }
  
  void draw() {
    a.draw();
    b.draw();
    
    stroke(white);
    line(a.p, b.p);
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
    return L * (1 + a * sin((f * t) + (2 * PI * p)));
  }
}

oscillator o(float L, float a, float f, float p) {
  return new oscillator(L, a, f, p);
}

float d(point_mass a, point_mass b){
  return d(a.p, b.p);
}
