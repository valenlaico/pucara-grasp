import java.io.File;
import java.util.HashMap;

public class StatsManager {
  private HashMap<String, Integer> globalStats;
  private JSONArray historial;
  private String statsPath;

  public StatsManager() {
    statsPath = dataPath("stats.json");
    globalStats = new HashMap<String, Integer>();
    cargar();
  }

  private void cargar() {
    File f = new File(statsPath);
    if (f.exists()) {
      JSONObject guardado = loadJSONObject(statsPath);
      historial = guardado.getJSONArray("historial");
      JSONObject global = guardado.getJSONObject("global");
      globalStats.put("totalPartidas", global.getInt("totalPartidas"));
      globalStats.put("scoreMaximo",   global.getInt("scoreMaximo"));
      globalStats.put("totalEnemigos", global.getInt("totalEnemigos"));
      globalStats.put("tiempoTotal",   global.getInt("tiempoTotal"));
    } else {
      historial = new JSONArray();
      globalStats.put("totalPartidas", 0);
      globalStats.put("scoreMaximo",   0);
      globalStats.put("totalEnemigos", 0);
      globalStats.put("tiempoTotal",   0);
    }
  }

  public void guardar(int score, int tiempoSeg, int enemigos, float precision) {
    int totalPartidas = globalStats.get("totalPartidas") + 1;
    globalStats.put("totalPartidas", totalPartidas);
    if (score > globalStats.get("scoreMaximo")) {
      globalStats.put("scoreMaximo", score);
    }
    globalStats.put("totalEnemigos", globalStats.get("totalEnemigos") + enemigos);
    globalStats.put("tiempoTotal",   globalStats.get("tiempoTotal") + tiempoSeg);

    JSONObject partida = new JSONObject();
    partida.setInt("partida",   totalPartidas);
    partida.setInt("score",     score);
    partida.setInt("tiempo",    tiempoSeg);
    partida.setInt("enemigos",  enemigos);
    partida.setFloat("precision", precision);

    JSONArray nuevo = new JSONArray();
    nuevo.setJSONObject(0, partida);
    for (int i = 0; i < min(historial.size(), 9); i++) {
      nuevo.setJSONObject(i + 1, historial.getJSONObject(i));
    }
    historial = nuevo;

    JSONObject global = new JSONObject();
    global.setInt("totalPartidas", globalStats.get("totalPartidas"));
    global.setInt("scoreMaximo",   globalStats.get("scoreMaximo"));
    global.setInt("totalEnemigos", globalStats.get("totalEnemigos"));
    global.setInt("tiempoTotal",   globalStats.get("tiempoTotal"));

    JSONObject guardado = new JSONObject();
    guardado.setJSONArray("historial", historial);
    guardado.setJSONObject("global", global);
    saveJSONObject(guardado, statsPath);
  }
}
