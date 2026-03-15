import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class PenyewaanController extends GetxController {
  final supabase = Supabase.instance.client;

  final namaController = TextEditingController();
  final tanggalController = TextEditingController();
  final kegiatanController = TextEditingController();

  var penyewaanList = <Map<String, dynamic>>[].obs;

  Future<void> fetchPenyewaan() async {
    final data = await supabase
        .from('penyewaan')
        .select()
        .order('id', ascending: false);

    penyewaanList.value = List<Map<String, dynamic>>.from(data);
  }

  @override
  void onInit() {
    fetchPenyewaan();
    super.onInit();
  }

  Future<String?> tambahPenyewaan() async {
    if (namaController.text.isNotEmpty &&
        tanggalController.text.isNotEmpty &&
        kegiatanController.text.isNotEmpty) {
      try {
        await supabase.from('penyewaan').insert({
          'nama': namaController.text,
          'tanggal': tanggalController.text,
          'kegiatan': kegiatanController.text,
        });

        namaController.clear();
        tanggalController.clear();
        kegiatanController.clear();

        await fetchPenyewaan();
        return null;
      } catch (e) {
        return e.toString();
      }
    }

    return 'Semua field wajib diisi';
  }

  Future<String?> updatePenyewaan(
    int id,
    String nama,
    String tanggal,
    String kegiatan,
  ) async {
    try {
      await supabase
          .from('penyewaan')
          .update({'nama': nama, 'tanggal': tanggal, 'kegiatan': kegiatan})
          .eq('id', id);

      await fetchPenyewaan();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> hapusPenyewaan(int id) async {
    try {
      await supabase.from('penyewaan').delete().eq('id', id);
      await fetchPenyewaan();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
