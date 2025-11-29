import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Importa el mapa
import 'package:latlong2/latlong.dart'; // Importa las coordenadas

class Ubicacion extends StatelessWidget {
  const Ubicacion({super.key});

  @override
  Widget build(BuildContext context) {
    
    // 1. Define tu ubicación
    final LatLng miUbicacion = LatLng(18.64481, -91.7897874); 

    return Scaffold(
      appBar: AppBar(
        elevation: 5.0,
        title: Text("Ubicación de Paulette"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 500,
          width: 500,
          
          child: FlutterMap(
            // 2. Opciones del mapa (centro y zoom)
            options: MapOptions(
              initialCenter: miUbicacion,
              initialZoom: 16.0,
            ),
            
            // 3. Capas del mapa (hijos)
            children: [
              
              // --- Capa 1: El mapa base (las "teselas") ---
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.paulette', 
              ),
          
              // --- Capa 2: Los marcadores (chinchetas) ---
              MarkerLayer(
                markers: [
                  Marker(
                    point: miUbicacion, // Dónde va el marcador
                    width: 80,
                    height: 80,
                    // El widget del marcador (puedes poner lo que sea)
                    child: Tooltip(
                      message: 'Paulette Estética',
                      child: Icon(
                        Icons.location_pin,
                        color: const Color.fromARGB(255, 45, 4, 230),
                        size: 45,
                      ),
                    ),
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}