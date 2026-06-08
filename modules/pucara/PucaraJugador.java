import processing.core.PApplet;
import processing.core.PImage;

public class PucaraJugador {
  private int    xPucara;
  private int    yPucara;
  private int    velocidad = 5;
  private PImage imagen;
  private int    ancho;
  private int    alto;

  PucaraJugador(int xPos, int yPos, int ancho, int alto) {
    this.xPucara = xPos;
    this.yPucara = yPos;
    this.ancho   = ancho;
    this.alto    = alto;
    // imagen se carga de forma diferida en dibujarPucara()
  }

  public int getX() { return xPucara; }
  public int getY() { return yPucara; }

  public void aplicarMovimiento(PucaraEstadoEntrada entrada) {
    if (entrada.moverIzq && xPucara - 30 > 0)              xPucara -= velocidad;
    if (entrada.moverDer && xPucara + 30 < ancho)          xPucara += velocidad;
    if (entrada.moverArr && yPucara - 30 > 0)              yPucara -= velocidad;
    if (entrada.moverAba && yPucara + 30 < alto - 40)      yPucara += velocidad;
  }

  public void dibujarPucara(PApplet app) {
    if (imagen == null) {
      imagen = app.loadImage("pucara_avion.png");
      if (imagen != null) imagen.resize(60, 60);
    }
    if (imagen != null) {
      app.image(imagen, xPucara, yPucara);
    } else {
      app.stroke(255);
      app.fill(0, 255, 0);
      app.triangle(xPucara - 20, yPucara + 40, xPucara, yPucara, xPucara + 20, yPucara + 40);
    }
  }
}
