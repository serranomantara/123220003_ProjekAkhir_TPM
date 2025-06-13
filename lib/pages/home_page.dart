import 'package:flutter/material.dart';
import '../models/egg_product.dart';
import '../api/egg_store_api.dart';
import '../widgets/egg_product_card.dart';
import 'detail_page.dart';
import 'cart_page.dart';
import 'order_page.dart';
import 'kesanpesan_page.dart';
import 'user_page.dart';
import 'konversi_waktu_page.dart'; // Import halaman konversi waktu
import '../services/user_service.dart';
import '../helpers/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<EggProduct> eggProducts = [];
  List<EggProduct> filteredEggProducts = [];
  bool isLoading = true;
  String? error;
  int _currentIndex = 0;
  String? userName;

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = true;
  String _searchQuery = '';

  // Scroll controllers untuk smooth scrolling
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;

  // Animation controllers
  late AnimationController _scrollButtonAnimationController;
  late Animation<double> _scrollButtonAnimation;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchHeightAnimation;
  late Animation<double> _searchOpacityAnimation;

  @override
  void initState() {
    super.initState();
    loadEggProducts();
    loadUserName();
    _initializeAnimations();
    _setupScrollController();
    _setupSearchController();
  }

  void _initializeAnimations() {
    // Animation controller untuk scroll to top button
    _scrollButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Scroll button animation dengan bounce effect
    _scrollButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scrollButtonAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Search animation controller
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Search height animation
    _searchHeightAnimation = Tween<double>(begin: 60.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Search opacity animation
    _searchOpacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Start with expanded search
    _searchAnimationController.reset();
  }

  void _setupScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _setupSearchController() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      _filterProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollButtonAnimationController.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const double scrollToTopThreshold = 200.0;
    const double searchCollapseThreshold = 100.0;
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

    // Handle search bar collapse/expand
    if (offset > searchCollapseThreshold && _isSearchExpanded) {
      setState(() {
        _isSearchExpanded = false;
      });
      _searchAnimationController.forward();
    } else if (offset <= searchCollapseThreshold && !_isSearchExpanded) {
      setState(() {
        _isSearchExpanded = true;
      });
      _searchAnimationController.reverse();
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

  // Filter products based on search query
  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      setState(() {
        filteredEggProducts = eggProducts;
      });
    } else {
      setState(() {
        filteredEggProducts = eggProducts
            .where(
              (product) => product.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();
      });
    }
  }

  // Clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      filteredEggProducts = eggProducts;
    });
  }

  Future<void> loadUserName() async {
    final name = await UserService.getCurrentUserName();
    setState(() {
      userName = name;
    });
  }

  Future<void> loadEggProducts() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final productList = await EggStoreApi().fetchProducts();

      final mappedProducts = productList.map((product) {
        return product.copyWith(imageUrl: product.assetImage);
      }).toList();

      setState(() {
        eggProducts = mappedProducts;
        filteredEggProducts = mappedProducts;
        isLoading = false;
      });
      _filterProducts(); // Apply current search filter
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        ).then((_) {
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderPage(
              selectedCurrency: 'IDR',
              selectedTimezone: 'WIB',
            ),
          ),
        ).then((_) {
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
      case 3:
        // Navigasi ke halaman konversi waktu
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KonversiWaktuPage()),
        ).then((_) {
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KesanPesanPage()),
        ).then((_) {
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.egg_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Relasi Telur',
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
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserPage()),
              ).then((_) => loadUserName());
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await UserService.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              tooltip: 'Keluar',
            ),
          ),
        ],
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
              // Animated Search Bar
              AnimatedBuilder(
                animation: _searchAnimationController,
                builder: (context, child) {
                  return Container(
                    height: _searchHeightAnimation.value,
                    margin: const EdgeInsets.all(16),
                    child: Opacity(
                      opacity: _searchOpacityAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari produk telur...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: _isSearchExpanded ? 16 : 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.green.shade600,
                              size: _isSearchExpanded ? 24 : 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey.shade600,
                                      size: _isSearchExpanded ? 24 : 20,
                                    ),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: _isSearchExpanded ? 16 : 8,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: _isSearchExpanded ? 16 : 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Main Content
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: loadEggProducts,
                      color: Colors.green.shade600,
                      backgroundColor: Colors.white,
                      strokeWidth: 3.0,
                      displacement: 50.0,
                      child: _buildContent(),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green.shade600,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart_rounded),
              label: 'Keranjang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_outlined),
              activeIcon: Icon(Icons.access_time_rounded),
              label: 'Zona Waktu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined),
              activeIcon: Icon(Icons.message_rounded),
              label: 'Kesan Pesan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat produk...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Card(
            elevation: 12,
            shadowColor: Colors.red.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.red.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loadEggProducts,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Colors.red.withOpacity(0.4),
                        ),
                        label: const Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (filteredEggProducts.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Card(
            elevation: 12,
            shadowColor: Colors.orange.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.orange.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Produk Tidak Ditemukan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada produk yang cocok dengan pencarian "$_searchQuery"',
                      style: TextStyle(
                        color: Colors.orange.shade600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Colors.orange.withOpacity(0.4),
                        ),
                        label: const Text(
                          'Hapus Pencarian',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (eggProducts.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Card(
            elevation: 12,
            shadowColor: Colors.green.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.green.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.egg_alt_outlined,
                        size: 48,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Produk Tidak Tersedia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan cek kembali nanti',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 16),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filteredEggProducts.length,
        itemBuilder: (context, index) {
          final product = filteredEggProducts[index];
          return EggProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EggProductDetailPage(product: product),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
