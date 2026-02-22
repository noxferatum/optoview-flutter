import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_config.dart';

abstract final class ConfigStorage {
  static const _prefix = 'last_config_';

  static Future<void> saveConfig(TestConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefix}lado', config.lado.name);
    await prefs.setString('${_prefix}categoria', config.categoria.name);
    await prefs.setString(
        '${_prefix}forma', config.forma?.name ?? '_null');
    await prefs.setString('${_prefix}velocidad', config.velocidad.name);
    await prefs.setString('${_prefix}movimiento', config.movimiento.name);
    await prefs.setInt('${_prefix}duracion', config.duracionSegundos);
    await prefs.setDouble('${_prefix}tamano', config.tamanoPorc);
    await prefs.setBool('${_prefix}tamanoAleatorio', config.tamanoAleatorio);
    await prefs.setDouble('${_prefix}distancia', config.distanciaPct);
    await prefs.setString(
        '${_prefix}distanciaModo', config.distanciaModo.name);
    await prefs.setString('${_prefix}fijacion', config.fijacion.name);
    await prefs.setString('${_prefix}fondo', config.fondo.name);
    await prefs.setBool('${_prefix}fondoDistractor', config.fondoDistractor);
    await prefs.setBool(
        '${_prefix}fondoDistractorAnimado', config.fondoDistractorAnimado);
    await prefs.setString(
        '${_prefix}estimuloColor', config.estimuloColor.name);
  }

  static Future<TestConfig?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('${_prefix}lado')) return null;

    try {
      final formaName = prefs.getString('${_prefix}forma');
      Forma? forma;
      if (formaName != null && formaName != '_null') {
        forma = Forma.values.byName(formaName);
      }

      return TestConfig(
        lado: Lado.values.byName(prefs.getString('${_prefix}lado')!),
        categoria: SimboloCategoria.values
            .byName(prefs.getString('${_prefix}categoria')!),
        forma: forma,
        velocidad: Velocidad.values
            .byName(prefs.getString('${_prefix}velocidad')!),
        movimiento: Movimiento.values
            .byName(prefs.getString('${_prefix}movimiento')!),
        duracionSegundos: prefs.getInt('${_prefix}duracion')!,
        tamanoPorc: prefs.getDouble('${_prefix}tamano')!,
        tamanoAleatorio: prefs.getBool('${_prefix}tamanoAleatorio') ?? false,
        distanciaPct: prefs.getDouble('${_prefix}distancia')!,
        distanciaModo: DistanciaModo.values
            .byName(prefs.getString('${_prefix}distanciaModo')!),
        fijacion:
            Fijacion.values.byName(prefs.getString('${_prefix}fijacion')!),
        fondo: Fondo.values.byName(prefs.getString('${_prefix}fondo')!),
        fondoDistractor: prefs.getBool('${_prefix}fondoDistractor')!,
        fondoDistractorAnimado:
            prefs.getBool('${_prefix}fondoDistractorAnimado') ?? false,
        estimuloColor: EstimuloColor.values
            .byName(prefs.getString('${_prefix}estimuloColor')!),
      );
    } catch (_) {
      return null;
    }
  }
}
