import java.util.Random;
import processing.core.PApplet;
import processing.core.PImage;

public class PucaraShooter extends PucaraEnemigo {

  private Random rand    = new Random();
  private int    ancho;
  private int    xTarget;
  private int    fc      = 0;

  PucaraShooter(int xPos, int yPos, int velocidad, int ancho) {
    super(xPos, yPos, velocidad);
    this.ancho   = ancho;
    this.xTarget = xEnemigo;
    // imagen se carga de forma diferida en dibujar()
  }

  @Override
  public void actualizar() {
    if ((xTarget + Math.abs(velocidad) >= xEnemigo) && (xEnemigo >= xTarget - Math.abs(velocidad))) {
      xTarget = rand.nextInt(50, ancho - 50);
    } else if (xEnemigo > xTarget + 1) {
      xEnemigo -= velocidad;
    } else {
      xEnemigo += velocidad;
    }
  }

  @Override
  public boolean debeDisparar() {
    fc++;
    if (fc >= 90) { fc = 0; return true; }
    return false;
  }

  @Override
  public void dibujar(PApplet app) {
    if (imagen == null) {
      imagen = app.loadImage("pucara_shooter.png");
      if (imagen != null) imagen.resize(60, 60);
    }
    if (imagen != null) {
      app.image(imagen, xEnemigo, yEnemigo);
    } else {
      app.stroke(0);
      app.fill(255, 150, 0);
      app.rect(xEnemigo, yEnemigo, 45, 35);
      app.fill(255, 230, 0);
      app.ellipse(xEnemigo - 10, yEnemigo - 5, 10, 10);
      app.ellipse(xEnemigo + 10, yEnemigo - 5, 10, 10);
    }
  }
}
