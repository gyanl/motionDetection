// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/QLHMtE5XsMs

import processing.video.*;
import processing.sound.*;

SoundFile soundfile;
Capture video;
PImage prev;

float threshold = 25;

float motionX = 0;
float motionY = 0;

float lerpX = 0;
float lerpY = 0;

//Sine wave
int xspacing = 2;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave

float theta = 0.0;  // Start angle at 0
float amplitude = 75.0;  // Height of wave
float period = 500.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] yvalues;  // Using an array to store height values for the wave

int posX;

void setup() {
    size(640, 480);
    // Load a soundfile
  soundfile = new SoundFile(this, "vibraphon.aiff");

  // These methods return useful infos about the file
  println("SFSampleRate= " + soundfile.sampleRate() + " Hz");
  println("SFSamples= " + soundfile.frames() + " samples");
  println("SFDuration= " + soundfile.duration() + " seconds");

  // Play the file in a loop
  soundfile.loop();
 
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, cameras[3]);
  video.start();
  prev = createImage(640, 360, RGB);
  // Start off tracking for red
 
}


void mousePressed() {
}

void captureEvent(Capture video) {
  prev.copy(video, 0, 0, video.width, video.height, 0, 0, prev.width, prev.height);
  prev.updatePixels();
  video.read();
}

void draw() {
  //video.loadPixels();
  //prev.loadPixels();
  //image(video, 0, 0);

  //threshold = map(mouseX, 0, width, 0, 100);
  threshold = 50;


  int count = 0;
  
  float avgX = 0;
  float avgY = 0;

  loadPixels();
  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      color prevColor = prev.pixels[loc];
      float r2 = red(prevColor);
      float g2 = green(prevColor);
      float b2 = blue(prevColor);

      float d = distSq(r1, g1, b1, r2, g2, b2); 

      if (d > threshold*threshold) {
        //stroke(255);
        //strokeWeight(1);
        //point(x, y);
        avgX += x;
        avgY += y;
        count++;
        pixels[loc] = color(255);
      } else {
        pixels[loc] = color(0);
      }
    }
  }
  //updatePixels();

  // We only consider the color found if its color distance is less than 10. 
  // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.
  if (count > 200) { 
    motionX = avgX / count;
    motionY = avgY / count;
    // Draw a circle at the tracked pixel
  }
  
  lerpX = lerp(lerpX, motionX, 0.1); 
  lerpY = lerp(lerpY, motionY, 0.1); 
  
  //Sine
    //Sine
    period = lerpY;
    w = width+16;
    dx = (TWO_PI / period) * xspacing;
    yvalues = new float[w/xspacing];
  
  background(0);
  calcWave();
  renderWave();
  
  
  //fill(255, 0, 255);
  //strokeWeight(2.0);
  //stroke(0);
  
  //map(posX, 0, 640, 0, width);
  
  ellipse(width-lerpX, lerpY, 18, 18);

  //image(video, 0, 0, 100, 100);
  //image(prev, 100, 0, 100, 100);

  //println(mouseX, threshold);
  
    // Map mouseX from 0.25 to 4.0 for playback rate. 1 equals original playback speed,
  // 2 is twice the speed and will sound an octave higher, 0.5 is half the speed and
  // will make the file sound one ocative lower.
  float playbackSpeed = map(lerpX, 0, width, 0.5, 2.0);
  soundfile.rate(playbackSpeed);

  // Map mouseY from 0.2 to 1.0 for amplitude
  float amplitude = map(lerpY, 0, width, 1.0, 2.0);
  soundfile.amp(amplitude);

  // Map mouseY from -1.0 to 1.0 for left to right panning
  //float panning = map(lerpY, 0, height, -1.0, 1.0);
  //soundfile.pan(panning);
  
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

void calcWave() {
  // Increment theta (try different values for 'angular velocity' here
  theta += 0.02;
  amplitude=2*lerpX/3;
  // For every x value, calculate a y value with sine function
  float x = theta;
  for (int i = 0; i < yvalues.length; i++) {
    yvalues[i] = sin(x)*amplitude;
    x+=dx;
  }
}

void renderWave() {
  noStroke();
  fill(255);
  // A simple way to draw the wave with an ellipse at each location
  for (int x = 0; x < yvalues.length; x++) {
    ellipse(x*xspacing, height/2+yvalues[x], 10, 10);
  }
}
