


//>>>>>>>>>>>>>>>>RULES CONSOLE<<<<<<<<<<<<<<<<<<<<<<<
class ruleBoxSingle{  //to be used only inside of ruleBox
  int x;
  int y;
  int[][] rules;  
  int l;
  color c;
  
  ruleBoxSingle(int xindex, int yindex, int [][] ruleSet, int l){
    this.x=xindex;  //has to be 0-9
    this.y=yindex;  //has to be 0-1
    this.rules = ruleSet;
    this.l = l;  
    this.c = color(255);
  }
  
  void display(){
    stroke(c);
    if(ruleSet[y][x]==1){
      fill(c);
    }else{
      noFill(); 
    } 
    rect(x*l, y*l, l, l);
  }

  void clicked(){  //the external container will detect if the box is clicked or not and activate the method
    if(rules[y][x] == 1){
      rules[y][x]=0; 
    }else{
      rules[y][x]=1;  
    }
  } 
}

class ruleBox{
  
  int px;
  int py;
  ruleBoxSingle[][] boxes;
  int w;
  int h;
  int l;
  
  ruleBox(int px, int py, int boxdim, int [][] ruleSet){
    boxes = new ruleBoxSingle[2][9];
    for ( int y = 0; y<2; y++){
      for( int x = 0; x<9; x++){
        boxes[y][x] = new ruleBoxSingle(x, y, ruleSet, boxdim);
      }
    }
    this.px=px;
    this.py=py;   
    this.l=boxdim;
    this.w = 9*l;
    this.h= 2*l; 
  }
  
  void display(){
    pushMatrix();
    translate(px,py);
    for ( int y = 0; y<2; y++){
      for( int x = 0; x<9; x++){
        boxes[y][x].display();
      }
    }
    popMatrix();
  }
  
  void clickDetection(int click_x, int click_y){ 
     if( click_x>px && click_x<px+w && click_y>py && click_y<py+h){       
       int xindex = floor((click_x-px)/l);
       int yindex = floor((click_y-py)/l); 
       boxes[yindex][xindex].clicked();
     }
  }
}

//>>>>>>>>>>>>>>>>>>>PULSE CHECKBOX<<<<<<<<<<<<<<<<<<<<
class checkBox{
  int px;
  int py;
  int l;
  color c;
  boolean checked;

  checkBox(int px, int py, int l, boolean check){
    this.px=px;
    this.py=py;
    this.l=l;
    this.c = color(255);
    this.checked = check;
  }
  
  void clickDetection(int click_x, int click_y){
     if( click_x>px && click_x<px+l && click_y>py && click_y<py+l){
        if(checked){
           checked = false;
        }else{
           checked = true;
        }
     }  
  }
  
  boolean isChecked(){
    return checked;  
  }
  
    void display(){
    pushMatrix();
    translate(px,py);
    stroke(c);
    if(checked){
      fill(c);
    }else{
      noFill(); 
    }
    rect(0, 0, l, l);
    popMatrix();
  }
}

//>>>>>>>>>>>>>>>>>>>SHAPE RADIOBOXES<<<<<<<<<<<<<<<<<<<<<<<<<
class radioBoxes{
  int num;
  int index;
  int px;
  int py;
  color c;
  int l;
  
  radioBoxes(int px, int py, int l,int num){
    this.px=px;
    this.py=py;
    this.l=l;
    this.num = num;
    this.index = 0;
    c = color(255);
  }
  
  void display(){
    pushMatrix();
    translate(px,py);
    stroke(c);
    for (int i = 0; i<num; i++){
      if(i==index){
        fill(c);
      }else{
        noFill(); 
      }
      rect(i*l, 0, l, l);
    }
    popMatrix();
  }
  
  boolean isClicked(int click_x, int click_y){
     if( click_x>px && click_x<px+l*num && click_y>py && click_y<py+l){ 
       index = floor((click_x-px)/l);
       return true;
     }
     return false;
  }

  int getIndex(){
    return index;
  }  
  
}
