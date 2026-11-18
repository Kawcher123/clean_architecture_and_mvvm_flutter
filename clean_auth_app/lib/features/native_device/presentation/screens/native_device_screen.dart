import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/native_device_provider.dart';

class NativeDeviceScreen extends StatefulWidget {
  const NativeDeviceScreen({super.key});

  @override
  State<NativeDeviceScreen> createState() => _NativeDeviceScreenState();
}

class _NativeDeviceScreenState extends State<NativeDeviceScreen> {
  final messageController = TextEditingController(
    text: 'Hello from Flutter Clean Architecture!',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NativeDeviceProvider>().loadDeviceInfo();
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Device (MethodChannel)'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<NativeDeviceProvider>().loadDeviceInfo(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<NativeDeviceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.deviceInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.deviceInfo == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: provider.loadDeviceInfo,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final info = provider.deviceInfo!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Data from Java / Swift via MethodChannel',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _InfoTile(label: 'Platform', value: info.platform),
              _InfoTile(label: 'Model', value: info.model),
              _InfoTile(label: 'Manufacturer', value: info.manufacturer),
              _InfoTile(label: 'OS version', value: info.osVersion),
              _InfoTile(
                label: 'Battery',
                value: info.batteryLevel < 0
                    ? 'Unavailable'
                    : '${info.batteryLevel}%',
              ),
              _InfoTile(label: 'Source', value: info.source),
              const SizedBox(height: 24),
              Text(
                'Show native Toast / Alert',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final ok = await provider.showMessage(messageController.text);
                  if (!context.mounted) return;
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error ?? 'Failed'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.phone_android),
                label: const Text('Call Native UI'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
