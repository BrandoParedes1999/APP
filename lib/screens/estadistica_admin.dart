
import 'package:flutter/material.dart';
import 'package:paulette/screens/reportemenu_admin.dart';

class EstadisticaAdmin extends StatefulWidget {
  const EstadisticaAdmin({super.key});

   @override
  State<EstadisticaAdmin> createState() => _EstadisticaAdminState();
}

  
class _EstadisticaAdminState extends State<EstadisticaAdmin> {
  String _mesSeleccionado = "Enero";
  bool _mostrarMeses = false;

  List<String> meses = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
  ];

  void _seleccionarFiltro(String filtro) {
    print("Filtro seleccionado: $filtro");
  }

  void _descargarPDF() {
    print("Descargando reporte en formato PDF...");
  }

  void _toggleMeses() {
    setState(() {
      _mostrarMeses = !_mostrarMeses;
    });
  }

  void _seleccionarMes(String mes) {
    setState(() {
      _mesSeleccionado = mes;
      _mostrarMeses = false;
    });
    print("Mes seleccionado: $_mesSeleccionado");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text(
          "Reportes",
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Botón del mes
                        InkWell(
                          onTap: _toggleMeses,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _mesSeleccionado,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Botones SEMANAL y MENSUAL 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _seleccionarFiltro("SEMANAL"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              ),
                              child: const Text("SEMANAL", style: TextStyle(fontSize: 14)),
                            ),
                            ElevatedButton(
                              onPressed: () => _seleccionarFiltro("MENSUAL"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              ),
                              child: const Text("MENSUAL", style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Contenedor para gráfica
                        Container(
                          height: 350,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "ESPACIO PARA LA GRÁFICA",
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botón PDF
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _descargarPDF,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                            ),
                            child: const Text("PDF", style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100), 
              ],
            ),

            // Lista flotante de meses
            if (_mostrarMeses)
              Positioned(
                top: 50, // ajusta según donde quieres que aparezca
                left: 20,
                child: Container(
                  width: 150, // ancho reducido
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    itemCount: meses.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => _seleccionarMes(meses[index]),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            meses[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),

      persistentFooterButtons: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          child: ElevatedButton(
            onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context)=>ReportemenuAdmin()),
                );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: const Color(0xFF000000),
              foregroundColor: const Color(0xFFFFFFFF),
              elevation: 5,
            ),
            child: const Text(
              "Inicio",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

