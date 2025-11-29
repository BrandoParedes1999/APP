import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paulette/component/footer_user.dart';
import 'package:paulette/screens_users/manicure/agenda_cita.dart';
import 'package:paulette/screens_users/menu_client.dart';

class ManicureDesignsPage extends StatefulWidget {
  const ManicureDesignsPage({super.key});

  @override
  State<ManicureDesignsPage> createState() => _ManicureDesignsPageState();
}

class _ManicureDesignsPageState extends State<ManicureDesignsPage> {
  String searchText = "";
  String selectedCategory = "Todas";

  final List<String> categories = [
    "Todas",
    "Flores",
    "Minimalista",
    "Acrílico",
    "3D",
    "Natural",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Diseños de Manicure",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔍 BUSCADOR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar diseño...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) => setState(() => searchText = value),
            ),
          ),

          const SizedBox(height: 10),

          // 🔽 FILTRO POR CATEGORÍA
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: categories.map((cat) {
                final bool isSelected = cat == selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.pinkAccent : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pinkAccent),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.pinkAccent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 📌 LISTA DE DISEÑOS DESDE FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("manicure_designs")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.pinkAccent),
                  );
                }

                final docs = snapshot.data!.docs;

                // 🔎 Aplicar búsqueda
                final filtered = docs.where((doc) {
                  final title = doc["nombre"].toString().toLowerCase();
                  final category = doc["categories"];
                  final searchMatch = title.contains(searchText.toLowerCase());
                  final categoryMatch =
                      selectedCategory == "Todas" ||
                      category == selectedCategory;

                  return searchMatch && categoryMatch;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "No se encontraron diseños",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final image = item["imageUrl"];
                    final title = item["nombre"];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookAppointmentScreen(
                              designId: item.id,
                              designTitle: item["nombre"],
                              imageUrl: item["imageUrl"],
                              price: (item["precio"] is num)
                                  ? (item["precio"] as num).toDouble()
                                  : double.tryParse(
                                          item["precio"].toString(),
                                        ) ??
                                        0.0,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.08),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              child: Image.network(
                                image,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // 🔹 NOMBRE
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                left: 10,
                                right: 10,
                              ),
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),

                            // // 🔹 DESCRIPCIÓN (ahora sí activa)
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 10,
                            //     vertical: 4,
                            //   ),
                            //   child: Text(
                            //     //item["descripcion"] ?? "Sin descripción",
                            //     maxLines: 2,
                            //     overflow: TextOverflow.ellipsis,
                            //     style: const TextStyle(
                            //       fontSize: 12,
                            //       color: Colors.black54,
                            //     ),
                            //   ),
                            // ),

                            // 🔹 PRECIO
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                bottom: 8,
                                right: 10,
                              ),
                              child: Text(
                                "\$${item["precio"]}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      //FOOTER CLIENTE CHICOS
      persistentFooterButtons: const [FooterMenuClient()],
    );
  }
}
