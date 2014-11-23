//>>>>>>>>>>>>>>CAShape CLASSES<<<<<<<<<<<<<<<<<<<<<<<<<

//PRESETS RULES
final int [][] CA_GAME_OF_LIFE = { 
  { 0, 0, 0, 1, 0, 0, 0, 0, 0}, 
  { 0, 0, 1, 1, 0, 0, 0, 0, 0} };
final int [][] CA_REPLICATOR = { 
  { 0, 1, 0, 1, 0, 1, 0, 1, 0}, 
  { 0, 1, 0, 1, 0, 1, 0, 1, 0} };
final int [][] CA_SEEDS = { 
  { 0, 0, 1, 0, 0, 0, 0, 0, 0}, 
  { 0, 0, 0, 0, 0, 0, 0, 0, 0} };
final int [][] CA_B25S4 = { 
  { 0, 0, 1, 0, 0, 1, 0, 0, 0}, 
  { 0, 0, 0, 0, 1, 0, 0, 0, 0} };  
final int [][] CA_34LIFE = { 
  { 0, 0, 0, 1, 1, 0, 0, 0, 0}, 
  { 0, 0, 0, 1, 1, 0, 0, 0, 0} };
final int [][] CA_DIAMOEBA = { 
  { 0, 0, 0, 1, 0, 1, 1, 1, 1}, 
  { 0, 0, 0, 0, 0, 1, 1, 1, 1} };
final int [][] CA_2X2 = { 
  { 0, 0, 0, 1, 0, 0, 1, 0, 0}, 
  { 0, 1, 1, 0, 0, 1, 0, 0, 0} };  
final int [][] CA_LIFE_WITHOUT_DEATH = { 
  { 0, 0, 0, 1, 0, 0, 0, 0, 0}, 
  { 1, 1, 1, 1, 1, 1, 1, 1, 1} };  
final int [][] CA_HIGH_LIFE = { 
  { 0, 0, 0, 1, 0, 0, 1, 0, 0}, 
  { 0, 0, 1, 1, 0, 0, 0, 0, 0} };
final int [][] CA_DAY_AND_NIGHT = { 
  { 0, 0, 0, 1, 0, 0, 1, 1, 1}, 
  { 0, 0, 0, 1, 1, 0, 1, 1, 1} };
final int [][] CA_MORLEY = { 
  { 0, 0, 0, 1, 0, 0, 1, 0, 1}, 
  { 0, 0, 1, 0, 1, 1, 0, 0, 0} };  


class CAShape {

  color mainColor = color(255);
  int h;
  int w;
  int[][] CA;
  int[][] nextCA;
  PVector start;
  PImage seedMask;
  PImage boundaryMask;
  int [][] rules; //dimension [2][9], first row is birth, second row is survive
  float density; //density of seeds, range 0.0-1.0
  float threshold = 200;
  boolean wrong = false;
  CellPos head;

  //CONSTRUCTORS
  //takes in the constructor two images, uses the first to define the boundary shape and the second to define the shape of the initialized cells zone
  //to detect active cell the blue channel is used, and a threshold value of 200
  //density value is for the percentual of random seed cells in the seed zone
  //optional start vector offset for printing the whole automata in a different position  
  //wrong mode activate an alternative cellular automata
  CAShape(PImage boundary, float density, int[][] ruleset) {
    this(boundary, boundary, density, new PVector(0,0), ruleset, false);
  }
  CAShape(PImage boundary, PImage seeds, float density, int[][] ruleset) {
    this(boundary, seeds, density, new PVector(0,0), ruleset, false);
  }
  CAShape(PImage boundary, PImage seeds, float density, int[][] ruleset, boolean wrong) {
    this(boundary, seeds, density, new PVector(0,0), ruleset, wrong);
  }
  CAShape(PImage boundary, PImage seeds, float density, PVector start, int[][] ruleset) {
    this (boundary, seeds, density, start, ruleset, false);
  }
  
  CAShape(PImage boundary, PImage seeds, float density, PVector start, int[][] ruleset, boolean wrong) {
    this.w = boundary.width;
    this.h = boundary.height;
    this.boundaryMask = boundary;
    this.seedMask = seeds;
    this.density = density;
    this.rules = ruleset;
    this.start = start;
    this.head=new CellPos(0, 0, false);
    this.wrong=wrong;
    CA = new int[h][w];
    nextCA = new int[h][w];
    _initialize();
    //now all the cells are 0 and we got the linked list of cells and seeds
    reset();
  }

  //METHODS

  void _initialize(){ //INTERNAL METHOD
    CellPos iterator = head;
    boundaryMask.loadPixels();
    seedMask.loadPixels();
    for (int y = 0; y<this.h; y++) {
      for (int x = 0; x<this.w; x++) {
        CA[y][x] = 0;
        nextCA[y][x] = 0;
        if( float(boundaryMask.pixels[y*w+x] & 0xFF) > threshold){ //bitshifting select the blue channel
          //is inside the mask
          if( float(seedMask.pixels[y*w+x] & 0xFF)>threshold){ //bitshifting select the blue channel
            //is seed
              iterator.setNext(new CellPos(x, y, true));
              iterator = iterator.next();
          }else{
            //it isn't seed
              iterator.setNext(new CellPos(x, y, false));
              iterator = iterator.next();
          }
        }//end if
      }
    }  
  }//end inititialize
  //only linked cells are controlled for survive or birth, so external cells are always dead

  void display(color col) {
    pushMatrix();
    translate(start.x, start.y);
    noStroke();
    fill(col);
    CellPos cell=head;
    while(cell.hasNext()){
      cell = cell.next();
      if ( CA[cell.y][cell.x] == 1) {
          //point didn't worked as aspected, using rect without stroke, just filling
          rect(cell.x, cell.y, 1, 1);
      }
    }
    popMatrix();
  }
  
  void display() {
    display(mainColor);
  }

  void advance() {
    CellPos cell=head;
    while(cell.hasNext()){
      cell= cell.next();
      int x = cell.x;
      int y = cell.y;
      int neighbours = 0;
      for (int yy=-1; yy<=1; yy++) {
          for (int xx=-1; xx<=1; xx++) {
            if ( y+yy>=0 && x+xx>=0 && !(xx==0 && yy==0) && y+yy<CA.length && x+xx<CA[y].length ) { //not out of boundary and not the examined cel
              neighbours+=CA[y+yy][x+xx];
            }
          }
      }//end counting
      
      if (wrong){
        CA[y][x] = rules[CA[y][x]][neighbours];
        //the wrong cellular automata does not use two different arrays but update the arrays as it go
      }else{
        nextCA[y][x] = rules[CA[y][x]][neighbours];
      }
      //the cell state determine if the birth row or survive row is selected
      //the neighbours count determine the rule to be applied
    }
    if(!wrong){
      int [][] temp= CA;
      CA=nextCA;
       nextCA=temp;
    }
  }//end advance
  
  void reset(){

    CellPos cell=head;
    while(cell.hasNext()){
      cell=cell.next();
      if(cell.isSeed && random(1)<density){
        CA[cell.y][cell.x] = 1;  
      }else{
        CA[cell.y][cell.x] = 0;  
      } 
    }
  }
  
  
  //change the boundary and reset all the cells
  void reShape(PImage reBoundary, PImage reSeed){
    if(boundaryMask.width!=reBoundary.width ||boundaryMask.height!=reBoundary.height ){
        println("BEWARE!: not matching boundary image dimensions!"); 
        return;
    }
    if( seedMask.width!=reSeed.width|| seedMask.height!=reSeed.height){
        println("BEWARE!: not matching seed image dimensions!"); 
        return;
    }
    boundaryMask = reBoundary;
    seedMask = reSeed;
    
    //Java Garbage Collector,
    //hallowed be your name.
    //Your kingdom come,
    //your will be done
    //whatever the platform is.
    
    //Give us our memory back,
    //and forgive our orphaned nodes,
    //as we can't free them by ourselves.
    //And lead us not to curse the Virtual Machine,
    //but deliver us from memory leak.
    
    _initialize(); //AMEN
  }
  
  //change just the seed shape
  void reSeed(PImage reSeed){
    seedMask = reSeed;
    reSeed.loadPixels();
    CellPos cell=head;
    while(cell.hasNext()){
      cell = cell.next();
      boolean seed= float(reSeed.pixels[cell.y*reSeed.width+cell.x] & 0xFF) > threshold;  //bitshifting select the blue channel
      if (seed){
        cell.isSeed=true;
        if(random(1)<density){
          CA[cell.y][cell.x] = 1;
        }else{
          CA[cell.y][cell.x] = 0; 
        }    
      }else{
        cell.isSeed=false;
        CA[cell.y][cell.x] = 0;     
      }       
    }
  }
  
  void setRules(int[][]ruleset) {
    this.rules = ruleset;
  }
  
  void setMode(boolean mode){
    wrong=mode;  
  }

  void setThreshold(int threshold){
    this.threshold = threshold;  
  }
  
}//end class



//each cell has a reference to the next, forming a linked list that can be browsed in linear time
//it also has boolean flag to know if it is a seed cell
class CellPos{
  int x;
  int y;
  boolean isSeed;  
  CellPos next=null;
  
  CellPos(int x, int y, boolean isSeed){
    this.x = x;
    this.y = y;
    this.isSeed = isSeed;  
  }
  
  void setNext(CellPos another){
    next= another;
  }
  
  CellPos next(){
    return next;  
  }
  
  boolean hasNext(){
    if(next==null){
      return false;  
    }
    return true;
  }
  
}

