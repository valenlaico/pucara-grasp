import java.util.Random;

public class gameManager {
 
  private Random rand = new Random();
  private ArrayList<Enemigo> enemigos;
  private ArrayList<Misil> misiles;
  private ArrayList<Bomba> bombas;
  private Pucara p;
  private Base b;
  private Movimiento movimiento;
  private boolean gameOver = false;
  private boolean pausa = false;
  private int dificultad = 60;
  private int fc = 0;
  private int framesHastaDisparo = 0;
  private int framesPartida = 0;
  private int oleadaActual = 1;
  private String motivoGameOver = "El Pucara fue destruido";
  private int score = 0;
  private int tiempoJugadoSegundos;
  private int misileDisparados = 0;
  private int misilesImpactaron = 0;
  private int enemigosDestruidosEnPartida = 0;
  private StatsManager statsManager;

  gameManager(Movimiento m) {
    this.movimiento = m;
    reiniciar();
    this.statsManager = new StatsManager();
  }

  public void update() {
    framesPartida++;
    if (framesPartida < 120 * 60) {
      oleadaActual = 1;
    } else if (framesPartida < 270 * 60) {
      oleadaActual = 2;
    } else {
      oleadaActual = 3;
    }

    movimiento.aplicarMovimiento(p);

    if (movimiento.consultarYConsumirDisparo()) {
      misiles.add(p.crearMis());
      misileDisparados++;
    }  
    
    if (fc >= dificultad) {
      if (rand.nextInt(2) == 0) {
        if (oleadaActual == 1) {
          enemigos.add(new Jet(-40, rand.nextInt(150, 200), 2));
        } else if (oleadaActual == 2) {
          if (rand.nextInt(100) < 70) {
            enemigos.add(new Jet(-40, rand.nextInt(150, 200), 2));
          } else {
            enemigos.add(new Shooter(-40, rand.nextInt(75, 125), 3));        
          } 
        } else {
          if (rand.nextInt(100) < 50) {
            enemigos.add(new Jet(-40, rand.nextInt(150, 200), 2));
          } else if (rand.nextInt(100) < 60) {
            enemigos.add(new Shooter(-40, rand.nextInt(75, 125), 3));
          } else {
            enemigos.add(new Bomber(-40, rand.nextInt(50), 2));
          }          
        }
      } else {
        if (oleadaActual == 1) {
          enemigos.add(new Jet(width + 40, rand.nextInt(150, 200), -2));
        } else if (oleadaActual == 2) {
          if (rand.nextInt(100) < 70) {
            enemigos.add(new Jet(width + 40, rand.nextInt(150, 200), -2));
          } else {
            enemigos.add(new Shooter(width + 40, rand.nextInt(75, 125), 3));       
          } 
        } else {
          if (rand.nextInt(100) < 50) {
            enemigos.add(new Jet(width + 40, rand.nextInt(150, 200), -2));
          } else if (rand.nextInt(100) < 60) {
            enemigos.add(new Shooter(width + 40, rand.nextInt(75, 125), 3));
          } else {
            enemigos.add(new Bomber(width + 40, rand.nextInt(50), -2));
          }          
        }
      }
      fc = 0;
    } else {
      fc += 1;
    }

    if (enemigos.isEmpty() == false) {
      for (int i = enemigos.size() - 1; i >= 0; i--) {
        Enemigo e = enemigos.get(i);
        e.actualizar();

        if (dist(p.getX(), p.getY(), e.getX(), e.getY()) < 35) {
          terminarPartida("Chocaste contra un enemigo");
          return;
        }

        boolean enemigoEliminado = false;
        for (int j = misiles.size() - 1; j >= 0; j--) {
          Misil mis = misiles.get(j);
          if (dist(mis.getX(), mis.getY(), e.getX(), e.getY()) < 35 && !mis.esEnemigo()) {
            enemigos.remove(i);
            misiles.remove(j);
            score += 10;
            if (score % 100 == 0 && dificultad > 10) {
              dificultad -= 5;
            }
            misilesImpactaron++;
            enemigosDestruidosEnPartida++;
            enemigoEliminado = true;
            break;
          }
        }

        if (enemigoEliminado) continue;

        if (e instanceof Shooter) {
          Shooter s = (Shooter) e;
          if (framesHastaDisparo >= 90) {
            misiles.add(s.crearMis());
            framesHastaDisparo = 0;
          } else {
            framesHastaDisparo += 1;
          }
        }

        if (e.salioDePantalla() || e.getY() >= b.getY() - b.getH() / 2) {
          if (b.colisiona(e.getX(), e.getY())) {
            if (b.recibirDanio(25)) {
              terminarPartida("La base fue destruida");
              return;
            }
          }
          if (e instanceof Bomber) {
            bombas.add(new Bomba(rand.nextInt(50, width - 50), rand.nextInt(height - 150, height - 50)));
          }
          enemigos.remove(i);
        }
      }
    }

    if (misiles.isEmpty() == false) {
      for (int i = misiles.size() - 1; i >= 0; i--) {
        Misil mis = misiles.get(i);
        mis.actualizarMisil();
        if (dist(mis.getX(), mis.getY(), p.getX(), p.getY()) < 35 && mis.esEnemigo()) {
          terminarPartida("Chocaste contra un misil enemigo");
          return;
        }
        if (mis.salioDePantalla()) {
          misiles.remove(i);
        }
      }
    }

    if (bombas.isEmpty() == false) {
      for (int i = bombas.size() - 1; i >= 0; i--) {
        Bomba b = bombas.get(i);
        b.actualizarBomba();
        if (b.exploto()) {
          if (dist(p.getX(), p.getY(), b.getX(), b.getY()) < 50) {
            terminarPartida("Explotaste por una bomba enemiga");
            return;
          }
          bombas.remove(i);
        }
      }
    }
  }

  public void visual() {
    b.dibujar();
    p.dibujarPucara();
    if (enemigos.isEmpty() == false) {
      for (Enemigo e : enemigos) e.dibujar();
    }
    if (misiles.isEmpty() == false) {
      for (Misil mis : misiles) mis.dibujarMisil();
    }
    if (bombas.isEmpty() == false) {
      for (Bomba b : bombas) b.dibujarBomba();
    }
    fill(255);
    textSize(18);
    textAlign(LEFT, TOP);
    text("Score: " + score, 15, 15);
    text("Dificultad: " + dificultad, 15, 40);
    if (oleadaActual == 1) {
      text("Oleada 1, tiempo restante: " + ((120 * 60 - framesPartida) / 60) / 60 + ":" + nf(((120 * 60 - framesPartida) / 60) % 60, 2), 15, 65);
    } else if (oleadaActual == 2) {
      text("Oleada 2, tiempo restante: " + ((270 * 60 - framesPartida) / 60) / 60 + ":" + nf(((270 * 60 - framesPartida) / 60) % 60, 2), 15, 65);
    } else {
      text("Oleada Final", 15, 65);
    }
    textAlign(RIGHT, TOP);
    text("WASD mover | F disparar ", width - 15, 15);
  }

  private void terminarPartida(String motivo) {
    gameOver = true;
    motivoGameOver = motivo;
    tiempoJugadoSegundos = framesPartida / 60;
    float precision = misileDisparados > 0 ? (float) misilesImpactaron / (float) misileDisparados : 0.0f;
    statsManager.guardar(score, tiempoJugadoSegundos, enemigosDestruidosEnPartida, precision);
  }
  
  public void reiniciar() {
    b = new Base(20, 300);
    p = new Pucara(300, 500);
    enemigos  = new ArrayList<Enemigo>();
    misiles   = new ArrayList<Misil>();
    bombas    = new ArrayList<Bomba>();
    gameOver  = false;
    pausa     = false;
    fc = 0;
    framesHastaDisparo = 0;
    framesPartida = 0;
    oleadaActual  = 1;
    dificultad    = 60;
    score         = 0;
    motivoGameOver = "El Pucara fue destruido";
    misileDisparados = 0;
    misilesImpactaron = 0;
    enemigosDestruidosEnPartida = 0;
    movimiento.resetear();
  }
  
  public boolean isGameOver() { return gameOver; }
  public boolean isPausa()    { return pausa; }
  
  public void alternarPausa() { 
    this.pausa = !this.pausa; 
  }
  
  public void drawGameOver() {
    background(50, 0, 0);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(42);
    text("GAME OVER", width / 2, height / 2 - 50);
    textSize(22);
    text(motivoGameOver, width / 2, height / 2);
    text("Score final: " + score, width / 2, height / 2 + 35);
    textSize(18);
    text("Presiona R para reiniciar", width / 2, height / 2 + 80);
  }
  
  public void drawPausa() {
    fill(0, 0, 0, 150);
    rect(width / 2, height / 2, width + 5, height + 5);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(42);
    text("JUEGO PAUSADO", width / 2, height / 2 - 50);
    textSize(22);
    text("Dificultad actual: Un enemigo cada " + dificultad + " frames", width / 2, height / 2);
    text("Score actual: " + score, width / 2, height / 2 + 35);
    textSize(18);
    text("Presiona P para despausar", width / 2, height / 2 + 80);
  }
}
