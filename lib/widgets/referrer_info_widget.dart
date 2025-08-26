import 'package:flutter/material.dart';
import 'package:decision_spinner/services/install_referrer_service.dart';

class ReferrerInfoWidget extends StatefulWidget {
  const ReferrerInfoWidget({super.key});

  @override
  State<ReferrerInfoWidget> createState() => _ReferrerInfoWidgetState();
}

class _ReferrerInfoWidgetState extends State<ReferrerInfoWidget> {
  Map<String, String?> _referrerData = {};
  bool _isProcessed = false;

  @override
  void initState() {
    super.initState();
    _loadReferrerData();
  }

  Future<void> _loadReferrerData() async {
    final data = await InstallReferrerService.getReferrerData();
    final processed = await InstallReferrerService.isReferrerProcessed();

    setState(() {
      _referrerData = data;
      _isProcessed = processed;
    });
  }

  Future<void> _resetReferrerData() async {
    await InstallReferrerService.resetReferrerData();
    await _loadReferrerData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Install Referrer Info',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: _loadReferrerData,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Processed: ${_isProcessed ? 'Yes' : 'No'}',
              style: TextStyle(
                color: _isProcessed ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (_referrerData.isNotEmpty) ...[
              const Text(
                'UTM Parameters:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              for (final entry in _referrerData.entries)
                if (entry.value != null && entry.key != 'raw_referrer_data')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            '${entry.key}:',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value!,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),

              if (_referrerData['raw_referrer_data'] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Raw Referrer Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _referrerData['raw_referrer_data']!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ] else ...[
              const Text(
                'No referrer data available',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetReferrerData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset Referrer Data'),
            ),
          ],
        ),
      ),
    );
  }
}
