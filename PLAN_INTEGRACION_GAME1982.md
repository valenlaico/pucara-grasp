# Integración: Módulo Pucará → Game1982

---

## Si conocías el código antes de la integración

El juego sigue siendo exactamente el mismo. Todos los actores (`Jet`, `Shooter`, `Bomber`, `Pucara`, `Base`, `Misil`, `Bomba`), todos los gestores (`GestorProyectiles`, `SistemaColisiones`, `GestorOleadas`, `GestorScore`), y toda la lógica GRASP que ya aplicamos están intactos en `modules/pucara/`. Lo único que cambió fue la capa de "enchufe" con el framework y tres cuestiones técnicas de migración.

---

## Resumen ejecutivo: qué cambió y por qué

### 1. Hay una clase nueva: `ModuloPucara` (la única novedad real)

Antes, el punto de entrada era `MVP.pde` con su `setup()` y `draw()`. El framework Game1982 no sabe lo que es un `setup()`: él espera una clase que implemente la interfaz `ModuloJuego` con métodos como `iniciar()`, `pausar()`, `actualizar(app)`, `dibujar(app)`.

`ModuloPucara` es esa clase. No tiene lógica de juego propia; solo traduce los llamados del lobby a llamados sobre `PucaraGameManager`.

```
Antes:  MVP.pde ──────────────────────► gameManager
After:  Lobby ──► ModuloPucara ────────► PucaraGameManager
```

**GRASP — Controller + Creator + Indirection:**
- Es el Controller que recibe eventos externos (start, pause, resume) y los delega.
- Es el Creator de `PucaraMovimiento` y `PucaraGameManager`.
- Es la capa de Indirection entre el lobby y el juego: el lobby no sabe que existe un `gameManager`.

---

### 2. Todos los nombres llevan prefijo `Pucara`

El framework junta los `.java` de todos los módulos en una sola carpeta para que Processing los compile juntos. Si el módulo Skyhawk también tiene una clase `Enemigo` o `Base`, el compilador se rompe.

```
gameManager       →  PucaraGameManager
Enemigo           →  PucaraEnemigo
Jet               →  PucaraJet
Shooter           →  PucaraShooter
Bomber            →  PucaraBomber
Pucara (el avión) →  PucaraJugador
Base              →  PucaraBase
Misil             →  PucaraMisil
Bomba             →  PucaraBomba
Movimiento        →  PucaraMovimiento
EstadoEntrada     →  PucaraEstadoEntrada
GestorOleadas     →  PucaraGestorOleadas
FabricaEnemigos   →  PucaraFabricaEnemigos
GestorProyectiles →  PucaraGestorProyectiles
SistemaColisiones →  PucaraSistemaColisiones
GestorScore       →  PucaraGestorScore
Interfaz          →  PucaraInterfaz
```

La lógica interna de cada clase es idéntica. Es un renombrado mecánico.

---

### 3. Los `.pde` se convierten a `.java` y reciben `PApplet app` en los métodos de dibujo

En un archivo `.pde` dentro del sketch de Processing, funciones como `image()`, `rect()`, `fill()`, `dist()` están disponibles globalmente porque el archivo compila dentro de la clase del sketch. En un `.java` externo (que es lo que el módulo necesita), ese acceso implícito no existe.

La solución fue pasar explícitamente `PApplet app` a todos los métodos que dibujan:

```java
// Antes (en .pde):
public void dibujar() {
    image(imagen, x, y, 60, 60);   // acceso implícito al sketch
}

// Después (en .java):
public void dibujar(PApplet app) {
    app.image(imagen, x, y, 60, 60);  // acceso explícito
}
```

La cadena de llamados queda: `ModuloPucara.dibujar(app)` → `PucaraGameManager.visual(app)` → cada entidad recibe `app`.

**GRASP — Low Coupling:** en vez de depender del sketch globalmente (un acoplamiento implícito e invisible), cada clase declara exactamente lo que necesita. El acoplamiento queda localizado y explícito.

---

### 4. `loadImage()` se hace diferida (primer frame en lugar del constructor)

En los constructores de `Jet`, `Shooter`, `Bomber`, `Misil`, etc. había llamadas a `loadImage()`. Eso funciona en un sketch porque Processing tiene el contexto gráfico listo en `setup()`. En un módulo externo, el constructor corre antes de que el módulo haya recibido el `PApplet`, así que `loadImage()` fallaría.

La solución es cargarlo en el primer `dibujar(app)`:

```java
// Antes (constructor):
this.imagen = loadImage("jet.png");

// Después (primer frame de dibujar):
public void dibujar(PApplet app) {
    if (imagen == null) imagen = app.loadImage("pucara_jet.png");
    ...
}
```

No cambia el comportamiento: el fallback de dibujo sin imagen ya existía en todos los casos.

---

### 5. Los globals `width` y `height` se reemplazan con dimensiones explícitas

En un `.pde`, `width` y `height` son globales del sketch. En un `.java` externo no existen.

**Fuente de los valores:** `ModuloPucara` recibe un `ContextoJuego` del lobby antes de iniciar, que contiene `getAnchoPantalla()` y `getAltoPantalla()`. Esos valores se pasan al constructor de `PucaraGameManager`:

```java
// En ModuloPucara.iniciar():
gm = new PucaraGameManager(movimiento, ctx.getAnchoPantalla(), ctx.getAltoPantalla());
```

`PucaraGameManager` los almacena como `ancho` y `alto`, y los pasa a donde se necesitan:
- `new PucaraBase(ancho, alto, 20, 300)` — la base necesita saber dónde está el fondo
- `new PucaraJugador(300, 500, ancho, alto)` — para chequear los límites de movimiento
- `new PucaraFabricaEnemigos(ancho, alto)` — para saber desde dónde entrar en pantalla
- `e.salioDePantalla(ancho, alto)` — para chequear si el enemigo salió
- `gestorProyectiles.update(alto)` — para chequear si el misil salió por arriba o abajo

En los métodos de dibujo, `app.width` y `app.height` son equivalentes directos.

---

### 6. `dist()` se reemplaza con `PApplet.dist()`

`dist()` en Processing es un método de instancia del sketch. En Java puro es un método **estático** de `PApplet`. Cambio de una línea en `PucaraSistemaColisiones`:

```java
// Antes:
dist(mis.getX(), mis.getY(), e.getX(), e.getY()) < 35

// Después:
PApplet.dist(mis.getX(), mis.getY(), e.getX(), e.getY()) < 35
```

---

### 7. `nf()` se reemplaza con `String.format()`

`nf()` es una función de Processing para formatear números con relleno. No existe en Java estándar.

```java
// Antes:
nf(segundos % 60, 2)           // rellena con ceros hasta 2 dígitos
nf(precision * 100, 0, 1)      // 1 decimal

// Después:
String.format("%02d", segundos % 60)
String.format("%.1f", precision * 100)
```

---

### 8. `StatsManager` se elimina

`StatsManager` persistía las partidas en un `stats.json` local. En el módulo integrado, esa responsabilidad ya la tiene el `GestorEstadisticas` del lobby: él llama a `getEstadisticasGenerales()` cuando quiere guardar y acumula el historial entre sesiones.

Mantener dos sistemas de persistencia paralelos duplicaría una responsabilidad que otro experto ya tiene.

**GRASP — Information Expert:** el lobby es el experto en persistir estadísticas de múltiples módulos. El módulo solo necesita saber reportar sus datos de la partida actual.

`PucaraGameManager` tiene ahora un método `construirEstadisticas()` que crea un `EstadisticasGenerales` a partir de `PucaraGestorScore`:

```java
public EstadisticasGenerales construirEstadisticas(String nombreModulo) {
    return new EstadisticasGenerales(
        nombreModulo,
        gestorScore.getScore(),
        1,   // partidasJugadas — el lobby acumula entre sesiones
        0,   // partidasGanadas — Pucará no tiene condición de victoria
        1,   // partidasPerdidas — el juego siempre termina en game over
        gestorScore.getEnemigosDestruidos(),
        (long) gestorScore.getTiempoSegundos()
    );
}
```

---

### 9. `MVP.pde` desaparece

`MVP.pde` tenía `setup()` y `draw()`. Esas responsabilidades pasan a `ModuloPucara`:

| `MVP.pde` | `ModuloPucara` |
|---|---|
| `setup()` — crear movimiento y gameManager | `iniciar()` — mismo código |
| `draw()` — leer teclado, update, visual | `actualizar()` + `dibujar()` |
| `movimiento.registrarListener(this)` | Se llama en el primer frame de `actualizar()` |

---

### 10. La máquina de estados del lobby (detalle de implementación)

El contrato `ModuloJuego` exige que el módulo maneje su propio estado con las clases de `contracts/`: `NoIniciadoState`, `EnEjecucionState`, `PausadoState`, `FinalizadoState`, etc.

Estas clases son **validadores**: si el lobby llama a `pausar()` cuando el módulo ya está pausado, la clase lanza `EstadoInvalidoException`. `ModuloPucara` hace las transiciones él mismo después de que el validador pasa sin error.

El loop de juego detecta el game over y dispara la transición:

```java
// En ModuloPucara.actualizar():
boolean eraGameOver = gm.isGameOver();
gm.update(movimiento.leerTeclado());
if (!eraGameOver && gm.isGameOver()) {
    finalizar();  // → FinalizadoState + notifica FINALIZADO al lobby
}
```

---

## Relación de clases

```
╔═══════════════════════════════════════════════════════════════════╗
║  FRAMEWORK (Game1982 — no tocar)                                  ║
║                                                                   ║
║  HomeJuego  ──────────────────────────────────────────────────┐  ║
║  (lobby)    registrarModulo()                                  │  ║
╚════════════════════════════════════════════════════════════════╪══╝
                                             implementa          │
                        ╔════════════════════╧══════════════╗   │
                        ║  <<interface>>                    ║◄──┘
                        ║  ModuloJuego (contracts/)         ║
                        ║  iniciar/pausar/reanudar/finalizar║
                        ║  actualizar(app) / dibujar(app)   ║
                        ║  getEstadisticasGenerales()       ║
                        ╚════════════════════╤══════════════╝
                                             │ implementa
                        ╔════════════════════▼══════════════╗
                        ║  ModuloPucara          [NUEVA]    ║
                        ║  ─────────────────────────────    ║
                        ║  ctx: ContextoJuego               ║
                        ║  estadoActual: EstadoJuego        ║
                        ║  observers: List<IModuloObserver> ║
                        ║  ─────────────────────────────    ║
                        ║  crea y posee:                    ║
                        ╚══╤══════════════════╤═════════════╝
                           │                  │
              ╔════════════▼══╗    ╔══════════▼═════════════════╗
              ║ PucaraMovim.  ║    ║  PucaraGameManager         ║
              ║ ───────────── ║    ║  ─────────────────────     ║
              ║ HashSet teclas║    ║  ancho, alto               ║
              ║ AWT KeyAdapter║    ║  gameOver, pausa           ║
              ║ ───────────── ║    ║  motivoGameOver            ║
              ║ leerTeclado() ║    ║  ─────────────────────     ║
              ║   ↓           ║    ║  update(EstadoEntrada)     ║
              ╚══╤════════════╝    ║  visual(PApplet)           ║
                 │                 ║  construirEstadisticas()   ║
     PucaraEstadoEntrada           ╚══╤════════════════════════╝
     (DTO: WASD + F + P + R)          │  posee y orquesta
                                      │
          ┌───────────────────────────┼──────────────────────────┐
          │                           │                          │
  ╔═══════▼════════╗    ╔═════════════▼═══════╗    ╔════════════▼═══╗
  ║ PucaraGestor   ║    ║ PucaraGestorOleadas  ║    ║ PucaraGestor   ║
  ║ Proyectiles    ║    ║ ─────────────────    ║    ║ Score          ║
  ║ ─────────────  ║    ║ oleada, dificultad   ║    ║ ────────────   ║
  ║ List<Misil>    ║    ║ framesPartida        ║    ║ score          ║
  ║ List<Bomba>    ║    ╚═════════════════════╝    ║ precision      ║
  ║ ─────────────  ║                               ╚════════════════╝
  ║ crearMisil()   ║    ╔═════════════════════╗
  ║ crearBomba()   ║    ║ PucaraFabrica       ║
  ║ update(alto)   ║    ║ Enemigos            ║
  ║ dibujar(app)   ║    ║ ─────────────────   ║
  ╚═══════╤════════╝    ║ ancho, alto         ║
          │             ║ crearEnemigo(tipo)  ║
          │             ╚══════╤══════════════╝
          │                    │ crea
          │      ╔═════════════╪══════════════════════╗
          │      │             │                      │
          │  ╔═══▼═══╗   ╔═════▼═════╗   ╔═══════════▼═╗
          │  ║Pucara ║   ║  Pucara   ║   ║   Pucara    ║
          │  ║ Jet   ║   ║ Shooter   ║   ║  Bomber     ║
          │  ╚═══════╝   ╚═══════════╝   ╚═════════════╝
          │       └──────────┴───────────────┘
          │               extienden
          │       ╔═══════════════════════╗
          │       ║  PucaraEnemigo        ║
          │       ║  (abstract)           ║
          │       ║  ─────────────────    ║
          │       ║  debeDisparar()       ║
          │       ║  debeLanzarBomba()    ║
          │       ║  calcularPosBomba()   ║
          │       ║  salioDePantalla()    ║
          │       ║  dibujar(app)         ║
          │       ╚═══════════════════════╝
          │
    ╔═════▼═══════╗  ╔══════════════════════╗
    ║ PucaraMisil ║  ║ PucaraSistemaColision.║
    ║ PucaraBomba ║  ║ ──────────────────── ║
    ╚═════════════╝  ║ PApplet.dist()        ║
                     ╚══════════════════════╝

  ╔════════════════════╗   ╔══════════════════╗
  ║ PucaraJugador      ║   ║ PucaraBase       ║
  ║ ───────────────    ║   ║ ───────────────  ║
  ║ ancho, alto        ║   ║ ancho, alto (w,y)║
  ║ aplicarMovimiento()║   ║ colisiona()      ║
  ║ dibujarPucara(app) ║   ║ recibirDanio()   ║
  ╚════════════════════╝   ║ dibujar(app)     ║
                           ╚══════════════════╝

  ╔═══════════════════╗
  ║ PucaraInterfaz    ║
  ║ ───────────────   ║
  ║ dibujarHUD(app)   ║
  ║ dibujarPausa(app) ║
  ║ dibujarGameOver() ║
  ╚═══════════════════╝
```

---

## Qué NO está en `modules/pucara/`

| Archivo | Por qué no está |
|---|---|
| `MVP.pde` | Su lógica está en `ModuloPucara`. El standalone sigue funcionando desde `MVP/`. |
| `StatsManager.pde` | El lobby persiste estadísticas. `PucaraGameManager.construirEstadisticas()` lo reemplaza. |
| Las clases de `contracts/` | Vienen del repo de Game1982, no las proveemos nosotros. |

---

## Qué entrega el equipo Pucará al Lobby

1. La carpeta `modules/pucara/` completa (18 archivos `.java`).
2. Los assets en `modules/pucara/data/` con prefijo `pucara_`:
   - `pucara_bomber.png`, `pucara_shooter.png`, `pucara_jet.png`
   - `pucara_misil.png`, `pucara_bomba.png`, `pucara_crosshair.png`
   - `pucara_avion.png` (el jugador — era `pucara.png`)
3. El Lobby agrega **una línea** a `Game1982.pde`:
   ```java
   homeJuego.registrarModulo(new ModuloPucara());
   ```

---

## Estructura del repositorio después de la integración

```
pucara-grasp/
├── MVP/                        ← versión standalone (sin tocar, sigue funcionando)
│   └── *.pde
├── modules/
│   └── pucara/                 ← lo que se entrega al repo Game1982
│       ├── ModuloPucara.java
│       ├── PucaraGameManager.java
│       ├── PucaraEnemigo.java
│       ├── PucaraJet.java
│       ├── PucaraShooter.java
│       ├── PucaraBomber.java
│       ├── PucaraJugador.java
│       ├── PucaraBase.java
│       ├── PucaraMisil.java
│       ├── PucaraBomba.java
│       ├── PucaraMovimiento.java
│       ├── PucaraEstadoEntrada.java
│       ├── PucaraGestorOleadas.java
│       ├── PucaraFabricaEnemigos.java
│       ├── PucaraGestorProyectiles.java
│       ├── PucaraSistemaColisiones.java
│       ├── PucaraGestorScore.java
│       ├── PucaraInterfaz.java
│       └── data/
│           └── pucara_*.png    ← assets renombrados (copiar manualmente)
├── PLAN_INTEGRACION_GAME1982.md
└── PLAN_REFACTORING_GRASP.md
```
