/// Discrete font scale factors applied to the clinician UI via
/// `MediaQuery.textScaler`. Scaling is intentionally coarse (3 steps)
/// and never applied inside the immersive clinical tests.
enum FontScale {
  normal(1.0, 'normal'),
  grande(1.15, 'grande'),
  muyGrande(1.30, 'muyGrande');

  const FontScale(this.scale, this.storageKey);

  final double scale;
  final String storageKey;

  static FontScale fromStorageKey(String? key) {
    for (final v in FontScale.values) {
      if (v.storageKey == key) return v;
    }
    return FontScale.normal;
  }
}
