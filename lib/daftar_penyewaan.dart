import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'penyewaan.dart';

class DaftarPenyewaan extends StatelessWidget {
  DaftarPenyewaan({super.key});

  final PenyewaanController controller = Get.find();

  String _pickText(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) return value.toString();
    }
    return '';
  }

  int? _pickId(Map<String, dynamic> data) {
    final value = data['id'] ?? data['ID'] ?? data['Id'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Penyewaan"),
        actions: [
          IconButton(
            onPressed: () {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.penyewaanList.isEmpty) {
          return const Center(child: Text("Belum ada data penyewaan"));
        }

        return ListView.builder(
          itemCount: controller.penyewaanList.length,
          itemBuilder: (context, index) {
            final data = controller.penyewaanList[index];
            final id = _pickId(data);
            final nama = _pickText(data, ['nama', 'Nama', 'Nama Penyewa']);
            final tanggal = _pickText(
              data,
              ['tanggal', 'Tanggal', 'Tanggal Penyewaan'],
            );
            final kegiatan = _pickText(
              data,
              ['kegiatan', 'Kegiatan', 'Kegiatan Acara'],
            );

            return Card(
              color: colorScheme.surfaceContainerLow,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(nama),
                subtitle: Text(
                  "$tanggal\n$kegiatan",
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        if (id != null) {
                          _showEditDialog(context, id, data);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (id == null) return;
                        final errorMessage = await controller.hapusPenyewaan(id);
                        if (errorMessage != null) {
                          Get.snackbar(
                            'Error',
                            'Gagal menghapus: $errorMessage',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showEditDialog(
    BuildContext context,
    int id,
    Map<String, dynamic> data,
  ) {
    final namaController = TextEditingController(
      text: _pickText(data, ['nama', 'Nama', 'Nama Penyewa']),
    );
    final tanggalController = TextEditingController(
      text: _pickText(data, ['tanggal', 'Tanggal', 'Tanggal Penyewaan']),
    );
    final kegiatanController = TextEditingController(
      text: _pickText(data, ['kegiatan', 'Kegiatan', 'Kegiatan Acara']),
    );

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Penyewaan"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama Penyewa"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tanggalController,
                decoration: const InputDecoration(
                  labelText: "Tanggal Penyewaan",
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: kegiatanController,
                decoration: const InputDecoration(labelText: "Kegiatan Acara"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final errorMessage = await controller.updatePenyewaan(
                id,
                namaController.text,
                tanggalController.text,
                kegiatanController.text,
              );
              if (errorMessage == null) {
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Gagal mengubah: $errorMessage',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
