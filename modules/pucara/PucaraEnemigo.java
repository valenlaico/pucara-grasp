import processing.core.PApplet;
import processing.core.PImage;

public abstract class PucaraEnemigo {
  protected int    xEnemigo;
  protected int    yEnemigo;
  protected int    velocidad;
  protected PImage imagen;

  PucaraEnemigo(int xPos, int yPos, int vel) {
    this.xEnemigo  = xPos;
    this.yEnemigo  = yPos;
    this.velocidad = vel;
  }

  public int getX() { return xEnemigo; }
  public int getY() { return yEnemigo; }

  public boolean salioDePantalla(int ancho, int alto) {
    return (yEnemigo > alto + 50) || (yEnemigo < -50)
        || (xEnemigo > ancho + 100) || (xEnemigo < -100);
  }

  // Polimorfismo GRASP: evita instanceof en PucaraGameManager.
  // Las subclases sobreescriben según su comportamiento específico.
  public boolean debeDisparar()        { return false; }
  public boolean debeLanzarBomba()     { return false; }
  public int[]   calcularPosicionBomba() { return new int[]{0, 0}; }

  public abstract void actualizar();
  public abstract void dibujar(PApplet app);
}
