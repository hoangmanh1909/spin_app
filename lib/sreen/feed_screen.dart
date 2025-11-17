import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spin_app/controller/process_controller.dart';
import 'package:spin_app/models/feed_response.dart';
import 'package:spin_app/models/login_response.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ProcessController _con = ProcessController();
  final ScrollController _scrollController = ScrollController();

  LoginResponse? userProfile;
  bool _isLoggedIn = false;

  List<FeedResponse> feeds = []; // dữ liệu gốc
  List<FeedResponse> filteredFeeds = []; // dữ liệu sau khi lọc search

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _refreshFeeds();

    // Lắng nghe scroll để load thêm
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 80) {
        _loadMore();
      }
    });
  }

  Future<void> _checkUserStatus() async {
    SharedPreferences? _prefs = await SharedPreferences.getInstance();
    String? userMap = _prefs.getString('user');
    if (userMap != null) {
      setState(() {
        userProfile = LoginResponse.fromJson(jsonDecode(userMap));
        _isLoggedIn = true;
      });
    }
  }

  Future<void> _refreshFeeds() async {
    _currentPage = 1;
    _hasMore = true;
    feeds.clear();
    filteredFeeds.clear();
    await _fetchFeeds();
  }

  Future<void> _fetchFeeds() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;

    var resp = await _con.getFeeds(
      userProfile?.id ?? 0,
      _currentPage,
      _pageSize,
    );

    if (resp.code == "00") {
      List<FeedResponse> newItems = List<FeedResponse>.from(
          (jsonDecode(resp.data!)
              .map((model) => FeedResponse.fromJson(model))));

      if (newItems.length < _pageSize) {
        _hasMore = false;
      }

      feeds.addAll(newItems);

      // update filtered luôn (để search realtime hoạt động)
      filteredFeeds = List.from(feeds);

      _currentPage++;

      if (mounted) setState(() {});
    }

    _isLoadingMore = false;
  }

  Future<void> _loadMore() async {
    if (_hasMore && !_isLoadingMore) {
      await _fetchFeeds();
    }
  }

  void _searchFeed(String keyword) {
    keyword = keyword.toLowerCase();

    setState(() {
      if (keyword.isEmpty) {
        filteredFeeds = List.from(feeds);
      } else {
        filteredFeeds = feeds.where((item) {
          return item.title!.toLowerCase().contains(keyword) ||
              item.content!.toLowerCase().contains(keyword);
        }).toList();
      }
    });
  }

  void _openLikedStories() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đi tới danh sách câu chuyện đã thích ❤️")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD54F),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshFeeds,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _buildHeader(),
              const SizedBox(height: 8),

              // --- Danh sách feed ---
              ...filteredFeeds.map((item) => _buildFeedCard(item)),

              // --- Loading ở cuối trang ---
              if (_isLoadingMore)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (!_hasMore)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: Text(
                      "— Hết rồi 😎 —",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: TextField(
                controller: _searchController,
                onChanged: _searchFeed, // realtime search
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Tìm kiếm...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 46,
            child: GestureDetector(
              onTap: _openLikedStories,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.favorite, color: Colors.red, size: 18),
                    SizedBox(width: 4),
                    Text(
                      "Đã thích",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(FeedResponse item) {
    DateTime createdAt =
        DateFormat("dd/MM/yyyy HH:mm:ss").parse(item.createdAt!);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.content!,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      item.isCustom == "Y"
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          item.isCustom == "Y" ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${item.likes}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm • dd/MM').format(createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
