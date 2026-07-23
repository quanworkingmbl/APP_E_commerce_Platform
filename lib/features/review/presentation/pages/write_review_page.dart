import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/review_bloc.dart';

class WriteReviewPage extends StatefulWidget {
  const WriteReviewPage({
    super.key,
    required this.orderItemId,
    required this.productName,
  });

  final int orderItemId;
  final String productName;

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  int _rating = 5;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viết đánh giá')),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state.status == ReviewStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gửi đánh giá thành công. Chờ admin duyệt.')),
            );
            context.pop(true);
          }
          if (state.errorMessage != null && state.status == ReviewStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(widget.productName, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              const Text('Chọn số sao'),
              Row(
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = star),
                    icon: Icon(
                      star <= _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Nội dung đánh giá',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.status == ReviewStatus.submitting
                    ? null
                    : () => context.read<ReviewBloc>().submitReview(
                          orderItemId: widget.orderItemId,
                          rating: _rating,
                          content: _controller.text.trim(),
                        ),
                child: Text(state.status == ReviewStatus.submitting ? 'Đang gửi...' : 'Gửi đánh giá'),
              ),
            ],
          );
        },
      ),
    );
  }
}
