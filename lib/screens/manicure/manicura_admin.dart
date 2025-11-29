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

  // NUEVA FUNCIÓN: Alternar el estado activo
  Future<void> _toggleDesignStatus(
      String designId, bool currentStatus) async {
    try {
      // Se asume que DesignService tiene la función toggleActiveStatus
      await _designService.toggleActiveStatus(
          designId, !currentStatus); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentStatus
                  ? "Diseño Activado (Visible al cliente)"
                  : "Diseño Desactivado (Oculto al cliente)",
            ),
            backgroundColor: !currentStatus ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cambiar estado: $e")),
        );
      }
    }
  }

  // Lógica de eliminación (código existente)
  Future<void> _deleteDesign(DesignModel design) async {
    final confirmar = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar diseño?"),
        content: const Text(
            "Esta acción eliminará el diseño y su imagen permanentemente."),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      if (design.publicId.isNotEmpty) {
        // Asumiendo que CloudinaryService tiene la función deleteImage
        await CloudinaryService.deleteImage(design.publicId);
      }

      await _designService.deleteDesign(design.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Diseño eliminado")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

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

                // APLICAR FILTROS DE BÚSQUEDA, TEMPORADA y CATEGORÍA
                designs = designs.where((d) {
                  final titleMatch = d.title.toLowerCase().contains(searchQuery);
                  
                  final seasonMatch = selectedSeason == "Todas" ||
                      d.season.toLowerCase() == selectedSeason.toLowerCase();

                  final categoryMatch = selectedCategory == "Todas" ||
                      d.categories.any((cat) => 
                          cat.toLowerCase() == selectedCategory.toLowerCase());
                      
                  return titleMatch && seasonMatch && categoryMatch;
                }).toList();

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
                          // IMAGEN Y BADGE DE ESTATUS
                          Stack(
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
                              // BADGE DE ESTATUS (ACTIVO/INACTIVO)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: design.isActive
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    design.isActive ? "ACTIVO" : "INACTIVO",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                      onPressed: () => _deleteDesign(design),
                                    ),
                                  ],
                                ),

                                const Divider(height: 1), 

                                // TOGGLE DE ACTIVIDAD (ACTIVO/INACTIVO)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Mostrar al Cliente",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: design.isActive
                                              ? Colors.green
                                              : Colors.red),
                                    ),
                                    Switch(
                                      value: design.isActive,
                                      onChanged: (newStatus) =>
                                          _toggleDesignStatus(
                                              design.id, design.isActive),
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.red,
                                    )
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