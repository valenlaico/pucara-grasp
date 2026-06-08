public class PucaraEstadoEntrada {
  boolean moverIzq;
  boolean moverDer;
  boolean moverArr;
  boolean moverAba;
  boolean disparar;
  boolean pausa;
  boolean reiniciar;

  PucaraEstadoEntrada(boolean moverIzq, boolean moverDer, boolean moverArr, boolean moverAba,
                      boolean disparar, boolean pausa, boolean reiniciar) {
    this.moverIzq  = moverIzq;
    this.moverDer  = moverDer;
    this.moverArr  = moverArr;
    this.moverAba  = moverAba;
    this.disparar  = disparar;
    this.pausa     = pausa;
    this.reiniciar = reiniciar;
  }
}
