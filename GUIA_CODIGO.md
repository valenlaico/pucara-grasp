# Guía del código: Pucará

> Para entenderlo de cero, y para poder explicárselo a alguien más.

---

## 1. El juego

**Pucará** es un juego de acción aérea en 2D. El jugador pilota un avión FMA IA-58 Pucará y tiene que sobrevivir tres oleadas de enemigos mientras protege una base en el suelo.

### Cómo se juega

- **Movimiento:** WASD o flechas
- **Disparar:** F
- **Pausar:** P
- **Reiniciar (tras game over):** R

El jugador muere si:
- Choca con un enemigo
- Un misil enemigo lo alcanza
- Una bomba explota cerca suyo
- La base en el suelo es destruida (la base tiene barra de vida)

### Los enemigos

| Tipo | Comportamiento | Ataque |
|---|---|---|
| **Jet** | Entra desde un lado, baja en diagonal hacia el jugador | Colisión directa (kamikaze) |
| **Shooter** | Se mueve horizontalmente de forma errática | Dispara misiles hacia abajo |
| **Bomber** | Vuela en línea recta de lado a lado | Al salir de pantalla, lanza una bomba |

### Las oleadas

El juego tiene un sistema de dificultad progresiva:
- **Oleada 1** (0–2 min): solo Jets
- **Oleada 2** (2–4.5 min): Jets + Shooters
- **Oleada 3** (4.5 min en adelante): Jets + Shooters + Bombers
- Cada 100 puntos, los enemigos aparecen más seguido

---

## 2. Tecnología

El juego está hecho en **Processing** (versión 4), que es un entorno de programación visual basado en Java. Cada archivo `.pde` es básicamente una clase Java con acceso a funciones de dibujo como `rect()`, `image()`, `fill()`, etc.

El loop principal corre a **60 FPS**. En cada frame se ejecuta `draw()`, que llama:
1. `movimiento.leerTeclado()` → qué teclas están presionadas ahora mismo
2. `gameManager.update(entrada)` → mover todo, detectar colisiones, actualizar estado
3. `gameManager.visual()` → dibujar todo en pantalla

---

## 3. Arquitectura: de afuera hacia adentro

El código está dividido en capas. La forma más fácil de entenderlo es de afuera hacia adentro.

```
MVP.pde (el loop principal)
    └── gameManager (el director de orquesta)
            ├── GestorOleadas     (cuándo y qué enemigo aparece)
            ├── FabricaEnemigos   (cómo crear cada tipo de enemigo)
            ├── GestorProyectiles (gestiona misiles y bombas en vuelo)
            ├── SistemaColisiones (detecta si algo chocó con algo)
            ├── GestorScore       (puntaje, precisión, tiempo)
            ├── Interfaz          (HUD, pausa, game over)
            ├── Pucara/Jugador    (el avión del jugador)
            ├── Base              (la base en el suelo)
            └── Lista de Enemigos (Jet, Shooter, Bomber)
```

**La regla de oro:** `gameManager` sabe qué hay que hacer pero delega el _cómo_ a cada clase. Cada clase se encarga solo de su propia responsabilidad.

---

## 4. GRASP: qué es y qué se aplicó

**GRASP** (General Responsibility Assignment Software Patterns) es un conjunto de principios para decidir qué clase debería hacer qué cosa. No son patrones de diseño como Singleton o Factory; son criterios de sentido común formalizados.

Los más importantes para este proyecto:

### Information Expert
> La responsabilidad debe estar en la clase que tiene la información necesaria para cumplirla.

**Ejemplo:** `Bomber` sabe dónde está y de qué tipo es, por eso es él quien calcula dónde va a caer la bomba (`calcularPosicionBomba()`). Antes lo calculaba `gameManager`, que no debería saber ese detalle.

### Creator
> La clase A debe crear instancias de B si A contiene o usa a B.

**Ejemplo:** `FabricaEnemigos` crea `Jet`, `Shooter` y `Bomber` porque su única razón de existir es esa. `GestorProyectiles` crea `Misil` y `Bomba` porque los gestiona.

### Controller
> Un objeto no-de-interfaz que recibe y coordina eventos del sistema.

**Ejemplo:** `gameManager` es el Controller del juego. Recibe la entrada del teclado y coordina todo lo que pasa en un frame, pero no implementa la lógica concreta de ninguna cosa.

### Low Coupling (bajo acoplamiento)
> Minimizar las dependencias entre clases.

**Ejemplo:** `Movimiento` usa un `KeyAdapter` de Java AWT registrado directamente en el componente gráfico. No depende de `keyPressed()` del sketch principal, por lo que puede funcionar igual dentro de un módulo externo.

### High Cohesion (alta cohesión)
> Una clase debe tener responsabilidades relacionadas entre sí.

**Ejemplo:** antes de la refactorización, `gameManager` tenía 8 responsabilidades (spawn de enemigos, colisiones, UI, estadísticas, etc.). Después del refactor, cada una de esas responsabilidades tiene su propia clase.

### Polymorphism
> Usar polimorfismo en lugar de preguntar "¿qué tipo sos?" con `instanceof`.

**Ejemplo:** `gameManager` ya no hace `if (e instanceof Shooter)`. En cambio, llama `e.debeDisparar()` y `e.debeLanzarBomba()`. Cada enemigo responde a esas preguntas según su propia naturaleza.

### Pure Fabrication
> A veces conviene crear una clase que no representa nada del dominio real, pero que agrupa responsabilidades técnicas.

**Ejemplo:** `SistemaColisiones` no es un objeto del mundo del juego; es una clase técnica que agrupa toda la geometría de detección de colisiones.

---

## 5. Las clases, una por una

### Entidades del juego

#### `Pucara` / `PucaraJugador` — el avión del jugador
Guarda posición (x, y) y velocidad. El método `aplicarMovimiento(EstadoEntrada)` mueve el avión según las teclas presionadas, respetando los bordes de la pantalla.

#### `Enemigo` / `PucaraEnemigo` — clase base abstracta
Define la interfaz común de todos los enemigos: posición, velocidad, `actualizar()`, `dibujar()`, `salioDePantalla()`. También tiene los métodos de polimorfismo: `debeDisparar()` y `debeLanzarBomba()` devuelven `false` por defecto; las subclases los sobreescriben.

#### `Jet` — enemigo tipo kamikaze
Se mueve en diagonal hacia el jugador. Cuando está sobre el punto objetivo en X, empieza a bajar. No dispara; su ataque es el choque directo.

#### `Shooter` — enemigo que dispara
Se mueve horizontalmente hacia objetivos aleatorios en X. Cada 90 frames, `debeDisparar()` devuelve `true`, señal para que `GestorProyectiles` cree un misil enemigo.

#### `Bomber` — enemigo que lanza bombas
Vuela en línea recta de un lado a otro. Cuando sale de pantalla, `debeLanzarBomba()` devuelve `true`. `calcularPosicionBomba()` elige un punto aleatorio en la zona de juego (lejos de la base) donde va a caer la bomba.

#### `Misil` / `PucaraMisil`
Se mueve verticalmente. Los misiles del jugador suben; los del enemigo bajan. Tiene `esEnemigo()` para distinguir quién lo disparó, y `salioDePantalla()` para que `GestorProyectiles` lo elimine.

#### `Bomba` / `PucaraBomba`
Aparece como una mira (crosshair) en el punto objetivo durante 3 segundos, luego cae desde arriba. Cuando llega al punto objetivo, `exploto()` devuelve `true`.

#### `Base` / `PucaraBase`
La base en el suelo. Tiene barra de vida (vida máx: 300). Los enemigos que la alcanzan le hacen 25 de daño. Si llega a 0, el juego termina.

---

### Sistemas de juego

#### `gameManager` / `PucaraGameManager` — el director de orquesta
La clase más importante del juego. En cada frame (`update()`):

1. Mueve al jugador
2. Crea un misil si el jugador disparó
3. Pide a `GestorOleadas` si hay que spawnear un enemigo
4. Por cada enemigo activo:
   - Lo mueve
   - Chequea si chocó con el jugador
   - Chequea si un misil del jugador lo destruyó
   - Chequea si debe disparar o lanzar bomba
   - Chequea si salió de pantalla o llegó a la base
5. Actualiza todos los proyectiles
6. Chequea misiles enemigos vs jugador
7. Chequea bombas vs jugador
8. Limpia bombas explotadas
9. Acumula el tiempo

`gameManager` no implementa ninguna de estas lógicas; las delega.

#### `GestorOleadas` / `PucaraGestorOleadas`
Decide cuándo y qué tipo de enemigo aparece. Controla dos contadores:
- `framesPartida`: para saber en qué oleada estamos
- `fc`: contador de frames entre spawns; cuando llega a `dificultad`, spawnea un enemigo y resetea

Devuelve un `String` con el tipo y lado: `"jet-izq"`, `"shooter-der"`, `"bomber-izq"`, etc.

#### `FabricaEnemigos` / `PucaraFabricaEnemigos`
Recibe el `String` de `GestorOleadas` y crea el `Enemigo` correspondiente con la posición, velocidad y parámetros correctos. Aísla la lógica de construcción del resto del sistema.

#### `GestorProyectiles` / `PucaraGestorProyectiles`
Mantiene dos listas: `misiles` y `bombas`. Se encarga de:
- Crear misiles y bombas cuando se lo piden
- Moverlos cada frame
- Eliminar los que salieron de pantalla o explotaron
- Eliminar el misil específico que golpeó a un enemigo (colaborando con `SistemaColisiones`)

La separación de responsabilidades clave: `SistemaColisiones` *detecta* la colisión, `GestorProyectiles` *elimina* el proyectil.

#### `SistemaColisiones` / `PucaraSistemaColisiones`
Clase técnica (Pure Fabrication) que concentra toda la geometría de detección. Todos sus métodos son detección pura: reciben objetos, calculan distancias con `dist()`, devuelven booleano. Nunca modifica listas.

Métodos:
- `hayColisionMisilJugadorConEnemigo(misil, enemigo)` — un misil específico contra un enemigo
- `chequearMisilesEnemigosVsPucara(misiles, jugador)` — todos los misiles vs el jugador
- `chequearBombasVsPucara(bombas, jugador)` — todas las bombas vs el jugador
- `hayColisionConPucara(enemigo, jugador)` — un enemigo vs el jugador

#### `GestorScore` / `PucaraGestorScore`
Lleva la cuenta de disparos, impactos, enemigos destruidos y tiempo. Calcula la precisión (`impactos / disparos`). No sabe nada del juego; solo acumula números.

---

### Soporte

#### `Movimiento` / `PucaraMovimiento`
Maneja el input del teclado. Usa un `HashSet<Integer>` de teclas activas que se actualiza con un `KeyAdapter` de Java AWT. Esto permite detectar múltiples teclas simultáneas (por ejemplo, moverse en diagonal mientras disparás).

`leerTeclado()` devuelve un `EstadoEntrada` con el estado de cada acción en este frame. Las acciones de un solo disparo (F, P, R) tienen una "antirrebote" para que una presión cuente una sola vez.

#### `EstadoEntrada` / `PucaraEstadoEntrada`
DTO (Data Transfer Object): una estructura de datos simple con 7 booleanos. Es el resultado de `leerTeclado()` y la entrada de `gameManager.update()`. Desacopla completamente al `gameManager` de `Movimiento`.

#### `Interfaz` / `PucaraInterfaz`
Dibuja el HUD (score, dificultad, oleada, controles), la pantalla de pausa y la pantalla de game over. Solo dibuja; no tiene estado propio ni toma decisiones.

---

## 6. El flujo de un frame completo

Este es el camino que recorre el código en cada `1/60` de segundo. Entender esto es entender el juego.

```
draw()
│
├─ movimiento.leerTeclado()
│     Lee el HashSet de teclas activas
│     Devuelve EstadoEntrada { moverIzq, moverDer, ... disparar, pausa, reiniciar }
│
└─ gameManager.update(entrada)
      │
      ├─ 1. p.aplicarMovimiento(entrada)
      │        Mueve el avión según WASD, respetando bordes
      │
      ├─ 2. if (entrada.disparar) gestorProyectiles.crearMisilJugador(x, y)
      │        Agrega un Misil a la lista; gestorScore registra el disparo
      │
      ├─ 3. String tipo = gestorOleadas.update()
      │        Incrementa el contador; si llegó a dificultad → devuelve "jet-izq"
      │        Si no es null → fabricaEnemigos.crearEnemigo(tipo) → agrega a lista
      │
      ├─ 4. for cada enemigo:
      │        │
      │        ├─ e.actualizar()              Mueve al enemigo (cada tipo mueve diferente)
      │        │
      │        ├─ sistemaColisiones.hayColisionConPucara(e, p)
      │        │     Si chocó → terminarPartida("Chocaste con un enemigo")
      │        │
      │        ├─ gestorProyectiles.eliminarMisilQueGolpeo(sc, e)
      │        │     Itera los misiles del jugador
      │        │     sistemaColisiones.hayColision(misil, enemigo) → si true: elimina misil
      │        │     Si hubo impacto → elimina enemigo, suma puntos, actualiza dificultad
      │        │
      │        ├─ if e.debeDisparar()         Solo Shooter devuelve true (cada 90 frames)
      │        │     gestorProyectiles.crearMisilEnemigo(x, y)
      │        │
      │        └─ if e.salioDePantalla() || e llegó a la base:
      │               if base.colisiona(x, y) → base.recibirDanio(25)
      │               if e.debeLanzarBomba()  → Solo Bomber devuelve true
      │                   int[] pos = e.calcularPosicionBomba()
      │                   gestorProyectiles.crearBomba(pos[0], pos[1])
      │               Elimina el enemigo de la lista
      │
      ├─ 5. gestorProyectiles.update()
      │        Mueve todos los misiles y bombas
      │        Elimina misiles que salieron de pantalla
      │
      ├─ 6. sistemaColisiones.chequearMisilesEnemigosVsPucara()
      │        Si algún misil enemigo alcanzó al jugador → terminarPartida()
      │
      ├─ 7. sistemaColisiones.chequearBombasVsPucara()
      │        Si alguna bomba explotada está cerca del jugador → terminarPartida()
      │
      └─ 8. gestorProyectiles.limpiarBombasExplotadas()
             Cada 60 frames: gestorScore.incrementarTiempo()

gameManager.visual(app) — dibuja todo en el orden correcto:
      base.dibujar()
      jugador.dibujarPucara()
      for cada enemigo: e.dibujar()
      gestorProyectiles.dibujar()
      interfaz.dibujarHUD()
      if pausa: interfaz.dibujarPausa()
```

---

## 7. La historia del refactor

El código original (primer commit) tenía todo concentrado en `gameManager`: 267 líneas, 8 responsabilidades distintas. Un solo archivo que movía jugadores, detectaba colisiones, controlaba oleadas, dibujaba el HUD y guardaba estadísticas.

El refactor aplicó GRASP para distribuir esas responsabilidades:

| Antes (en gameManager) | Después (en su propia clase) |
|---|---|
| Lógica de oleadas y spawn | `GestorOleadas` |
| Creación de enemigos | `FabricaEnemigos` |
| Gestión de proyectiles | `GestorProyectiles` |
| Detección de colisiones | `SistemaColisiones` |
| Score y estadísticas | `GestorScore` |
| Dibujo de UI | `Interfaz` |
| Leer teclado | `Movimiento` (ya existía, se desacoplócon `EstadoEntrada`) |

El resultado: `gameManager` pasó a 95 líneas con una sola responsabilidad real: coordinar.

---

## 8. La integración con Game1982

El proyecto también vive como un módulo dentro de un framework de múltiples juegos (`Game1982`). Para eso existe la carpeta `modules/pucara/` con los mismos archivos pero convertidos a `.java` con el prefijo `Pucara` en todos los nombres.

La única clase genuinamente nueva es `ModuloPucara`, que implementa la interfaz `ModuloJuego` del framework. Es la capa de adaptación entre el lobby del framework y el `PucaraGameManager`:

```
Framework (Game1982)
    └── ModuloPucara         ← nueva — habla el idioma del framework
            └── PucaraGameManager  ← mismo gameManager de siempre
```

Los tres cambios técnicos obligatorios para pasar de `.pde` a `.java` externo:
1. **`PApplet app`** se pasa explícitamente a los métodos de dibujo (antes era implícito del sketch)
2. **`loadImage()`** se hace en el primer frame de `dibujar()` en lugar del constructor
3. **`width`/`height`** se reemplazan por las dimensiones del `ContextoJuego` del framework

La lógica del juego es idéntica en ambas versiones.

---

## 9. Para explicarlo (preguntas frecuentes)

### "¿Qué es GRASP y por qué lo usaron?"
GRASP son criterios para decidir qué clase hace qué. Usamos los más relevantes para este tipo de sistema: Information Expert (cada clase maneja su propia información), Controller (gameManager coordina sin implementar), y Polimorfismo (los enemigos responden diferente a los mismos mensajes sin necesidad de `instanceof`).

### "¿Por qué SistemaColisiones no elimina el misil cuando detecta la colisión?"
Porque su responsabilidad es detectar, no modificar. Si SistemaColisiones eliminara el misil, tendría acceso a la lista de GestorProyectiles, creando un acoplamiento innecesario. El que crea y gestiona los misiles (GestorProyectiles) es el que los elimina.

### "¿Por qué Bomber calcula dónde cae la bomba y no gameManager?"
Information Expert: el Bomber sabe su propio tipo y su posición. Es el experto en su propio comportamiento. Que gameManager calculara eso sería lo mismo que una persona diciéndole al Bomber cómo hacer su trabajo.

### "¿Por qué Movimiento usa KeyAdapter de Java AWT y no el keyPressed() de Processing?"
Porque `keyPressed()` de Processing solo te dice la última tecla presionada. Para detectar múltiples teclas simultáneas (WASD + F al mismo tiempo), necesitás trackear qué teclas están actualmente abajo. El `KeyAdapter` se engancha directamente al componente gráfico y mantiene un `HashSet` con todas las teclas activas, sin importar cuántas sean.

### "¿Por qué EstadoEntrada es una clase separada y no se pasa directamente Movimiento a gameManager?"
Porque así gameManager no depende de Movimiento. gameManager recibe un simple DTO con booleanos y no sabe de dónde vienen. Esto es Low Coupling: si mañana cambiamos el sistema de input (por ejemplo, un gamepad), solo cambia Movimiento; gameManager no se entera.

### "¿Cuál es la diferencia entre MVP/ y modules/pucara/?"
`MVP/` es el juego standalone que corre directamente en Processing IDE. `modules/pucara/` es el mismo juego empaquetado como módulo para el framework Game1982, que permite correr múltiples juegos bajo un lobby común. La lógica es idéntica; la diferencia es la capa de adaptación (`ModuloPucara`) y algunos ajustes técnicos de Java puro vs Processing sketch.

### "¿Cómo funciona el sistema de dificultad?"
`GestorOleadas` tiene un contador `fc`. Cada frame sube 1. Cuando llega a `dificultad` (empieza en 60), spawnea un enemigo y resetea. Cada 100 puntos, `dificultad` baja en 5 (hasta un mínimo de 10). Menos `dificultad` = los frames entre spawns son menos = aparecen más seguido.

### "¿Qué pasa cuando el jugador muere?"
`gameManager` llama a `terminarPartida(motivo)`, que setea `gameOver = true` y el `motivoGameOver` (el texto que se muestra). En el siguiente frame, `update()` detecta `gameOver` y solo espera que el jugador presione R para llamar a `reiniciar()`.
