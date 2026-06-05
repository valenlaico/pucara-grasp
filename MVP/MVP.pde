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
  movimiento.leerTeclado(gm);
  
  if (!gm.isGameOver() && !gm.isPausa()) {
    gm.update();
    gm.visual();
  } else if (gm.isPausa()) {
    gm.visual();
    gm.drawPausa();
  } else {
    gm.drawGameOver();
  }
}
