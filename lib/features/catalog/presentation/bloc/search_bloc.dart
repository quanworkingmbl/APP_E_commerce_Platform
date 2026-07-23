import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/catalog_models.dart';
import '../../data/repositories/catalog_repository.dart';

part 'search_state.dart';

class SearchBloc extends Cubit<SearchState> {
  SearchBloc(this._repository, this._prefs) : super(const SearchState.initial()) {
    _loadRecent();
  }

  final CatalogRepository _repository;
  final SharedPreferences _prefs;

  Future<void> _loadRecent() async {
    final recent = _prefs.getStringList(AppConstants.recentSearchKey) ?? [];
    emit(state.copyWith(recentSearches: recent));
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    emit(state.copyWith(status: SearchStatus.loading, query: query));
    try {
      final result = await _repository.getProducts(search: query.trim());
      await _saveRecent(query.trim());
      emit(state.copyWith(status: SearchStatus.success, results: result.items, query: query.trim()));
    } catch (_) {
      emit(state.copyWith(status: SearchStatus.failure, errorMessage: 'Tìm kiếm thất bại'));
    }
  }

  Future<void> _saveRecent(String query) async {
    final recent = [query, ...state.recentSearches.where((e) => e != query)].take(8).toList();
    await _prefs.setStringList(AppConstants.recentSearchKey, recent);
    emit(state.copyWith(recentSearches: recent));
  }

  void clearResults() {
    emit(state.copyWith(status: SearchStatus.initial, results: [], query: ''));
  }
}
