public class Bomber extends Enemigo {
  
  Bomber(int xPos, int yPos, int velocidad) {
    super(xPos, yPos, velocidad);
    this.imagen = loadImage("bomber.png");
  }
  
  public void actualizar() {
    xEnemigo += velocidad;
  }
  
  public void dibujar() {
    if (imagen != null) {
      image(imagen, xEnemigo, yEnemigo, 60, 60);
    } else {
      stroke(0);
      fill(100, 180, 255);
      triangle(xEnemigo - 35, yEnemigo + 20, xEnemigo, yEnemigo - 20, xEnemigo + 35, yEnemigo + 20);
      fill(255, 0, 0);
      rect(xEnemigo, yEnemigo + 15, 18, 18);
    }
  }
}
