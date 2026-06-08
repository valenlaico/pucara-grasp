import processing.core.PApplet;
import java.util.ArrayList;

public class PucaraGestorProyectiles {
  private ArrayList<PucaraMisil> misiles = new ArrayList<PucaraMisil>();
  private ArrayList<PucaraBomba> bombas  = new ArrayList<PucaraBomba>();

  public void crearMisilJugador(int x, int y) {
    misiles.add(new PucaraMisil(x, y - 30, false));
  }

  public void crearMisilEnemigo(int x, int y) {
    misiles.add(new PucaraMisil(x, y + 20, true));
  }

  public void crearBomba(int x, int y) {
    bombas.add(new PucaraBomba(x, y));
  }

  // PucaraSistemaColisiones solo detecta; PucaraGestorProyectiles decide qué eliminar.
  public boolean eliminarMisilQueGolpeo(PucaraSistemaColisiones sc, PucaraEnemigo e) {
    for (int j = misiles.size() - 1; j >= 0; j--) {
      if (sc.hayColisionMisilJugadorConEnemigo(misiles.get(j), e)) {
        misiles.remove(j);
        return true;
      }
    }
    return false;
  }

  public void update(int alto) {
    for (int i = misiles.size() - 1; i >= 0; i--) {
      misiles.get(i).actualizarMisil();
      if (misiles.get(i).salioDePantalla(alto)) misiles.remove(i);
    }
    for (int i = bombas.size() - 1; i >= 0; i--) {
      bombas.get(i).actualizarBomba();
    }
  }

  public void limpiarBombasExplotadas() {
    for (int i = bombas.size() - 1; i >= 0; i--) {
      if (bombas.get(i).exploto()) bombas.remove(i);
    }
  }

  public void dibujar(PApplet app) {
    for (PucaraMisil mis : misiles) mis.dibujarMisil(app);
    for (PucaraBomba b   : bombas)  b.dibujarBomba(app);
  }

  public ArrayList<PucaraMisil> getMisiles() { return misiles; }
  public ArrayList<PucaraBomba> getBombas()  { return bombas; }

  public void reiniciar() {
    misiles.clear();
    bombas.clear();
  }
}
