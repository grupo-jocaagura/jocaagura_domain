part of 'jocaagura_domain.dart';

class DateUtils {
  static DateTime dateTimeFromDynamic(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      // Intenta parsear la cadena como fecha
      return DateTime.tryParse(value) ?? DateTime.now();
    } else if (value is int) {
      // Trata el valor como un timestamp en milisegundos
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is Duration) {
      // Trata el valor como una duración, suma a la fecha actual
      return DateTime.now().add(value);
    }
    // Valor por defecto: fecha actual
    return DateTime.now();
  }
}
