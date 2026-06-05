import java.util.Random;

public class FabricaEnemigos {
  private Random rand = new Random();

  // tipo puede ser "jet-izq", "jet-der", "shooter-izq", "shooter-der", "bomber-izq", "bomber-der"
  public Enemigo crearEnemigo(String tipo) {
    boolean esIzquierda = tipo.endsWith("-izq");
    int xPos  = esIzquierda ? -40 : width + 40;
    int signo = esIzquierda ? 1 : -1;

    if (tipo.startsWith("jet")) {
      return new Jet(xPos, rand.nextInt(150, 200), 2 * signo);
    } else if (tipo.startsWith("shooter")) {
      return new Shooter(xPos, rand.nextInt(75, 125), 3);
    } else {
      return new Bomber(xPos, rand.nextInt(50), 2 * signo);
    }
  }
}
