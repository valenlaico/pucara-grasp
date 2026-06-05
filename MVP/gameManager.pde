public class gameManager {

  private GestorOleadas     gestorOleadas     = new GestorOleadas();
  private FabricaEnemigos   fabricaEnemigos   = new FabricaEnemigos();
  private GestorProyectiles gestorProyectiles = new GestorProyectiles();
  private SistemaColisiones sistemaColisiones = new SistemaColisiones();
  private GestorScore       gestorScore       = new GestorScore();
  private Interfaz          interfaz          = new Interfaz();
  private StatsManager      statsManager;
  private Movimiento        movimiento;

  private Pucara             p;
  private Base               base;
  private ArrayList<Enemigo> enemigos;

  private boolean gameOver      = false;
  private boolean pausa         = false;
  private String motivoGameOver = "El Pucara fue destruido";

  gameManager(Movimiento m) {
    this.movimiento   = m;
    this.statsManager = new StatsManager();
    reiniciar();
  }

  public void update(EstadoEntrada entrada) {
    if (entrada.pausa && !gameOver) alternarPausa();

    if (gameOver) {
      if (entrada.reiniciar) reiniciar();
      return;
    }
    if (pausa) return;

    // 1. Mover pucara
    p.aplicarMovimiento(entrada);

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

    // 4. Actualizar cada enemigo: movimiento, colision con pucara,
    //    impacto de misil, disparo Shooter, salida de pantalla / base
    for (int i = enemigos.size() - 1; i >= 0; i--) {
      Enemigo e = enemigos.get(i);
      e.actualizar();

      if (sistemaColisiones.hayColisionConPucara(e, p)) {
        terminarPartida("Chocaste contra un enemigo");
        return;
      }

      if (sistemaColisiones.chequearMisilJugadorVsEnemigo(gestorProyectiles.getMisiles(), e)) {
        enemigos.remove(i);
        gestorScore.registrarImpacto();
        gestorScore.registrarEnemigo();
        gestorScore.sumarPuntos(10);
        gestorOleadas.actualizarDificultad(gestorScore.getScore());
        continue;
      }

      if (e instanceof Shooter) {
        if (((Shooter) e).debeDisparar()) {
          gestorProyectiles.crearMisilEnemigo(e.getX(), e.getY());
        }
      }

      if (e.salioDePantalla() || e.getY() >= base.getY() - base.getH() / 2) {
        if (base.colisiona(e.getX(), e.getY())) {
          if (base.recibirDanio(25)) {
            terminarPartida("La base fue destruida");
            return;
          }
        }
        if (e instanceof Bomber) {
          gestorProyectiles.crearBomba();
        }
        enemigos.remove(i);
      }
    }

    // 5. Mover proyectiles y limpiar los que salieron de pantalla
    gestorProyectiles.update();

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

    // 9. Acumular tiempo (cada 60 frames = 1 segundo)
    if (gestorOleadas.getFrames() % 60 == 0) gestorScore.incrementarTiempo();
  }

  public void visual() {
    if (gameOver) {
      interfaz.dibujarGameOver(motivoGameOver, gestorScore.getScore());
      return;
    }
    base.dibujar();
    p.dibujarPucara();
    for (Enemigo e : enemigos) e.dibujar();
    gestorProyectiles.dibujar();
    interfaz.dibujarHUD(gestorScore.getScore(), gestorOleadas.getDificultad(),
                        gestorOleadas.getOleada(), gestorOleadas.getFrames());
    if (pausa) interfaz.dibujarPausa(gestorScore.getScore(), gestorOleadas.getDificultad());
  }

  private void terminarPartida(String motivo) {
    gameOver      = true;
    motivoGameOver = motivo;
    statsManager.guardar(
      gestorScore.getScore(),
      gestorScore.getTiempoSegundos(),
      gestorScore.getEnemigosDestruidos(),
      gestorScore.getPrecision()
    );
  }

  public void reiniciar() {
    base     = new Base(20, 300);
    p        = new Pucara(300, 500);
    enemigos = new ArrayList<Enemigo>();
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
