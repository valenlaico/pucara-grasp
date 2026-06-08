public class SistemaColisiones {

  // Detección pura: devuelve true si este misil del jugador impacta al enemigo.
  // No modifica ninguna lista; GestorProyectiles es responsable de la eliminación.
  public boolean hayColisionMisilJugadorConEnemigo(Misil mis, Enemigo e) {
    return !mis.esEnemigo() && dist(mis.getX(), mis.getY(), e.getX(), e.getY()) < 35;
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
