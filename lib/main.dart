import 'package:flutter/material.dart';
import 'package:mini_directory/services/api_services.dart';
import 'package:provider/provider.dart';
import 'providers/business_provider.dart';
import 'screens/business_list_screen.dart';
import 'services/storage_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    final storage = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BusinessProvider(api: api, storage: storage)),
      ],
      child: MaterialApp(
        title: 'Mini Business Directory',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const BusinessListScreen(),
      ),
    );
  }
}
