import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'form_penyewaan.dart';
import 'login.dart';
import 'penyewaan.dart';

class DaftarPenyewaan extends StatelessWidget {
  DaftarPenyewaan({super.key});

  final PenyewaanController controller = Get.find();

  Future<bool> _confirmLogout(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          "Konfirmasi",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "apakah anda yakin ingin logout?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Batal", style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text("Lanjutkan", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          "Konfirmasi",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "apakah anda yakin ingin menghapus daftar penyewaan ini?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Batal", style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text("Lanjutkan", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
    return result ?? false;
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF241A22) : const Color(0xFFE9C1D4);
    final appBarBg = isDark ? const Color(0xFF2F2330) : const Color(0xFFF1ECEF);
    final cardBg = isDark ? const Color(0xFF3A2D3A) : const Color(0xFFE8DEE4);
    final textColor = isDark
        ? const Color(0xFFF1DFE8)
        : const Color(0xFF4C3A45);
    final accentColor = isDark
        ? const Color(0xFFE7A1C5)
        : const Color(0xFF7E4C69);
    final borderColor = isDark
        ? const Color(0xFF5D4A5C)
        : const Color(0xFFCCBEC7);
    final shadowColor = isDark ? Colors.black54 : Colors.black26;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Daftar Penyewaan",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
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
          return Center(
            child: Text(
              "Belum ada data penyewaan",
              style: TextStyle(color: textColor),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: controller.penyewaanList.length,
          itemBuilder: (context, index) {
            final data = controller.penyewaanList[index];
            final id = _pickId(data);
            final nama = _pickText(data, ['nama', 'Nama', 'Nama Penyewa']);
            final tanggal = _pickText(data, [
              'tanggal',
              'Tanggal',
              'Tanggal Penyewaan',
            ]);
            final kegiatan = _pickText(data, [
              'kegiatan',
              'Kegiatan',
              'Kegiatan Acara',
            ]);

            return Card(
              color: cardBg,
              elevation: 3,
              shadowColor: shadowColor,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: borderColor, width: 0.8),
              ),
              child: ListTile(
                title: Text(
                  nama,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "$tanggal\n$kegiatan",
                  style: TextStyle(color: textColor),
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: accentColor),
                      onPressed: () {
                        if (id != null) {
                          _showEditDialog(context, id, data);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        if (id == null) return;
                        final confirmed = await _confirmDelete(context);
                        if (!confirmed) return;
                        final errorMessage = await controller.hapusPenyewaan(
                          id,
                        );
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) async {
          if (index == 0) {
            Get.off(() => FormPenyewaan());
            return;
          }
          if (index == 2) {
            final confirmed = await _confirmLogout(context);
            if (!confirmed) return;
            await controller.supabase.auth.signOut();
            Get.offAll(() => LoginPage());
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Form",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: "Daftar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_outlined),
            activeIcon: Icon(Icons.logout),
            label: "Logout",
          ),
        ],
      ),
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
