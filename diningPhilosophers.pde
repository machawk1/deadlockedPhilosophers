World world;


Table table1, table2, table3, table4;
Table [] tables;
void setup()
{

  world = new World();                        //create the world object
  
  size(world.worldWidth, world.worldHeight);  //define the size of the world/palette
  //framerate(60);                              //set the refresh rate
  colorMode(RGB,255,255,255,100);           
  smooth();                                   //make shapes primative 
  tables = new Table[5]; //table 0 is dead
  
  
  
  tables[0] = tables[1] = table1 = new Table(); //create table 0/1, assign 0 to 1 to prevent index errors
  tables[2] = table2 = new Table();             //create table 2
  tables[3] = table3 = new Table();             //create table 3
  tables[4] = table4 = new Table();             //create table 4
}

void draw()
{
    background(0);                             //reset background color each time

     world.draw();
     
    //***************DEFINE TEXT CHARACTERISTICS**********
     char [] chars = new char[4];
     chars[0] = '1'; chars[1] = '2'; chars[2] = '3'; chars[3] = '4';
     textFont(createFont("Arial",8,true,chars));


    //give the table the type of resource it's on
    WorldRegion copyOfRegionOccupiedData;

     for(int i=1; i<=4; i++){ //traverse all philosophers
       
       if(tables[i].alive) {
         copyOfRegionOccupiedData = world.getRegionByPosition(tables[i].xPosition, tables[i].yPosition);
         
         tables[i].draw();
         
         if(tables[i].acquiringResourceFromRegion != null)
           fill(0,255,0);
         else if(tables[i].acquiringResourceFromRegion == null)
         {
           fill(255,0,0);
//           acquireResource();XXX boolean useResource(int tableNumber, WorldRegion regionTableIsIn)
             tables[i].useResource(i, copyOfRegionOccupiedData);
         }
         else
           fill(255,255,255);    //should never get here
         
         text(i,tables[i].xPosition-2,tables[i].yPosition+3);   //label the tables with their respective number from the array
         fill(255);                                             //reset fill color of tables to white
         
         if(tables[i].useResource(i, copyOfRegionOccupiedData))    //solely for the philosopher and table
         {
           //findAnotherResource();
         }
         else {}  //resource not acquired, wait here
       }
       else {} //table is dead
     }
     System.out.println();   //break line after spitting out the verbose array of useResource
    
}  //end draw


//******************************************************************
//*********** WORLD CLASS *********************************************
//******************************************************************

class World
{
  WorldRegion [][] region;
 
  int worldWidth, worldHeight, worldDepth;
  
  public World()
  {
    this.worldHeight = this.worldWidth = this.worldDepth = 200;
    
    this.region = new WorldRegion[2][2];
    this.region[0][0] = new WorldRegion(0,0,this.worldWidth/2, color(255,0,0));
    this.region[1][0] = new WorldRegion(this.worldWidth/2,0,this.worldWidth/2, color(0,255,0));
    this.region[0][1] = new WorldRegion(0,this.worldHeight/2,this.worldWidth/2, color(0,0,255));
    this.region[1][1] = new WorldRegion(this.worldWidth/2,this.worldHeight/2,this.worldWidth/2, color(255,255,0)); 
    
   //reset all using worldregions's occupiedByTableNumber
    for(int i=0; i<=1; i++)
      for(int j=0; j<=1; j++)
        this.region[i][j].occupiedByTableNumber = -1;   
  }
  
  public WorldRegion getRegionByPosition(int x, int y)
  {
    WorldRegion toReturn;
  
    if(x<this.worldWidth/2 &&  x>0 && y<this.worldHeight/2 && y>0) toReturn = this.region[0][0];
    else if(x>=this.worldWidth/2 && x < this.worldWidth && y<this.worldHeight/2 && y>0)  toReturn = this.region[1][0];
    else if(x<this.worldWidth/2 && x>0 && y < this.worldHeight && y >=this.worldHeight/2)  toReturn = this.region[0][1];
    else if(x>=this.worldWidth/2 && x< this.worldWidth && y>=this.worldWidth/2 && y < this.worldWidth)  toReturn = this.region[1][1];
    else {System.out.println("All tables are dead."); return null;}
    
    return toReturn;
  }
  
  void draw()
  {
    noStroke();
    for(int i=0; i<=1; i++){
      int j=0;
      for(j=0; j<=1; j++)
      {
        fill(this.region[i][j].regionColor);
        this.region[i][j].draw();
      }
    }
    fill(255);
  }
}  //end World (oh no, armageddon!  Ahhhh!)


//******************************************************************
//*********** WORLDREGION CLASS *********************************************
//******************************************************************

class WorldRegion
{
  int xLeftBound, yTopBound, width;
  color regionColor;
  String regionColorString;
  int occupiedByTableNumber;
  
  
  
  public WorldRegion(int x, int y, int widthIn, color colorIn)
  {
    if(colorIn == color(255,255,0))  this.regionColorString = "yellow";
    else if(colorIn == color(0,0,255))  this.regionColorString = "blue";
    else if(colorIn == color(255,0,0))    this.regionColorString = "red";
    else if(colorIn == color(0,255,0))  this.regionColorString = "green";
    else                  this.regionColorString = "no color, yo" + colorIn;
    
    //System.out.println(this.regionColorString);
    this.xLeftBound = x;
    this.yTopBound = y;
    this.width = widthIn;
    this.regionColor = colorIn;
  }
  
  void draw()
  {
    rect(this.xLeftBound, this.yTopBound, this.width, this.width);
  }
} //end WorldRegion


//******************************************************************
//*********** TABLE CLASS *********************************************
//******************************************************************

public int tableNumber = 0;

class Table{
  Philosopher [] philosopher;
  int tableIndex;
  int xPosition, yPosition, zPosition;
  //movement bound scheme
  int xLowerRand, xUpperRand, yLowerRand, yUpperRand;
  
  World worldWhereTableExists;             //trivial, no?
  WorldRegion acquiringResourceFromRegion; //null if occupied by another table that is acquiring resources
  
  boolean alive;
  boolean tableCompleted;

  public Table()
  {
    this.philosopher = new Philosopher[5];  //0 doesn't exist
    
    for(int i=0; i<=4; i++)
      this.philosopher[i] = new Philosopher(this, (i+1)*3);
   
    this.tableIndex = tableNumber;
    tableNumber++;
    this.alive = true;
    this.tableIndex = (int)random(1,4);
    
    //initialize table position
    this.xPosition = (int)random(25,world.worldWidth-25);
    this.yPosition = (int)random(25,world.worldHeight-25);
    
    this.worldWhereTableExists = world;
    this.acquiringResourceFromRegion = null;
    this.tableCompleted = false;
    
    //set randomness bounds used in initial movement scheme
    this.xLowerRand = this.yLowerRand = -2;
    this.xUpperRand = this.yUpperRand = 2;
  }
  
  public int[] getRandomPosition()
  {
    int position[] = new int[2];
    
      position[0] = (int)random(this.xLowerRand,this.xUpperRand);
      position[1] = (int)random(this.yLowerRand,this.yUpperRand);
     return position;
  }
  
  boolean useResource(int tableNumber, WorldRegion regionTableIsIn)
  {   
    
     //match the region given to a region in the world
    for(int i=0; i<2; i++)
    {
      for(int j=0; j<2; j++)
      {
          if(regionTableIsIn == world.region[i][j] && regionTableIsIn.occupiedByTableNumber != tableNumber && regionTableIsIn.occupiedByTableNumber != -1) //right region, table not current
              {
                System.out.println("table is     in region ["+i+"[]"+j+"] but it is already occupied -- occupied by "+regionTableIsIn.occupiedByTableNumber);
                try{
                  tables[tableNumber].acquiringResourceFromRegion.occupiedByTableNumber = -1;
                }
                catch(NullPointerException npe) {}
                tables[tableNumber].acquiringResourceFromRegion = null;
                return false;}
          else if(regionTableIsIn == world.region[i][j] && regionTableIsIn.occupiedByTableNumber == -1) //correct region found
          {
            //regionTableIsIn = world.region[i][j];
            //set table's old region to -1, if one exists at all
            if(tables[tableNumber].acquiringResourceFromRegion != null){
                tables[tableNumber].acquiringResourceFromRegion.occupiedByTableNumber = -1;}

              
            //set the region to have its resource being taken from specified table     T <- [R]
            //find REAL region instead of manipulating copy passed in           
             world.region[i][j].occupiedByTableNumber = tableNumber;
            
            //set table to be acquiring resource from determined region
            
            System.out.println("{"+world.region[i][j].occupiedByTableNumber + "}");
            tables[tableNumber].acquiringResourceFromRegion = world.region[i][j];
            
            //find philosopher with the color of the region on the specified table and change his color
            for(int p=1; p<tables[tableNumber].philosopher.length; p++)
              if(world.region[i][j].regionColor == tables[tableNumber].philosopher[p].philosopherColor)
              {
                tables[tableNumber].philosopher[p].requirementsFulfilled = true;
                tables[tableNumber].philosopher[p].philosopherColor = color(0,0,0);
                break;
              }
            
            //find next target region (pass table #
            findNextTargetRegion(i);
            
            return true; //resource found, kick back true to tell table to find another resource

          }
          else  System.out.println("table is not in region ["+i+"]["+j+"]");
       }
     
    }
    if(regionTableIsIn != null)
              System.out.print("["+regionTableIsIn.regionColorString + " - "+ regionTableIsIn.occupiedByTableNumber + "] ");
    
          
    return false;
  }
  
  void findNextTargetRegion(int tableNumber)
  {
    WorldRegion worldRegion = tables[tableNumber].acquiringResourceFromRegion;
    int [] regionCoords = new int[2]; // [x][y]
    int lookAtX;;
    int lookAtY;
    
    try{
    if(worldRegion.regionColor == color(255,0,0)) {regionCoords[0]=0; regionCoords[1]=0;  }
    else if(worldRegion.regionColor == color(0,255,0)) { regionCoords[0]=1; regionCoords[1]=0; }
    else if(worldRegion.regionColor == color(0,0,255)) { regionCoords[0]=0; regionCoords[1]=1; }
    else if(worldRegion.regionColor == color(255,255,0)) { regionCoords[0]=1; regionCoords[1]=1; }
    }
    catch(NullPointerException npe){ return;}
    for(int i=1; i<tables[tableNumber].philosopher.length; i++)
    {
        if(tables[tableNumber].philosopher[i].philosopherColor != color(0)) //philosopher's needs are not already met
        {
          //focus on philosopher's color to determine desired region
          //find region
          for(int j=0; j<2; j++)
            for(int k=0; k<2; k++)
              if(world.region[j][k].regionColor == tables[tableNumber].philosopher[i].philosopherColor)
              {
                
              }
          
        }
    }


    
    //world.region
  }
  
  void draw()
  {
   int d[] = getRandomPosition();
   if(this.xPosition + d[0] > world.worldWidth || this.xPosition + d[0] < 0)  this.xPosition += (-1*d[0]);
   else if(this.yPosition + d[1] > world.worldWidth || this.yPosition + d[1] < 0) this.yPosition += (-1*d[1]);
   else
   {this.xPosition += d[0];
   this.yPosition += d[1];
   }
   if(alive){
     stroke(100);
     ellipse(this.xPosition, this.yPosition, 10,10); //draw table
     noStroke();
     for(int p=0; p<this.philosopher.length; p++){
       this.philosopher[p].draw();} //draw philosophers at above table
    } 
     
   if(this.xPosition<0 || this.xPosition > world.worldWidth || this.yPosition < 0 || this.yPosition > world.worldWidth){
       this.alive = false;
       if(this.acquiringResourceFromRegion != null)  
       {
         this.acquiringResourceFromRegion.occupiedByTableNumber = -1;
         this.acquiringResourceFromRegion = null;
       }  
       // ELSE if table wasn't acquiring resource, but died
     }

   fill(255);
   } //end draw

 }

//******************************************************************
//*********** PHILOSOPHER CLASS *********************************************
//******************************************************************

class Philosopher {
  int resource1, resource2;
  color philosopherColor;
  int clockPosition;
  Table table;
  boolean requirementsFulfilled;
  
  
  
  
  public Philosopher(Table tableIn, int clockPositionIn)
  {
    this.table = tableIn;

    this.clockPosition = clockPositionIn;
    //set color based on clockPosition
    if(clockPosition == 12)  this.philosopherColor = color(0,255,0);
    else if(clockPosition == 3)  this.philosopherColor = color(0,0,255);
    else if(clockPosition == 6)  this.philosopherColor = color(255,0,0);
    else if(clockPosition == 9)  this.philosopherColor = color(255,255,0);
    
    this.requirementsFulfilled = false;
    
    
  }
  
  void draw()
  {
    fill(this.philosopherColor);
    if(this.clockPosition == 3){
      ellipse(table.xPosition+7, table.yPosition,4,4);}
    else if(this.clockPosition == 6){
       ellipse(table.xPosition, table.yPosition+7,4,4);}
    else if(this.clockPosition == 9){
      ellipse(table.xPosition-7, table.yPosition,4,4);}
   else if(this.clockPosition == 12){
      ellipse(table.xPosition, table.yPosition-7,4,4);}
   
  } //end draw

} //end philosopher class




 
 
 
 
 
 

