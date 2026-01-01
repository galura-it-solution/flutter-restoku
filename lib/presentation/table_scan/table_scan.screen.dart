import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/modal_dialog.dart';

class TableScanScreen extends StatelessWidget {
  const TableScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    Future<void> handleManualInput() async {
      controller.stop();
      final manualController = TextEditingController();
      final inputDecoration = InputDecoration(
        filled: true,
        fillColor: MasterColor.dark_10,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MasterColor.primary.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      );
      final manualTableId = await Get.dialog<int>(
        FormDialogShell(
          icon: Icons.table_bar,
          title: 'Input Nomor Meja',
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: TextField(
              controller: manualController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration.copyWith(hintText: 'Contoh: 12'),
            ),
          ),
          actions: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final raw = manualController.text.trim();
                    final parsed = int.tryParse(raw);
                    if (parsed == null || parsed <= 0) {
                      Get.snackbar(
                        'Info',
                        'Nomor meja tidak valid.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: MasterColor.warning,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(10),
                        borderRadius: 8,
                      );
                      return;
                    }
                    Get.back(result: parsed);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Pilih'),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: true,
      );
      manualController.dispose();
      if (manualTableId == null) {
        controller.start();
        return;
      }
      Get.back(result: manualTableId);
    }

    return Scaffold(
      backgroundColor: MasterColor.black,
      appBar: AppBar(
        backgroundColor: MasterColor.black,
        foregroundColor: MasterColor.white,
        title: const Text('Scan QR Meja'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final raw = capture.barcodes.isNotEmpty
                  ? (capture.barcodes.first.rawValue ?? '')
                  : '';
              if (raw.isEmpty) return;

              final match = RegExp(r'(\d+)').firstMatch(raw);
              if (match == null) return;
              final tableId = int.tryParse(match.group(1) ?? '');
              if (tableId == null) return;

              controller.stop();
              Get.back(result: tableId);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: MasterColor.black.withValues(alpha: 0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Arahkan kamera ke QR code meja',
                    style: TextStyle(
                      color: MasterColor.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: handleManualInput,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MasterColor.white,
                        side: const BorderSide(color: MasterColor.white),
                      ),
                      child: const Text('Input Manual'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
