import processing.core.PApplet;
import processing.core.PImage;
import java.util.ArrayList;

public class ModuloPucara implements ModuloJuego {

  private PucaraGameManager gm;
  private PucaraMovimiento  movimiento;
  private PApplet           app;
  private ContextoJuego     ctx;
  private EstadoJuego       estadoActual = new NoIniciadoState();
  private ArrayList<IModuloObserver> observers = new ArrayList<IModuloObserver>();
  private PImage            imagenFondo;

  // ── Metadata ────────────────────────────────────────────────────────────────
  public String getNombreModulo() { return "Pucara"; }
  public String getDescripcion()  { return "FMA IA-58 Pucará — defensa aérea de la base"; }
  public String getNombreAvion()  { return "FMA IA-58 Pucará"; }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  public void inicializarContexto(ContextoJuego ctx) {
    this.ctx = ctx;
  }

  // El lobby llama a iniciar() antes del primer frame.
  // ctx ya fue seteado con las dimensiones de pantalla, así que gameManager
  // puede inicializarse completamente sin necesitar PApplet todavía.
  public void iniciar() throws EstadoInvalidoException {
    estadoActual.iniciar(this);
    estadoActual = new EnEjecucionState();
    movimiento = new PucaraMovimiento();
    gm = new PucaraGameManager(movimiento, ctx.getAnchoPantalla(), ctx.getAltoPantalla());
    notificar(ModuloEvento.Tipo.INICIADO);
  }

  public void pausar() throws EstadoInvalidoException {
    estadoActual.pausar(this);
    estadoActual = new PausadoState();
    if (gm != null && !gm.isPausa()) gm.alternarPausa();
    notificar(ModuloEvento.Tipo.PAUSADO);
  }

  public void reanudar() throws EstadoInvalidoException {
    estadoActual.reanudar(this);
    estadoActual = new EnEjecucionState();
    if (gm != null && gm.isPausa()) gm.alternarPausa();
    notificar(ModuloEvento.Tipo.REANUDADO);
  }

  public void finalizar() throws EstadoInvalidoException {
    estadoActual.finalizar(this);
    estadoActual = new FinalizadoState();
    notificar(ModuloEvento.Tipo.FINALIZADO);
  }

  // ── Game loop (llamado por el lobby cada frame) ───────────────────────────

  public void actualizar(PApplet app) {
    if (this.app == null) {
      this.app = app;
      // El listener AWT se registra una sola vez; captura multi-tecla
      // independientemente del keyPressed() del sketch principal.
      movimiento.registrarListener(app);
    }
    if (gm == null) return;

    boolean eraGameOver = gm.isGameOver();
    gm.update(movimiento.leerTeclado());

    if (eraGameOver && !gm.isGameOver()) {
      // Reinicio con R mientras el módulo estaba pausado (ESC previo durante game over)
      if ("PAUSADO".equals(estadoActual.getNombre())) {
        try { reanudar(); } catch (EstadoInvalidoException e) { /* ignorar */ }
      }
    } else if (gm.isGameOver() && "PAUSADO".equals(estadoActual.getNombre())) {
      // ESC durante game over → volver al lobby
      try { finalizar(); }
      catch (EstadoInvalidoException e) { notificar(ModuloEvento.Tipo.ERROR); }
    }
  }

  public void dibujar(PApplet app) {
    app.pushStyle();
    if (imagenFondo == null) {
      imagenFondo = app.loadImage("pucara_fondo.png");
      if (imagenFondo != null) imagenFondo.resize(app.width, app.height);
    }
    app.imageMode(PApplet.CORNER);
    if (imagenFondo != null) app.image(imagenFondo, 0, 0);
    else                     app.background(0);
    app.strokeWeight(2);
    app.ellipseMode(PApplet.CENTER);
    app.rectMode(PApplet.CENTER);
    app.imageMode(PApplet.CENTER);
    if (gm != null) gm.visual(app);
    app.popStyle();
  }

  // ── Estadísticas ─────────────────────────────────────────────────────────

  public EstadisticasGenerales getEstadisticasGenerales() {
    if (gm == null) {
      return new EstadisticasGenerales(getNombreModulo(), 0, 0, 0, 0, 0, 0L);
    }
    return gm.construirEstadisticas(getNombreModulo());
  }

  // ── Estado y observers ───────────────────────────────────────────────────

  public EstadoJuego getEstado() { return estadoActual; }

  public void agregarObserver(IModuloObserver o)  { observers.add(o); }
  public void removerObserver(IModuloObserver o)  { observers.remove(o); }

  private void notificar(ModuloEvento.Tipo tipo) {
    ModuloEvento evento = new ModuloEvento(tipo, getNombreModulo());
    for (IModuloObserver o : new ArrayList<>(observers)) o.onEventoModulo(evento);
  }

  // ── Reset ────────────────────────────────────────────────────────────────

  // El lobby llama a reset() para permitir jugar de nuevo sin recargar el módulo.
  public void reset() {
    if (movimiento != null) movimiento.deregistrarListener(app);
    if (gm != null) gm.reiniciar();
    estadoActual = new NoIniciadoState();
    app        = null;
    imagenFondo = null;
  }
}
