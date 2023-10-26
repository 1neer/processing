int i = 0;
int totalBalls = 0; 
Ball[] myBall = new Ball[100];
Firework[] fireworks = new Firework[100];
PFont myFont;

void setup() {
  size(600, 400);
  myFont = createFont("HakgyoansimBombanghakR.ttf", 32);
  textFont(myFont);
}

void draw() {
  background(255);
  for (int j = 0; j < myBall.length; j++) {
    if (myBall[j] != null) {
      myBall[j].move();
      myBall[j].display();
      if (myBall[j].getBounces() >= 5) {
        fireworks[j] = new Firework(myBall[j].xpos, myBall[j].ypos);
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
void mousePressed() {
  if (i < 101) {
    myBall[i] = new Ball(color(100), mouseX, mouseY, 2, 2);
    totalBalls++; // 공을 만들 때마다 totalBalls 증가
    i = i + 1;
  }
}
