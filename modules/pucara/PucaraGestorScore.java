public class PucaraGestorScore {
  private int score              = 0;
  private int misileDisparados   = 0;
  private int misilesImpactaron  = 0;
  private int enemigosDestruidos = 0;
  private int tiempoSegundos     = 0;

  public void registrarDisparo()  { misileDisparados++; }
  public void registrarImpacto()  { misilesImpactaron++; }
  public void registrarEnemigo()  { enemigosDestruidos++; }
  public void incrementarTiempo() { tiempoSegundos++; }

  public void sumarPuntos(int cantidad) { score += cantidad; }

  public int   getScore()              { return score; }
  public int   getMisileDisparados()   { return misileDisparados; }
  public int   getEnemigosDestruidos() { return enemigosDestruidos; }
  public int   getTiempoSegundos()     { return tiempoSegundos; }

  public float getPrecision() {
    return misileDisparados > 0 ? (float) misilesImpactaron / misileDisparados : 0.0f;
  }

  public void reiniciar() {
    score              = 0;
    misileDisparados   = 0;
    misilesImpactaron  = 0;
    enemigosDestruidos = 0;
    tiempoSegundos     = 0;
  }
}
