import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:paulette/models/notificacion_model.dart';
import 'package:paulette/services/notificacion_Service.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  /// 🎨 Icono según tipo
  IconData _getIcon(String type) {
    switch (type) {
      case "appointment_approved":
        return Icons.check_circle;
      case "appointment_rejected":
        return Icons.cancel;
      case "reminder":
        return Icons.notifications_active;
      default:
        return Icons.notifications;
    }
  }

  /// 🎨 Color según tipo
  Color _getColor(String type) {
    switch (type) {
      case "appointment_approved":
        return Colors.green;
      case "appointment_rejected":
        return Colors.red;
      case "reminder":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  /// ✅ Marcar todas como leídas
  Future<void> _markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _notificationService.markAllAsRead(user.uid);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Todas las notificaciones marcadas como leídas"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 🗑️ Eliminar notificación
  Future<void> _deleteNotification(String id) async {
    await _notificationService.deleteNotification(id);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Notificaciones"),
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text("Debes iniciar sesión"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Notificaciones",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Marcar todas como leídas",
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _notificationService.getUserNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No tienes notificaciones",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final icon = _getIcon(notification.type);
              final color = _getColor(notification.type);

              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteNotification(notification.id);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? Colors.white
                        : color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notification.isRead
                          ? Colors.grey.shade200
                          : color.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.w600
                            : FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          notification.body,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      if (!notification.isRead) {
                        await _notificationService.markAsRead(notification.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return "Ahora";
    } else if (difference.inHours < 1) {
      return "Hace ${difference.inMinutes} min";
    } else if (difference.inDays < 1) {
      return "Hace ${difference.inHours} h";
    } else if (difference.inDays < 7) {
      return "Hace ${difference.inDays} d";
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}