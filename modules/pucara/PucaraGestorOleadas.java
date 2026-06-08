import java.util.Random;

public class PucaraGestorOleadas {
  private Random rand       = new Random();
  private int framesPartida = 0;
  private int oleadaActual  = 1;
  private int dificultad    = 90;
  private int fc            = 0;

  public String update() {
    framesPartida++;

    if      (framesPartida <  60 * 60) oleadaActual = 1;
    else if (framesPartida < 120 * 60) oleadaActual = 2;
    else                               oleadaActual = 3;

    fc++;
    if (fc >= dificultad) {
      fc = 0;
      return elegirTipoYLado();
    }
    return null;
  }

  private String elegirTipoYLado() {
    String lado = rand.nextInt(2) == 0 ? "-izq" : "-der";

    if (oleadaActual == 1) {
      return "jet" + lado;
    } else if (oleadaActual == 2) {
      return rand.nextInt(100) < 70 ? "jet" + lado : "shooter" + lado;
    } else {
      if      (rand.nextInt(100) < 50) return "jet" + lado;
      else if (rand.nextInt(100) < 60) return "shooter" + lado;
      else                             return "bomber" + lado;
    }
  }

  public void actualizarDificultad(int score) {
    if (score % 100 == 0 && score > 0 && dificultad > 10) {
      dificultad -= 5;
    }
  }

  public int getOleada()     { return oleadaActual; }
  public int getDificultad() { return dificultad; }
  public int getFrames()     { return framesPartida; }

  public void reiniciar() {
    framesPartida = 0;
    oleadaActual  = 1;
    dificultad    = 90;
    fc            = 0;
  }
}
