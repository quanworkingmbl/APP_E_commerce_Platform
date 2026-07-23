import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/search_bloc.dart';
import '../widgets/product_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tìm sản phẩm...', border: InputBorder.none),
          onSubmitted: (value) => context.read<SearchBloc>().search(value),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.read<SearchBloc>().search(_controller.text),
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state.status == SearchStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.results.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.recentSearches.isNotEmpty) ...[
                  const Text('Tìm kiếm gần đây', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...state.recentSearches.map((q) => ListTile(
                        title: Text(q),
                        leading: const Icon(Icons.history),
                        onTap: () {
                          _controller.text = q;
                          context.read<SearchBloc>().search(q);
                        },
                      )),
                ] else
                  const Center(child: Text('Nhập từ khóa để tìm sản phẩm')),
              ],
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final product = state.results[index];
              return ProductCard(
                product: product,
                onTap: () => context.push('/product/${product.slug}'),
              );
            },
          );
        },
      ),
    );
  }
}
