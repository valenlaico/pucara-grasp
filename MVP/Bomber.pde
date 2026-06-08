import java.util.Random;

public class Bomber extends Enemigo {

  private Random rand = new Random();

  Bomber(int xPos, int yPos, int velocidad) {
    super(xPos, yPos, velocidad);
    this.imagen = loadImage("bomber.png");
  }

  public void actualizar() {
    xEnemigo += velocidad;
  }

  @Override
  public boolean debeLanzarBomba() { return true; }

  // Elige una posición aleatoria en la zona de juego, lejos de la base (parte inferior)
  @Override
  public int[] calcularPosicionBomba() {
    int x = rand.nextInt(50, width - 50);
    int y = rand.nextInt(150, height - 200);
    return new int[]{x, y};
  }

  public void dibujar() {
    if (imagen != null) {
      image(imagen, xEnemigo, yEnemigo, 60, 60);
    } else {
      stroke(0);
      fill(100, 180, 255);
      triangle(xEnemigo - 35, yEnemigo + 20, xEnemigo, yEnemigo - 20, xEnemigo + 35, yEnemigo + 20);
      fill(255, 0, 0);
      rect(xEnemigo, yEnemigo + 15, 18, 18);
    }
  }
}
