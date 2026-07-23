import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/product_grid_shimmer.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../bloc/product_list_bloc.dart';
import '../widgets/product_card.dart';
import '../../data/models/catalog_models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.title = 'E-Commerce'});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductListBloc>().load(refresh: true);
    getIt<NotificationBloc>().refreshUnread();
  }

  List<CategoryModel> _flatCategories(List<CategoryModel> roots) {
    final result = <CategoryModel>[];
    void walk(List<CategoryModel> items) {
      for (final c in items) {
        result.add(c);
        if (c.children.isNotEmpty) walk(c.children);
      }
    }
    walk(roots);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
          if (widget.title == 'E-Commerce')
            BlocBuilder<NotificationBloc, NotificationState>(
              bloc: getIt<NotificationBloc>(),
              builder: (context, state) {
                return IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: badges.Badge(
                    showBadge: state.unreadCount > 0,
                    badgeContent: Text(
                      state.unreadCount > 99 ? '99+' : '${state.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                );
              },
            ),
          if (widget.title == 'E-Commerce')
            IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.push('/profile')),
        ],
      ),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          if (state.status == ProductListStatus.loading && state.products.isEmpty) {
            return const ProductGridShimmer();
          }
          if (state.status == ProductListStatus.failure && state.products.isEmpty) {
            return ErrorView(
              message: state.errorMessage ?? 'Không tải được sản phẩm',
              onRetry: () => context.read<ProductListBloc>().load(refresh: true),
            );
          }

          final categories = _flatCategories(state.categories);

          return RefreshIndicator(
            onRefresh: () => context.read<ProductListBloc>().load(refresh: true),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: PageView(
                      children: [
                        _BannerCard(color: AppColors.primary, title: 'Khuyến mãi hè', subtitle: 'Giảm đến 30%'),
                        _BannerCard(color: Colors.deepPurple, title: 'Hàng mới', subtitle: 'Cập nhật mỗi tuần'),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Tất cả'),
                            selected: state.categoryId == null,
                            onSelected: (_) => context.read<ProductListBloc>().selectCategory(null),
                          ),
                        ),
                        ...categories.map((c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(c.name),
                                selected: state.categoryId == c.id,
                                onSelected: (_) => context.read<ProductListBloc>().selectCategory(c.id),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= state.products.length) {
                          context.read<ProductListBloc>().loadMore();
                          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)));
                        }
                        final product = state.products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => context.push('/product/${product.slug}'),
                        );
                      },
                      childCount: state.hasMore ? state.products.length + 1 : state.products.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.color, required this.title, required this.subtitle});

  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.75)]),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
