import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../data/models/catalog_models.dart';
import '../bloc/product_detail_bloc.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.slug});

  final String slug;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<ProductDetailBloc>().load(widget.slug);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
      body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          if (state.status == ProductDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProductDetailStatus.failure || state.product == null) {
            return Center(child: Text(state.errorMessage ?? 'Không tìm thấy sản phẩm'));
          }

          final product = state.product!;
          final images = product.images.isNotEmpty
              ? product.images
              : [const ProductImageModel(url: '', altText: 'placeholder')];
          final variants = product.variants.where((v) => v.active).toList();
          final selected = state.selectedVariant;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 320,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final url = images[index].url;
                            if (url.isEmpty) {
                              return Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 64));
                            }
                            return CachedNetworkImage(
                              imageUrl: resolveImageUrl(url),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(formatVnd(selected?.price), style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold)),
                            if (product.description?.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              Text(product.description!),
                            ],
                            if (variants.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text('Chọn biến thể', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: variants.map((v) {
                                  final label = [v.color, v.size].where((e) => e != null && e.isNotEmpty).join(' / ');
                                  final isSelected = selected?.id == v.id;
                                  return ChoiceChip(
                                    label: Text(label.isEmpty ? v.sku : label),
                                    selected: isSelected,
                                    onSelected: (_) => context.read<ProductDetailBloc>().selectVariant(v),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selected == null
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Giỏ hàng sẽ có ở module Cart')),
                              );
                            },
                      child: const Text('Thêm vào giỏ'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
