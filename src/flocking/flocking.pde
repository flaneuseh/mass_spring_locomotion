// README
// 
// # BOIDS! (Craig Reynolds' Flocking)
// 
// ## An implementation in Processing by Kaylah Facey.
//
// ### Commands:
// 
// * space bar - Start or stop the simulation (default stopped).
// * left mouse held down - continuous attraction (in attraction mode) or repulsion (in repulsion mode):
// -   a - Switch to attraction mode (default).
// -   r - Switch to repulsion mode.
// * s - Cause all boids to be instantly scattered to random positions in the window, and with random directions.
// * p - Toggle whether to have creatures leave a path, that is, whether the window is cleared each display step or not (default off).
// When pathing leave a trail of dots or fading trail. Do not preserve the entire path, as that quickly clutters the window.
// * c - Clear the screen, but do not delete any boids. (This can be useful when creatures are leaving paths.)
// * 1-4 - Toggle forces on/off (default on):
//   - 1 - flock centering 
//   - 2 - velocity matching 
//   - 3 - collision avoidance 
//   - 4 - wandering 
// * Spawn and Kill:
//   - +/= - Spawn (add one new boid to the simulation) (up to 100)
//   - (minus sign) - Kill (Remove one boid from the simulation) (down to 0).
// 
// ## Custom Commands:
// * right mouse held down - do the opposite of the left mouse (repulsion in attraction mode, attraction in repulsion mode)
// 
// ### Extras:
// * Functional GUI
// * Multiple boid species:
//   - "Active" species controls what species appear on screen (inactive species don't affect the simulation)
//   - "+/-" species is the species that the "spawn" and "kill" buttons (or +/- keys) control the population of.
//   - Initially there are no blue or grey boids, those must be activated and added to to use.
//   - Blue boids don't flock with orange boids but otherwise don't behave differently.
//   - Grey boids are bigger and chase blue and orange boids. Blue and orange boids flee them, for a predator/prey dynamic.
// 
// FUTURE IDEAS:
// * Implement 3D flocking.
// * Allow predators to eat prey.
// * Include fixed collision objects for the creatures to steer around.
// * food/resources/shelter
// * Use a grid or Voronoi/Dalauney triangles to only consider the closest neighborhood of boids.
// * boid colour variation
// 

// Simulation Parameters
boolean running = false;
boolean attraction = true;
boolean pathing = false;
int alpha_p = 20; // the alpha value to use when pathing.

// Colours.
color black = #000000;
color white = #ffffff;
color light_grey = #cccccc;
color aqua = #00ffff;
color red = #ff0000;
color green = #00802b;

// Default boids.
color light_orange = #ffa366;
color orange = #ff6600;
color dark_orange = #993d00;

// Friendly boids.
color light_blue = #b3b3ff;
color blue = #0000ff;
color dark_blue = #000099;

// Predator boids.
color light_pgrey = #a3a3c2;
color pgrey = #666699;
color dark_pgrey = #3d3d5c;

// Flock
Flock flock = new Flock();
int initial_size = 16;

int max_x = 1150;
int max_y = 850;

boolean flock_centering = false;
boolean velocity_matching = false;
boolean collision_avoidance = false;
boolean wander = false;

boolean show_collision_circles = false;
boolean show_perception_circles = false;

String current_species = "Orange"; // The species currently being added/removed to/from.

void setup() {
  size(1350, 850);
  surface.setTitle("BOIDS!");
  clear_paths();
  for (int i = 0; i < initial_size; i++) {
    flock.spawn(current_species);
  }
  for (int i = 0; i < toggle_dimensions.length; i++) {
    toggle_dimensions[i][0] = max_cx - 25;
    toggle_dimensions[i][1] = starting_cy + text_spacing*(i+1) - 14;
    toggle_dimensions[i][2] = font_size;
  }
  for (int i = 0; i < button_dimensions.length; i++) {
    button_dimensions[i][0] = starting_cx;
    button_dimensions[i][1] = button_start_y + button_spacing*i - 14;
    button_dimensions[i][2] = max_cx - 25 + font_size - starting_cx;
    button_dimensions[i][3] = button_size;
  }
  for (int i = 0; i < species_texts.length; i++) {
    for (int j = 0; j < species_toggle_dimensions[i].length; j++) {
      species_toggle_dimensions[i][j][0] = max_cx - 59 + (font_size + 2) * j;
      species_toggle_dimensions[i][j][1] = species_start_y + text_spacing*i - 14;
      species_toggle_dimensions[i][j][2] = font_size;
    }
  }
  strokeWeight(2);
}

void draw() {
  paint_background(pathing);
  show_mouse();
  show_controls();
  flock.show();
  if (running) {
    flock.update(dt);
  }
}

void show_mouse() {
  if (mouse_active()) {
    color c;
    if (attracting()) { 
      // attraction left or repulsion right: attraction
      c = green;
    }
    else { // repulsion left or attraction right: repulsion
      c = red;
    }
    
    int alpha = pathing? 20 : 130;
    fill(c, alpha);
    noStroke();
    circle(mouseX, mouseY, boid_p*2);
  }
}

boolean mouse_active() {
  return mousePressed && mouseX <= max_x && mouseY <= max_y;
}

boolean attracting() {
  // attraction left or repulsion right: attraction
  // repulsion left or attraction right: repulsion
  return (attraction && mouseButton == LEFT) || (!attraction && mouseButton == RIGHT);
}

void paint_background (boolean pathing) {
  noStroke();
  if (pathing) fill(aqua, alpha_p);
  else fill(aqua);
  rect(0, 0, max_x, max_y);
}

int min_cx = max_x;
int min_cy = 0;
int max_cx = 1350;
int max_cy = max_y;

int font_size = 16;
int text_spacing = font_size + 5;
int starting_cx = min_cx + 10;
int starting_cy = min_cy + 20;

String[] toggle_texts = {"flock centering", "velocity matching", "collision avoidance", "wander", "show paths", "show collision circles", "show perception"};
int[][] toggle_dimensions = new int[toggle_texts.length][4];

int button_size = font_size + 5;
int button_spacing = button_size + 5;
int button_start_y = starting_cy + text_spacing * (toggle_texts.length + 1);

String[][] button_texts = {{"clear", "clear"}, {"scatter", "scatter"}, {"set mouse to repulse", "set mouse to attract"}, {"play", "pause"}, {"spawn", "spawn"}, {"kill", "kill"}};
int[][] button_dimensions = new int[button_texts.length][4];

int species_start_y = button_start_y + button_spacing * (button_texts.length);
String[] species_texts = {"active species", "+/- species"};
color[] species_on_colours = {orange, blue, pgrey};
color[] species_off_colours = {light_orange, light_blue, light_pgrey};
int[][][] species_toggle_dimensions = new int[species_texts.length][3][4];

void show_controls() {
  fill(white);
  stroke(black);
  rect(min_cx, min_cy, max_cx - min_cx, max_cy);
  
  fill(black);
  textSize(font_size);
  text("CONTROLS", starting_cx, starting_cy);
  
  boolean[] toggles = {flock_centering, velocity_matching, collision_avoidance, wander, pathing, show_collision_circles, show_perception_circles};
  for (int i = 0; i < toggles.length; i++) {
    text(toggle_texts[i], starting_cx, starting_cy + text_spacing*(i+1));
    fill(toggles[i]? black: white);
    stroke(black);
    square(toggle_dimensions[i][0], toggle_dimensions[i][1], toggle_dimensions[i][2]);
    fill(black);
  }
  
  boolean[] buttons = {true, true, attraction, !running, true, true};
  for (int i = 0; i < buttons.length; i++) {
    int text_index = buttons[i]? 0: 1;
    if (mousePressed && mouse_in(button_dimensions[i])) fill(light_grey); else noFill();
    rect(button_dimensions[i][0], button_dimensions[i][1], button_dimensions[i][2], button_dimensions[i][3]);
    fill(black);
    text(button_texts[i][text_index], starting_cx + 5, button_start_y + int(button_spacing*i) + 3);  
  }
  
  boolean[] active_species = {orange_active, blue_active, grey_active};
  boolean[] species_pop = new boolean[3];
  switch (current_species) {
    case "Orange":
      species_pop[0] = true;
      break;
    case "Blue":
      species_pop[1] = true;
      break;
    case "Grey":
      species_pop[2] = true;
      break;
    default:
      break;
  }
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
        case "flock centering":
          flock_centering = !flock_centering;
          break;
        case "velocity matching":
          velocity_matching = !velocity_matching;
          break;
        case "collision avoidance":
          collision_avoidance = !collision_avoidance;
          break;
        case "wander":
          wander = !wander;
          break;
        case "show paths":
          pathing = !pathing;
          break;
        case "show collision circles":
          show_collision_circles = !show_collision_circles;
          break;
        case "show perception":
          show_perception_circles = !show_perception_circles;
          break;
        default:
          break;
      }
    }
  }

  for (int i = 0; i < button_dimensions.length; i++) {
    if (mouse_in(button_dimensions[i])) {
      switch (button_texts[i][0]) {   
        case "clear":
          clear_paths();
          break;
        case "scatter":
          flock.scatter();
          break;
        case "set mouse to repulse":
          attraction = !attraction;
          break;
        case "play":
          running = !running;
          break;
        case "spawn":
          flock.spawn(current_species);
          break;
        case "kill":
          flock.kill(current_species);
          break;
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
            case 0: 
              orange_active = !orange_active;
              break;
            case 1: 
              blue_active = !blue_active;
              break;
            case 2: 
              grey_active = !grey_active;
              break;
            default:
              break;
          }
        }
        else {
          switch(j) {
            case 0: 
              current_species = "Orange";
              break;
            case 1: 
              current_species = "Blue";
              break;
            case 2: 
              current_species = "Grey";
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

void clear_paths() {
  paint_background(false);
}

void keyPressed() {
  switch (key) {
    case ' ':
      running = !running;
      println(running? "Play" : "Pause");
      break;
    case 'a':
      attraction = true;
      println("Toggle left mouse attraction (right mouse repulsion)");
      break;
    case 'r':
      attraction = false;
      println("Toggle left mouse repulsion (right mouse attraction)");
      break;
    case 's':
      flock.scatter();
      println("Scatter");
      break;
    case 'p':
      pathing = !pathing;
      println("Toggle pathing " + (pathing? "on" : "off"));
      break;
    case 'c':
      clear_paths();
      println("Clear");
      break;
    case '1':
      flock_centering = !flock_centering;
      println("Toggle flock centering " + (flock_centering? "on" : "off"));
      println("Flock centering: " + (flock_centering? "on":"off") + "; velocity matching: " + (velocity_matching? "on":"off") + "; collision avoidance: " + (collision_avoidance? "on" : "off") + "; wander: " + (wander? "on" : "off"));
      break;
    case '2':
      velocity_matching = !velocity_matching;
      println("Toggle velocity matching " + (velocity_matching? "on" : "off"));
      println("Flock centering: " + (flock_centering? "on":"off") + "; velocity matching: " + (velocity_matching? "on":"off") + "; collision avoidance: " + (collision_avoidance? "on" : "off") + "; wander: " + (wander? "on" : "off"));
      break;
    case '3':
      collision_avoidance = !collision_avoidance;
      println("Toggle collision avoidance " + (collision_avoidance? "on" : "off"));
      println("Flock centering: " + (flock_centering? "on":"off") + "; velocity matching: " + (velocity_matching? "on":"off") + "; collision avoidance: " + (collision_avoidance? "on" : "off") + "; wander: " + (wander? "on" : "off"));
      break;
    case '4':
      wander = !wander;
      println("Toggle wander " + (wander? "on" : "off"));
      println("Flock centering: " + (flock_centering? "on":"off") + "; velocity matching: " + (velocity_matching? "on":"off") + "; collision avoidance: " + (collision_avoidance? "on" : "off") + "; wander: " + (wander? "on" : "off"));
      break;
    case '+':
    case '=':
      flock.spawn(current_species);
      println("Spawn");
      break;
    case '-':
      flock.kill(current_species);
      println("Kill");
      break;
    default:
      break;
  }
}
