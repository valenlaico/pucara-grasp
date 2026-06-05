import java.util.HashSet;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;

public class Movimiento {
  private HashSet<Integer> teclasActivas = new HashSet<Integer>();
  private boolean crearMis = false;
  private boolean reinMis = true;
  private boolean reinP = true;
  private boolean reinR = true;

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

  public void leerTeclado(gameManager gm) {
    boolean fPresionada = teclasActivas.contains(KeyEvent.VK_F);
    if (fPresionada && reinMis) {
      crearMis = true;
    }
    if (!fPresionada) {
      reinMis = true;
    }

    boolean pPresionada = teclasActivas.contains(KeyEvent.VK_P);
    if (pPresionada && !gm.isGameOver() && reinP) {
      gm.alternarPausa();
      reinP = false;
    }
    if (!pPresionada) {
      reinP = true;
    }

    boolean rPresionada = teclasActivas.contains(KeyEvent.VK_R);
    if (rPresionada && gm.isGameOver() && reinR) {
      gm.reiniciar();
      reinR = false;
    }
    if (!rPresionada) {
      reinR = true;
    }
  }

  public boolean consultarYConsumirDisparo() {
    if (crearMis) {
      crearMis = false;
      reinMis = false;
      return true;
    }
    return false;
  }

  public void resetear() {
    teclasActivas.clear();
    crearMis = false;
    reinMis = true;
    reinP = true;
    reinR = true;
  }

  public void aplicarMovimiento(Pucara p) {
    if (teclasActivas.contains(KeyEvent.VK_A) || teclasActivas.contains(KeyEvent.VK_LEFT)) p.moverIzq();
    if (teclasActivas.contains(KeyEvent.VK_D) || teclasActivas.contains(KeyEvent.VK_RIGHT)) p.moverDer();
    if (teclasActivas.contains(KeyEvent.VK_W) || teclasActivas.contains(KeyEvent.VK_UP)) p.moverArr();
    if (teclasActivas.contains(KeyEvent.VK_S) || teclasActivas.contains(KeyEvent.VK_DOWN)) p.moverAba();
  }
}
