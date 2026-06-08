public abstract class Enemigo {
  protected int xEnemigo;
  protected int yEnemigo;
  protected int velocidad;
  protected PImage imagen;
  
  Enemigo(int xPos, int yPos, int vel) {
    this.xEnemigo = xPos;
    this.yEnemigo = yPos;
    this.velocidad = vel;
  }
  
  public int getX() {
    return xEnemigo;
  }
  
  public int getY() {
    return yEnemigo;
  }
 
  public boolean salioDePantalla() {
    return (yEnemigo > height + 50) || (yEnemigo < -50) || (xEnemigo > width + 100) || (xEnemigo < -100);
  }
  
  public boolean debeDisparar()        { return false; }
  public boolean debeLanzarBomba()     { return false; }
  public int[]   calcularPosicionBomba() { return new int[]{0, 0}; }

  public abstract void actualizar();

  public abstract void dibujar();
}
