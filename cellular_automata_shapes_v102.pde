/* 
Cellular Shapes
by Nicola Pisanti
http://cargocollective.com/nicolapisanti
June 2014

A life-like cellular automata is constrained in a predetermined shape, 
another shape determines the boundary of initlialization seeds. 
You can choose one of four shapes with the console 
and activate automatic reset of the automata (each 10 frames). 
Another set of checkbox in the console let you choose the automata rules of birth and survival.
( "s" key to start/stop saving frames)


*/
boolean save = false;
int pulseTime = 10;
PFont font;
int counter;
CAShape ca;
int [][] ruleSet = { 
  { 0, 0, 0, 1, 0, 0, 0, 0, 0}, 
  { 0, 0, 1, 1, 0, 0, 0, 0, 0} };
ruleBox rulesConsole;
radioBoxes shapeConsole;
checkBox pulseButton;
checkBox wrongButton;
PGraphics pg1b;
PGraphics pg1s;
PGraphics pg2b;
PGraphics pg2s;
PGraphics pg3b;
PGraphics pg3s;
PGraphics pg4s;

void setup() {

  font = loadFont("LaoUI-12.vlw");
  textFont(font);
  textSize(12);
  
  counter = 0;
  frameRate(15);
  size(500, 550, P2D);
  noSmooth();
  //CONSOLE
  rulesConsole = new ruleBox(290, 520, 12, ruleSet);
  shapeConsole = new radioBoxes(100, 520, 12, 4);
  pulseButton = new checkBox(160, 520, 12, false);
  wrongButton = new checkBox(410, 520, 12, false);
  //FIRST SHAPE : Parasitic Walls 
  int radius1=360;
  
  pg1b = createGraphics (500,500, P2D);
  pg1b.beginDraw();
  pg1b.background(0);
  pg1b.stroke(255);
  pg1b.strokeWeight(14);
  pg1b.noFill();
  pg1b.ellipse(250, 250, radius1, radius1);
  pg1b.endDraw();
  
  pg1s = createGraphics (500,500, P2D);
  pg1s.beginDraw();
  pg1s.background(0);
  pg1s.stroke(255);
  pg1s.strokeWeight(3); 
  pg1s.noFill();
  pg1s.ellipse(250, 250, radius1, radius1);
  pg1s.endDraw();
  
  //SECOND SHAPE : the Triangle
  int radius2 = 220;
  pg2b = createGraphics (500,500, P2D);
  pg2b.beginDraw();
  pg2b.background(0);
  pg2b.fill(255);
  pg2b.translate(250,300);
  pg2b.rotate(-HALF_PI);
  pg2b.noFill();
  pg2b.stroke(255);
  pg2b.strokeWeight(25);
  pg2b.triangle(cos(0)*radius2,sin(0)*radius2, cos(TWO_PI/3)*radius2, sin(TWO_PI/3)*radius2, cos(TWO_PI/3*2)*radius2, sin(TWO_PI/3*2)*radius2);
  pg2b.endDraw();
  
  pg2s = createGraphics (500,500, P2D);
  pg2s.beginDraw();
  pg2s.background(0);
  pg2s.fill(255);
  pg2s.translate(250,300);
  pg2s.rotate(-HALF_PI);
  pg2s.noFill();
  pg2s.stroke(255);
  pg2s.strokeWeight(2);
  pg2s.triangle(cos(0)*radius2,sin(0)*radius2, cos(TWO_PI/3)*radius2, sin(TWO_PI/3)*radius2, cos(TWO_PI/3*2)*radius2, sin(TWO_PI/3*2)*radius2);
  pg2s.endDraw();
  
  //THIRD SHAPE : the Cellular March
  int w = 30;
  int h= 360;
  int maxDim = 500;
  
  pg3b = createGraphics (500,500, P2D);
  pg3b.beginDraw();
  pg3b.background(0);
  pg3b.stroke(255);
  pg3b.strokeWeight(1);
  pg3b.rect((maxDim-w)/2, (maxDim-h)/2, w, h);
  pg3b.endDraw();
  
  pg3s = createGraphics (500,500, P2D);
  pg3s.beginDraw();
  pg3s.background(0);
  pg3s.stroke(255);
  pg3s.strokeWeight(25);
  pg3s.noFill();
  pg3s.line((maxDim-w)/2, (maxDim+h)/2 , maxDim/2, (maxDim+h)/2);
  pg3s.line((maxDim-w)/2, (maxDim-h)/2 , maxDim/2, (maxDim-h)/2);
  pg3s.endDraw();

  //FOURTH SHAPE: the Pillar
  //uses the same rectangle costrain as the third shape
  //with different initialization shape
  pg4s = createGraphics (500,500, P2D);
  pg4s.beginDraw();
  pg4s.background(0);
  pg4s.stroke(255);
  pg4s.strokeWeight(10);
  pg4s.noFill();
  pg4s.line(maxDim/2, (maxDim+h)/2 , maxDim/2, (maxDim-h)/2);
  pg4s.endDraw();

  //initialize CA
  ca = new CAShape(pg1b, pg1s, 0.5, new PVector(0,0), ruleSet, wrongButton.isChecked());
  
}

//>>>>>>>>>>>>>>>>>>>>>DRAW<<<<<<<<<<<<<<<<<<<<<<
void draw() {
  background(0);
  stroke(255);
  ca.display();
  ca.advance();
  if(pulseButton.isChecked()){
    counter++;
    if (counter == pulseTime){
      counter = 0;
      ca.reset(); 
    }
  }
  fill(255);

  switch (shapeConsole.getIndex()){
        case 0: text("Parasitic Walls", 100, 545); break; 
        case 1: text("the Triangle", 100, 545); break;  
        case 2: text("the Cellular March", 100, 545); break; 
        case 3: text("the Pillar", 100, 545); break; 
        default:  ;
  }
  
  rulesConsole.display();
  text("B", 280, 531);
  text("S", 280, 543);
  shapeConsole.display();
  pulseButton.display();
  wrongButton.display();
  if(save){
      saveFrame("output-###.jpg");  
  }
}


//>>>>>>>>>>>>>>>>>>>>>>INTERACTION<<<<<<<<<<<<<<<<<<<<<<<<<<<<

void mousePressed(){
  
    int prevShape = shapeConsole.getIndex();  
    if(shapeConsole.isClicked(mouseX, mouseY)){
      switch (shapeConsole.getIndex()){
        case 0: ca.reShape(pg1b,pg1s); break; 
        case 1: ca.reShape(pg2b,pg2s); break;  
        case 2: if(prevShape==2){
                  ca.reSeed(pg3s);
                }else{
                  ca.reShape(pg3b,pg3s);
                } 
                break; 
        case 3: if(prevShape==1){
                  ca.reSeed(pg4s);
                }else{
                  ca.reShape(pg3b,pg4s);
                } 
                break; 
        default:  ;
      }
    }
    pulseButton.clickDetection(mouseX,mouseY);
    rulesConsole.clickDetection(mouseX, mouseY);
    wrongButton.clickDetection(mouseX,mouseY);
    ca.setMode(wrongButton.isChecked());
    ca.reset();
    
}

void keyPressed(){
  if(key=='s'){
    if(save){
      save = false;
      println("not saving anymore");
    }else{
      save = true;
      println("saving frames");
    }
    ca.reset();
  }
}
  

