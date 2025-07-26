import 'package:flutter/material.dart';
import 'agent_controller.dart';

class AgentControllerProvider extends ChangeNotifier {
  AgentController? _controller;

  AgentController? get controller => _controller;

  void initialize(String agentId) {
    _controller = AgentController(agentId);
    _controller!.initialize();
    notifyListeners();
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    notifyListeners();
  }
}
