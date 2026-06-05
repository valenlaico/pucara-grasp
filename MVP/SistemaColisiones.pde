public class SistemaColisiones {

  // Verifica si un misil del jugador impacto este enemigo.
  // Si hay impacto, elimina el misil de la lista y devuelve true.
  public boolean chequearMisilJugadorVsEnemigo(ArrayList<Misil> misiles, Enemigo e) {
    for (int j = misiles.size() - 1; j >= 0; j--) {
      Misil mis = misiles.get(j);
      if (!mis.esEnemigo() && dist(mis.getX(), mis.getY(), e.getX(), e.getY()) < 35) {
        misiles.remove(j);
        return true;
      }
    }
    return false;
  }

  // Devuelve true si algun misil enemigo impacto la pucara.
  public boolean chequearMisilesEnemigosVsPucara(ArrayList<Misil> misiles, Pucara p) {
    for (Misil mis : misiles) {
      if (mis.esEnemigo() && dist(mis.getX(), mis.getY(), p.getX(), p.getY()) < 35) {
        return true;
      }
    }
    return false;
  }

  // Devuelve true si alguna bomba explotada esta cerca de la pucara.
  public boolean chequearBombasVsPucara(ArrayList<Bomba> bombas, Pucara p) {
    for (Bomba b : bombas) {
      if (b.exploto() && dist(p.getX(), p.getY(), b.getX(), b.getY()) < 50) {
        return true;
      }
    }
    return false;
  }

  // Devuelve true si el enemigo colisiono con la pucara.
  public boolean hayColisionConPucara(Enemigo e, Pucara p) {
    return dist(p.getX(), p.getY(), e.getX(), e.getY()) < 35;
  }
}
