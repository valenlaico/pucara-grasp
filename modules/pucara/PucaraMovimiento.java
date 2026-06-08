import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import processing.core.PApplet;

public class PucaraMovimiento {
  private Set<Integer> teclasActivas = Collections.synchronizedSet(new HashSet<Integer>());
  private KeyAdapter   keyListener;
  private boolean reinMis = true;
  private boolean reinP   = true;
  private boolean reinR   = true;

  public PucaraMovimiento() {}

  // Registra el listener AWT directamente sobre el componente nativo del sketch.
  // No depende del keyPressed/keyReleased del sketch principal; funciona de forma
  // independiente, lo que permite multi-tecla simultáneo dentro del módulo.
  public void registrarListener(PApplet sketch) {
    java.awt.Component componente = (java.awt.Component) sketch.getSurface().getNative();
    keyListener = new KeyAdapter() {
      public void keyPressed(KeyEvent evento)  { teclasActivas.add(evento.getKeyCode()); }
      public void keyReleased(KeyEvent evento) { teclasActivas.remove(evento.getKeyCode()); }
    };
    componente.addKeyListener(keyListener);
  }

  public void deregistrarListener(PApplet sketch) {
    if (keyListener != null && sketch != null) {
      java.awt.Component componente = (java.awt.Component) sketch.getSurface().getNative();
      componente.removeKeyListener(keyListener);
      keyListener = null;
    }
  }

  public PucaraEstadoEntrada leerTeclado() {
    boolean fPresionada = teclasActivas.contains(KeyEvent.VK_F);
    boolean disparar = fPresionada && reinMis;
    if (disparar)    reinMis = false;
    if (!fPresionada) reinMis = true;

    boolean pPresionada = teclasActivas.contains(KeyEvent.VK_P);
    boolean pausa = pPresionada && reinP;
    if (pausa)       reinP = false;
    if (!pPresionada) reinP = true;

    boolean rPresionada = teclasActivas.contains(KeyEvent.VK_R);
    boolean reiniciar = rPresionada && reinR;
    if (reiniciar)   reinR = false;
    if (!rPresionada) reinR = true;

    boolean izq = teclasActivas.contains(KeyEvent.VK_A) || teclasActivas.contains(KeyEvent.VK_LEFT);
    boolean der  = teclasActivas.contains(KeyEvent.VK_D) || teclasActivas.contains(KeyEvent.VK_RIGHT);
    boolean arr  = teclasActivas.contains(KeyEvent.VK_W) || teclasActivas.contains(KeyEvent.VK_UP);
    boolean aba  = teclasActivas.contains(KeyEvent.VK_S) || teclasActivas.contains(KeyEvent.VK_DOWN);

    return new PucaraEstadoEntrada(izq, der, arr, aba, disparar, pausa, reiniciar);
  }

  public void resetear() {
    teclasActivas.clear();
    reinMis = true;
    reinP   = true;
    reinR   = true;
  }
}
