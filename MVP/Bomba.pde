public class Bomba {
  private int xBomba;
  private int yBomba;
  private PImage crosshair;
  private PImage imBomba;
  private boolean estaCayendo = false;
  private boolean exploto = false;
  private int fc;
  private int target;
  
  Bomba(int xPos, int yPos) {
    this.xBomba = xPos;
    this.yBomba = yPos;
    this.crosshair = loadImage("crosshair.png");;
    this.imBomba = loadImage("bomba.png");
  }
  
  public int getX() {
    return xBomba;
  }

  public int getY() {
    return yBomba;
  }
  
  public boolean exploto() {
    return exploto;
  }
  
  public void actualizarBomba() {
    if (fc >= 180 && !estaCayendo) {
      target = yBomba;
      yBomba -= 200;
      estaCayendo = true;
    } else {
      fc += 1;
    }
    if (estaCayendo) {
      if (target >= yBomba) {
        exploto = true;
      } else {
        yBomba += 10;
      }
    }
  }
  
  public void dibujarBomba() {
    if (estaCayendo) {
      if (imBomba != null) {
        image(imBomba, xBomba, yBomba, 15, 30);
      } else {
        stroke(255, 0, 0);
        strokeWeight(6);
        line(xBomba, yBomba, xBomba, yBomba + 10);
        strokeWeight(2);
      }
    } else {
      if (crosshair != null) {
        image(crosshair, xBomba, yBomba, 50, 50);
      } else {
        stroke(255, 0, 0);
        noFill();
        circle(xBomba, yBomba, 50);
        strokeWeight(2);
      }
    }
  }
}
