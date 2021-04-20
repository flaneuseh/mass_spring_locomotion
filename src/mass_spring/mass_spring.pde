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
  point_mass a = pm("A", p(150, 450), null, 1);
  float rads = PI/3;
  
  point p = p(150, 500);
  vector vap = v(a.p, p);
  point pb = sum(a.p, r(vap, 1*rads/2));
  vector vab = v(a.p, pb);
  a.p.y += ground_y - pb.y;
  
  point_mass b = pm("B", sum(a.p, vab), null, 1);
  
  point_mass c = pm("C", sum(a.p, r(vab, -1*rads)), null, 1);
  point_mass d = pm("D", sum(a.p, r(vab, -2*rads)), null, 1);
  point_mass e = pm("E", sum(a.p, r(vab, -3*rads)), null, 1);
  point_mass f = pm("F", sum(a.p, r(vab, -4*rads)), null, 1);
  point_mass g = pm("G", sum(a.p, r(vab, -5*rads)), null, 1);
  
  //s(a, b, o(87.5, .43, PI/16, .25)), // 125
  //s(b, c, o(87.5, .43, PI/16, .75)), // 50
  //s(a, c, o(87.5, .43, PI/16, .43)), // 100
  creatures = new Creature[]{
    new Creature(new spring[]{
      s(a, b, o(d(a, b), .25, PI/32, PI/2)), 
      s(a, c, o(d(a, b), .25, PI/32, 3*PI/2)),
      s(a, d, o(d(a, d), .25, PI/16, PI/2)), 
      s(a, e, o(d(a, b), .25, PI/16, PI/2)),
      s(a, f),// o(d(a, b), .25, PI/16, 2*PI/3)),
      s(a, g),// o(d(a, b), .25, PI/16, 5*PI/3)),
      s(b, c), 
      s(c, d), 
      s(d, e), 
      s(e, f), 
      s(f, g), 
      s(g, b),
    }),
    //new Creature(new spring[]{
    //  s(pm("A", p(500, 100), null, 1), pm("B", p(500, 200), null, 1), o(100, .9, PI/16, 0))
    //})
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
  strokeWeight(10);
  line(0, ground_y + 10, max_x, ground_y + 10);
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