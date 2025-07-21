import 'package:flutter/material.dart';
import '../../apis/did_api.dart';
import '../agent_page.dart';

class AgentsListScreen extends StatefulWidget {
  const AgentsListScreen({super.key});

  @override
  State<AgentsListScreen> createState() => _AgentsListScreenState();
}

class _AgentsListScreenState extends State<AgentsListScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, List<Map<String, dynamic>>>> _future;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _future = DidApi.fetchAgents();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    ); // Default to 'My Agents'
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agents'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Agents'),
            Tab(text: 'All Agents'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final agentsMap = snapshot.data ?? {'all': [], 'mine': []};
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAgentsList(agentsMap['mine']!),
              _buildAgentsList(agentsMap['all']!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAgentsList(List<Map<String, dynamic>> agents) {
    if (agents.isEmpty) {
      return const Center(child: Text('No agents found.'));
    }
    return ListView.builder(
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agent = agents[index];
        final name = agent['preview_name'] ?? 'Agent';
        final id = agent['id'] ?? '';
        final description = agent['preview_description'] ?? '';
        final thumbnail = agent['preview_thumbnail'] as String?;
        return ListTile(
          leading: thumbnail != null
              ? CircleAvatar(backgroundImage: NetworkImage(thumbnail))
              : const CircleAvatar(child: Icon(Icons.person)),
          title: Text(name),
          subtitle: Text(description),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AgentPage(agentId: id)),
            );
          },
        );
      },
    );
  }
}
