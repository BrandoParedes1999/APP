import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paulette/component/footer_user.dart';
import 'package:paulette/screens_users/manicure/mis_citas.dart';
import 'package:paulette/screens_users/notificaciones.dart';
import 'package:paulette/services/notificacion_Service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import 'manicure/manicure_user.dart';

class MenuClient extends StatefulWidget {
  const MenuClient({super.key});

  @override
  State<MenuClient> createState() => _MenuClientState();
}

class _MenuClientState extends State<MenuClient> {
  UserModel? usuario;
  final userService = UserService();
  final notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    usuario = await userService.getUserById(uid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: Text(
          usuario == null ? "..." : "Hola, ${usuario!.nombre} 👋",
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        actions: [
          // Badge de notificaciones con contador
          if (currentUser != null)
            StreamBuilder<int>(
              stream: notificationService.getUnreadCount(currentUser.uid),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 15),

          _menuCard(
            title: "Diseños de Manicure",
            icon: Icons.brush_rounded,
            color: Colors.pinkAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManicureDesignsPage()),
            ),
          ),

          const SizedBox(height: 20),

          _menuCard(
            title: "Servicios de Pedicure",
            icon: Icons.spa_rounded,
            color: Colors.teal,
            onTap: () => print("ir a Pedicure"),
          ),

          const SizedBox(height: 20),

          _menuCard(
            title: "Mis Citas",
            icon: Icons.calendar_month_rounded,
            color: Colors.deepPurple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyAppointmentsScreen()),
            ),
          ),
        ],
      ),
      persistentFooterButtons: const [FooterMenuClient()],
    );
  }

  Widget _menuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            CircleAvatar(
              radius: 32,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}