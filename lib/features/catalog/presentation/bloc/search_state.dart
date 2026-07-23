part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  const SearchState({
    required this.status,
    this.query = '',
    this.results = const [],
    this.recentSearches = const [],
    this.errorMessage,
  });

  const SearchState.initial()
      : status = SearchStatus.initial,
        query = '',
        results = const [],
        recentSearches = const [],
        errorMessage = null;

  final SearchStatus status;
  final String query;
  final List<ProductSummaryModel> results;
  final List<String> recentSearches;
  final String? errorMessage;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<ProductSummaryModel>? results,
    List<String>? recentSearches,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, query, results, recentSearches, errorMessage];
}
