import processing.core.PApplet;
import java.util.ArrayList;

public class PucaraGameManager {

  private PucaraGestorOleadas     gestorOleadas     = new PucaraGestorOleadas();
  private PucaraGestorProyectiles gestorProyectiles = new PucaraGestorProyectiles();
  private PucaraSistemaColisiones sistemaColisiones = new PucaraSistemaColisiones();
  private PucaraGestorScore       gestorScore       = new PucaraGestorScore();
  private PucaraInterfaz          interfaz          = new PucaraInterfaz();
  private PucaraFabricaEnemigos   fabricaEnemigos;
  private PucaraMovimiento        movimiento;

  private PucaraJugador             p;
  private PucaraBase                base;
  private ArrayList<PucaraEnemigo>  enemigos;

  private int     ancho;
  private int     alto;
  private boolean gameOver      = false;
  private boolean pausa         = false;
  private String  motivoGameOver = "El Pucara fue destruido";

  PucaraGameManager(PucaraMovimiento m, int ancho, int alto) {
    this.movimiento      = m;
    this.ancho           = ancho;
    this.alto            = alto;
    this.fabricaEnemigos = new PucaraFabricaEnemigos(ancho, alto);
    reiniciar();
  }

  public void update(PucaraEstadoEntrada entrada) {
    if (entrada.pausa && !gameOver) alternarPausa();

    if (gameOver) {
      if (entrada.reiniciar) reiniciar();
      return;
    }
    if (pausa) return;

    // 1. Mover pucara
    p.aplicarMovimiento(entrada);
    if (p.salioDePantalla(ancho)) {
      p.cambiarLado(ancho);
    }

    // 2. Disparo del jugador
    if (entrada.disparar) {
      gestorProyectiles.crearMisilJugador(p.getX(), p.getY());
      gestorScore.registrarDisparo();
    }

    // 3. Spawn de enemigos
    String tipoEnemigo = gestorOleadas.update();
    if (tipoEnemigo != null) {
      enemigos.add(fabricaEnemigos.crearEnemigo(tipoEnemigo));
    }

    // 4. Actualizar cada enemigo
    for (int i = enemigos.size() - 1; i >= 0; i--) {
      PucaraEnemigo e = enemigos.get(i);
      e.actualizar();

      if (sistemaColisiones.hayColisionConPucara(e, p)) {
        terminarPartida("Chocaste contra un enemigo");
        return;
      }

      if (gestorProyectiles.eliminarMisilQueGolpeo(sistemaColisiones, e)) {
        enemigos.remove(i);
        gestorScore.registrarImpacto();
        gestorScore.registrarEnemigo();
        gestorScore.sumarPuntos(10);
        gestorOleadas.actualizarDificultad(gestorScore.getScore());
        continue;
      }

      if (e.debeDisparar()) {
        gestorProyectiles.crearMisilEnemigo(e.getX(), e.getY());
      }

      if (e.salioDePantalla(ancho, alto) || e.getY() >= base.getY() - base.getH() / 2) {
        if (base.colisiona(e.getX(), e.getY())) {
          if (base.recibirDanio(25)) {
            terminarPartida("La base fue destruida");
            return;
          }
        }
        if (e.debeLanzarBomba()) {
          int[] pos = e.calcularPosicionBomba();
          gestorProyectiles.crearBomba(pos[0], pos[1]);
        }
        enemigos.remove(i);
      }
    }

    // 5. Mover proyectiles y limpiar los que salieron de pantalla
    gestorProyectiles.update(alto);

    // 6. Misiles enemigos vs pucara
    if (sistemaColisiones.chequearMisilesEnemigosVsPucara(gestorProyectiles.getMisiles(), p)) {
      terminarPartida("Chocaste contra un misil enemigo");
      return;
    }

    // 7. Bombas vs pucara
    if (sistemaColisiones.chequearBombasVsPucara(gestorProyectiles.getBombas(), p)) {
      terminarPartida("Explotaste por una bomba enemiga");
      return;
    }

    // 8. Limpiar bombas explotadas
    gestorProyectiles.limpiarBombasExplotadas();

    // 9. Acumular tiempo
    if (gestorOleadas.getFrames() % 60 == 0) gestorScore.incrementarTiempo();
  }

  public void visual(PApplet app) {
    if (gameOver) {
      interfaz.dibujarGameOver(app, motivoGameOver, gestorScore.getScore(), gestorScore.getPrecision());
      return;
    }
    base.dibujar(app);
    p.dibujarPucara(app);
    for (PucaraEnemigo e : enemigos) e.dibujar(app);
    gestorProyectiles.dibujar(app);
    interfaz.dibujarHUD(app, gestorScore.getScore(), gestorOleadas.getDificultad(),
                        gestorOleadas.getOleada(), gestorOleadas.getFrames());
    if (pausa) interfaz.dibujarPausa(app, gestorScore.getScore(), gestorOleadas.getDificultad());
  }

  // Construye EstadisticasGenerales para el lobby.
  // Pucará no tiene condición de victoria: cada sesión es siempre 1 partida perdida.
  // El lobby acumula el historial entre sesiones con su propio GestorEstadisticas.
  public EstadisticasGenerales construirEstadisticas(String nombreModulo) {
    return new EstadisticasGenerales(
      nombreModulo,
      gestorScore.getScore(),
      1,
      0,
      1,
      gestorScore.getEnemigosDestruidos(),
      (long) gestorScore.getTiempoSegundos()
    );
  }

  private void terminarPartida(String motivo) {
    gameOver       = true;
    motivoGameOver = motivo;
  }

  public void reiniciar() {
    base     = new PucaraBase(ancho, alto, 20, 300);
    p        = new PucaraJugador(300, 500, ancho, alto);
    enemigos = new ArrayList<PucaraEnemigo>();
    gameOver       = false;
    pausa          = false;
    motivoGameOver = "El Pucara fue destruido";
    gestorOleadas.reiniciar();
    gestorProyectiles.reiniciar();
    gestorScore.reiniciar();
    movimiento.resetear();
  }

  public boolean isGameOver() { return gameOver; }
  public boolean isPausa()    { return pausa; }
  public void alternarPausa() { pausa = !pausa; }
}
