import java.util.HashSet;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;

public class Movimiento {
  private HashSet<Integer> teclasActivas = new HashSet<Integer>();
  private boolean reinMis = true;
  private boolean reinP   = true;
  private boolean reinR   = true;

  public Movimiento() {}

  public void registrarListener(processing.core.PApplet sketch) {
    java.awt.Component componente = (java.awt.Component) sketch.getSurface().getNative();
    componente.addKeyListener(new KeyAdapter() {
      public void keyPressed(KeyEvent evento) {
        teclasActivas.add(evento.getKeyCode());
      }
      public void keyReleased(KeyEvent evento) {
        teclasActivas.remove(evento.getKeyCode());
      }
    });
  }

  // Devuelve el estado de todas las teclas relevantes para este frame.
  // Las acciones de un solo disparo (disparar, pausa, reiniciar) se consumen aqui.
  public EstadoEntrada leerTeclado() {
    boolean fPresionada = teclasActivas.contains(KeyEvent.VK_F);
    boolean disparar = fPresionada && reinMis;
    if (disparar)   reinMis = false;
    if (!fPresionada) reinMis = true;

    boolean pPresionada = teclasActivas.contains(KeyEvent.VK_P);
    boolean pausa = pPresionada && reinP;
    if (pausa)      reinP = false;
    if (!pPresionada) reinP = true;

    boolean rPresionada = teclasActivas.contains(KeyEvent.VK_R);
    boolean reiniciar = rPresionada && reinR;
    if (reiniciar)  reinR = false;
    if (!rPresionada) reinR = true;

    boolean izq = teclasActivas.contains(KeyEvent.VK_A) || teclasActivas.contains(KeyEvent.VK_LEFT);
    boolean der  = teclasActivas.contains(KeyEvent.VK_D) || teclasActivas.contains(KeyEvent.VK_RIGHT);
    boolean arr  = teclasActivas.contains(KeyEvent.VK_W) || teclasActivas.contains(KeyEvent.VK_UP);
    boolean aba  = teclasActivas.contains(KeyEvent.VK_S) || teclasActivas.contains(KeyEvent.VK_DOWN);

    return new EstadoEntrada(izq, der, arr, aba, disparar, pausa, reiniciar);
  }

  public void resetear() {
    teclasActivas.clear();
    reinMis = true;
    reinP   = true;
    reinR   = true;
  }
}
