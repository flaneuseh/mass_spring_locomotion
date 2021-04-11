float max_v = 10; // max velocity
float kd = -.001;   // viscuous damping coefficient.

class Creature {
  ArrayList<spring> springs;
  ArrayList<point_mass> points;
  
  Creature() {
    springs = new ArrayList<spring>();
    points = new ArrayList<point_mass>();
  }
  
  Creature(ArrayList<spring> springs, ArrayList<point_mass> points) {
    if (springs != null) this.springs = springs;
    if (points != null) this.points = points;
  }
  
  Creature(spring[] springs, point_mass[] points) {
    for (spring s: springs) {
      add_spring(s);
    }
    for (point_mass p: points) {
      add_point(p);
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
    v = v(random(-max_v, max_v), random(-max_v, max_v));
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
    fill(white);
    circle(p.x, p.y, m);
    F = v(); // Reset F after every draw so that it can be recalculated at each update.
  }
  
  void update() {
    F = sum(F, prod(v, kd));   // damping
    
    vector a = prod(F, m); // acceleration F = ma
    v = sum(v, prod(a, dt));
    v = clamp(0, v, max_v);
    p = sum(p, prod(v, dt));
    p = wrap(p(0, 0), p, p(max_x, max_y));
  }
}

int rest_spring_width = 4;
float fk = 10; // default spring constant.
class spring {
  point_mass a;
  point_mass b;
  float L;        // rest length
  float k;        // spring constant
  
  spring() {
    a = new point_mass();
    b = new point_mass();
    L = 0;
    k = fk;
  }
  
  spring(point_mass a, point_mass b, float L, float k) {
    if (a != null) this.a = a;
    if (b != null) this.b = b;
    this.L = L;
    if (k != 0) this.k = k;
  }
  
  void draw() {
    a.draw();
    b.draw();
    
    float d_ab = d(a.p, b.p);
    float inv_percent_L = L/d_ab;
    int spring_width = min(round(inv_percent_L * rest_spring_width), 1); // thicker when shorter, thinner when longer
    
    strokeWeight(spring_width);
    line(a.p, b.p);
    strokeWeight(1);
  }
  
  void update() {
    // Spring force for a = -(k(distance - L) + kd(u((a.v - b.v) . (a.p - b.p)))u(a.p - b.p) 
    // From Sticky Feet: Evolution in a Multi-Creature Physical Simulation https://gatech.instructure.com/courses/179608/files/21490663?wrap=1
    vector delta_p = sum(v(a.p), prod(v(b.p), -1)); // pa - pb
    vector delta_v = sum(a.v, prod(b.v, -1));       // va - vb
    float current_distance = d(a.p, b.p);
    float spring_force = k * (current_distance - L); 
    float damping_force = kd * dot(delta_v, delta_p) / min(m(delta_p), .0001); 
    vector F = prod(u(delta_p), -(spring_force + damping_force));        
    
    // Add spring force to existing point forces.
    a.F = sum(a.F, F);
    b.F = sum(b.F, prod(F, -1));
  }
}
