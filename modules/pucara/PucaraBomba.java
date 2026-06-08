import processing.core.PApplet;
import processing.core.PImage;

public class PucaraBomba {
  private int    xBomba;
  private int    yBomba;
  private PImage crosshair;
  private PImage imBomba;
  private boolean estaCayendo = false;
  private boolean exploto     = false;
  private int    fc;
  private int    target;

  PucaraBomba(int xPos, int yPos) {
    this.xBomba = xPos;
    this.yBomba = yPos;
    // imágenes se cargan de forma diferida en dibujarBomba()
  }

  public int     getX()    { return xBomba; }
  public int     getY()    { return yBomba; }
  public boolean exploto() { return exploto; }

  public void actualizarBomba() {
    if (fc >= 180 && !estaCayendo) {
      target = yBomba;
      yBomba -= 200;
      estaCayendo = true;
    } else {
      fc += 1;
    }
    if (estaCayendo) {
      if (yBomba >= target) exploto = true;
      else                  yBomba += 10;
    }
  }

  public void dibujarBomba(PApplet app) {
    if (estaCayendo) {
      if (imBomba == null) imBomba = app.loadImage("pucara_bomba.png");
      if (imBomba != null) {
        app.image(imBomba, xBomba, yBomba, 15, 30);
      } else {
        app.stroke(255, 0, 0);
        app.strokeWeight(6);
        app.line(xBomba, yBomba, xBomba, yBomba + 10);
        app.strokeWeight(2);
      }
    } else {
      if (crosshair == null) crosshair = app.loadImage("pucara_crosshair.png");
      if (crosshair != null) {
        app.image(crosshair, xBomba, yBomba, 50, 50);
      } else {
        app.stroke(255, 0, 0);
        app.noFill();
        app.circle(xBomba, yBomba, 50);
        app.strokeWeight(2);
      }
    }
  }
}
