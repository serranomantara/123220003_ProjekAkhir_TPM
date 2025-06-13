import 'package:flutter/material.dart';
import 'dart:async';

class KonversiWaktuPage extends StatefulWidget {
  const KonversiWaktuPage({super.key});

  @override
  State<KonversiWaktuPage> createState() => _KonversiWaktuPageState();
}

class _KonversiWaktuPageState extends State<KonversiWaktuPage>
    with TickerProviderStateMixin {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  // Animation controllers
  late AnimationController _cardAnimationController;
  late AnimationController _clockAnimationController;
  late List<Animation<double>> _cardAnimations;
  late Animation<double> _clockRotationAnimation;

  // Scroll controllers untuk smooth scrolling
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;

  // Animation controllers untuk scroll button
  late AnimationController _scrollButtonAnimationController;
  late Animation<double> _scrollButtonAnimation;

  // Timezone data dengan warna hijau pertanian
  final List<Map<String, dynamic>> _timezones = [
    {
      'name': 'WIB',
      'fullName': 'Waktu Indonesia Barat',
      'offset': 7,
      'icon': Icons.schedule,
      'color': Colors.green.shade600,
      'country': 'Indonesia',
    },
    {
      'name': 'WITA',
      'fullName': 'Waktu Indonesia Tengah',
      'offset': 8,
      'icon': Icons.access_time,
      'color': Colors.green.shade700,
      'country': 'Indonesia',
    },
    {
      'name': 'WIT',
      'fullName': 'Waktu Indonesia Timur',
      'offset': 9,
      'icon': Icons.timer,
      'color': Colors.green.shade800,
      'country': 'Indonesia',
    },
    {
      'name': 'London',
      'fullName': 'Greenwich Mean Time',
      'offset': 0, // GMT
      'icon': Icons.location_city,
      'color': Colors.teal.shade600,
      'country': 'United Kingdom',
    },
    {
      'name': 'New York',
      'fullName': 'Eastern Standard Time',
      'offset': -5, // EST
      'icon': Icons.location_city_outlined,
      'color': Colors.lightGreen.shade600,
      'country': 'United States',
    },
    {
      'name': 'Berlin',
      'fullName': 'Central European Time',
      'offset': 1, // CET
      'icon': Icons.account_balance,
      'color': Colors.green.shade500,
      'country': 'Germany',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollController();
    _startTimer();
  }

  void _initializeAnimations() {
    // Card animation controller
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Clock rotation animation
    _clockAnimationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );

    // Scroll button animation controller
    _scrollButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Clock rotation animation
    _clockRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _clockAnimationController, curve: Curves.linear),
    );

    // Scroll button animation dengan bounce effect
    _scrollButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scrollButtonAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Card animations with staggered effect
    _cardAnimations = List.generate(
      _timezones.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );

    // Start animations
    _cardAnimationController.forward();
    _clockAnimationController.repeat();
  }

  void _setupScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    const double scrollToTopThreshold = 200.0;
    final double offset = _scrollController.offset;

    // Handle scroll to top button visibility
    if (offset > scrollToTopThreshold && !_showScrollToTopButton) {
      setState(() {
        _showScrollToTopButton = true;
      });
      _scrollButtonAnimationController.forward();
    } else if (offset <= scrollToTopThreshold && _showScrollToTopButton) {
      setState(() {
        _showScrollToTopButton = false;
      });
      _scrollButtonAnimationController.reverse();
    }
  }

  // Smooth scroll to top function
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _cardAnimationController.dispose();
    _clockAnimationController.dispose();
    _scrollButtonAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _getTimeForTimezone(int offsetHours) {
    // Get current device time
    final now = DateTime.now();

    // Get device timezone offset
    final deviceOffset = now.timeZoneOffset.inHours;

    // Calculate the target timezone time
    final targetTime = now.add(Duration(hours: offsetHours - deviceOffset));

    return targetTime;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _formatDate(DateTime time) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];

    return '${days[time.weekday % 7]}, ${time.day} ${months[time.month - 1]} ${time.year}';
  }

  Widget _buildTimezoneCard(Map<String, dynamic> timezone, int index) {
    final targetTime = _getTimeForTimezone(timezone['offset']);

    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimations[index].value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - _cardAnimations[index].value)),
            child: Opacity(
              opacity: _cardAnimations[index].value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 12,
                  shadowColor: timezone['color'].withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          timezone['color'].withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: timezone['color'].withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with icon and timezone info
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: timezone['color'].withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  timezone['icon'],
                                  color: timezone['color'],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      timezone['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: timezone['color'],
                                      ),
                                    ),
                                    Text(
                                      timezone['country'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Time difference indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: timezone['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'UTC${timezone['offset'] >= 0 ? '+' : ''}${timezone['offset']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: timezone['color'],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Full timezone name
                          Text(
                            timezone['fullName'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Time display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  timezone['color'].withOpacity(0.1),
                                  timezone['color'].withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: timezone['color'].withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _formatTime(targetTime),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: timezone['color'],
                                    fontFamily: 'monospace',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(targetTime),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _clockRotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _clockRotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'Konversi Waktu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade800.withOpacity(0.95),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade800, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
              Color(0xFF81C784),
              Color(0xFFE8F5E9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Current device time header
              Container(
                margin: const EdgeInsets.all(16),
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.green.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.green.shade50],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.smartphone,
                                  color: Colors.green.shade600,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Waktu Perangkat Anda',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade100,
                                  Colors.green.shade50,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _formatTime(_currentTime),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                    fontFamily: 'monospace',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(_currentTime),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Timezone cards
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _timezones.length,
                      itemBuilder: (context, index) {
                        return _buildTimezoneCard(_timezones[index], index);
                      },
                    ),

                    // Smooth Scroll to Top Button
                    if (_showScrollToTopButton)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: ScaleTransition(
                          scale: _scrollButtonAnimation,
                          child: FloatingActionButton(
                            onPressed: _scrollToTop,
                            backgroundColor: Colors.green.shade600,
                            elevation: 8,
                            child: const Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
