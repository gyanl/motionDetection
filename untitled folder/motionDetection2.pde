// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/QLHMtE5XsMs

import processing.video.*;
import processing.sound.*;
SoundFile[] file;
Capture video;
PImage prev;

float threshold = 25;
int ballCount = 150;
ballPhysics[] ball = new ballPhysics[ballCount];
int timer;

float motionX = 0;
float motionY = 0;

float lerpX = 0;
float lerpY = 0;


void setup() {
    int numsounds = 5;
  file = new SoundFile[numsounds];
  file[0] = new SoundFile(this, "kick.wav");
  file[1] = new SoundFile(this, "snare.wav");
  file[2] = new SoundFile(this, "cowbell.wav");
  file[3] = new SoundFile(this, "clap.wav");
  file[4] = new SoundFile(this, "cymbal.wav");
  
  
  size(640, 480);
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, cameras[3]);
  video.start();
  prev = createImage(640, 480, RGB);
    colorMode(HSB, 255, 255, 255);  
  noStroke();
  frameRate(60);
  smooth();
   frame.setResizable(true);
  for (int i = 0; i<ballCount; i++) {
    ball[i] = new ballPhysics();
  }
  // Start off tracking for red
}




void captureEvent(Capture video) {
  prev.copy(video, 0, 0, video.width, video.height, 0, 0, prev.width, prev.height);
  prev.updatePixels();
  video.read();
}

void draw() {
  video.loadPixels();
  prev.loadPixels();
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
  
  fill(255, 0, 255);
  strokeWeight(1.0);
  stroke(0);
  ellipse(avgX, avgY, 36, 36);
    int ballCounter=0;
  int exitCounter=0;
  for (int i = 0; i<ballCount; i++) {
    if (ball[i].present==1) {
      ballCounter++;
      //println(str(i)+":"+str(ball[i].time)+" x:"+str(ball[i].location.x)+" y:"+str(ball[i].location.y)+" vx:"+str(ball[i].velocity.x)+" vy:"+str(ball[i].velocity.y));
    }
    if (ball[i].exit==1) {
      exitCounter++;
    }
    ball[i].update(avgX,avgY);
  }

  if (timer>70) {
    timer=0;
    
      for (int i = 0; i<ballCount; i++) {
        if (ball[i].present == 0) {
          //ball[i].spawn(random(50,width-50),random(50,height-50));
          ball[i].spawn(lerpX,lerpY);
          return;
        }
      }
    
  } else
    timer++;

  //image(video, 0, 0, 100, 100);
  //image(prev, 100, 0, 100, 100);

  //println(mouseX, threshold);
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
