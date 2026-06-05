import java.util.Random;

gameManager gm;
Movimiento movimiento;

void setup() {
  size(600, 600);
  frameRate = 60;
  background(0);
  ellipseMode(CENTER);
  rectMode(CENTER);
  imageMode(CENTER);

  movimiento = new Movimiento();
  movimiento.registrarListener(this);
  gm = new gameManager(movimiento);
}

void draw() {
  background(0);
  strokeWeight(2);
  EstadoEntrada entrada = movimiento.leerTeclado();
  gm.update(entrada);
  gm.visual();
}
