public class Pucara {
  private int xPucara;
  private int yPucara;
  private int velocidad = 3;
  private PImage imagen;
  
  Pucara(int xPos, int yPos) {
    this.xPucara = xPos;
    this.yPucara = yPos;
    this.imagen = loadImage("pucara.png");
  }
  
  public int getX() {
    return xPucara;
  }

  public int getY() {
    return yPucara;
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
  
  public void moverIzq() {
    if (xPucara - 30 > 0) {
      xPucara -= velocidad;
    }
  }
  
  public void moverDer() {
    if (xPucara + 30 < width) {
      xPucara += velocidad;
    }
  }
  
  public void moverAba() {
    if (yPucara + 30 < height - 40) {
      yPucara += velocidad;
    }
  }
  
  public void moverArr() {
    if (yPucara - 30 > 0) {
      yPucara -= velocidad;
    }
  }
  
  public Misil crearMis() {
    return new Misil(xPucara, yPucara - 30, false);
  }
}
