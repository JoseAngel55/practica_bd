import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  /// Programa una notificación 2 días antes de la fecha de entrega
  static Future<void> programarRecordatorio({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaEntrega,
  }) async {
    final fechaRecordatorio = fechaEntrega.subtract(const Duration(days: 2));
    if (fechaRecordatorio.isBefore(DateTime.now())) return;

    final tzFecha = tz.TZDateTime.from(fechaRecordatorio, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'recordatorios_channel',
      'Recordatorios',
      channelDescription: 'Recordatorios de ventas y servicios',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tzFecha,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelarNotificacion(int id) async {
    await _plugin.cancel(id);
  }
}
