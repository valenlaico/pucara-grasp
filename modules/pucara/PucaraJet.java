import java.util.Random;
import processing.core.PApplet;
import processing.core.PImage;

public class PucaraJet extends PucaraEnemigo {

  private Random rand  = new Random();
  private int    ancho;
  private int    xTarget;

  PucaraJet(int xPos, int yPos, int velocidad, int ancho) {
    super(xPos, yPos, velocidad);
    this.ancho   = ancho;
    this.xTarget = rand.nextInt(50, ancho - 50);
    // imagen se carga de forma diferida en dibujar()
  }

  @Override
  public void actualizar() {
    if ((xTarget + Math.abs(velocidad)/2 >= xEnemigo) && (xEnemigo >= xTarget - Math.abs(velocidad)/2)) {
      yEnemigo += Math.abs(velocidad);
    } else {
      xEnemigo += velocidad;
    }
  }

  @Override
  public void dibujar(PApplet app) {
    if (imagen == null) {
      imagen = app.loadImage("pucara_jet.png");
      if (imagen != null) imagen.resize(60, 60);
    }
    if (imagen != null) {
      app.image(imagen, xEnemigo, yEnemigo);
    } else {
      app.stroke(0);
      app.fill(0, 255, 0);
      app.ellipse(xEnemigo, yEnemigo, 40, 40);
      app.fill(255, 255, 0);
      app.ellipse(xEnemigo - 10, yEnemigo - 5, 15, 10);
      app.ellipse(xEnemigo + 10, yEnemigo - 5, 15, 10);
      app.stroke(255, 0, 0);
      app.line(xEnemigo + 5, yEnemigo - 5, xEnemigo + 10, yEnemigo + 10);
    }
  }
}
