import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/business.dart';
import '../services/api_services.dart';
import '../services/storage_services.dart';


enum BusinessStateStatus { initial, loading, loaded, empty, error }

class BusinessState {
  final BusinessStateStatus status;
  final List<Business> items;
  final String? message;

  BusinessState._({required this.status, this.items = const [], this.message});

  factory BusinessState.initial() => BusinessState._(status: BusinessStateStatus.initial);
  factory BusinessState.loading() => BusinessState._(status: BusinessStateStatus.loading);
  factory BusinessState.loaded(List<Business> items) => BusinessState._(status: BusinessStateStatus.loaded, items: items);
  factory BusinessState.empty() => BusinessState._(status: BusinessStateStatus.empty);
  factory BusinessState.error(String message) => BusinessState._(status: BusinessStateStatus.error, message: message);
}

class BusinessProvider extends ChangeNotifier {
  final ApiService api;
  final StorageService storage;

  BusinessState _state = BusinessState.initial();
  BusinessState get state => _state;

  BusinessProvider({required this.api, required this.storage});

  Future<void> load() async {
    _state = BusinessState.loading();
    notifyListeners();

    try {
      final raw = await api.fetchRawBusinesses();
      final jsonString = jsonEncode(raw);
      // try parse into model (normalize + validate)
      final List<Business> parsed = [];
      for (var i = 0; i < raw.length; i++) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(raw[i] as Map);
        final b = Business.fromMap(map, idPrefix: 'biz', idx: i);
        parsed.add(b);
      }
      if (parsed.isEmpty) {
        _state = BusinessState.empty();
        notifyListeners();
        return;
      }
      // persist for offline
      await storage.saveBusinessesJson(jsonString);
      _state = BusinessState.loaded(parsed);
      notifyListeners();
    } catch (e) {
      // on network/config error -> try cached
      final cached = await storage.loadBusinessesJson();
      if (cached != null) {
        try {
          final rawCached = jsonDecode(cached) as List<dynamic>;
          final List<Business> parsed = [];
          for (var i = 0; i < rawCached.length; i++) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(rawCached[i] as Map);
            final b = Business.fromMap(map, idPrefix: 'cached', idx: i);
            parsed.add(b);
          }
          _state = BusinessState.loaded(parsed);
          notifyListeners();
          return;
        } catch (_) {
          // fallthrough to error
        }
      }
      _state = BusinessState.error(e.toString());
      notifyListeners();
    }
  }

  Future<void> retry() async => load();
}
