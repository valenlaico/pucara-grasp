public class Pucara {
  private int xPucara;
  private int yPucara;
  private int velocidad = 3;
  private PImage imagen;

  Pucara(int xPos, int yPos) {
    this.xPucara = xPos;
    this.yPucara = yPos;
    this.imagen  = loadImage("pucara.png");
  }

  public int getX() { return xPucara; }
  public int getY() { return yPucara; }

  public void aplicarMovimiento(EstadoEntrada entrada) {
    if (entrada.moverIzq && xPucara - 30 > 0)          xPucara -= velocidad;
    if (entrada.moverDer && xPucara + 30 < width)       xPucara += velocidad;
    if (entrada.moverArr && yPucara - 30 > 0)           yPucara -= velocidad;
    if (entrada.moverAba && yPucara + 30 < height - 40) yPucara += velocidad;
  }

  public void dibujarPucara() {
    if (imagen != null) {
      image(imagen, xPucara, yPucara, 60, 60);
    } else {
      stroke(255);
      fill(0, 255, 0);
      triangle(xPucara - 20, yPucara + 40, xPucara, yPucara, xPucara + 20, yPucara + 40);
    }
  }
}
