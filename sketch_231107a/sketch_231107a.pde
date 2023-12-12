import processing.opengl.*;
import processing.video.*;
import ddf.minim.*;
import processing.serial.*;

Movie myMovie;
Block2 player;
int i = 0;
int totalBalls = 0; 
Ball[] myBall = new Ball[100];
Block2[] block = new Block2[100];
Firework[] fireworks = new Firework[100];
Block bg;
PFont myFont;
PImage pointer;
int filterStartTime = 0; // 필터가 시작된 시간
boolean filter = false;
Serial myPort;//아두이노 연결

int x = 0;

void setup() {
  myPort = new Serial(this, "COM6", 9600);
  myPort.bufferUntil('\n');
  size(600, 400, OPENGL);
  myMovie = new Movie(this, "test.mp4"); // 객체 초기화1
  myMovie.loop();
  myFont = createFont("HakgyoansimBombanghakR.ttf", 32);
  textFont(myFont);
  pointer = loadImage("mouse-pointer.png");
  PImage BlockImage = loadImage("flower.jpg");
  bg = new Block(BlockImage, 0, 0, 600, 400);
  player = new Block2(myMovie, 300 , 300, 100, 30);
  for(int i = 0; i <6; i++){
    block[i] = new Block2(myMovie, 100*i, 100, 99, 100); 
  }
}

void draw() {
  background(255);
  if (filter == true) {
    bg.display();
    bg.crash();
    filterStartTime++;
  }

  if (filterStartTime == 60 || filterStartTime == 0) {
    bg.display();
    filterStartTime = 0;
    filter = false;
  }
  for(int i = 0; i <block.length; i++){
    if (block[i] != null){
    block[i].display(); 
    }
  }
  player.display();
  player.move(x);
  x = 0;
  
  for (int j = 0; j < myBall.length; j++) {
    if (myBall[j] != null) {
      myBall[j].move();
      myBall[j].display();
      
      // 공과 Block2 객체 간의 충돌 확인
      if (player.checkCollision(myBall[j])) {
        myBall[j].reverseDirection();
      }
      for(int i = 0; i <block.length; i++){
        if (block[i] != null){
        if(block[i].checkCollision(myBall[j])){
          myBall[j].reverseDirection();
          block[i].crash++;
            if(block[i].crash >= 5){
              block[i] = null;
            }
          }
        }
      }
      
      if (myBall[j].getBounces() >= 5) {
        fireworks[j] = new Firework(myBall[j].xpos, myBall[j].ypos);
        filter = true;
        myBall[j] = null;
      }
    }
  }

  for (int k = 0; k < fireworks.length; k++) {
    if (fireworks[k] != null) {
      fireworks[k].update();
      fireworks[k].display();
      if (fireworks[k].isFinished()) {
        fireworks[k] = null;
      }
    }
  }
  pointerDrow();
  updateInfo(); // 정보 업데이트 함수 호출
}

void updateInfo() {
  int activeBalls = 0;
  for (int j = 0; j < myBall.length; j++) {
    if (myBall[j] != null) {
      activeBalls++;
    }
  }
  fill(0);
  textSize(20);
  textAlign(RIGHT, TOP);
  text("현재 창에 있는 공: " + activeBalls, width - 10, 10);
  text("지금까지 소환한 공: " + totalBalls, width - 10, 40);
}

public class Ball {
  color c;
  float xpos;
  float ypos;
  float xspeed;
  float yspeed;
  int bounces = 0;

  Ball(color tempc, float tempxpos, float tempypos, float tempxspeed, float tempyspeed) {
    c = tempc;
    xpos = tempxpos;
    ypos = tempypos;
    xspeed = tempxspeed;
    yspeed = tempyspeed;
  }

  void display() {
    stroke(0);
    fill(c);
    ellipse(xpos, ypos, 32, 32);
  }

  void move() {
    xpos = xpos + xspeed;
    ypos = ypos + yspeed;
    if (xpos > width || xpos < 0) {
      xspeed = -xspeed;
      bounces++;
    }
    if (ypos > height || ypos < 0) {
      yspeed = -yspeed;
      bounces++;
    }
  }
  
  void reverseDirection() {
    xspeed = -xspeed;
    yspeed = -yspeed;
    bounces++;
  }

  int getBounces() {
    return bounces;
  }
}

class Firework {
  float x, y;
  float[] sparksX, sparksY;
  int lifespan = 180; // 3초에 해당하는 프레임 수 (60프레임/초 기준)

  Firework(float x, float y) {
    this.x = x;
    this.y = y;
    sparksX = new float[100];
    sparksY = new float[100];

    for (int i = 0; i < 100; i++) {
      sparksX[i] = x;
      sparksY[i] = y;
    }
  }

  void update() {
    for (int i = 0; i < sparksX.length; i++) {
      sparksX[i] += random(-5, 5);
      sparksY[i] += random(-5, 5);
    }
    lifespan--; // 수명 감소
  }

  void display() {
    for (int i = 0; i < sparksX.length; i++) {
      stroke(255, 0, 0); // 빨간색으로 설정
      strokeWeight(2); // 선 두께를 줄임
      point(sparksX[i], sparksY[i]);
    }
  }

  boolean isFinished() {
    return lifespan <= 0;
  }
}

public class Block {
  PImage BlockImage;
  float x, y;
  float hei, wid;

  Block(PImage BlockImage, float x, float y, float hei, float wid) {
    this.BlockImage = BlockImage;
    this.x = x;
    this.y = y;
    this.hei = hei;
    this.wid = wid;
  }

  void display() {
    image(BlockImage, x, y, hei, wid);
  }

  void crash() {
    filter(INVERT);
  }
}

public class Block2 {
  Movie mymovie;
  float xpos, ypos, hei, wid;
  public int crash;
  Block2(Movie movie, float x, float y, float wid, float hei) {
    this.mymovie = movie;
    this.xpos = x;
    this.ypos = y;
    this.hei = hei;
    this.wid = wid;
    this.crash = 0;
  }

  void display() {
    noStroke();
    beginShape();
    texture(mymovie);
    vertex(xpos, ypos, xpos, ypos);
    vertex(xpos + wid, ypos, xpos + wid, ypos);
    vertex(xpos + wid, ypos + hei, xpos + wid, ypos + hei);
    vertex(xpos, ypos + hei, xpos, ypos + hei);
    endShape();
  }
  
  void move(int x){
    if(this.xpos <= 0 || this.xpos >= 500){
      x = 0;
    }
    this.xpos = this.xpos + x;
  }

  // 공과 Block2 객체 간의 충돌을 확인하는 메서드
  boolean checkCollision(Ball ball) {
    float ballRadius = 16; // 공 반지름
    float blockLeft = xpos;
    float blockRight = xpos + wid;
    float blockTop = ypos;
    float blockBottom = ypos + hei;

    // 충돌 체크
    if (ball.xpos + ballRadius > blockLeft && ball.xpos - ballRadius < blockRight &&
        ball.ypos + ballRadius > blockTop && ball.ypos - ballRadius < blockBottom) {
      return true; // 충돌이 있으면 true 반환
    } else {
      return false; // 충돌이 없으면 false 반환
    }
  }
}

void mousePressed() {
  if (i < 101) {
    myBall[i] = new Ball(color(100), mouseX, mouseY, 2, 2);
    totalBalls++; // 공을 만들 때마다 totalBalls 증가
    i = i + 1;
  }
}

void pointerDrow() {
  image(pointer, mouseX, mouseY, 40, 40);
} 

void movieEvent(Movie myMovie) {
  myMovie.read(); 
}

void serialEvent(Serial p) {
 String inString = myPort.readStringUntil('\n');
 char ch=inString.charAt(0);
 if (ch == 'd') {
 x = 3;
 }
 else if (ch == 'a') {
 x = -3;
 }

}
