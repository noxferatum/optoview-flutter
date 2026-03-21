import 'dart:typed_data';

/// Stub para plataformas no-web. No se ejecuta nunca.
void downloadFileWeb(Uint8List bytes, String filename, String mimeType) {
  throw UnsupportedError('downloadFileWeb solo disponible en web');
}
