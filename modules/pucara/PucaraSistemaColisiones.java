import processing.core.PApplet;
import java.util.ArrayList;

public class PucaraSistemaColisiones {

  // Detección pura: devuelve true si este misil del jugador impacta al enemigo.
  // No modifica ninguna lista; PucaraGestorProyectiles es responsable de la eliminación.
  public boolean hayColisionMisilJugadorConEnemigo(PucaraMisil mis, PucaraEnemigo e) {
    return !mis.esEnemigo() && PApplet.dist(mis.getX(), mis.getY(), e.getX(), e.getY()) < 35;
  }

  public boolean chequearMisilesEnemigosVsPucara(ArrayList<PucaraMisil> misiles, PucaraJugador p) {
    for (PucaraMisil mis : misiles) {
      if (mis.esEnemigo() && PApplet.dist(mis.getX(), mis.getY(), p.getX(), p.getY()) < 35) {
        return true;
      }
    }
    return false;
  }

  public boolean chequearBombasVsPucara(ArrayList<PucaraBomba> bombas, PucaraJugador p) {
    for (PucaraBomba b : bombas) {
      if (b.exploto() && PApplet.dist(p.getX(), p.getY(), b.getX(), b.getY()) < 50) {
        return true;
      }
    }
    return false;
  }

  public boolean hayColisionConPucara(PucaraEnemigo e, PucaraJugador p) {
    return PApplet.dist(p.getX(), p.getY(), e.getX(), e.getY()) < 35;
  }
}
