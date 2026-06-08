import processing.core.PApplet;

public class PucaraBase {
  private int x, y, w, h;
  private int vidaMax, vida;
  private boolean destruida;

  // ancho y alto reemplazan los globales width/height de Processing
  PucaraBase(int ancho, int alto, int altura, int vidaMaxima) {
    this.w       = ancho;
    this.h       = altura;
    this.x       = ancho / 2;
    this.y       = alto - altura / 2;
    this.vidaMax = vidaMaxima;
    this.vida    = vidaMaxima;
    this.destruida = false;
  }

  public boolean colisiona(float px, float py) {
    return (px >= 0 && px <= w && py >= y - h / 2 && py <= y + h / 2);
  }

  public boolean recibirDanio(int danio) {
    if (destruida) return false;
    vida -= danio;
    if (vida <= 0) { vida = 0; destruida = true; }
    return destruida;
  }

  public boolean estaDestruida() { return destruida; }
  public int getY() { return y; }
  public int getH() { return h; }

  public void reiniciar() { vida = vidaMax; destruida = false; }

  public void dibujar(PApplet app) {
    if (!destruida) {
      app.stroke(0, 200, 255);
      app.fill(0, 80, 120);
    } else {
      app.stroke(100);
      app.fill(40);
    }
    app.strokeWeight(2);
    app.rect(x, y, w, h);

    if (!destruida) {
      float pct  = (float) vida / vidaMax;
      int barW   = w - 20, barH = 8;
      int barX   = x, barY = y - h / 2 - 10;
      app.noStroke();
      app.fill(60);
      app.rect(barX, barY, barW, barH);
      app.fill(pct > 0.5f ? app.color(0,220,80) : pct > 0.25f ? app.color(255,180,0) : app.color(220,30,30));
      app.rect(barX - barW/2 + (barW*pct)/2, barY, barW*pct, barH);
      app.stroke(180); app.strokeWeight(1); app.noFill();
      app.rect(barX, barY, barW, barH);
      app.fill(255); app.noStroke(); app.textSize(11); app.textAlign(PApplet.CENTER, PApplet.CENTER);
      app.text("BASE  " + vida + " / " + vidaMax, barX, barY);
    } else {
      app.fill(150,50,50); app.noStroke(); app.textSize(14); app.textAlign(PApplet.CENTER, PApplet.CENTER);
      app.text("BASE DESTRUIDA", x, y);
    }
  }
}
