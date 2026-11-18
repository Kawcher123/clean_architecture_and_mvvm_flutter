import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/native_device_viewmodel.dart';

class NativeDeviceView extends StatefulWidget {
  const NativeDeviceView({super.key});

  @override
  State<NativeDeviceView> createState() => _NativeDeviceViewState();
}

class _NativeDeviceViewState extends State<NativeDeviceView> {
  final messageController = TextEditingController(
    text: 'Hello from Flutter MVVM!',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NativeDeviceViewModel>().loadDeviceInfo();
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
        title: const Text('Native Device (MVVM)'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<NativeDeviceViewModel>().loadDeviceInfo(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<NativeDeviceViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.deviceInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null && vm.deviceInfo == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vm.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: vm.loadDeviceInfo,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final info = vm.deviceInfo!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Data from Java / Swift via MethodChannel',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Platform'),
                subtitle: Text(info.platform),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Model'),
                subtitle: Text(info.model),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Manufacturer'),
                subtitle: Text(info.manufacturer),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('OS version'),
                subtitle: Text(info.osVersion),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Battery'),
                subtitle: Text(
                  info.batteryLevel < 0
                      ? 'Unavailable'
                      : '${info.batteryLevel}%',
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Source'),
                subtitle: Text(info.source),
              ),
              const SizedBox(height: 24),
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
                  final ok = await vm.showMessage(messageController.text);
                  if (!context.mounted) return;
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(vm.error ?? 'Failed')),
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
