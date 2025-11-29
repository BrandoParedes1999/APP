import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class AdminAppointmentsPanel extends StatefulWidget {
  const AdminAppointmentsPanel({super.key});

  @override
  State<AdminAppointmentsPanel> createState() => _AdminAppointmentsPanelState();
}

class _AdminAppointmentsPanelState extends State<AdminAppointmentsPanel>
    with SingleTickerProviderStateMixin {
  final AppointmentService _appointmentService = AppointmentService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 🎨 Color según estado
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "approved":
        return Colors.blue;
      case "completed":
        return Colors.green;
      case "cancelled":
      case "canceled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// ✅ Aprobar cita
  Future<void> _approveAppointment(String appointmentId) async {
    final success = await _appointmentService.updateStatus(
      appointmentId,
      "approved",
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Cita aprobada exitosamente" : "Error al aprobar cita",
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// ❌ Rechazar cita
  Future<void> _rejectAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Rechazar cita?"),
        content: const Text("El cliente será notificado del rechazo."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Rechazar"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await _appointmentService.updateStatus(
        appointmentId,
        "cancelled",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? "Cita rechazada" : "Error al rechazar cita",
            ),
            backgroundColor: success ? Colors.orange : Colors.red,
          ),
        );
      }
    }
  }

  /// ✔️ Completar cita
  Future<void> _completeAppointment(String appointmentId) async {
    final success = await _appointmentService.updateStatus(
      appointmentId,
      "completed",
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Cita marcada como completada" : "Error al completar",
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// 📊 Estadísticas
  Widget _buildStatistics(List<Appointment> appointments) {
    final pending = appointments.where((a) => a.status == "pending").length;
    final approved = appointments.where((a) => a.status == "approved").length;
    final completed = appointments.where((a) => a.status == "completed").length;
    final totalRevenue = appointments
        .where((a) => a.status == "completed")
        .fold(0.0, (sum, a) => sum + a.price);

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Pendientes",
                  value: "$pending",
                  color: Colors.orange,
                  icon: Icons.pending_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: "Aprobadas",
                  value: "$approved",
                  color: Colors.blue,
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Completadas",
                  value: "$completed",
                  color: Colors.green,
                  icon: Icons.verified_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: "Ingresos",
                  value: "\$${totalRevenue.toStringAsFixed(0)}",
                  color: Colors.pinkAccent,
                  icon: Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📋 Lista de citas según filtro
  Widget _buildAppointmentsList(String status) {
    return StreamBuilder<List<Appointment>>(
      stream: _appointmentService.getAllAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No hay citas registradas",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Filtrar según el tab
        List<Appointment> filtered = snapshot.data!;
        if (status != "all") {
          filtered = filtered.where((a) => a.status == status).toList();
        }

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              "No hay citas con este estado",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final appointment = filtered[index];
            return _AppointmentCard(
              appointment: appointment,
              onApprove: () => _approveAppointment(appointment.id),
              onReject: () => _rejectAppointment(appointment.id),
              onComplete: () => _completeAppointment(appointment.id),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Panel de Administración",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Todas"),
            Tab(text: "Pendientes"),
            Tab(text: "Aprobadas"),
            Tab(text: "Completadas"),
          ],
        ),
      ),
      body: Column(
        children: [
          // 📊 ESTADÍSTICAS
          StreamBuilder<List<Appointment>>(
            stream: _appointmentService.getAllAppointments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              return _buildStatistics(snapshot.data!);
            },
          ),

          const Divider(height: 1),

          // 📋 CONTENIDO DE TABS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList("all"),
                _buildAppointmentsList("pending"),
                _buildAppointmentsList("approved"),
                _buildAppointmentsList("completed"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de tarjeta de estadística
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de tarjeta de cita
class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onComplete;

  const _AppointmentCard({
    required this.appointment,
    required this.onApprove,
    required this.onReject,
    required this.onComplete,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "approved":
        return Colors.blue;
      case "completed":
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return "Pendiente";
      case "approved":
        return "Aprobada";
      case "completed":
        return "Completada";
      default:
        return "Cancelada";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con imagen
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  appointment.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    _getStatusText(appointment.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Información
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y precio
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appointment.designTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${appointment.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Cliente
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        appointment.userName ?? "Cliente",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // Fecha y hora
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('dd/MM/yyyy').format(appointment.date),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      appointment.time,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),

                // Descripción
                if (appointment.description != null &&
                    appointment.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      appointment.description!,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                // Botones de acción
                const SizedBox(height: 12),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (appointment.status.toLowerCase()) {
      case "pending":
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check, size: 18),
                label: const Text("Aprobar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close, size: 18),
                label: const Text("Rechazar"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );

      case "approved":
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.verified, size: 18),
            label: const Text("Marcar como Completada"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}