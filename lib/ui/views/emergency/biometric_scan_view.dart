import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import 'package:go_router/go_router.dart';

class BiometricScanView extends StatefulWidget {
  final bool isFace;
  const BiometricScanView({super.key, this.isFace = true});

  @override
  State<BiometricScanView> createState() => _BiometricScanViewState();
}

class _BiometricScanViewState extends State<BiometricScanView>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  bool _isScanning = false;
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _hasResult = false;
    });
    _scannerController.repeat();

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isScanning = false;
        _hasResult = true;
      });
      _scannerController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFace ? 'RECONNAISSANCE FACIALE' : 'SCAN EMPREINTE DIGITALE',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              widget.isFace
                  ? 'Veuillez placer le visage du patient dans le cadre.'
                  : 'Veuillez placer le doigt sur le lecteur USB.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          _buildScannerUI(),
          const Spacer(),
          if (!_isScanning && !_hasResult)
            Padding(
              padding: const EdgeInsets.all(40),
              child: ElevatedButton(
                onPressed: _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emergencyRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'COMMENCER LE SCAN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          if (_hasResult)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'PATIENT IDENTIFIÉ : Amara Sylla',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'ACCÉDER AU DOSSIER (ID: 9982)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScannerUI() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Frame
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(
                color: _hasResult
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(widget.isFace ? 140 : 24),
            ),
          ),
          // Corners
          if (!_hasResult) ...[
            _buildCorner(Alignment.topLeft, 0),
            _buildCorner(Alignment.topRight, 1),
            _buildCorner(Alignment.bottomLeft, 3),
            _buildCorner(Alignment.bottomRight, 2),
          ],
          // Icon
          Icon(
            widget.isFace
                ? Icons.face_retouching_natural_rounded
                : Icons.fingerprint_rounded,
            color: _hasResult
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
            size: 140,
          ),
          // Scan Line
          if (_isScanning)
            AnimatedBuilder(
              animation: _scannerController,
              builder: (context, child) {
                return Positioned(
                  top: 280 * _scannerController.value,
                  child: Container(
                    width: 280,
                    height: 2,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emergencyRed,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, int quarters) {
    return Positioned(
      child: Align(
        alignment: alignment,
        child: RotatedBox(
          quarterTurns: quarters,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.emergencyRed, width: 4),
                left: BorderSide(color: AppColors.emergencyRed, width: 4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
