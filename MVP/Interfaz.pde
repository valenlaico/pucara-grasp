public class Interfaz {

  public void dibujarHUD(int score, int dificultad, int oleada, int framesPartida) {
    fill(255);
    textSize(18);
    textAlign(LEFT, TOP);
    text("Score: " + score, 15, 15);
    text("Dificultad: " + dificultad, 15, 40);
    if (oleada == 1) {
      text("Oleada 1, tiempo restante: " + ((120 * 60 - framesPartida) / 60) / 60 + ":" + nf(((120 * 60 - framesPartida) / 60) % 60, 2), 15, 65);
    } else if (oleada == 2) {
      text("Oleada 2, tiempo restante: " + ((270 * 60 - framesPartida) / 60) / 60 + ":" + nf(((270 * 60 - framesPartida) / 60) % 60, 2), 15, 65);
    } else {
      text("Oleada Final", 15, 65);
    }
    textAlign(RIGHT, TOP);
    text("WASD mover | F disparar ", width - 15, 15);
  }

  public void dibujarPausa(int score, int dificultad) {
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

  public void dibujarGameOver(String motivo, int score) {
    background(50, 0, 0);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(42);
    text("GAME OVER", width / 2, height / 2 - 50);
    textSize(22);
    text(motivo, width / 2, height / 2);
    text("Score final: " + score, width / 2, height / 2 + 35);
    textSize(18);
    text("Presiona R para reiniciar", width / 2, height / 2 + 80);
  }
}
