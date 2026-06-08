import processing.core.PApplet;
import processing.core.PImage;

public class PucaraMisil {
  private int    xMisil;
  private int    yMisil;
  private int    velocidad  = 5;
  private PImage imagen;
  private boolean misEnemigo;

  PucaraMisil(int xPos, int yPos, boolean status) {
    this.xMisil    = xPos;
    this.yMisil    = yPos;
    this.misEnemigo = status;
    // imagen se carga de forma diferida en dibujarMisil()
  }

  public int  getX()       { return xMisil; }
  public int  getY()       { return yMisil; }
  public boolean esEnemigo() { return misEnemigo; }

  public void actualizarMisil() {
    yMisil += misEnemigo ? velocidad : -velocidad;
  }

  public boolean salioDePantalla(int alto) {
    return (yMisil > alto + 40) || (yMisil < -40);
  }

  public void dibujarMisil(PApplet app) {
    if (imagen == null) imagen = app.loadImage("pucara_misil.png");
    if (imagen != null) {
      app.image(imagen, xMisil, yMisil, 15, 30);
    } else {
      app.stroke(255, 0, 0);
      app.strokeWeight(6);
      app.line(xMisil, yMisil, xMisil, yMisil + 10);
      app.strokeWeight(2);
    }
  }
}
