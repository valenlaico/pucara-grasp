import java.util.Random;

public class GestorProyectiles {
  private ArrayList<Misil> misiles = new ArrayList<Misil>();
  private ArrayList<Bomba>  bombas = new ArrayList<Bomba>();
  private Random rand = new Random();

  public void crearMisilJugador(int x, int y) {
    misiles.add(new Misil(x, y - 30, false));
  }

  public void crearMisilEnemigo(int x, int y) {
    misiles.add(new Misil(x, y + 20, true));
  }

  public void crearBomba() {
    bombas.add(new Bomba(rand.nextInt(50, width - 50), rand.nextInt(height - 150, height - 50)));
  }

  public void update() {
    for (int i = misiles.size() - 1; i >= 0; i--) {
      misiles.get(i).actualizarMisil();
      if (misiles.get(i).salioDePantalla()) misiles.remove(i);
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

  public void dibujar() {
    for (Misil mis : misiles) mis.dibujarMisil();
    for (Bomba  b  : bombas)  b.dibujarBomba();
  }

  public ArrayList<Misil> getMisiles() { return misiles; }
  public ArrayList<Bomba>  getBombas() { return bombas; }

  public void reiniciar() {
    misiles.clear();
    bombas.clear();
  }
}
