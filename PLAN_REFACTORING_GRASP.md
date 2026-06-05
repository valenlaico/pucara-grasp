# Plan de Refactoring — MVP FINAL 2
### Principios GRASP: Bajo Acoplamiento, Alta Cohesión

---

## 1. Diagnóstico del Estado Actual

### El problema central: GameManager tiene 8 responsabilidades

```
GameManager (estado actual — 267 líneas)
│
├── 1. Gestión de enemigos (spawn, update, eliminar)
├── 2. Gestión de mísiles (crear, mover, eliminar)
├── 3. Gestión de bombas (crear, explotar, eliminar)
├── 4. Detección de TODAS las colisiones
├── 5. Lógica de oleadas y dificultad
├── 6. Tracking de estadísticas (score, disparos, impactos)
├── 7. Renderización de toda la UI (HUD, pantalla pausa, game over)
└── 8. Coordinación del flujo de juego (pausa, game over, reinicio)
```

Además, hay violaciones fuera de GameManager:
- `Movimiento` llama directamente a `gm.alternarPausa()` y `gm.reiniciar()` → **acoplamiento bidireccional inverso**
- `Pucara.crearMis()` y `Shooter.crearMis()` crean objetos que GameManager necesita almacenar → **violación de Creator**

---

## 2. Principios GRASP Aplicados

| Principio | Cómo se aplica en este plan |
|-----------|----------------------------|
| **Information Expert** | Cada manager conoce y gestiona su propia colección. `SistemaColisiones` tiene toda la info de posiciones. `GestorScore` tiene toda la info de puntuación. |
| **Creator** | `GestorProyectiles` crea mísiles y bombas (es quien los almacena y usa). `FabricaEnemigos` crea enemigos. Se elimina `crearMis()` de `Pucara` y `Shooter`. |
| **Controller** | `GameManager` queda como controlador puro: coordina sin implementar. No toca listas, no hace math de colisiones. |
| **Low Coupling** | `Movimiento` deja de conocer a `GameManager`. `Shooter` deja de conocer a `Misil`. Las dependencias van en una sola dirección. |
| **High Cohesion** | Cada clase nueva tiene una razón de existir claramente delimitada. |
| **Polymorphism** | Se mantiene y refuerza la jerarquía `Enemigo → {Jet, Shooter, Bomber}`. `Shooter` ya no necesita `crearMis()` porque ese comportamiento pasa al `GestorProyectiles`. |
| **Pure Fabrication** | Se introducen `GestorOleadas`, `GestorProyectiles`, `SistemaColisiones`, `Interfaz` y `FabricaEnemigos` — no representan entidades del dominio, sino servicios técnicos necesarios para lograr cohesión. |
| **Indirection** | `EstadoEntrada` actúa como intermediario entre `Movimiento` y el resto del sistema, eliminando la dependencia directa. |
| **Protected Variations** | La lógica de oleadas y dificultad queda aislada en `GestorOleadas`, protegiéndola de cambios en GameManager. |

---

## 3. Nueva Arquitectura — Clases en Detalle

### Clases NUEVAS

---

### `GestorOleadas` ← era parte de GameManager

**Principio GRASP:** Information Expert + Protected Variations

**¿Qué hace exactamente?**

Hoy GameManager contiene toda la lógica de oleadas mezclada dentro de `update()`: mira `framesPartida`, decide en qué oleada estás, ajusta la dificultad según el score, y calcula `framesHastaDisparo`. Todo eso vive pegado a la lógica de colisiones y de mísiles, lo cual hace imposible modificar las oleadas sin tocar también el resto.

`GestorOleadas` extrae esa lógica a su propio archivo y la encapsula. Cada llamada a `update()` le pasás el score actual y él solo te responde: "spawneá un Shooter" o "todavía no, seguí esperando". No sabe nada de enemigos concretos — solo sabe *cuándo* y *qué tipo* hay que spawnear.

**Responsabilidades concretas:**
- Llevar la cuenta de `framesPartida` para saber en qué oleada estás (oleada 1, 2 o 3)
- Llevar la cuenta de `framesHastaProximoSpawn` para espaciar los spawns
- Decidir el tipo de enemigo a spawnear según la oleada y la aleatoriedad
- Calcular la dificultad actual en base al score (hoy está hardcodeado en GameManager)
- Exponer `getOleada()` y `getDificultad()` para que otros puedan mostrarlo en pantalla

**Lo que NO hace:** no crea instancias de enemigos (eso es de FabricaEnemigos), no los agrega a ninguna lista (eso es de GameManager).

```
GestorOleadas
├── oleadaActual: int
├── dificultad: int
├── framesPartida: int
├── framesHastaProximoSpawn: int
├── update(score: int) → String | null   // "jet", "shooter", "bomber", o null
├── reiniciar()
├── getOleada(): int
└── getDificultad(): int
```

---

### `FabricaEnemigos` ← era parte de GameManager

**Principio GRASP:** Creator

**¿Qué hace exactamente?**

Hoy GameManager tiene bloques enormes de código como este:

```java
if (rand.nextInt(100) < 30 + dificultad * 5) {
    enemigos.add(new Jet(rand.nextInt(50, width-50), 0, 2 + dificultad));
} else if (...) {
    enemigos.add(new Shooter(...));
}
```

Esa lógica de "qué parámetros le paso a cada tipo de enemigo" vive en GameManager, que no tiene por qué saber eso. Si mañana querés cambiar la velocidad inicial de un Jet, tenés que entrar a GameManager a buscar entre 267 líneas.

`FabricaEnemigos` centraliza toda esa lógica de construcción. Recibe un tipo de enemigo y la dificultad actual, y devuelve un objeto listo para usar. GameManager ya no necesita hacer `new Jet(...)` directamente — ni siquiera necesita importar `Jet`, `Shooter` o `Bomber`.

**Responsabilidades concretas:**
- Construir un `Jet` con la posición y velocidad correctas según la dificultad
- Construir un `Shooter` con la posición y velocidad correctas
- Construir un `Bomber` con la posición y velocidad correctas
- Calcular posiciones iniciales aleatorias (ese `rand.nextInt(50, width-50)` que hoy está en GameManager)

**Lo que NO hace:** no decide cuándo spawnear (eso es GestorOleadas), no guarda la lista de enemigos activos (eso es GameManager).

```
FabricaEnemigos
└── crearEnemigo(tipo: String, dificultad: int): Enemigo
    // Devuelve new Jet / new Shooter / new Bomber configurado
```

---

### `GestorProyectiles` ← era parte de GameManager + Pucara + Shooter

**Principio GRASP:** Creator + Information Expert

**¿Qué hace exactamente?**

Este es el cambio más importante en términos de acoplamiento. Hoy hay tres lugares distintos que crean mísiles:
- `Pucara.crearMis()` crea el mísil del jugador
- `Shooter.crearMis()` crea el mísil del enemigo
- GameManager llama a esos métodos y guarda el resultado en su propia lista

Esto viola Creator: quien crea un objeto debería ser quien lo almacena y lo usa. `Pucara` no guarda su propia lista de mísiles — los crea y se los entrega a GameManager. Lo mismo `Shooter`. Eso crea dependencias innecesarias: `Pucara` conoce a `Misil`, `Shooter` conoce a `Misil`, y GameManager también.

`GestorProyectiles` es el único dueño de las listas `misiles` y `bombas`. Él los crea, los actualiza, los mueve y los elimina. Pucara solo dice "estoy disparando desde (x, y)" — no toca un solo objeto `Misil`.

**Responsabilidades concretas:**
- Mantener `ArrayList<Misil> misiles` y `ArrayList<Bomba> bombas`
- Crear un mísil del jugador cuando se lo piden (con dirección hacia arriba)
- Crear un mísil enemigo cuando se lo piden (con dirección hacia abajo)
- Crear una bomba cuando un Bomber lanza
- Mover todos los proyectiles activos cada frame
- Eliminar los que salieron de pantalla
- Dibujar todos los proyectiles
- Exponer las listas para que `SistemaColisiones` pueda leerlas

**Lo que NO hace:** no decide cuándo se dispara (eso lo decide GameManager al leer el input), no detecta colisiones (eso es SistemaColisiones).

```
GestorProyectiles
├── misiles: ArrayList<Misil>
├── bombas: ArrayList<Bomba>
├── crearMisilJugador(x: int, y: int)
├── crearMisilEnemigo(x: int, y: int)
├── crearBomba(x: int, y: int)
├── update()
├── dibujar()
├── getMisiles(): ArrayList<Misil>
├── getBombas(): ArrayList<Bomba>
└── reiniciar()
```

---

### `SistemaColisiones` ← era parte de GameManager

**Principio GRASP:** Information Expert + Pure Fabrication

**¿Qué hace exactamente?**

Hoy GameManager tiene varios loops anidados que comprueban colisiones: mísiles vs enemigos, mísiles enemigos vs pucara, bombas vs pucara, bombas vs base, pucara vs enemigos. Todo eso mezclado en `update()` con el resto de la lógica.

El problema es que GameManager toma decisiones que no le corresponden: "si el mísil tocó al enemigo, eliminá al enemigo, sumá score, eliminá el mísil". Eso es lógica de colisión + lógica de score + modificación de listas, todo junto.

`SistemaColisiones` encapsula *solo la detección*. Compara posiciones y radios, y devuelve el resultado. No modifica ninguna lista, no suma score, no llama a nada. GameManager recibe el resultado y decide qué hacer con él.

**Responsabilidades concretas:**
- Recibir dos listas o dos objetos y decir si colisionaron
- Detectar cuáles enemigos fueron alcanzados por mísiles del jugador
- Detectar si la pucara fue impactada por algún mísil enemigo
- Detectar si alguna bomba explosionó cerca de la pucara
- Detectar si alguna bomba explosionó cerca de la base
- Detectar si un enemigo tocó directamente a la pucara (colisión física)

**Lo que NO hace:** no modifica las listas (no elimina nada), no suma ni resta vida, no llama a `terminarPartida`. Solo reporta qué colisionó.

```
SistemaColisiones
├── chequearMisilesVsEnemigos(misiles, enemigos): ArrayList<Enemigo>
├── chequearMisilesVsPucara(misiles, pucara): boolean
├── chequearBombasVsPucara(bombas, pucara): boolean
├── chequearBombasVsBase(bombas, base): boolean
└── chequearEnemigosVsPucara(enemigos, pucara): Enemigo | null
```

---

### `GestorScore` ← era parte de GameManager

**Principio GRASP:** Information Expert

**¿Qué hace exactamente?**

Hoy GameManager tiene variables como `score`, `misileDisparados`, `misilesImpactaron`, `enemigosDestruidosEnPartida`, y las modifica en distintos lugares de `update()`. El cálculo de precisión (`(float) misilesImpactaron / misileDisparados`) también vive ahí.

El problema es que esas variables no tienen nada que ver con coordinar el juego — son estadísticas puras. Si GameManager decide terminar la partida, tiene que calcular la precisión, formatear los datos y llamar a StatsManager. Esa cadena completa vive en `terminarPartida()`.

`GestorScore` es el dueño de todas esas variables. Cada vez que pasa algo relevante (se disparó, se impactó, se destruyó un enemigo), GameManager le avisa con un método simple. Al final de la partida, `GestorScore` ya tiene todo listo para pasarle a `StatsManager`.

**Responsabilidades concretas:**
- Guardar `score`, `misileDisparados`, `misilesImpactaron`, `enemigosDestruidos`, `tiempoSegundos`
- Registrar cada evento relevante con métodos de una sola línea
- Calcular la precisión cuando se la pidan
- Sumar puntos al score según el tipo de evento (destruir enemigo, tiempo, etc.)
- Pasarle los datos finales a StatsManager al terminar la partida

**Lo que NO hace:** no persiste nada en disco (eso es StatsManager), no dibuja el score en pantalla (eso es Interfaz).

```
GestorScore
├── score: int
├── misileDisparados: int
├── misilesImpactaron: int
├── enemigosDestruidos: int
├── tiempoSegundos: int
├── registrarDisparo()
├── registrarImpacto()
├── registrarEnemigo()
├── incrementarTiempo()
├── sumarPuntos(cantidad: int)
├── getScore(): int
├── getPrecision(): float
└── reiniciar()
```

---

### `Interfaz` ← era parte de GameManager

**Principio GRASP:** Pure Fabrication

**¿Qué hace exactamente?**

Hoy GameManager tiene métodos `drawGameOver()`, `drawPausa()` y dentro de `visual()` dibuja el HUD (score, oleada, dificultad). Eso significa que GameManager necesita saber de Processing: cómo escribir texto, cómo dibujar rectángulos semi-transparentes, qué fuente usar.

La lógica de juego y el renderizado de UI no deberían estar en el mismo lugar. Si querés cambiar el color del texto del game over, tenés que buscar en GameManager entre colisiones y spawns.

`Interfaz` agrupa todo lo visual que no es el juego en sí (los sprites de enemigos y pucara ya los dibuja cada clase). Se encarga del HUD que siempre está visible y de las pantallas de estado (pausa, game over).

**Responsabilidades concretas:**
- Dibujar el HUD superior: score actual, oleada actual, dificultad
- Dibujar la pantalla de pausa con el overlay y el texto
- Dibujar la pantalla de game over con el motivo, el score final, la precisión y el botón de reinicio
- Acceder a StatsManager para mostrar las estadísticas históricas en game over

**Lo que NO hace:** no dibuja enemigos, ni pucara, ni mísiles (cada clase se dibuja sola), no modifica ningún estado del juego.

```
Interfaz
├── dibujarHUD(score: int, oleada: int, dificultad: int)
├── dibujarPausa()
└── dibujarGameOver(motivo: String, score: int, precision: float, statsManager: StatsManager)
```

---

### `EstadoEntrada` ← soluciona Movimiento ↔ GameManager

**Principio GRASP:** Indirection

**¿Qué hace exactamente?**

Este es el problema más raro del proyecto: `Movimiento` es el manejador de input, pero llama directamente a `gm.alternarPausa()` y `gm.reiniciar()`. Eso significa que el sistema de input *controla* al GameManager, cuando debería ser al revés.

El problema es que no hay forma de que Movimiento comunique "presionaron pausa" sin tener una referencia a alguien que pueda pausar. La solución es un objeto intermediario que transporte el estado sin crear dependencias.

`EstadoEntrada` es una clase simple — casi un struct — con booleanos que representan qué teclas están activas en este frame. `Movimiento` lo llena, GameManager lo lee. Ninguno sabe del otro.

**Responsabilidades concretas:**
- Contener el estado de todas las teclas relevantes para este frame
- Ser creado por `Movimiento` cada frame
- Ser leído por `GameManager` para tomar decisiones

**Lo que NO hace:** no tiene lógica propia, no modifica nada. Es puro transporte de datos.

```
EstadoEntrada
├── moverIzq: boolean
├── moverDer: boolean
├── moverArr: boolean
├── moverAba: boolean
├── disparar: boolean
├── pausa: boolean
└── reiniciar: boolean
```

---

### Clases MODIFICADAS

---

### `GameManager` — Controller puro (de 267 a ~80 líneas)

**¿Qué cambia exactamente?**

GameManager deja de implementar cualquier lógica concreta. Su `update()` se convierte en una secuencia de llamadas a sus managers. El cuerpo pasa de 130 líneas de lógica mezclada a algo así:

```java
void update() {
  EstadoEntrada entrada = movimiento.leerTeclado();
  
  if (entrada.pausa) { alternarPausa(); return; }
  if (gameOver) return;
  if (entrada.reiniciar) { reiniciar(); return; }

  pucara.aplicarMovimiento(entrada);
  
  if (entrada.disparar) {
    gestorProyectiles.crearMisilJugador(pucara.getX(), pucara.getY());
    gestorScore.registrarDisparo();
  }

  String tipoSpawn = gestorOleadas.update(gestorScore.getScore());
  if (tipoSpawn != null)
    enemigos.add(fabricaEnemigos.crearEnemigo(tipoSpawn, gestorOleadas.getDificultad()));

  for (Enemigo e : enemigos) {
    e.actualizar();
    if (e instanceof Shooter && ((Shooter)e).debeDisparar())
      gestorProyectiles.crearMisilEnemigo(e.getX(), e.getY());
    if (e instanceof Bomber && ((Bomber)e).debeLanzarBomba())
      gestorProyectiles.crearBomba(e.getX(), e.getY());
  }

  gestorProyectiles.update();

  for (Enemigo e : sistemaColisiones.chequearMisilesVsEnemigos(...)) {
    gestorScore.registrarImpacto();
    gestorScore.registrarEnemigo();
    gestorScore.sumarPuntos(100);
    enemigos.remove(e);
  }

  if (sistemaColisiones.chequearEnemigosVsPucara(enemigos, pucara) != null)
    terminarPartida("Chocaste contra un enemigo");

  if (sistemaColisiones.chequearMisilesVsPucara(...))
    terminarPartida("Te impactó un misil enemigo");

  if (sistemaColisiones.chequearBombasVsBase(...))
    base.recibirDanio(25);

  if (base.estaDestruida())
    terminarPartida("La base fue destruida");

  gestorScore.incrementarTiempo();
}
```

GameManager sigue siendo el dueño de `ArrayList<Enemigo>` y de `pucara` y `base` porque es quien coordina sus interacciones. Los proyectiles los delega completamente a `GestorProyectiles`.

---

### `Movimiento` — Sin dependencia a GameManager

**¿Qué cambia exactamente?**

Se elimina el parámetro `gameManager gm` del método `leerTeclado`. En lugar de llamar a `gm.alternarPausa()`, ahora el método devuelve un `EstadoEntrada` con `pausa = true` cuando se presionó Escape. GameManager lee ese estado y decide qué hacer.

```java
// ANTES — Movimiento controla a GameManager:
public void leerTeclado(gameManager gm) {
  if (teclaPresionada(ESC)) gm.alternarPausa();
  if (teclaPresionada(R))   gm.reiniciar();
}

// DESPUÉS — Movimiento solo reporta el estado:
public EstadoEntrada leerTeclado() {
  return new EstadoEntrada(
    teclasActivas.contains(IZQ),
    teclasActivas.contains(DER),
    teclasActivas.contains(ARR),
    teclasActivas.contains(ABA),
    consumirDisparo(),
    consumirPausa(),
    consumirReinicio()
  );
}
```

---

### `Pucara` — Sin crearMis()

**¿Qué cambia exactamente?**

Se elimina `crearMis()` completamente. `Pucara` no sabe que existen los mísiles. Tampoco recibe un objeto `Movimiento` — recibe un `EstadoEntrada` y mueve su posición según los booleanos. Pucara queda con una sola razón de existir: representar al avión jugador.

```java
// Se ELIMINA:
public Misil crearMis() { return new Misil(xPucara, yPucara, false); }

// Se REEMPLAZA aplicarMovimiento:
public void aplicarMovimiento(EstadoEntrada entrada) {
  if (entrada.moverIzq && xPucara > 0)          xPucara -= velocidad;
  if (entrada.moverDer && xPucara < width)       xPucara += velocidad;
  if (entrada.moverArr && yPucara > 0)           yPucara -= velocidad;
  if (entrada.moverAba && yPucara < height - 50) yPucara += velocidad;
}
```

---

### `Shooter` — Sin crearMis(), con señal debeDisparar()

**¿Qué cambia exactamente?**

`Shooter` no debería saber nada sobre los mísiles. Su comportamiento de "disparar cada N frames" se convierte en una señal booleana que GameManager lee y actúa. Shooter solo lleva su contador interno — no toca ninguna lista de proyectiles.

```java
// Se ELIMINA:
public Misil crearMis() { return new Misil(xEnemigo, yEnemigo, true); }

// Se AÑADE:
public boolean debeDisparar() {
  fc++;
  if (fc >= framesHastaDisparo) { fc = 0; return true; }
  return false;
}
```

---

### `Bomber` — Con señal debeLanzarBomba()

**¿Qué cambia exactamente?**

La lógica de "un Bomber crea una Bomba cuando llega a cierta posición X" hoy está en GameManager. Se mueve a Bomber mismo, que es el Information Expert de su propia posición y comportamiento.

```java
// Se AÑADE:
public boolean debeLanzarBomba() {
  // la misma condición que hoy está en gameManager línea ~140
  return xEnemigo > width * 0.3 && xEnemigo < width * 0.7 && !yaLanzoBomba;
}
```

---

## 4. Diagrama de Dependencias — Antes vs. Después

### ANTES (acoplamiento fuerte, bidireccional)
```
MVP
 └─ GameManager ←────────────── Movimiento (¡flujo invertido!)
       │
       ├──► Pucara ──► Misil     (Pucara crea lo que no le pertenece)
       ├──► Base
       ├──► Jet
       ├──► Shooter ──► Misil   (Shooter crea lo que no le pertenece)
       ├──► Bomber
       ├──► Misil[]
       ├──► Bomba[]
       └──► StatsManager
```

### DESPUÉS (flujo unidireccional, cada clase en su carril)
```
MVP
 └─ GameManager (Controller)
       │
       ├──► Movimiento → EstadoEntrada ──► GameManager  (intermediario)
       │
       ├──► GestorOleadas ──► FabricaEnemigos ──► {Jet, Shooter, Bomber}
       ├──► GestorProyectiles ──► {Misil, Bomba}
       ├──► SistemaColisiones  (recibe refs, no las posee)
       ├──► GestorScore ──► StatsManager
       ├──► Interfaz ──► StatsManager
       ├──► Pucara
       └──► Base
```

---

## 5. Plan de Ejecución — Pasos

El plan respeta el corazón lógico del juego. Los cambios son **aditivos** (clases nuevas) antes de ser **destructivos** (eliminar código viejo).

### Fase 1 — Extraer sin romper
1. `EstadoEntrada.pde` — DTO de entrada (5 min)
2. `GestorScore.pde` — extraer stats de GameManager (15 min)
3. `Interfaz.pde` — extraer código visual de GameManager (20 min)

### Fase 2 — Pure Fabrication
4. `GestorOleadas.pde` — extraer lógica de oleadas/dificultad (20 min)
5. `FabricaEnemigos.pde` — centralizar creación de enemigos (15 min)
6. `GestorProyectiles.pde` — extraer gestión de proyectiles (25 min)
7. `SistemaColisiones.pde` — extraer toda la detección de colisiones (30 min)

### Fase 3 — Desacoplar clases existentes
8. `Movimiento.pde` → retornar `EstadoEntrada` en lugar de llamar a GameManager
9. `Pucara.pde` → eliminar `crearMis()`, `aplicarMovimiento(EstadoEntrada)`
10. `Shooter.pde` → eliminar `crearMis()`, añadir `debeDisparar()`
11. `Bomber.pde` → añadir `debeLanzarBomba()`

### Fase 4 — Simplificar GameManager
12. `GameManager.pde` → reescribir `update()` y `visual()` delegando a managers
13. `MVP.pde` → ajustar inicialización con todos los managers

---

## 6. Cuadro de Responsabilidades — Antes y Después

| Clase | Responsabilidades ANTES | Responsabilidades DESPUÉS | Cambio |
|-------|-------------------------|--------------------------|--------|
| **GameManager** | 1. Spawn enemies · 2. Gestionar mísiles · 3. Gestionar bombas · 4. Todas las colisiones · 5. Oleadas/dificultad · 6. Score/stats · 7. Renderizar UI · 8. Flujo de juego | **Solo:** Orquestar el flujo de juego (pausa, game over, reinicio) y coordinar managers | **De 8 a 1 responsabilidad** |
| **GestorOleadas** | _(no existía)_ | Controlar oleadas, dificultad y timing de spawn | **Nueva — Pure Fabrication** |
| **FabricaEnemigos** | _(no existía)_ | Crear instancias de enemigos según tipo y dificultad | **Nueva — Creator** |
| **GestorProyectiles** | _(no existía)_ | Crear, mover y eliminar mísiles y bombas | **Nueva — Creator + Info Expert** |
| **SistemaColisiones** | _(no existía)_ | Detectar y reportar todas las colisiones | **Nueva — Information Expert** |
| **GestorScore** | _(no existía)_ | Registrar y calcular estadísticas de la partida | **Nueva — Information Expert** |
| **Interfaz** | _(no existía)_ | Dibujar HUD, pantalla pausa y pantalla game over | **Nueva — Pure Fabrication** |
| **EstadoEntrada** | _(no existía)_ | Transportar estado del input entre clases | **Nueva — Indirection** |
| **Movimiento** | Leer teclado + **llamar a GameManager** directamente | Solo leer teclado y retornar `EstadoEntrada` | **Desacoplada** |
| **Pucara** | Moverse + **crear mísiles** | Solo moverse y dibujarse | **Simplificada** |
| **Shooter** | Moverse + **crear mísiles** | Moverse, dibujarse + señal `debeDisparar()` | **Simplificada** |
| **Bomber** | Moverse | Moverse + señal `debeLanzarBomba()` | **Mínimo añadido** |
| **Jet** | Moverse hacia objetivo | Sin cambios | **Intacta** |
| **Base** | Recibir daño, dibujarse | Sin cambios | **Intacta** |
| **Misil** | Moverse, dibujarse | Sin cambios | **Intacta** |
| **Bomba** | Caer, explotar, dibujarse | Sin cambios | **Intacta** |
| **StatsManager** | Persistir estadísticas en JSON | Sin cambios | **Intacta** |
| **Enemigo** | Clase abstracta base | Sin cambios | **Intacta** |

---

## 7. Métricas de Mejora Esperadas

| Métrica | Antes | Después |
|---------|-------|---------|
| Responsabilidades de GameManager | 8 | 1 |
| Líneas de GameManager | 267 | ~80 |
| Dependencias de GameManager | 9 clases concretas | 7 managers (sin conocer tipos concretos) |
| Clases con acoplamiento bidireccional | 2 (GM ↔ Movimiento) | 0 |
| Clases que crean proyectiles sin poseerlos | 2 (Pucara, Shooter) | 0 |
| Clases con más de 2 responsabilidades | 1 (GameManager) | 0 |
| Clases nuevas necesarias | — | 7 |

---

## 8. Qué NO cambia (corazón lógico del juego)

- La mecánica de colisiones (misma geometría, solo reubicada)
- El sistema de oleadas (misma lógica, solo aislada en GestorOleadas)
- La jerarquía de polimorfismo `Enemigo → {Jet, Shooter, Bomber}`
- La dificultad progresiva
- El sistema de puntuación y persistencia (`StatsManager` intacto)
- El comportamiento visual de cada entidad (cada clase sigue dibujándose a sí misma)
- El archivo `MVP.pde` como punto de entrada

---

*Documento generado para validación previa a ejecución.*
*Ante cualquier duda sobre alguna fase, consultar antes de ejecutar.*
