import java.util.Random;

public class Shooter extends Enemigo {

  private Random rand    = new Random();
  private int    xTarget;
  private int    fc      = 0;

  Shooter(int xPos, int yPos, int velocidad) {
    super(xPos, yPos, velocidad);
    this.imagen  = loadImage("shooter.png");
    this.xTarget = xEnemigo;
  }

  @Override
  public void actualizar() {
    if ((xTarget + abs(velocidad) >= xEnemigo) && (xEnemigo >= xTarget - abs(velocidad))) {
      xTarget = rand.nextInt(50, width - 50);
    } else if (xEnemigo > xTarget + 1) {
      xEnemigo -= velocidad;
    } else {
      xEnemigo += velocidad;
    }
  }

  // Devuelve true una vez cada 90 frames: señal para que GestorProyectiles cree el misil.
  @Override
  public boolean debeDisparar() {
    fc++;
    if (fc >= 90) { fc = 0; return true; }
    return false;
  }

  public void dibujar() {
    if (imagen != null) {
      image(imagen, xEnemigo, yEnemigo, 60, 60);
    } else {
      stroke(0);
      fill(255, 150, 0);
      rect(xEnemigo, yEnemigo, 45, 35);
      fill(255, 230, 0);
      ellipse(xEnemigo - 10, yEnemigo - 5, 10, 10);
      ellipse(xEnemigo + 10, yEnemigo - 5, 10, 10);
    }
  }
}
