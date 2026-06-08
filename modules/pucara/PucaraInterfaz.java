import processing.core.PApplet;

public class PucaraInterfaz {

  public void dibujarHUD(PApplet app, int score, int dificultad, int oleada, int framesPartida) {
    app.fill(255);
    app.textSize(18);
    app.textAlign(PApplet.LEFT, PApplet.TOP);
    app.text("Score: " + score, 15, 15);
    app.text("Dificultad: " + dificultad, 15, 40);
    if (oleada == 1) {
      app.text("Oleada 1, tiempo restante: "
        + ((120 * 60 - framesPartida) / 60) / 60 + ":"
        + String.format("%02d", ((120 * 60 - framesPartida) / 60) % 60), 15, 65);
    } else if (oleada == 2) {
      app.text("Oleada 2, tiempo restante: "
        + ((270 * 60 - framesPartida) / 60) / 60 + ":"
        + String.format("%02d", ((270 * 60 - framesPartida) / 60) % 60), 15, 65);
    } else {
      app.text("Oleada Final", 15, 65);
    }
    app.textAlign(PApplet.RIGHT, PApplet.TOP);
    app.text("WASD mover | F disparar ", app.width - 15, 15);
  }

  public void dibujarPausa(PApplet app, int score, int dificultad) {
    app.fill(0, 0, 0, 150);
    app.rect(app.width / 2, app.height / 2, app.width + 5, app.height + 5);
    app.fill(255);
    app.textAlign(PApplet.CENTER, PApplet.CENTER);
    app.textSize(42);
    app.text("JUEGO PAUSADO", app.width / 2, app.height / 2 - 50);
    app.textSize(22);
    app.text("Dificultad actual: Un enemigo cada " + dificultad + " frames", app.width / 2, app.height / 2);
    app.text("Score actual: " + score, app.width / 2, app.height / 2 + 35);
    app.textSize(18);
    app.text("Presiona P para despausar", app.width / 2, app.height / 2 + 80);
  }

  public void dibujarGameOver(PApplet app, String motivo, int score, float precision) {
    app.background(50, 0, 0);
    app.fill(255);
    app.textAlign(PApplet.CENTER, PApplet.CENTER);
    app.textSize(42);
    app.text("GAME OVER", app.width / 2, app.height / 2 - 60);
    app.textSize(22);
    app.text(motivo, app.width / 2, app.height / 2 - 15);
    app.text("Score final: " + score, app.width / 2, app.height / 2 + 20);
    app.text("Precisión: " + String.format("%.1f", precision * 100) + "%", app.width / 2, app.height / 2 + 55);
    app.textSize(18);
    app.text("Presiona R para reiniciar", app.width / 2, app.height / 2 + 95);
  }
}
