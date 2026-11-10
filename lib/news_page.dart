import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/gestures.dart';

// ==================== LINK TEXT WITH WEBVIEW ====================

class LinkWebView extends StatefulWidget {
  final String url;
  final String title;

  const LinkWebView({Key? key, required this.url, this.title = 'Lien'})
      : super(key: key);

  @override
  State<LinkWebView> createState() => _LinkWebViewState();
}

class _LinkWebViewState extends State<LinkWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => _progress = progress / 100);
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _progress = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _openInExternalBrowser() async {
    final Uri uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInExternalBrowser,
            tooltip: 'Ouvrir dans le navigateur',
          ),
        ],
        bottom: _isLoading && _progress < 1.0
            ? PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[200],
            valueColor:
            const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

class LinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LinkText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final urlRegExp = RegExp(
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
      caseSensitive: false,
    );

    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in urlRegExp.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: style,
        ));
      }

      String url = text.substring(match.start, match.end);
      String fullUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        fullUrl = 'https://$url';
      }

      spans.add(
        TextSpan(
          text: url,
          style: (style ?? const TextStyle(color: Colors.black)).copyWith(
            color: const Color(0xFF64B5F6),
            decoration: TextDecoration.underline,
          ),
          recognizer: (TapGestureRecognizer()
            ..onTap = () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LinkWebView(
                    url: fullUrl,
                    title: 'Lien externe',
                  ),
                ),
              );
            }),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(
        style: style ?? const TextStyle(color: Colors.white),
        children: spans,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
    );
  }
}

// ==================== FULLSCREEN IMAGE VIEWER ====================

class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final List<String>? allImages;
  final int initialIndex;

  const FullscreenImageViewer({
    Key? key,
    required this.imageUrl,
    this.allImages,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: allImages != null
            ? Text(
          '${initialIndex + 1} / ${allImages!.length}',
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: allImages?.length ?? 1,
        itemBuilder: (context, index) {
          final url = allImages != null ? allImages![index] : imageUrl;
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image,
                        size: 50, color: Colors.white),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== VIDEO PLAYER WITH CHEWIE ====================

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: widget.thumbnailUrl != null
            ? Image.network(widget.thumbnailUrl!, fit: BoxFit.cover)
            : Container(color: Colors.black),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.white, size: 42),
                const SizedBox(height: 8),
                Text(
                  'Erreur de chargement vidéo',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _openInBrowser,
                  child: const Text('Ouvrir dans le navigateur'),
                ),
              ],
            ),
          );
        },
      );

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _openInBrowser() async {
    final Uri url = Uri.parse(widget.videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Vidéo', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
            tooltip: 'Ouvrir dans le navigateur',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: Colors.white, size: 60),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger la vidéo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ouvrir dans le navigateur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      )
          : _chewieController != null
          ? Chewie(controller: _chewieController!)
          : const Center(
        child: Text('Aucune vidéo disponible',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ==================== WEBVIEW VIDEO PLAYER ====================

class WebViewVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const WebViewVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  State<WebViewVideoPlayer> createState() => _WebViewVideoPlayerState();
}

class _WebViewVideoPlayerState extends State<WebViewVideoPlayer> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_getVideoHtml());
  }

  String _getVideoHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <style>
        body, html { margin:0; padding:0; width:100%; height:100%; background:black; overflow:hidden; }
        .video-container { position:fixed; top:0; left:0; width:100%; height:100%; display:flex; justify-content:center; align-items:center; background:black; }
        video { width:100%; height:100%; object-fit:contain; background:black; }
        video::-webkit-media-controls-panel { background-color:rgba(0,0,0,0.7); }
        video::-webkit-media-controls-play-button,
        video::-webkit-media-controls-timeline,
        video::-webkit-media-controls-volume-slider { filter:invert(1); }
      </style>
    </head>
    <body>
      <div class="video-container">
        <video id="videoPlayer" controls autoplay playsinline webkit-playsinline
          src="${widget.videoUrl}" poster="${widget.thumbnailUrl ?? ''}">
          <source src="${widget.videoUrl}" type="video/mp4">
          Votre navigateur ne supporte pas la lecture vidéo.
        </video>
      </div>
    </body>
    </html>
    ''';
  }

  Future<void> _openInBrowser() async {
    final Uri url = Uri.parse(widget.videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen
          ? null
          : AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Vidéo',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
            tooltip: 'Ouvrir dans le navigateur',
          ),
          IconButton(
            icon: Icon(_isFullScreen
                ? Icons.fullscreen_exit
                : Icons.fullscreen),
            onPressed: () => setState(
                    () => _isFullScreen = !_isFullScreen),
            tooltip: 'Plein écran',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Chargement de la vidéo...',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== FACEBOOK POST MODEL ====================

class FacebookPost {
  final String id;
  final String message;
  final String? story;
  final DateTime createdTime;
  final String? pictureUrl;
  final String? fullPictureUrl;
  final bool isVideo;
  final String? videoUrl;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final String? permalinkUrl;
  final List<String> imageUrls;

  FacebookPost({
    required this.id,
    required this.message,
    this.story,
    required this.createdTime,
    this.pictureUrl,
    this.fullPictureUrl,
    required this.isVideo,
    this.videoUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    this.permalinkUrl,
    required this.imageUrls,
  });

  factory FacebookPost.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    bool isVideo = false;
    String? videoUrl;

    if (json['attachments'] != null &&
        json['attachments']['data'] != null &&
        json['attachments']['data'].isNotEmpty) {
      var attachments = json['attachments']['data'];
      for (var attachment in attachments) {
        if (attachment['type'] == 'video' ||
            attachment['media_type'] == 'video') {
          isVideo = true;
          if (attachment['media'] != null &&
              attachment['media']['source'] != null) {
            videoUrl = attachment['media']['source'];
          }
        }
        if (attachment['media'] != null &&
            attachment['media']['image'] != null &&
            attachment['media']['image']['src'] != null) {
          images.add(attachment['media']['image']['src']);
        }
        if (attachment['subattachments'] != null) {
          var subData = attachment['subattachments']['data'];
          for (var sub in subData) {
            if (sub['media'] != null &&
                sub['media']['image'] != null &&
                sub['media']['image']['src'] != null) {
              images.add(sub['media']['image']['src']);
            }
          }
        }
      }
    }

    if (images.isEmpty) {
      if (json['full_picture'] != null) {
        images.add(json['full_picture']);
      } else if (json['picture'] != null) {
        images.add(json['picture']);
      }
    }

    int likes = 0;
    if (json['likes'] != null) {
      if (json['likes']['summary'] != null) {
        likes = json['likes']['summary']['total_count'] ?? 0;
      } else if (json['likes']['data'] != null) {
        likes = json['likes']['data'].length;
      }
    }
    int comments = 0;
    if (json['comments'] != null) {
      if (json['comments']['summary'] != null) {
        comments = json['comments']['summary']['total_count'] ?? 0;
      } else if (json['comments']['data'] != null) {
        comments = json['comments']['data'].length;
      }
    }
    int shares = json['shares']?['count'] ?? 0;

    return FacebookPost(
      id: json['id'] ?? '',
      message: json['message'] ?? json['story'] ?? 'Aucune description',
      story: json['story'],
      createdTime: DateTime.parse(
          json['created_time'] ?? DateTime.now().toIso8601String()),
      pictureUrl: json['picture'],
      fullPictureUrl: json['full_picture'],
      isVideo: isVideo,
      videoUrl: videoUrl,
      likesCount: likes,
      commentsCount: comments,
      sharesCount: shares,
      permalinkUrl: json['permalink_url'],
      imageUrls: images,
    );
  }
}

// ==================== FACEBOOK SERVICE ====================

class FacebookService {
  static Future<List<FacebookPost>> fetchPosts({
    required String pageId,
    required String accessToken,
    required String apiVersion,
  }) async {
    try {
      final path = '/$apiVersion/$pageId/posts';
      final queryParams = {
        'fields':
        'message,created_time,full_picture,permalink_url,attachments{media_type,media,url,subattachments}',
        'limit': '10',
        'access_token': accessToken,
      };

      final url = Uri.https('graph.facebook.com', path, queryParams);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          List<FacebookPost> posts = [];
          for (var postJson in data['data']) {
            posts.add(FacebookPost.fromJson(postJson));
          }
          return posts;
        }
        return [];
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  static Future<void> openFacebookPost(String? permalinkUrl) async {
    if (permalinkUrl == null || permalinkUrl.isEmpty) return;
    final Uri url = Uri.parse(permalinkUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  }
}

// ==================== WYDAD NEWS PAGE (DARK DESIGN) ====================

class WydadNewsPage extends StatefulWidget {
  final String? token;
  final String? currentOrganizationId;
  final String? facebookPageId;
  final String? facebookPageToken;
  final String? graphApiVersion;

  const WydadNewsPage({
    Key? key,
    this.token,
    this.currentOrganizationId,
    this.facebookPageId,
    this.facebookPageToken,
    this.graphApiVersion,
  }) : super(key: key);

  @override
  State<WydadNewsPage> createState() => _WydadNewsPageState();
}

class _WydadNewsPageState extends State<WydadNewsPage> {
  List<FacebookPost> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;
  final ScrollController _scrollController = ScrollController();

  final Color primary = const Color(0xFFA8161F);

  @override
  void initState() {
    super.initState();
    _loadFacebookPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFacebookPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final posts = await FacebookService.fetchPosts(
        pageId: widget.facebookPageId ?? '833060977065976',
        accessToken: widget.facebookPageToken ??
            'EAARt9SiAafYBQwWLzPgUcOqtfuXHWETgZAo1fcm9pZCFqRqGusRo5by2BlLZA8vlZAAib0YBMaaKQKUUd4NHv4bxQZADfCii6BqdGTwliTnsyiOazuJN0BYdcO6H18xUdZAFNrBelGtZAlRQZBI6Napc9hTVNzFOdr7RyJPRRooqPhSuekMpHUZBwNZBCZC6BypQ6EVyDqT4esq',
        apiVersion: widget.graphApiVersion ?? 'v25.0',
      );

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<FacebookPost> get _filteredPosts {
    if (_searchQuery.isEmpty) return _posts;
    return _posts.where((post) {
      final query = _searchQuery.toLowerCase();
      return post.message.toLowerCase().contains(query) ||
          (post.story?.toLowerCase() ?? '').contains(query);
    }).toList();
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} an${(diff.inDays / 365).floor() > 1 ? 's' : ''}';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} mois';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min';
    }
    return 'à l\'instant';
  }

  void _showPostDetail(FacebookPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WydadNewsDetailPage(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A0710), Color(0xFF23030A), Color(0xFF120104)],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Glow radial
            Positioned(
              top: -140,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 520,
                  height: 520,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFC8172A).withOpacity(0.55),
                        const Color(0xFFC8172A).withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.62],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildHeader(),
                  ),

                  // Search
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _buildSearchBar(),
                  ),

                  const SizedBox(height: 14),

                  // Content
                  Expanded(
                    child: _isLoading
                        ? Center(
                      child: CircularProgressIndicator(color: primary),
                    )
                        : _errorMessage != null
                        ? _buildErrorState()
                        : _filteredPosts.isEmpty
                        ? _buildEmptyState()
                        : _isGridView
                        ? _buildGridView()
                        : _buildListView(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),

          const Text(
            'Actualités Wydad',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _isGridView = !_isGridView),
            child: _glassIconButton(
                _isGridView ? Icons.view_list : Icons.grid_view),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _loadFacebookPosts,
            child: _glassIconButton(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _glassIconButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        cursorColor: Colors.white,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher dans les actualités...',
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white.withOpacity(0.5),
          ),
          prefixIcon: Icon(Icons.search,
              color: Colors.white.withOpacity(0.6), size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            child: Icon(Icons.clear,
                color: Colors.white.withOpacity(0.6), size: 16),
          )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 60, color: Color(0xFFFF8A8A)),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Impossible de charger les actualités',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFacebookPosts,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Réessayer',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined,
              size: 64, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Aucune actualité trouvée',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Aucun résultat pour "$_searchQuery"'
                  : 'La page Wydad n\'a pas encore publié d\'actualités',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Effacer la recherche',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _loadFacebookPosts,
      color: primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        itemCount: _filteredPosts.length,
        itemBuilder: (context, index) =>
            _buildPostCard(_filteredPosts[index]),
      ),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator(
      onRefresh: _loadFacebookPosts,
      color: primary,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredPosts.length,
        itemBuilder: (context, index) =>
            _buildPostGridCard(_filteredPosts[index]),
      ),
    );
  }

  Widget _buildPostCard(FacebookPost post) {
    final imageUrl = post.imageUrls.isNotEmpty ? post.imageUrls.first : null;

    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (imageUrl != null)
                Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: Colors.white.withOpacity(0.05),
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 40, color: Colors.white38),
                        ),
                      ),
                    ),
                    if (post.isVideo)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow,
                              color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                )
              else
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary.withOpacity(0.3),
                        primary.withOpacity(0.1)
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.text_snippet,
                        size: 36, color: Colors.white38),
                  ),
                ),
              // Contenu
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: post.isVideo
                                ? const Color(0xFF64B5F6).withOpacity(0.2)
                                : primary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                post.isVideo
                                    ? Icons.videocam
                                    : Icons.article,
                                size: 10,
                                color: post.isVideo
                                    ? const Color(0xFF64B5F6)
                                    : const Color(0xFFF5CD52),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.isVideo ? 'Vidéo' : 'Actualité',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: post.isVideo
                                      ? const Color(0xFF64B5F6)
                                      : const Color(0xFFF5CD52),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time,
                            size: 12,
                            color: Colors.white.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(post.createdTime),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinkText(
                      text: post.message,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Inter',
                        height: 1.35,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildPostGridCard(FacebookPost post) {
    final imageUrl = post.imageUrls.isNotEmpty ? post.imageUrls.first : null;

    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    if (imageUrl != null)
                      Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white.withOpacity(0.05),
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.white38),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: primary.withOpacity(0.2),
                        child: const Center(
                          child: Icon(Icons.text_snippet,
                              size: 28, color: Colors.white38),
                        ),
                      ),
                    if (post.isVideo)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow,
                              color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinkText(
                        text: post.message,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          height: 1.3,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTimeAgo(post.createdTime),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== WYDAD NEWS DETAIL PAGE (DARK DESIGN) ====================

class WydadNewsDetailPage extends StatelessWidget {
  final FacebookPost post;

  const WydadNewsDetailPage({Key? key, required this.post}) : super(key: key);

  final Color primary = const Color(0xFFA8161F);

  void _openFullscreenImage(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenImageViewer(
          imageUrl: post.imageUrls.isNotEmpty ? post.imageUrls.first : '',
          allImages: post.imageUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  void _openVideoPlayer(BuildContext context) {
    if (post.videoUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewVideoPlayer(
            videoUrl: post.videoUrl!,
            thumbnailUrl:
            post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
          ),
        ),
      );
    } else if (post.permalinkUrl != null) {
      FacebookService.openFacebookPost(post.permalinkUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170205),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A0710), Color(0xFF23030A), Color(0xFF120104)],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF170205),
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.4),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: GestureDetector(
                  onTap: () {
                    if (post.isVideo) {
                      _openVideoPlayer(context);
                    } else if (post.imageUrls.isNotEmpty) {
                      _openFullscreenImage(context, 0);
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (post.imageUrls.isNotEmpty)
                        Image.network(
                          post.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.white.withOpacity(0.05),
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 50, color: Colors.white38),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: const BoxDecoration(  // ✅ decoration: BoxDecoration
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF4A0710), Color(0xFF23030A), Color(0xFF120104)],
                              stops: [0.0, 0.3, 1.0],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              post.isVideo
                                  ? Icons.videocam
                                  : Icons.article,
                              size: 80,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF170205).withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                      if (post.isVideo)
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: () => _openVideoPlayer(context),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color:
                                    Colors.white.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 32),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Facebook
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF1877F2).withOpacity(0.15),
                        border: Border.all(
                            color: const Color(0xFF1877F2).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.facebook,
                              size: 14, color: Color(0xFF64B5F6)),
                          SizedBox(width: 6),
                          Text(
                            'Page officielle Wydad',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64B5F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 13,
                            color: Colors.white.withOpacity(0.5)),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR')
                              .format(post.createdTime),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      child: LinkText(
                        text: post.message,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.start,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Photos
                    if (post.imageUrls.length > 1) ...[
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: post.imageUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () =>
                                  _openFullscreenImage(context, index),
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color:
                                      Colors.white.withOpacity(0.15)),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        post.imageUrls[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Bouton Facebook
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => FacebookService.openFacebookPost(
                            post.permalinkUrl),
                        icon: const Icon(Icons.facebook, size: 18),
                        label: const Text(
                          'Voir sur Facebook',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}