class Creature {
  ArrayList<spring> springs;
  ArrayList<point_mass> points;
  
  Creature() {
    springs = new ArrayList<spring>();
    points = new ArrayList<point_mass>();
  }
  
  Creature(ArrayList<spring> springs) {
    this();
    for (spring s: springs) {
      add_spring(s);
    }
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
