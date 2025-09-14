import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../widgets/business_card.dart';
import '../models/business.dart';
import 'business_detail_screen.dart';

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({super.key});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<BusinessProvider>(context, listen: false);
      prov.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Businesses'),
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, prov, _) {
          final state = prov.state;
          switch (state.status) {
            case BusinessStateStatus.initial:
            case BusinessStateStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case BusinessStateStatus.empty:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No results'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: prov.retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );

            case BusinessStateStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: prov.retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );

            case BusinessStateStatus.loaded:
              final filteredItems = state.items.where((b) {
                final query = _searchQuery.toLowerCase();
                return b.name.toLowerCase().contains(query) ||
                       b.location.toLowerCase().contains(query) ||
                       b.phone.toLowerCase().contains(query);
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search',
                      ),
                      onChanged: (q) {
                        setState(() {
                          _searchQuery = q.trim();
                        });
                      },
                    ),
                  ),
                  if (filteredItems.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No matching businesses found.'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (_, idx) {
                          final b = filteredItems[idx];
                          return BusinessCard<Business>(
                            item: b,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BusinessDetailScreen(business: b),
                                ),
                              );
                            },
                            builder: (ctx, business) {
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.green.shade200,
                                    child: Text(
                                      _initials(business.name),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          business.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Text('${business.location} • ${business.phone}'),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              );
          }
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
