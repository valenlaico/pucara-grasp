import java.util.Random;
import processing.core.PApplet;
import processing.core.PImage;

public class PucaraBomber extends PucaraEnemigo {

  private Random rand  = new Random();
  private int    ancho;
  private int    alto;

  PucaraBomber(int xPos, int yPos, int velocidad, int ancho, int alto) {
    super(xPos, yPos, velocidad);
    this.ancho = ancho;
    this.alto  = alto;
    // imagen se carga de forma diferida en dibujar()
  }

  @Override
  public void actualizar() {
    xEnemigo += velocidad;
  }

  @Override
  public boolean debeLanzarBomba() { return true; }

  // Elige una posición aleatoria en la zona de juego, lejos de la base (parte inferior).
  // Information Expert: el Bomber conoce su tipo y decide dónde cae la bomba.
  @Override
  public int[] calcularPosicionBomba() {
    int x = rand.nextInt(50, ancho - 50);
    int y = rand.nextInt(alto - 50, alto - 100);
    return new int[]{x, y};
  }

  @Override
  public void dibujar(PApplet app) {
    if (imagen == null) {
      imagen = app.loadImage("pucara_bomber.png");
      if (imagen != null) imagen.resize(60, 60);
    }
    if (imagen != null) {
      app.image(imagen, xEnemigo, yEnemigo);
    } else {
      app.stroke(0);
      app.fill(100, 180, 255);
      app.triangle(xEnemigo - 35, yEnemigo + 20, xEnemigo, yEnemigo - 20, xEnemigo + 35, yEnemigo + 20);
      app.fill(255, 0, 0);
      app.rect(xEnemigo, yEnemigo + 15, 18, 18);
    }
  }
}
