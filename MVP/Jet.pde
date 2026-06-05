public class Jet extends Enemigo {
  
  Random rand = new Random();
  private int xTarget = rand.nextInt(50, width - 50);
  
  
  Jet(int xPos, int yPos, int velocidad) {
    super(xPos, yPos, velocidad);
    this.imagen = loadImage("jet.png");
  }
  
  public void actualizar() {
    if ((xTarget + abs(velocidad)/2 >= xEnemigo) && (xEnemigo >= xTarget - abs(velocidad)/2)) {
      yEnemigo += abs(velocidad);
    } else {
      xEnemigo += velocidad;
    }
  }
  
  public void dibujar() {
    if (imagen != null) {
      image(imagen, xEnemigo, yEnemigo, 60, 60);
    } else {
      stroke(0);
      fill(0, 255, 0);
      ellipse(xEnemigo, yEnemigo, 40, 40);
      fill(255, 255, 0);
      ellipse(xEnemigo - 10, yEnemigo - 5, 15, 10);
      ellipse(xEnemigo + 10, yEnemigo - 5, 15, 10);
      stroke(255, 0, 0);
      line(xEnemigo + 5, yEnemigo - 5, xEnemigo + 10, yEnemigo + 10);
    }
  }
}
