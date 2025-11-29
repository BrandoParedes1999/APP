import 'package:flutter/material.dart';
import 'package:paulette/screens/manicure/add.design_cloudinary.dart';
import 'package:paulette/screens/manicure/edit_design_page.dart';
import 'package:paulette/services/cloudinary_service.dart';
import '../../services/design_service.dart';
import '../../models/design_model.dart';

class ManicuraAdmin extends StatefulWidget {
  const ManicuraAdmin({super.key});

  @override
  State<ManicuraAdmin> createState() => _ManicuraAdminState();
}

class _ManicuraAdminState extends State<ManicuraAdmin> {
  final DesignService _designService = DesignService();

  String searchQuery = "";
  String selectedSeason = "Todas";
  String selectedCategory = "Todas"; // 👈 Nuevo filtro

  final List<String> seasonOptions = [
    "Todas",
    "Verano",
    "Invierno",
    "Otoño",
    "Primavera"
  ];

  // 👇 Lista de categorías para el filtro
  final List<String> categoryOptions = [
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
      appBar: AppBar(
        elevation: 5,
        title: const Text(
          "Manicura",
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ---------------- BUSCADOR ----------------
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar diseño...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // ---------------- FILTROS ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // Filtro por temporada
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedSeason,
                          isExpanded: true,
                          items: seasonOptions.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSeason = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // 👇 Filtro por categoría
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.category, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          items: categoryOptions.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ---------------- LISTA DE TARJETAS ----------------
          Expanded(
            child: StreamBuilder<List<DesignModel>>(
              stream: _designService.getDesigns(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DesignModel> designs = snapshot.data!;

                // FILTRAR POR BÚSQUEDA
                designs = designs.where((d) {
                  final titleMatch = d.title.toLowerCase().contains(searchQuery);
                  return titleMatch;
                }).toList();

                // FILTRAR POR TEMPORADA
                if (selectedSeason != "Todas") {
                  designs = designs.where((d) {
                    return d.season.toLowerCase() == selectedSeason.toLowerCase();
                  }).toList();
                }

                // 👇 FILTRAR POR CATEGORÍA
                if (selectedCategory != "Todas") {
                  designs = designs.where((d) {
                    // Verificar si la categoría seleccionada está en la lista de categorías del diseño
                    return d.categories.any((cat) => 
                      cat.toLowerCase() == selectedCategory.toLowerCase()
                    );
                  }).toList();
                }

                if (designs.isEmpty) {
                  return const Center(
                    child: Text("No hay diseños que coincidan."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: designs.length,
                  itemBuilder: (context, index) {
                    final design = designs[index];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.network(
                              design.imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  design.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // 👇 MOSTRAR CATEGORÍAS
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: design.categories.map((cat) {
                                    return Chip(
                                      label: Text(
                                        cat,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor: Colors.pink.shade50,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 0,
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 8),
                                
                                Text(
                                  "Temporada: ${design.season}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  "Precio: \$${design.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 12),

                                // ----------- BOTONES EDITAR Y ELIMINAR -----------
                                Row(
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit),
                                      label: const Text("Editar"),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditDesignPage(design: design),
                                          ),
                                        );
                                      },
                                    ),

                                    const Spacer(),

                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text("Eliminar",
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () async {
                                        final confirmar = await showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text("¿Eliminar diseño?"),
                                            content: const Text(
                                                "Esta acción no se puede deshacer."),
                                            actions: [
                                              TextButton(
                                                child: const Text("Cancelar"),
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  "Eliminar",
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(context, true),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmar != true) return;

                                        try {
                                          if (design.publicId.isNotEmpty) {
                                            await CloudinaryService.deleteImage(
                                                design.publicId);
                                          }

                                          await _designService.deleteDesign(design.id);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text("Diseño eliminado")));
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text("Error: $e")));
                                        }
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ---------------- FOOTER ----------------
      persistentFooterButtons: [
        Row(
          children: [
            _footerButton(Icons.menu, "Inicio", () {}),
            const Spacer(),
            _footerButton(Icons.add, "Añadir", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDesignCloudinaryPage()),
              );
            }),
            const Spacer(),
            _footerButton(Icons.settings, "Ajustes", () {}),
          ],
        ),
      ],
    );
  }

  Widget _footerButton(IconData icon, String label, Function onTap) {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}