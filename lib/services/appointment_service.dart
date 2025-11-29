import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paulette/services/notificacion_Service.dart';
import '../models/appointment.dart';


class AppointmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  /// ---------------------------------------------------------
  /// 🔹 Crear una cita nueva
  /// ---------------------------------------------------------
  Future<bool> createAppointment(Appointment appointment) async {
    try {
      await _db
          .collection("appointments")
          .doc(appointment.id)
          .set(appointment.toMap());

      return true; // éxito
    } catch (e) {
      print("🔥 Error al crear cita: $e");
      return false;
    }
  }

  /// ---------------------------------------------------------
  /// 🔹 Obtener las citas de un usuario
  /// ---------------------------------------------------------
  Stream<List<Appointment>> getAppointmentsByUser(String userId) {
    return _db
        .collection("appointments")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    });
  }

  /// ---------------------------------------------------------
  /// 🔹 Verificar si un horario está disponible
  /// ---------------------------------------------------------
  Future<bool> isTimeSlotAvailable(DateTime date, String time) async {
    try {
      // Convertir la fecha al inicio y fin del día
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Buscar citas en esa fecha y hora
      final snapshot = await _db
          .collection("appointments")
          .where("date", 
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where("date", 
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where("time", isEqualTo: time)
          .where("status", whereIn: ["pending", "approved"]) // Solo citas activas
          .get();

      // Si no hay documentos, el horario está disponible
      return snapshot.docs.isEmpty;
    } catch (e) {
      print("🔥 Error al verificar disponibilidad: $e");
      return true; // En caso de error, permitir la reserva
    }
  }

  /// ---------------------------------------------------------
  /// 🔹 Obtener horarios ocupados para una fecha específica
  /// ---------------------------------------------------------
  Future<List<String>> getOccupiedTimeSlots(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _db
          .collection("appointments")
          .where("date", 
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where("date", 
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where("status", whereIn: ["pending", "approved"])
          .get();

      // Extraer las horas ocupadas
      return snapshot.docs
          .map((doc) => doc.data()["time"] as String)
          .toList();
    } catch (e) {
      print("🔥 Error al obtener horarios ocupados: $e");
      return [];
    }
  }

  /// ---------------------------------------------------------
  /// 🔹 Cambiar el estado de una cita CON NOTIFICACIÓN
  /// (por ejemplo: pending → approved → completed)
  /// ---------------------------------------------------------
  Future<bool> updateStatus(String appointmentId, String status) async {
    try {
      // Obtener datos de la cita para notificar
      final doc = await _db.collection("appointments").doc(appointmentId).get();
      if (!doc.exists) return false;

      final appointment = Appointment.fromMap(doc.data()!);

      // Actualizar estado
      await _db.collection("appointments").doc(appointmentId).update({
        "status": status,
      });

      // Enviar notificación según el nuevo estado
      if (status == "approved") {
        await _notificationService.notifyAppointmentApproved(
          userId: appointment.userId,
          appointmentId: appointmentId,
          designTitle: appointment.designTitle,
          date: appointment.date,
          time: appointment.time,
        );
      } else if (status == "cancelled" || status == "canceled") {
        await _notificationService.notifyAppointmentRejected(
          userId: appointment.userId,
          appointmentId: appointmentId,
          designTitle: appointment.designTitle,
        );
      }

      return true;
    } catch (e) {
      print("🔥 Error al actualizar status: $e");
      return false;
    }
  }

  /// ---------------------------------------------------------
  /// 🔹 Eliminar una cita
  /// ---------------------------------------------------------
  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      await _db.collection("appointments").doc(appointmentId).delete();
      return true;
    } catch (e) {
      print("🔥 Error al eliminar cita: $e");
      return false;
    }
  }

  /// ---------------------------------------------------------
  /// 🔹 Verificar si una cita ya fue calificada
  /// ---------------------------------------------------------
  Future<bool> hasRating(String appointmentId) async {
    try {
      final doc = await _db.collection("appointments").doc(appointmentId).get();
      if (!doc.exists) return false;
      return doc.data()?["hasRating"] ?? false;
    } catch (e) {
      print("🔥 Error al verificar rating: $e");
      return false;
    }
  }

  /// ---------------------------------------------------------
  /// 🔹 Obtener todas las citas (para admin)
  /// ---------------------------------------------------------
  Stream<List<Appointment>> getAllAppointments() {
    return _db
        .collection("appointments")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    });
  }
}