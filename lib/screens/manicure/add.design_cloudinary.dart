import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cloudinary_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AddDesignCloudinaryPage extends StatefulWidget {
  const AddDesignCloudinaryPage({super.key});

  @override
  State<AddDesignCloudinaryPage> createState() =>
      _AddDesignCloudinaryPageState();
}

class _AddDesignCloudinaryPageState extends State<AddDesignCloudinaryPage> {
  final nombreCtrl = TextEditingController();
  final precioCtrl = TextEditingController();

  File? imageFile;
  bool isLoading = false;

  final List<String> categories = [
    "Todas",
    "Flores",
    "Minimalista",
    "Acrílico",
    "3D",
    "Natural",
  ];

  List<String> selectedCategories = [];

  // Lista de temporadas para el Dropdown
  final List<String> seasons = [
    "Primavera",
    "Verano",
    "Otoño",
    "Invierno",
    "Todo el año",
  ];

  String? selectedSeason;

  Future<void> pickImage() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (picked == null) return;

    final compressed = await _compress(File(picked.path));
    setState(() => imageFile = compressed);
  }

  Future<File> _compress(File file) async {
    final targetPath =
        '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
    );

    if (result == null) return file;

    return File(result.path);
  }

  Future<void> saveDesign() async {
  if (nombreCtrl.text.isEmpty ||
      selectedSeason == null ||
      selectedCategories.isEmpty || 
      precioCtrl.text.isEmpty ||
      imageFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Completa todos los campos")),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    final uploadData = await CloudinaryService.uploadImageFull(imageFile!);

    await FirebaseFirestore.instance.collection("manicure_designs").add({
      "nombre": nombreCtrl.text.trim(),
      "temporada": selectedSeason,
      "categories": selectedCategories, // 👈 Guardar como lista
      "precio": double.parse(precioCtrl.text.trim()),
      "imageUrl": uploadData["url"],
      "publicId": uploadData["public_id"],
      "createdAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Diseño guardado correctamente")),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => isLoading = false);
  }
}

  @override
  void dispose() {
    nombreCtrl.dispose();
    precioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar diseño de manicura"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            // Imagen
            InkWell(
              onTap: pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: imageFile == null
                    ? const Center(
                        child: Text(
                          "Seleccionar imagen",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Nombre
            TextField(
              controller: nombreCtrl,
              decoration: InputDecoration(
                labelText: "Nombre del diseño",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ), 

            const SizedBox(height: 15),

            // Categorías (MULTISELECCIÓN)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade500),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Categorías",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                        },
                        selectedColor: Colors.pink.shade100,
                        checkmarkColor: Colors.pink.shade700,
                      );
                    }).toList(),
                  ),
                  if (selectedCategories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Seleccionadas: ${selectedCategories.join(', ')}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Temporada (DROPDOWN)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade500),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedSeason,
                hint: const Text("Selecciona la temporada"),
                isExpanded: true,
                underline: const SizedBox(),
                items: seasons.map((season) {
                  return DropdownMenuItem(value: season, child: Text(season));
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedSeason = value);
                },
              ),
            ),

            const SizedBox(height: 15),

            // Precio
            TextField(
              controller: precioCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Precio",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOTÓN GUARDAR
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveDesign,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Guardar diseño",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
