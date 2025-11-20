import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '/router/app_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xff5067e9);

    return Scaffold(
      body: Stack(
        children: [
          // Background putih
          Container(
            color: Colors.white,
          ),
          // Lingkaran blur 1
          Positioned(
            top: -140,
            left: 220,
            child: Container(
              width: 252,
              height: 252,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 100,
                    spreadRadius: 1,
                    color: Color(0xffc5cefd),
                  ),
                ],
              ),
            ),
          ),
          // Lingkaran blur 2 (gradient)
          Positioned(
            top: -140,
            left: 220,
            child: Container(
              width: 252,
              height: 252,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xffc5cefd),
                    const Color(0xffc5cefd).withOpacity(.05),
                    const Color(0xffc5cefd).withOpacity(.01),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 220,
                            child: Image.asset(
                              'assets/images/login-pic.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.home,
                                    size: 120, color: Colors.blue);
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Selamat Datang!',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Masuk atau buat akun dalam sekejap untuk\n'
                            'mengelola data warga, memantau keuangan, dan\n'
                            'mengatur semua kegiatan',
                            style: GoogleFonts.inter(
                              height: 1.4,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            context.go(AppRoutes.login);
                          },
                          child: Text('Masuk',
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            context.go(AppRoutes.register);
                          },
                          child: Text('Daftar',
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
