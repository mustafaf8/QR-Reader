import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/qr_scan_model.dart';
import '../services/hive_service.dart';
import '../services/common_helpers.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final HiveService _hiveService = HiveService();
  List<QrScanModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = _hiveService.getAllFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Sık kullanılanları yükleme hatası
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.favorites),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Theme.of(
          context,
        ).colorScheme.shadow.withValues(alpha: 0.1),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              onPressed: _clearAllFavorites,
              icon: const Icon(Icons.clear_all),
              tooltip: AppLocalizations.of(context)!.clearAll,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favorites.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.star_border,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.noFavoritesYet,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        AppLocalizations.of(context)!.addFavoritesHint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final favorite = _favorites[index];
                  return _buildFavoriteItem(favorite);
                },
              ),
      ),
    );
  }

  Widget _buildFavoriteItem(QrScanModel favorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shadowColor: Theme.of(
          context,
        ).colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(favorite.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(favorite.type),
              color: _getTypeColor(favorite.type),
              size: 20,
            ),
          ),
          title: Text(
            favorite.title ?? favorite.data,
            style: CommonHelpers.getResponsiveTextStyle(
              context,
              baseFontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(
                        favorite.type,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      favorite.type,
                      style: TextStyle(
                        fontSize: 11,
                        color: _getTypeColor(favorite.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimestamp(favorite.timestamp),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (favorite.type == 'WiFi' && favorite.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context)!.password}: ${_maskPassword(favorite.description!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Yıldız ikonu (Sık kullanılanlardan çıkar)
              IconButton(
                onPressed: () => _removeFromFavorites(favorite),
                icon: const Icon(Icons.star, color: Colors.amber, size: 20),
                tooltip: AppLocalizations.of(
                  context,
                )!.removeFromFavoritesTooltip,
              ),
              // Popup menü
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'copy':
                      _copyToClipboard(favorite);
                      break;
                    case 'open':
                      if (favorite.isUrl) {
                        _openUrl(favorite.data);
                      }
                      break;
                    case 'remove':
                      await _removeFromFavorites(favorite);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        const Icon(Icons.copy, size: 16),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.copyAction),
                      ],
                    ),
                  ),
                  if (favorite.isUrl)
                    PopupMenuItem(
                      value: 'open',
                      child: Row(
                        children: [
                          Icon(Icons.open_in_browser, size: 16),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.open),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.deleteAction,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () => _showFavoriteDetails(favorite),
        ),
      ),
    );
  }

  Future<void> _removeFromFavorites(QrScanModel favorite) async {
    try {
      await _hiveService.removeFromFavorites(favorite.id);
      await _loadFavorites(); // Listeyi yenile
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.removeFromFavoritesConfirm,
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorPrefix}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAllFavorites),
        content: Text(AppLocalizations.of(context)!.deleteAllFavoritesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.deleteAction),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _hiveService.clearAllFavorites();
        await _loadFavorites();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.allFavoritesDeleted),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.deleteError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard(QrScanModel favorite) async {
    // WiFi QR kodu için özel kopyalama menüsü göster
    if (favorite.type == 'WIFI') {
      await CommonHelpers.showWiFiCopyOptions(favorite, context);
    } else {
      // Diğer QR kodları için normal kopyalama
      await CommonHelpers.copyToClipboard(favorite.data, context);
    }
  }

  void _openUrl(String url) async {
    await CommonHelpers.openUrl(url, context);
  }

  void _showFavoriteDetails(QrScanModel favorite) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: CommonHelpers.getResponsiveDialogConstraints(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern Header with Gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTypeColor(favorite.type),
                      _getTypeColor(favorite.type).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        _getTypeIcon(favorite.type),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            favorite.title ??
                                AppLocalizations.of(context)!.favoriteDetail,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              favorite.type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        iconSize: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        minimumSize: const Size(24, 24),
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),

              // Content with Better Spacing
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Veri bölümü - Modern Card Design
                      _buildModernDetailCard(
                        AppLocalizations.of(context)!.dataContent,
                        Icons.data_object,
                        favorite.data,
                        _getTypeColor(favorite.type),
                      ),

                      const SizedBox(height: 8),

                      // Açıklama bölümü (varsa)
                      if (favorite.description != null)
                        _buildModernDetailCard(
                          AppLocalizations.of(context)!.description,
                          Icons.description,
                          favorite.description!,
                          Colors.green,
                        ),

                      if (favorite.description != null)
                        const SizedBox(height: 8),

                      // WiFi özel bilgileri
                      if (favorite.type == 'WiFi' &&
                          favorite.description != null)
                        _buildModernWiFiDetails(favorite.description!),

                      if (favorite.type == 'WiFi' &&
                          favorite.description != null)
                        const SizedBox(height: 8),

                      // Tarih bölümü - Bottom positioned
                      Card(
                        elevation: 0,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${AppLocalizations.of(context)!.dateLabel} ${_formatTimestamp(favorite.timestamp)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bottom padding for action buttons
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Action buttons - Modern Design
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    if (favorite.isUrl)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _openUrl(favorite.data);
                          },
                          icon: const Icon(Icons.open_in_browser, size: 20),
                          label: Text(
                            AppLocalizations.of(context)!.openWebPage,
                            style: TextStyle(fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                            shadowColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (favorite.isUrl) const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _copyToClipboard(favorite);
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: Text(
                              AppLocalizations.of(context)!.copyAction,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _removeFromFavorites(favorite);
                            },
                            icon: const Icon(Icons.delete, size: 18),
                            label: Text(
                              AppLocalizations.of(context)!.deleteAction,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 2,
                              shadowColor: Colors.red.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildModernDetailCard(
    String title,
    IconData icon,
    String content,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.08),
              color.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: SelectableText(
                CommonHelpers.truncateText(content, 500),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernWiFiDetails(String description) {
    final lines = description.split('\n');
    String ssid = 'Bilinmiyor';
    String password = 'Bilinmiyor';

    for (final line in lines) {
      if (line.startsWith('WiFi Ağı: ')) {
        ssid = line.substring(10);
      } else if (line.startsWith('Şifre: ')) {
        password = line.substring(7);
      }
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.cyan.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyan.withValues(alpha: 0.08),
              Colors.cyan.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.wifi, color: Colors.cyan, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'WiFi Bilgileri',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildModernWiFiInfoRow(
              'Ağ Adı (SSID)',
              ssid,
              Icons.router,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildModernWiFiInfoRow(
              'Şifre',
              password,
              Icons.lock,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernWiFiInfoRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    final theme = Theme.of(context);
    switch (type) {
      case 'URL':
        return theme.colorScheme.primary;
      case 'EMAIL':
        return Colors.green;
      case 'PHONE':
        return Colors.purple;
      case 'SMS':
        return Colors.orange;
      case 'LOCATION':
        return Colors.red;
      case 'WIFI':
        return Colors.cyan;
      case 'VCARD':
        return Colors.indigo;
      case 'MECARD':
        return Colors.teal;
      case 'OTP':
        return Colors.amber;
      case 'CRYPTO':
        return Colors.deepOrange;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'EMAIL':
        return Icons.email;
      case 'PHONE':
        return Icons.phone;
      case 'SMS':
        return Icons.message;
      case 'LOCATION':
        return Icons.location_on;
      case 'WIFI':
        return Icons.wifi;
      case 'VCARD':
        return Icons.contact_page;
      case 'MECARD':
        return Icons.person;
      case 'OTP':
        return Icons.security;
      case 'CRYPTO':
        return Icons.currency_bitcoin;
      default:
        return Icons.text_fields;
    }
  }

  String _maskPassword(String description) {
    final l10n = AppLocalizations.of(context)!;
    if (description.contains('${l10n.passwordLabel}: ')) {
      final parts = description.split('${l10n.passwordLabel}: ');
      if (parts.length > 1) {
        final password = parts[1];
        if (password.length > 2) {
          return '${password.substring(0, 2)}${'*' * (password.length - 2)}';
        }
      }
    }
    return description;
  }

  String _formatTimestamp(DateTime timestamp) {
    // Sadece tarih formatı: "15.12.2024"
    return '${timestamp.day.toString().padLeft(2, '0')}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.year}';
  }
}
