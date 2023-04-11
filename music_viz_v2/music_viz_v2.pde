import processing.sound.*;

// init audio processing objects
AudioIn audio;
Amplitude amp;
FFT fft;

// init variables for lisajou curves and triangles
float a, b, phi, t, t_inc, j_inc, scale_a, scale_b;
boolean adding;
int col_inc, red, blue, green;
int x_pos, y_pos;
float rads;

float scale = 500;
float inner_scale = 500;
float i_inc = 1.3;
int h = 0, s = 400, l = 400;
float outer_phi = 0;
boolean rotate = true;

LCurve red_curve, green_curve, red_curve2;
float phi_3d = 0;
boolean phi_adding = true;
float phi_3d_scale_factor = 6.0;

// init variables for audio processing 
float amplitude = 0.0;
int bands = 128;
float smoothingFactor = 0.1;
float fftScale = 5.0;
float[] sum = new float[bands];
float[] spectrum = new float[bands];
float barWidth;


void setup() {
  fullScreen(P3D);
  // set up audio processing tools
  audio = new AudioIn(this);
  amp = new Amplitude(this);
  fft = new FFT(this, bands);
  audio.start();
  amp.input(audio);
  fft.input(audio);
  
  // init the lisajou curves
  red_curve = new LCurve(0.75, 6, PI,
              0, .01, .4, .001,
              200, 200,
              true,
              20,0,10,100,0);
              
  green_curve = new LCurve(1.0, 2.0, PI,
              0, .01, .5, .001,
              100, 100,
              true,
              20,10,0,100,1);

  // init the rest of our vars
  background(0);
  x_pos = width/2;
  y_pos = height/2;
  rads = 0.0;
  barWidth = width/float(bands);
  colorMode(HSB, 500);
}

void draw() {
  
  if (phi_adding) {
    phi_3d += 0.003;
    inner_scale -= 0.1;
    if (phi_3d > 10) phi_adding = false;
  } else {
    phi_3d -= 0.003;
    inner_scale += 0.1;
    if (phi_3d < -10) phi_adding = true;
  }
  println(phi_3d);
  translate(x_pos, y_pos, 300);
  rads += 0.005;
  background(0);
  colorMode(RGB, 255);
  
  fft.analyze(spectrum);
  amplitude = amp.analyze();
  
  for (int i = 0; i < bands; i++) {
    // Smooth the FFT spectrum data by smoothing factor
    sum[i] += (spectrum[i] - sum[i]) * smoothingFactor;
  }
  
  rotateY(rads);
  rotateZ(rads);
  red_curve.update(amplitude, sum);
  green_curve.update(amplitude, sum);
  
  
  if (rotate) {
    outer_phi += .005;//*(amp.analyze()/0.19);
  }
  
  noFill();
  colorMode(HSB, 500);
  for (float i=0; i<2*PI; i+=0.03) {
    pushMatrix();
    rotateX(i);
    h = int(i * 500.0/(2*PI));
    stroke(h,s,l);
    triangle(cos(i+rads)*-1*inner_scale, -1*inner_scale, 0, sin(i+rads)*inner_scale, sin(i+rads)*inner_scale, 0);
    popMatrix();
    
  }  
}
