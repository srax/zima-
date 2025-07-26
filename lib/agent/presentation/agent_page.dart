import 'package:flutter/material.dart';
import '../../auth/presentation/screens/login_screen.dart';
import '../application/agent_controller_provider.dart';
import '../../../app/presentation/widgets/widgets.dart';

class AgentPage extends StatefulWidget {
  final String agentId;
  const AgentPage({super.key, required this.agentId});

  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  late AgentControllerProvider _controllerProvider;

  @override
  void initState() {
    super.initState();
    _controllerProvider = AgentControllerProvider();
    _controllerProvider.initialize(widget.agentId);
  }

  @override
  void dispose() {
    _controllerProvider.dispose();
    super.dispose();
  }

  void _kickToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _controllerProvider,
        builder: (context, child) {
          final controller = _controllerProvider.controller;
          if (controller == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Video player
                  Expanded(
                    child: VideoPlayerWidget(
                      videoRenderer: controller.video,
                      isLoading: controller.isLoading,
                      errorMessage: controller.error,
                    ),
                  ),

                  // Chat input
                  ChatInputWidget(
                    controller: controller.textController,
                    onSend: controller.sendMessage,
                    onVoiceRecord: controller.toggleVoiceRecording,
                    isRecording: controller.isRecording,
                    isLoading: controller.isLoading,
                  ),
                ],
              ),

              // Connection status overlay
              ConnectionStatusWidget(
                isLoading: controller.isLoading,
                errorMessage: controller.error,
                onRetry: controller.retry,
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final controller = _controllerProvider.controller;
    if (controller == null) {
      return AppBar(title: const Text('Agent'));
    }

    return AgentHeaderWidget(
      agentId: widget.agentId,
      onLogout: _kickToLogin,
      avatarUrl: controller.avatarUrl,
      isLoading: controller.isLoading,
    );
  }
}
