import java.util.Random;

public class PucaraFabricaEnemigos {
  private Random rand  = new Random();
  private int    ancho;
  private int    alto;

  PucaraFabricaEnemigos(int ancho, int alto) {
    this.ancho = ancho;
    this.alto  = alto;
  }

  public PucaraEnemigo crearEnemigo(String tipo) {
    boolean esIzquierda = tipo.endsWith("-izq");
    int xPos  = esIzquierda ? -40 : ancho + 40;
    int signo = esIzquierda ? 1 : -1;

    if (tipo.startsWith("jet")) {
      return new PucaraJet(xPos, rand.nextInt(150, 200), 2 * signo, ancho);
    } else if (tipo.startsWith("shooter")) {
      return new PucaraShooter(xPos, rand.nextInt(75, 125), 3, ancho);
    } else {
      return new PucaraBomber(xPos, rand.nextInt(50), 2 * signo, ancho, alto);
    }
  }
}
