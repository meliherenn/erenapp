import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:erenapp/constants.dart';
import 'package:erenapp/route/route_constants.dart';
import 'package:erenapp/screens/components/dot_indicators.dart';

class OnBordingScreen extends StatefulWidget {
  const OnBordingScreen({super.key});

  @override
  State<OnBordingScreen> createState() => _OnBordingScreenState();
}

class _OnBordingScreenState extends State<OnBordingScreen> {
  late final PageController _pageController;
  int _pageIndex = 0;

  final List<_OnboardModel> _pages = const [
    _OnboardModel(
      image: "assets/onboarding_assets/Illustration-0.png",
      title: "Aradığınız ürünü \nbulun",
      description:
      "Burada, sorunsuz bir gezinme deneyimi için özenle sınıflandırılmış zengin ürün çeşitlerini göreceksiniz.",
    ),
    _OnboardModel(
      image: "assets/onboarding_assets/Illustration-1.png",
      title: "Alışveriş sepetinizi \ndoldurun",
      description:
      "İstediğiniz herhangi bir ürünü sepetinize ekleyin veya istek listenize kaydedin.",
    ),
    _OnboardModel(
      image: "assets/onboarding_assets/Illustration-2.png",
      title: "Hızlı ve güvenli \nödeme",
      description: "Kolaylığınız için birçok ödeme seçeneği mevcuttur.",
    ),
    _OnboardModel(
      image: "assets/onboarding_assets/Illustration-3.png",
      title: "Paket takibi",
      description:
      "Siparişlerinizi paketleyebilir ve gönderilerinizi sorunsuz yönetmenize yardımcı olabiliriz.",
    ),
    _OnboardModel(
      image: "assets/onboarding_assets/Illustration-4.png",
      title: "Yakındaki mağazalar",
      description:
      "Yakındaki mağazaları takip edin, ürünlerine göz atın ve bilgi alın.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, logInScreenRoute);
  }

  void _next() {
    if (_pageIndex < _pages.length - 1) {
      _pageController.nextPage(duration: defaultDuration, curve: Curves.ease);
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    "Atla",
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  itemBuilder: (context, index) {
                    final m = _pages[index];
                    final isTextOnTop = index.isOdd;

                    final image = Flexible(
                      flex: 11,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.asset(m.image, fit: BoxFit.contain),
                      ),
                    );

                    final text = Flexible(
                      flex: 9,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            m.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            m.description,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    );

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isTextOnTop) text,
                        if (isTextOnTop) const SizedBox(height: 16),
                        image,
                        if (!isTextOnTop) const SizedBox(height: 16),
                        if (!isTextOnTop) text,
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  ...List.generate(
                    _pages.length,
                        (i) => Padding(
                      padding: const EdgeInsets.only(right: defaultPadding / 4),
                      child: DotIndicator(isActive: i == _pageIndex),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/Arrow - Right.svg",
                        width: 32,
                        height: 32,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardModel {
  final String image;
  final String title;
  final String description;
  const _OnboardModel({
    required this.image,
    required this.title,
    required this.description,
  });
}
