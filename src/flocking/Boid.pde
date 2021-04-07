float boid_r = 7;   // radius of the boids
float boid_a = PI/8; // angle of boid triangle.
float boid_p = boid_r * 30;  // radius of boid perception

float min_v = 7; // Prevent boids from becoming stuck anywhere by setting a low minimum velocity to help them to jiggle out of place.
float max_v = 10;

float w_fc = 1; // weight for flock centering
float w_vm = .00002; // weight for velocity matching
float w_ca = 2; // weight for collision avoidance
float w_wa = 35; // weight for wall avoidance
float w_w = 10;  // weight for wander
float w_m = .001; // weight for mouse attraction/repulsion.
float w_flee = .0005; // weight for chase
float w_chase = .0005; // weight for flee

class Boid {
  point p;    // point x, y at center
  vector v;     // velocity x, y
  color fill;    
  color outline;
  float r;  // radius of bounding circle
  float o = boid_a;  // angle of triangle
  
  Boid() {
    r = boid_r + random(-2, 2);
    p = random_valid_point(r);
    v = v();
  }
  
  // Draw boid at current vector facing in the direction of vector.
  void show() {
    // Collision circle.
    if (show_collision_circles) {
      noFill();
      stroke(red);
      circle(p.x, p.y, r*2);
    }
    
    if (show_perception_circles) {
      stroke(white);
      noFill();
      circle(p.x, p.y, boid_p*2);
    }
    
    // True location (center of boid)
    //stroke(black);
    //fill(black);
    //circle(p.x, p.y, 10);
    
    // Boid representation.
    vector u = u(v);
    vector a = sum(p, prod(u, r));
    vector iu = i(u);
    vector u2 = r(iu, o);
    vector b = sum(p, prod(u2, r));
    o = -o;
    vector u3 = r(iu, o);
    vector c = sum(p, prod(u3, r));
    
    fill(fill);
    stroke(outline);
    triangle(a.x, a.y, b.x, b.y, c.x, c.y);
  }
  
  // Does the boid contain this vector?
  boolean contains(point p) {
    return d(this.p, p) <= r;
  }
}

class Orange extends Boid { 
  Orange() {
    super();
    this.fill = orange;
    this.outline = dark_orange;
  }
}

class Blue extends Boid {
  Blue() {
    super();
    this.fill = blue;    
    this.outline = dark_blue;
  }
}

class Grey extends Boid {
  Grey() {
    super();
    this.fill = pgrey;    
    this.outline = dark_pgrey;
    this.r = boid_r*2 + random(-3, 3);  
  }
}

float dt = .5;

String[] species = {"Orange", "Blue", "Grey"};
boolean orange_active = true;
boolean blue_active = false;
boolean grey_active = false;
class Flock {
  ArrayList<Orange> orange_flock;
  ArrayList<Blue> blue_flock;
  ArrayList<Grey> grey_flock;
  
  Flock() {
    orange_flock = new ArrayList<Orange>();
    blue_flock = new ArrayList<Blue>();
    grey_flock = new ArrayList<Grey>();
  }
  
  ArrayList<Boid> all() {
    ArrayList<Boid> all = new ArrayList<Boid>();
    if (orange_active) all.addAll(orange_flock);
    if (blue_active) all.addAll(blue_flock);
    if (grey_active) all.addAll(grey_flock);
    return all;
  }
  
  // Spawn a random boid.
  Boid spawn(String species) {
    switch (species) {
      case "Blue":
        Blue b = new Blue();
        blue_flock.add(b);
        return b;
      case "Grey":
        Grey g = new Grey();
        grey_flock.add(g);
        return g;
      case "Orange":
      default:
        Orange o = new Orange();
        orange_flock.add(o);
        return o;
    }
  }
  
  // Kill a random boid.
  Boid kill(String species) {
    switch (species) {
      case "Blue":
        if (blue_flock.size() <= 0) return null;
        return blue_flock.remove(floor(random(blue_flock.size())));
      case "Grey":
        if (grey_flock.size() <= 0) return null;
        return grey_flock.remove(floor(random(grey_flock.size())));
      case "Orange":
      default:
        if (orange_flock.size() <= 0) return null;
        return orange_flock.remove(floor(random(orange_flock.size())));
    }
  }
  
  void scatter() {
    for (Boid b : all()) {
      b.p = random_valid_point(b.r);
      b.v = v();
    }
  }
  
  void show() {
    for (Boid b : all()){
      b.show();
      
      // Velocity & forces.
      //vector force_on_b = calculate_forces(b);
      //vector force_from_b = sum(b.p, force_on_b);
      //stroke(black);
      //line(b.p.x, b.p.y, force_from_b.x, force_from_b.y);
      //vector velocity_from_b = sum(b.p, b.v);
      //line(b.p.x, b.p.y, velocity_from_b.x, velocity_from_b.y);
    }
  }
  
  void update(float dt) {
    for (Boid b : all()){
      update(b, dt);
    }
  }
  
  // Update vector and vector by 1 timestep.
  void update(Boid b, float dt) {
    vector f = calculate_forces(b);
    b.v = sum(b.v, prod(f, dt));
    
    // Limit velocity magnitude
    float m = m(b.v);
    if (m < min_v) {
      b.v = prod(u(b.v), min_v);
    }
    else if (m > max_v) {
      b.v = prod(u(b.v), max_v);
    }
    
    b.p = p(sum(b.p, prod(b.v, dt)));
    
    // Force boid back into boundaries if it escapes.
    if (b.p.x < 0) b.p.x = b.r*2;
    if (b.p.y < 0) b.p.y = b.r*2;
    if (b.p.x > max_x) b.p.x = max_x - b.r*2;
    if (b.p.y > max_y) b.p.y = max_y - b.r*2;
  }
  
  // Calculate forces acting on b.
  vector calculate_forces(Boid b) {
    vector f =v(0, 0);
    
    vector sum_fc = v(0, 0);
    float sum_wfc = 0;
    vector f_vm = v(0, 0); // velocity matching
    vector f_ca = v(0, 0); // collision avoidance
    
    vector sum_flee = v(0, 0);
    vector sum_chase = v(0, 0);
    float sum_wflee = 0;
    float sum_wchase = 0;
    
    for (Boid n: neighbors(b)) {
      f_ca = sum(f_ca, prod(sum(b.p, i(n.p)), weight_ca(n, b)));     // f_ca += w(p - pi)
      boolean same_species = (b.getClass() == n.getClass());
      if (same_species) {
        // Only flock with members of the same species.
        sum_wfc += weight_fc(n, b);
        sum_fc = sum(sum_fc, prod(sum(n.p, i(b.p)), w_fc));            // sum_fc += w(pi - p)
        f_vm = sum(f_vm, prod(sum(n.v, i(b.v)), weight_vm(n, b)));     // f_vm += w(vi - v)
      }
      else if (n instanceof Grey) {
        // Flee predator.
        sum_wflee += weight_flee(n, b);
        sum_flee = sum(sum_flee, prod(sum(b.p, i(n.p)), weight_flee(n, b)));
      }
      else if (b instanceof Grey) {
        // Chase prey.
        sum_wchase += weight_chase(n, b);
        sum_chase = sum(sum_chase, prod(sum(n.p, i(b.p)), weight_chase(n, b)));
      }
      
    }
    
    sum_wfc = max(sum_wfc, .001); // Ensure against division by 0.
    vector f_fc = prod(sum_fc, 1 / sum_wfc); // flock centering
    vector f_w = v(random(-.05, .05), random(-.05, .05)); // wander
    
    if (flock_centering)     f = sum(f, prod(f_fc, w_fc));
    if (velocity_matching)   f = sum(f, prod(f_vm, w_vm));
    if (collision_avoidance) f = sum(f, prod(f_ca, w_ca));
    if (wander)              f = sum(f, prod(f_w, w_w));
    
    // avoid walls
    f = sum(f, prod(wall_force(b), w_wa));
    
    // Mouse attraction/repulsion.
    point mouse_loc = p(mouseX, mouseY);
    if (mouse_active() && d(mouse_loc, b.p) <= boid_p) {
      vector force_dir;
      if (attracting()) { 
        force_dir = sum(mouse_loc, i(b.p));
      }
      else { 
        force_dir = sum(b.p, i(mouse_loc));
      }
      
      vector f_m = prod(force_dir, weight_m(b, mouse_loc)); // w(pi - p)
      f = sum(f, prod(f_m, w_m));
    }
    
    // Flee predators.
    //sum_wflee = max(sum_wflee, .001); // Ensure against division by 0.
    //vector f_flee = prod(sum_flee, 1 / sum_wflee); // flee predator (Grey)
    f = sum(f, prod(sum_flee, w_flee));
    
    // Chase prey.
    //sum_wchase = max(sum_wchase, .001); // Ensure against division by 0.
    //vector f_chase = prod(sum_chase, 1 / sum_wchase); // chase prey (Blue, Orange)
    f = sum(f, prod(sum_chase, w_chase));
    
    return f;
  }
  
  // vector representing the force away from the nearest wall.
  vector wall_force(Boid b) {
    point p = b.p;
    
    boolean closer_to_x0 = abs(p.x - 0) < abs(p.x - max_x);
    float wall_x = closer_to_x0? 0 : max_x;
    
    boolean closer_to_y0 = abs(p.y - 0) < abs(p.y - max_y);
    float wall_y = closer_to_y0? 0 : max_y;
    
    float d_x = abs(p.x - wall_x);
    float d_y = abs(p.y - wall_y);
    
    float min_d = max(min(d_x, d_y) - b.r, .0001);
    float wall_w = (min_d <= boid_p)? weight_wa(min_d) : 0;
    
    vector wall_f = v(0, 0);
    wall_f.x = (d_x <= boid_p)? p.x - wall_x : 0;
    wall_f.y = (d_y <= boid_p)? p.y - wall_y : 0;
    
    return prod(wall_f, wall_w);
  }
  
  // Get neighbors in b's perception.
  ArrayList<Boid> neighbors(Boid b) {
    ArrayList<Boid> neighbors = new ArrayList<Boid>();
    for (Boid n: all()) {
      if (n != b && d(n.p, b.p) <= boid_p + n.r) {
        // Is any part of n in b's perception radius?
        neighbors.add(n);
      }
    }
    return neighbors;
  }
  
  // Weighting collision avoidance by distance.
  float weight_ca(Boid a, Boid b) {
    // Boids' radius is part of the distance, 
    // and if they are within eachothers' radius they are overlapping.
    float d = max(d(a.p, b.p) - (a.r + b.r)/2., .0001); 
    if (d < boid_p/2.) return 1./sq(d); // Collision perception is 1/2 other perception.
    else return .0001;
  }
  
  // Weighting velocity matching by distance.
  float weight_vm(Boid a, Boid b) {
    return boid_p - d(a.p, b.p);
  }
  
  // Weighting flock centering by distance.
  float weight_fc(Boid a, Boid b) {
    return boid_p - d(a.p, b.p);
  }
  
  // Weighting wall avoidance by distance.
  float weight_wa(float d_from_wall) {
    return 1./sq(d_from_wall);
  }
  
  // Weighting mouse force by distance.
  float weight_m(Boid b, point p) {
    return boid_p - d(p, b.p);
  }
  
  // Weight chase.
  float weight_chase(Boid a, Boid b) {
    return boid_p - d(a.p, b.p);
  }
  
  // Weight flee.
  float weight_flee(Boid a, Boid b) {
    return boid_p - d(a.p, b.p);
  }
}

// Random point within the boundaries and respecting an object radius.
point random_valid_point(float r) {
  return p(
    floor(random(0 + r, max_x - r)),
    floor(random(0 + r, max_y - r))
  );
}
  
