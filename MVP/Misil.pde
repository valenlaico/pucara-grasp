public class Misil {
  private int xMisil;
  private int yMisil;
  private int velocidad = 5;
  private PImage imagen;
  private boolean misEnemigo;
  
  Misil(int xPos, int yPos, boolean status) {
    this.xMisil = xPos;
    this.yMisil = yPos;
    this.imagen = loadImage("misil.png");
    this.misEnemigo = status;
  }
  
  public int getX() {
    return xMisil;
  }

  public int getY() {
    return yMisil;
  }
  
  public void actualizarMisil() {
    if (misEnemigo) {
      yMisil += velocidad;
    } else {
      yMisil -= velocidad;
    }
  }
  
  public void dibujarMisil() {
    if (imagen != null) {
      image(imagen, xMisil, yMisil, 15, 30);
      } else {
        stroke(255, 0, 0);
        strokeWeight(6);
        line(xMisil, yMisil, xMisil, yMisil + 10);
        strokeWeight(2);
     }
  }
  
  public boolean salioDePantalla() {
    return (yMisil > height + 40) || (yMisil < -40);
  }
  
  public boolean esEnemigo() {
    return misEnemigo;
  }
}
