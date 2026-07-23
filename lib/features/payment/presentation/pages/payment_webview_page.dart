import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/di/injection.dart';
import '../../data/repositories/payment_repository.dart';

class PaymentWebViewPage extends StatefulWidget {
  const PaymentWebViewPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  final _repo = getIt<PaymentRepository>();
  WebViewController? _controller;
  var _loading = true;
  var _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPayment();
  }

  Future<void> _initPayment() async {
    try {
      final payment = await _repo.createPayment(widget.orderId);
      if (!mounted) return;
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => _loading = true),
            onPageFinished: (_) => setState(() => _loading = false),
            onNavigationRequest: (request) {
              if (_handleReturnUrl(request.url)) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(payment.paymentUrl));
      setState(() {
        _controller = controller;
        _initialized = true;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool _handleReturnUrl(String url) {
    if (!url.contains('/payments/vnpay/return')) {
      return false;
    }
    final uri = Uri.tryParse(url);
    final code = uri?.queryParameters['vnp_ResponseCode'];
    if (code == '00') {
      context.go('/payment/success?orderId=${widget.orderId}');
    } else {
      context.go('/payment/failure?orderId=${widget.orderId}');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/orders/${widget.orderId}'),
        ),
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _initPayment, child: const Text('Thử lại')),
                  ],
                ),
              ),
            )
          else if (_initialized && _controller != null)
            WebViewWidget(controller: _controller!)
          else
            const SizedBox.shrink(),
          if (_loading)
            const ColoredBox(
              color: Color(0x88FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
