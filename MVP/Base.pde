public class Base {
  private int x, y, w, h;
  private int vidaMax, vida;
  private boolean destruida;

  Base(int altura, int vidaMaxima) {
    this.w = width;
    this.h = altura;
    this.x = width / 2;
    this.y = height - altura / 2;
    this.vidaMax = vidaMaxima;
    this.vida = vidaMaxima;
    this.destruida = false;
  }

  public boolean colisiona(float px, float py) {
    return (px >= 0 && px <= width && py >= y - h / 2 && py <= y + h / 2);
  }

  public boolean recibirDanio(int danio) {
    if (destruida) return false;
    vida -= danio;
    if (vida <= 0) { vida = 0; destruida = true; }
    return destruida;
  }

  public boolean estaDestruida() { 
    return destruida; 
  }
  public int getY() {
    return y;
  }
  public int getH() {
    return h; 
  }
  public void reiniciar() {
    vida = vidaMax; 
    destruida = false; 
  }

  public void dibujar() {
    if (!destruida) { 
      stroke(0, 200, 255); 
      fill(0, 80, 120); 
    } else { 
      stroke(100);      
      fill(40);
    }
    strokeWeight(2);
    rect(x, y, w, h);

    if (!destruida) {
      float pct = (float) vida / vidaMax;
      int barW = width - 20, barH = 8;
      int barX = width / 2, barY = y - h / 2 - 10;
      noStroke(); fill(60);
      rect(barX, barY, barW, barH);
      fill(pct > 0.5 ? color(0,220,80) : pct > 0.25 ? color(255,180,0) : color(220,30,30));
      rect(barX - barW/2 + (barW*pct)/2, barY, barW*pct, barH);
      stroke(180); strokeWeight(1); noFill();
      rect(barX, barY, barW, barH);
      fill(255); noStroke(); textSize(11); textAlign(CENTER, CENTER);
      text("BASE  " + vida + " / " + vidaMax, barX, barY);
    } else {
      fill(150,50,50); noStroke(); textSize(14); textAlign(CENTER,CENTER);
      text("BASE DESTRUIDA", x, y);
    }
  }
}
