import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/qr_scan_model.dart';
import '../services/hive_service.dart';
import '../services/common_helpers.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final HiveService _hiveService = HiveService();
  List<QrScanModel> _scans = [];
  List<QrScanModel> _filteredScans = [];
  String _searchQuery = '';
  String? _selectedType;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scans = _hiveService.getAllQrScans();
      setState(() {
        _scans = scans;
        _filteredScans = scans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Log removed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.historyLoadError}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterScans() {
    setState(() {
      _filteredScans = _scans.where((scan) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            scan.data.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            scan.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (scan.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);

        final matchesType = _selectedType == null || scan.type == _selectedType;

        return matchesSearch && matchesType;
      }).toList();
    });
  }

  List<String> get _availableTypes {
    final types = _scans.map((scan) => scan.type).toSet().toList();
    types.sort();
    return types;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.scanHistory),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Theme.of(
          context,
        ).colorScheme.shadow.withValues(alpha: 0.1),
        actions: [
          IconButton(
            onPressed: _loadScans,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.refreshTooltip,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'clear':
                  await _clearAllScans();
                  break;
                case 'export':
                  await _exportScans();
                  break;
                case 'stats':
                  _showStatistics();
                  break;
                case 'removeDuplicates':
                  await _removeDuplicateScans();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.statistics),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.green),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.export),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'removeDuplicates',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.removeDuplicates),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.deleteAll),
                  ],
                ),
              ),
            ],
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
        child: Column(
          children: [
            // Modern Filtre ve arama bölümü
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Arama kutusu
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchHistory,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _filterScans();
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterScans();
                    },
                  ),
                  const SizedBox(height: 16),
                  // Modern Tip filtresi
                  if (_availableTypes.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.filterLabel,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            AppLocalizations.of(context)!.all,
                            null,
                          ),
                          const SizedBox(width: 8),
                          ..._availableTypes.map(
                            (type) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildFilterChip(type, type),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Tarama listesi
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredScans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noScansYet,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.startScanning,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredScans.length,
                      itemBuilder: (context, index) {
                        final scan = _filteredScans[index];
                        return _buildScanItem(scan);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? type) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
        _filterScans();
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildScanItem(QrScanModel scan) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(
          context,
        ).colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(scan.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(scan.type),
              color: _getTypeColor(scan.type),
              size: 20,
            ),
          ),
          title: Text(
            scan.title ?? scan.data,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(scan.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  scan.type,
                  style: TextStyle(
                    fontSize: 11,
                    color: _getTypeColor(scan.type),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (scan.type == 'WiFi' && scan.description != null)
                Text(
                  '${AppLocalizations.of(context)!.password}: ${_maskPassword(scan.description!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontFamily: 'monospace',
                  ),
                ),
              Text(
                _formatTimestamp(scan.timestamp),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Yıldız ikonu (Sık kullanılanlara ekle/çıkar)
              IconButton(
                onPressed: () => _toggleFavorite(scan),
                icon: Icon(
                  _hiveService.isFavorite(scan.id)
                      ? Icons.star
                      : Icons.star_border,
                  color: _hiveService.isFavorite(scan.id)
                      ? Colors.amber
                      : Colors.grey,
                  size: 20,
                ),
                tooltip: _hiveService.isFavorite(scan.id)
                    ? AppLocalizations.of(context)!.removeFromFavoritesAction
                    : AppLocalizations.of(context)!.addToFavoritesAction,
              ),
              // Popup menü
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'copy':
                      _copyToClipboard(scan);
                      break;
                    case 'delete':
                      await _deleteScan(scan);
                      break;
                    case 'open':
                      if (scan.isUrl) {
                        _openUrl(scan.data);
                      }
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
                  if (scan.isUrl)
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
                    value: 'delete',
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
          onTap: () => _showScanDetails(scan),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    final theme = Theme.of(context);
    switch (type) {
      case 'URL':
        return theme.colorScheme.primary;
      case 'E-posta':
        return Colors.green;
      case 'Telefon':
        return Colors.orange;
      case 'SMS':
        return Colors.purple;
      case 'Konum':
        return Colors.red;
      case 'WiFi':
        return Colors.indigo;
      case 'vCard':
        return Colors.teal;
      case 'MeCard':
        return Colors.cyan;
      case 'OTP':
        return Colors.amber;
      case 'Kripto Para':
        return Colors.deepOrange;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getTranslatedType(String type) {
    switch (type) {
      case 'URL':
        return AppLocalizations.of(context)!.urlType;
      case 'E-posta':
        return AppLocalizations.of(context)!.emailType;
      case 'Telefon':
        return AppLocalizations.of(context)!.phoneType;
      case 'SMS':
        return AppLocalizations.of(context)!.smsType;
      case 'Konum':
        return AppLocalizations.of(context)!.locationType;
      case 'WiFi':
        return AppLocalizations.of(context)!.wifiType;
      case 'vCard':
        return AppLocalizations.of(context)!.contactType;
      case 'MeCard':
        return AppLocalizations.of(context)!.mecardType;
      case 'OTP':
        return AppLocalizations.of(context)!.otpType;
      case 'Kripto Para':
        return AppLocalizations.of(context)!.cryptoType;
      default:
        return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'E-posta':
        return Icons.email;
      case 'Telefon':
        return Icons.phone;
      case 'SMS':
        return Icons.message;
      case 'Konum':
        return Icons.location_on;
      case 'WiFi':
        return Icons.wifi;
      case 'vCard':
        return Icons.contact_page;
      case 'MeCard':
        return Icons.contact_phone;
      case 'OTP':
        return Icons.security;
      case 'Kripto Para':
        return Icons.currency_bitcoin;
      default:
        return Icons.text_fields;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    // Sadece tarih formatı: "15.12.2024"
    return '${timestamp.day.toString().padLeft(2, '0')}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.year}';
  }

  String _maskPassword(String password) {
    if (password.isEmpty ||
        password == AppLocalizations.of(context)!.noPasswordText ||
        password == AppLocalizations.of(context)!.hiddenPassword) {
      return password;
    }

    if (password.length <= 4) {
      return '•' * password.length;
    }

    // İlk 2 ve son 2 karakteri göster, ortasını maskele
    final firstTwo = password.substring(0, 2);
    final lastTwo = password.substring(password.length - 2);
    final middle = '•' * (password.length - 4);

    return '$firstTwo$middle$lastTwo';
  }

  void _showScanDetails(QrScanModel scan) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern Header with Gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTypeColor(scan.type),
                      _getTypeColor(scan.type).withValues(alpha: 0.8),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getTypeIcon(scan.type),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scan.title ?? _getTranslatedType(scan.type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getTranslatedType(scan.type),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),

              // Content with Better Spacing
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Veri bölümü - Modern Card Design
                      _buildModernDetailCard(
                        AppLocalizations.of(context)!.content,
                        Icons.data_object,
                        scan.data,
                        _getTypeColor(scan.type),
                      ),

                      const SizedBox(height: 16),

                      // Açıklama bölümü (varsa)
                      if (scan.description != null)
                        _buildModernDetailCard(
                          AppLocalizations.of(context)!.description,
                          Icons.description,
                          scan.description!,
                          Colors.green,
                        ),

                      if (scan.description != null) const SizedBox(height: 16),

                      // WiFi özel bilgileri
                      if (scan.type == 'WiFi' && scan.description != null)
                        _buildModernWiFiDetails(scan.description!),

                      const SizedBox(height: 16),

                      // Tarih bölümü - Bottom positioned
                      _buildModernDetailCard(
                        AppLocalizations.of(context)!.timeLabel,
                        Icons.access_time,
                        _formatTimestamp(scan.timestamp),
                        Colors.orange,
                      ),

                      if (scan.format != null) ...[
                        const SizedBox(height: 16),
                        _buildModernDetailCard(
                          AppLocalizations.of(context)!.formatLabel,
                          Icons.format_align_left,
                          scan.format!,
                          Colors.purple,
                        ),
                      ],
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
                    if (scan.isUrl)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _openUrl(scan.data);
                          },
                          icon: const Icon(Icons.open_in_browser, size: 20),
                          label: Text(
                            AppLocalizations.of(context)!.openWebPage,
                            style: const TextStyle(fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (scan.isUrl) const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _copyToClipboard(scan);
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: Text(
                              AppLocalizations.of(context)!.copyAction,
                              style: const TextStyle(fontSize: 14),
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
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 18),
                            label: Text(
                              AppLocalizations.of(context)!.closeAction,
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _copyToClipboard(QrScanModel scan) async {
    String textToCopy;

    if (scan.type == 'WiFi' && scan.description != null) {
      textToCopy = scan.description!;
    } else {
      textToCopy = scan.data;
    }

    await CommonHelpers.copyToClipboard(textToCopy, context);
  }

  Future<void> _deleteScan(QrScanModel scan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteScanTitle),
        content: Text(AppLocalizations.of(context)!.deleteScanConfirm),
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
        await _hiveService.deleteQrScan(scan.id);
        await _loadScans();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.scanDeleted),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.deleteError}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleFavorite(QrScanModel scan) async {
    try {
      if (_hiveService.isFavorite(scan.id)) {
        await _hiveService.removeFromFavorites(scan.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.removeFromFavoritesConfirm,
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await _hiveService.addToFavorites(scan);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.addedToFavorites),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      setState(() {}); // UI'yi güncelle
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorPrefix}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeDuplicateScans() async {
    try {
      await _hiveService.removeDuplicateScans();
      await _loadScans(); // Listeyi yenile
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.duplicatesRemoved),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.removeDuplicatesError}: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearAllScans() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAllScans),
        content: Text(AppLocalizations.of(context)!.deleteAllScansConfirm),
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
        await _hiveService.deleteAllQrScans();
        await _loadScans();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.allScansDeleted),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.deleteError}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _exportScans() async {
    try {
      final scansJson = _scans.map((scan) => scan.toJson()).toList();
      final jsonString = scansJson.toString();
      Clipboard.setData(ClipboardData(text: jsonString));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.historyCopiedToClipboard,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.exportError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStatistics() {
    final stats = _hiveService.getStatistics();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.statisticsTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow(
              '${AppLocalizations.of(context)!.totalScansLabel} ',
              '${stats['totalScans']}',
            ),
            _buildStatRow(
              '${AppLocalizations.of(context)!.urlScan}:',
              '${stats['urlScans']}',
            ),
            if (stats['lastScan'] != null)
              _buildStatRow('Son Tarama:', _formatTimestamp(stats['lastScan'])),
            if (stats['firstScan'] != null)
              _buildStatRow(
                '${AppLocalizations.of(context)!.firstScan}:',
                _formatTimestamp(stats['firstScan']),
              ),
            const SizedBox(height: 12),
            Text(
              '${AppLocalizations.of(context)!.typeDistribution}:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(stats['typeCounts'] as Map<String, int>).entries.map(
              (entry) => _buildStatRow('${entry.key}:', '${entry.value}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.closeAction),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _openUrl(String url) async {
    await CommonHelpers.openUrl(url, context);
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.wifi, color: Colors.cyan, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'WiFi Bilgileri',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModernWiFiInfoRow(
              'Ağ Adı (SSID)',
              ssid,
              Icons.router,
              Colors.blue,
            ),
            const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
