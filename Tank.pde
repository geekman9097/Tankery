import java.awt.geom.Area;
import java.util.Random;

class Tank extends Entity implements Hittable{
  private final Hull hull;
  private final Turret turret;
  private final Cannon cannon;
  private final Engine engine;
  private final float mass;
  public final int maxHealth;
  private final float speed;
  private final float traverse;
  
  private float turretFacing;
  private int health;
  private int reloadCounter;
  
  public Tank() {
    this(width/2,height/2,0,0,Hull.TEST,Turret.TEST,Cannon.TEST,Engine.TEST);
  }
  
  public Tank(float x, float y, float facing, float turretFacing) {
    this(x,y,facing,turretFacing, Hull.TEST, Turret.TEST, Cannon.TEST, Engine.TEST);
  }
  
  public Tank(float x, float y, float facing, float turretFacing, Random random) {
    this(x,y,facing,turretFacing,
    Hull.values()[random.nextInt(Hull.values().length)],
    Turret.values()[random.nextInt(Turret.values().length)],
    Cannon.values()[random.nextInt(Turret.values().length)],
    Engine.values()[random.nextInt(Turret.values().length)]);
  }
  
  public Tank(float x, float y, float facing, float turretFacing, Hull hull, Turret turret, Cannon cannon, Engine engine) {
    super(x,y,facing);
    this.hull=hull;
    this.turret=turret;
    this.turretFacing=turretFacing;
    this.cannon=cannon;
    this.engine=engine;
    this.mass = hull.mass+turret.mass+cannon.mass+engine.mass;
    this.maxHealth=hull.maxHealth+turret.maxHealth;
    this.health=this.maxHealth;
    this.speed=engine.power/(mass+hull.groundResistance);
    this.traverse=PI*engine.traversePower/(mass+hull.groundResistance);
  }
  
  protected void addToTrackers() {
    hittables.add(this);
    super.addToTrackers();
  }
  
  public void turnTurretBy(float delTheta) {
    turretFacing+=delTheta;
  }
  public void turnTurretTo(float theta) {
    turretFacing=theta;
  }
  
  public void damage(int damage) {
    health-=damage;
    health=constrain(health,0,maxHealth);
    if(health==0) this.markToRemove();
    logger.log(this+" hit for: " + damage+ ", now at: "+health); 
  }
  
  public void render() {
    render(hull,facing);
    render(turret,turretFacing);
    render(cannon,turretFacing);
  }
  
  public boolean contains(Shape collider) {
    //TODO: Use java.awt.shape for collision detection
    //return(dist(this.x,this.y,x,y)<20);
    return(collide(hull,facing,collider)||collide(turret,turretFacing,collider));
  }
  public float getThickness(float angle) {
    float incidence=(facing-angle)%TWO_PI;
    return hull.armor/sin(incidence);
  }
  
  public void render(Renderable r, float facing) {
    pushMatrix();
    translate(x,y);
    rotate(facing);
    shape(r.getRender());
    popMatrix();
  }
  
  public boolean collide(Collideable c, float facing, Shape other) {
    AffineTransform at = new AffineTransform();
    at.translate(x,y);
    at.rotate(facing);
    Area collider = new Area(at.createTransformedShape(c.getCollider()));
    collider.intersect(new Area(other));
    return !collider.isEmpty();
  }
  
  public int getHealth() {
    return health;
  }
  
  public float getTurretFacing() {
   return turretFacing;
  }
  
  public void fire() {
    if(reloadCounter==0) {
      cannon.fire(x,y,turretFacing);
      reloadCounter=cannon.reload;
    }
  }
  
  public void drive(float dir) {
    float newX = x+dir*speed*cos(facing);
    float newY = y+dir*speed*sin(facing);
    moveTo(newX,newY);
  }
  
  public void turn(float dir) {
    //println("traverse "+dir);
    turnBy(traverse*dir);
    turnTurretBy(traverse*dir);
  }
  
  public void aimTurret(float dir) {
    turnTurretBy(turret.turnRate*dir);
  }
  
  public void update() {
    reloadStep(false);
  }
  
  public void reloadStep(boolean wasLoader) {
      if(wasLoader) {
        reloadCounter=0;
      } else if (reloadCounter>0) {
        reloadCounter--;
      }
    }
}
