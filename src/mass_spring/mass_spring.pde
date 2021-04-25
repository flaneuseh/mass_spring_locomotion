// README
// 
// # Mass-Spring Locomotion
// 
// ## An implementation in Processing by Kaylah Facey.
//
// ### Commands:
// 
// * space bar - Start or stop the simulation (default stopped).
// * s - Cause all boids to be instantly scattered to random positions in the window, and with random directions.
// * p - Toggle whether to have creatures leave a path, that is, whether the window is cleared each display step or not (default off).
// When pathing leave a trail of dots or fading trail. Do not preserve the entire path, as that quickly clutters the window.
// * c - Clear the screen, but do not delete any boids. (This can be useful when creatures are leaving paths.)
// 
// 
// Extras:
// - multiple creatures that avoid eachother
// - obstacles
// - genetic algorithm optimized locomotion
//
// TODO
// - make inchworm more interesting:
//   - raise middle section 
//   - stagger oscillation
// - fix whirligig
// - writeup
// - controls
// - reset should reset velocity/forces as well as positions.
// 

// Simulation Parameters
boolean running = false;

// Colours.
color black = #000000;
color white = #ffffff;
color light_grey = #cccccc;

int max_x = 1150;
int max_y = 850;

float dt = .25; // Time per update step.
float t = 0;    // current time.

float ground_y = 500;

Creature[] creatures;
void setup() {
  size(1350, 850);
  
  // Whirligig
  ArrayList<spring> springs = new ArrayList<spring>();
  int curr = 0;
  int prev = 0;
  
  int spokes = 6;
  point_mass center = pm(p(150, 450)); // center
  float spoke_angle = 2*PI/spokes;
  
  point ground = p(150, 500);   // reference point on ground.
  vector vcg = v(center.p, ground);  // vector to ground.
  
  point cg = sum(center.p, r(vcg, 1*spoke_angle/2)); // point resting on ground below center.
  vcg = v(center.p, cg);                             // Vector between center and ground point.
  center.p.y += ground_y - cg.y;                     // Adjust center for spoke length.
  
  for (int i = 0; i < spokes; i++) {
    curr = springs.size();
    point_mass spoke = pm(sum(center.p, r(vcg, -i*spoke_angle)));
    float phase = PI;
    float freq = PI/8;
    float cycle = 2*PI/freq; // Time for a spoke to fully extend/retract.
    rest r = r(.95*cycle, cycle*(spokes-1), cycle*(spokes-i+1));  // move for one cycle; rest while the others move; offset to have each start moving in turn.
    //rest r = r(.95*cycle, cycle*(spokes-1), cycle*(spokes-i)+150);
    //rest r = r(.95*cycle, cycle*(spokes-1), cycle*(spokes-i));
    oscillator o = o(d(spoke, center), .3, freq, phase, r); 
    springs.add(s(center, spoke, o));
    if (i == 0) continue;
    springs.add(new spring(springs.get(prev).b, springs.get(curr).b));
    if (i == spokes - 1) springs.add(s(springs.get(curr).b, springs.get(0).b));
    prev = curr;
  }
  
  Creature whirligig = new Creature(springs);
  
  // Ticktock
  //springs = new ArrayList<spring>();
  //curr = 0;
  //prev = 0;
  
  //spokes = 6;
  //center = pm(p(150, 450)); // center
  //spoke_angle = 2*PI/spokes;
  
  //ground = p(150, 500);   // reference point on ground.
  //vcg = v(center.p, ground);  // vector to ground.
  
  //cg = sum(center.p, r(vcg, 1*spoke_angle/2)); // point resting on ground below center.
  //vcg = v(center.p, cg);                             // Vector between center and ground point.
  //center.p.y += ground_y - cg.y;                     // Adjust center for spoke length.
  
  //for (int i = 0; i < spokes; i++) {
  //  curr = springs.size();
  //  point_mass spoke = pm(sum(center.p, r(vcg, i*spoke_angle)));
  //  float difference = (i == 0)? 0 : PI; // -i*PI/num_spokes*/
  //  float freq = PI/8;
  //  oscillator o = o(d(spoke, center), .3, freq, PI/2 + difference, freq * (spokes-1), freq);
  //  springs.add(s(center, spoke, o));
  //  if (i == 0) continue;
  //  springs.add(new spring(springs.get(prev).b, springs.get(curr).b));
  //  if (i == spokes - 1) springs.add(s(springs.get(curr).b, springs.get(0).b));
  //  prev = curr;
  //}
  
  //Creature ticktock = new Creature(springs);
  
  // Inchworm
  springs = new ArrayList<spring>();
  curr = 0;
  prev = 0;
  int spacing = 20;
  int num_segments = 6;
  for(int i = 0; i < num_segments; i++) {
    int x = 100 + i*spacing;
    int y0 = 500;
    int y1 = (i > 1 && i < 4)? y0 - 56 : y0 - 50;
    curr = springs.size();
    point_mass pb = pm(p(x, y0));
    point_mass pt = pm(p(x, y1));
    if (i == 0) pb.fo = f(0, 3, PI/16, PI/2);                  // Friction increases as length increases.
    if (i == num_segments - 1) pb.fo = f(0, 100, PI/16, 3*PI/2); // Friction decreases as length increases.
    springs.add(s(pb, pt, d(pb, pt))); // vertical
    if (i == 0) continue;
    oscillator o = o(spacing, .5, PI/16, PI/2 /*+ PI*i/num_segments*/);
    point_mass p_a = springs.get(prev).a;
    point_mass p_b = springs.get(prev).b;
    point_mass c_a = springs.get(curr).a;
    point_mass c_b = springs.get(curr).b;
    spring bottom = s(p_a, c_a, o);
    spring top = s(p_b, c_b, o);
    spring forward_slash = s(p_a, c_b, d(p_a, c_b));
    spring back_slash = s(p_b, c_a,  d(p_a, c_b));
    springs.add(bottom);
    springs.add(top);
    springs.add(forward_slash);
    springs.add(back_slash);
    prev = curr;
  }
  Creature inchworm = new Creature(springs);
  
  creatures = new Creature[]{
    whirligig
    //inchworm
    //ticktock
  };
  
}

void draw() {
  noStroke();
  fill(black);
  rect(0, 0, max_x, max_y);
  show_controls();
  
  for (Creature c: creatures) {
    c.draw();
  }
  if (running) {
    update();
  }
  
  stroke(white);
  strokeWeight(15);
  line(0, ground_y + 15, max_x, ground_y + 15);
  
  int x = 0;
  for (int i = 20; i < max_x-20; i += 20) {
    text(x++, i, ground_y + 20);
  }
  
  fill(white);
  text(t, 50, ground_y + 50);
  strokeWeight(1);
}

void update() {
  t += dt;
  for (Creature c: creatures) {
    c.update();
  }
}

int min_cx = max_x;
int min_cy = 0;
int max_cx = 1350;
int max_cy = max_y;

int font_size = 16;
int text_spacing = font_size + 5;
int starting_cx = min_cx + 10;
int starting_cy = min_cy + 20;

String[] toggle_texts = {};
int[][] toggle_dimensions = new int[toggle_texts.length][4];

int button_size = font_size + 5;
int button_spacing = button_size + 5;
int button_start_y = starting_cy + text_spacing * (toggle_texts.length + 1);

String[][] button_texts = {};
int[][] button_dimensions = new int[button_texts.length][4];

int species_start_y = button_start_y + button_spacing * (button_texts.length);
String[] species_texts = {};
color[] species_on_colours = {};
color[] species_off_colours = {};
int[][][] species_toggle_dimensions = new int[species_texts.length][3][4];

void show_controls() {
  fill(white);
  stroke(black);
  rect(min_cx, min_cy, max_cx - min_cx, max_cy);
  
  fill(black);
  textSize(font_size);
  text("CONTROLS", starting_cx + 40, starting_cy);
  
  boolean[] toggles = {};
  for (int i = 0; i < toggles.length; i++) {
    text(toggle_texts[i], starting_cx, starting_cy + text_spacing*(i+1));
    fill(toggles[i]? black: white);
    stroke(black);
    square(toggle_dimensions[i][0], toggle_dimensions[i][1], toggle_dimensions[i][2]);
    fill(black);
  }
  
  boolean[] buttons = {};
  for (int i = 0; i < buttons.length; i++) {
    int text_index = buttons[i]? 0: 1;
    if (mousePressed && mouse_in(button_dimensions[i])) fill(light_grey); else noFill();
    rect(button_dimensions[i][0], button_dimensions[i][1], button_dimensions[i][2], button_dimensions[i][3]);
    fill(black);
    text(button_texts[i][text_index], starting_cx + 5, button_start_y + int(button_spacing*i) + 3);  
  }
  
  boolean[] active_species = {};
  boolean[] species_pop = new boolean[3];
  boolean[][] species_bools = {active_species, species_pop};
  
  noStroke();
  for (int i = 0; i < species_texts.length; i++) {
    fill(black);
    text(species_texts[i], starting_cx, species_start_y + text_spacing*i);
    for (int j = 0; j < species_toggle_dimensions[i].length; j++) {
      color fill_colour = species_bools[i][j]? species_on_colours[j] : species_off_colours[j];
      fill(fill_colour);
      square(species_toggle_dimensions[i][j][0], species_toggle_dimensions[i][j][1], species_toggle_dimensions[i][j][2]);
    }
  }
  stroke(black);
}

void mousePressed() {
  for (int i = 0; i < toggle_dimensions.length; i++) {
    if (mouse_in(toggle_dimensions[i])) {
      switch (toggle_texts[i]) {     
        default:
          break;
      }
    }
  }

  for (int i = 0; i < button_dimensions.length; i++) {
    if (mouse_in(button_dimensions[i])) {
      switch (button_texts[i][0]) {   
        default:
          break;
      }
    }
  }
  
  for (int i = 0; i < species_toggle_dimensions.length; i++) {
    for (int j = 0; j < species_toggle_dimensions[i].length; j++) {
      if (mouse_in(species_toggle_dimensions[i][j])) {
        if (i == 0) {
          switch(j) {
            default:
              break;
          }
        }
        else {
          switch(j) {
            default:
              break;
          }
        }
      }
    }
  }
}

// Ctrl = min x, min y, x size/size, y size (optional)
boolean mouse_in(int[] dimensions) {
  int min_x = dimensions[0];
  int max_x = min_x + dimensions[2];
  int min_y = dimensions[1];
  int max_y = dimensions[1] + (dimensions[3] > 0? dimensions[3] : dimensions[2]);
  return (mouseX >= min_x && mouseX <= max_x && mouseY >= min_y && mouseY <= max_y);
}

// Attempt at optimization for the whirligig creature.
//Creature whirligig_optimizer() {
//  int population = 100;
//  Creature[] herd = new Creature[population];
//  float[] distances = new float[population];
//  for (int i = 0; i < population; i++) {
//    herd[i] = random_whirligig();
//  }
//  float best_distance = 0;
//  Creature best = new Creature();
//  while (best_distance < 500 && !running) {
//    for (int i = 0; i < population; i++) {
//      Creature c = herd[i];
//      float distance = get_distance(c);
//      distances[i] = distance;
//      if (distance > best_distance) {
//        best_distance = distance;
//        best = c;
//        println("new best: " + best_distance + " with params: " + get_params(c));
//      }
//      if (random(1) < distance/best_distance) {
//        int mate_index = floor(random(population));
//        Creature mate = herd[mate_index];
//        Creature baby = mate(c, mate);
//        int baby_index = mate_index;
//        if (distances[mate_index] > distance) baby_index = mate_index;
//        herd[baby_index] = baby;
//        distances[baby_index] = get_distance(baby);
//      }
//    }
//  }
//  return best;
//}

//Creature random_whirligig() {
//  int num_spokes = 6;
//  float[] params = new float[num_spokes*5 + 1];
//  int i = 0;
//  params[i++] = num_spokes;
//  for (int s = 0; s < num_spokes; s++) {
//    params[i++] = random(.1, .9); // amplitude
//    params[i++] = random(2*PI + e);  // phase
//    params[i++] = random(PI/64, PI/8); // frequency                 
//    params[i++] = random(0, 500); // rest time
//    params[i++] = random(0, 500); // move time
//  }
//  return from_params(params);
//}

//String get_params(Creature c) {
//  float[] params = params(c);
//  String msg = "";
  
//  for (float f: params) {
//    msg += f + ", ";
//  }
  
//  return msg;
//}

//Creature from_params(float[] params) {
//  int i = 0;
//  int num_spokes = floor(params[i++]);
//  ArrayList<spring> springs = new ArrayList<spring>();
//  int curr = 0;
//  int prev = 0;
  
//  point_mass center = pm(p(150, 450)); // center
//  float spoke_angle = 2*PI/num_spokes;
  
//  point ground = p(150, 500);   // reference point on ground.
//  vector vcg = v(center.p, ground);  // vector to ground.
  
//  point cg = sum(center.p, r(vcg, 1*spoke_angle/2)); // point resting on ground below center.
//  vcg = v(center.p, cg);                             // Vector between center and ground point.
//  center.p.y += ground_y - cg.y;                     // Adjust center for spoke length.
  
//  for (int s = 0; s < num_spokes; s++) {
//    curr = springs.size();
//    point_mass spoke = pm(sum(center.p, r(vcg, i*spoke_angle)));
//    float amp = params[i++];
//    float phase = params[i++];
//    float freq = params[i++];
//    float rest_time = params[i++];
//    float move_time = params[i++];
//    oscillator o = o(d(spoke, center), amp, freq, phase, rest_time, move_time);
//    springs.add(s(center, spoke, o));
//    if (i == 0) continue;
//    springs.add(new spring(springs.get(prev).b, springs.get(curr).b));
//    if (i == num_spokes - 1) springs.add(s(springs.get(curr).b, springs.get(0).b));
//    prev = curr;
//  }
  
//  Creature c = new Creature(springs);
//  return c;
//}

//float[] params(Creature c) {
//  int num_spokes = 6;
//  float[] params = new float[num_spokes*5 + 1];
//  int i = 0; 
//  params[i++] = num_spokes;
//  for (spring s : c.springs) {
//    if (s.o != null) {
//      oscillator o = s.o;
//      params[i++] = o.a; // amplitude
//      params[i++] = o.p; // phase
//      params[i++] = o.f; // frequency                 
//      params[i++] = o.r; // rest time
//      params[i++] = o.m; // move time
//    }
//  }
//  return params;
//}

//float get_distance(Creature c) {
//  float start = c.points.get(0).p.x;
//  for (int t = 0; t < 1000; t++) {
//    c.update();
//  }
//  float end = c.points.get(0).p.x;
//  return end - start;
//}

//Creature mate(Creature a, Creature b) {
//  float[] pa = params(a);
//  float[] pb = params(b);
//  int num_spokes = floor((random(1) < .5)? pa[0] : pb[0]);
//  int crossover = floor(random(num_spokes));
//  int i = 0;
//  float[] params = new float[num_spokes*5 + 1];
//  params[i++] = num_spokes;
//  for (int s = 0; s < crossover; s++) {  
//    params[i] = (random(1) < .1)? pa[i] : pa[i] + random(-.1, .1); i++;  // amplitude
//    params[i] = (random(1) < .1)? pa[i] : pa[i] + random(-PI/16, PI/16); i++; // phase
//    params[i] = (random(1) < .1)? pa[i] : pa[i] + random(-PI/64, PI/64); i++;  // frequency                 
//    params[i] = (random(1) < .1)? pa[i] : max(pa[i] + random(-50, 50), 0); i++; // rest time
//    params[i] = (random(1) < .1)? pa[i] : max(pa[i] + random(-50, 50), 0); i++;  // move time
//  }
//  for (int s = crossover; s < num_spokes; s++) {
//    params[i] = (random(1) < .1)? pb[i] : pb[i] + random(-.1, .1); i++;  // amplitude
//    params[i] = (random(1) < .1)? pb[i] : pb[i] + random(-PI/16, PI/16); i++;  // phase
//    params[i] = (random(1) < .1)? pb[i] : pb[i] + random(-PI/64, PI/64); i++;  // frequency                 
//    params[i] = (random(1) < .1)? pb[i] : max(pb[i] + random(-50, 50), 0); i++; // rest time
//    params[i] = (random(1) < .1)? pb[i] : max(pb[i] + random(-50, 50), 0); i++;  // move time
//  }
  
//  return from_params(params);
//}

void keyPressed() {
  switch (key) {
    case ' ':
      running = !running;
      println(running? "Play" : "Pause");
      break;
    case 's':
      update();
      break;
    case 'r':
      setup();
      break;
    default:
      break;
  }
}
