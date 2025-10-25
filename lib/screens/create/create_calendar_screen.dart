import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CreateCalendarScreen extends StatefulWidget {
  const CreateCalendarScreen({super.key});

  @override
  State<CreateCalendarScreen> createState() => _CreateCalendarScreenState();
}

class _CreateCalendarScreenState extends State<CreateCalendarScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1)),
  );

  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onDataChanged);
    _descriptionController.addListener(_onDataChanged);
    _locationController.addListener(_onDataChanged);
    _organizerController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
  }

  String _formatDateTime(DateTime date, TimeOfDay time) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}T'
        '${time.hour.toString().padLeft(2, '0')}'
        '${time.minute.toString().padLeft(2, '0')}'
        '00Z';
  }

  String _getVEventString() {
    if (_titleController.text.isEmpty) return '';

    String vevent = 'BEGIN:VEVENT\n';
    vevent += 'SUMMARY:${_titleController.text}\n';

    if (_descriptionController.text.isNotEmpty) {
      vevent += 'DESCRIPTION:${_descriptionController.text}\n';
    }

    if (_locationController.text.isNotEmpty) {
      vevent += 'LOCATION:${_locationController.text}\n';
    }

    if (_organizerController.text.isNotEmpty) {
      vevent += 'ORGANIZER:${_organizerController.text}\n';
    }

    vevent += 'DTSTART:${_formatDateTime(_startDate, _startTime)}\n';
    vevent += 'DTEND:${_formatDateTime(_endDate, _endTime)}\n';
    vevent += 'END:VEVENT';

    return vevent;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Takvim QR Kodu'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
        actions: [
          if (_titleController.text.isNotEmpty && !_hasError)
            IconButton(
              onPressed: _saveEvent,
              icon: const Icon(Icons.save),
              tooltip: 'Kaydet',
            ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    // Modern Etkinlik bilgileri girişi
                    Card(
                      elevation: 8,
                      shadowColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event, color: Colors.blue.shade300),
                                const SizedBox(width: 8),
                                Text(
                                  'Etkinlik Bilgileri',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Başlık
                            TextField(
                              controller: _titleController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Etkinlik Başlığı *',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: 'Etkinlik adını girin',
                                hintStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.title,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Açıklama
                            TextField(
                              controller: _descriptionController,
                              maxLines: 3,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Açıklama',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: 'Etkinlik açıklaması',
                                hintStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.description,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Konum
                            TextField(
                              controller: _locationController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Konum',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: 'Etkinlik konumu',
                                hintStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Organizatör
                            TextField(
                              controller: _organizerController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Organizatör',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: 'Organizatör bilgisi',
                                hintStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Tarih ve saat seçimi
                            Text(
                              'Tarih ve Saat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Başlangıç tarihi ve saati
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.play_arrow,
                                        color: Colors.green.shade300,
                                      ),
                                      title: Text(
                                        'Başlangıç',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startTime.format(context)}',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      onTap: () => _selectDate(context, true),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _selectTime(context, true),
                                  icon: Icon(
                                    Icons.access_time,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  tooltip: 'Başlangıç saati',
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Bitiş tarihi ve saati
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.stop,
                                        color: Colors.red.shade300,
                                      ),
                                      title: Text(
                                        'Bitiş',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endTime.format(context)}',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      onTap: () => _selectDate(context, false),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _selectTime(context, false),
                                  icon: Icon(
                                    Icons.access_time,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  tooltip: 'Bitiş saati',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // QR kod önizlemesi
                    Card(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QR Kod Önizlemesi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _titleController.text.isEmpty
                                    ? Column(
                                        children: [
                                          Icon(
                                            Icons.event_busy,
                                            size: 64,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Etkinlik başlığı girin',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      )
                                    : _hasError
                                    ? Column(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 64,
                                            color: Colors.red.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _errorMessage,
                                            style: TextStyle(
                                              color: Colors.red.shade600,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                    : BarcodeWidget(
                                        barcode: Barcode.qrCode(),
                                        data: _getVEventString(),
                                        width: 200,
                                        height: 200,
                                        errorBuilder: (context, error) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                setState(() {
                                                  _hasError = true;
                                                  _errorMessage =
                                                      'Geçersiz etkinlik bilgisi';
                                                });
                                              });
                                          return Container(
                                            width: 200,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              border: Border.all(
                                                color: Colors.red.shade200,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  color: Colors.red.shade400,
                                                  size: 48,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Hata',
                                                  style: TextStyle(
                                                    color: Colors.red.shade600,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            // Kaydetme ve Paylaşma Butonları
                            if (_titleController.text.isNotEmpty &&
                                !_hasError) ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _saveEvent,
                                      icon: const Icon(Icons.save),
                                      label: const Text('Kaydet'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _shareEvent,
                                      icon: const Icon(Icons.share),
                                      label: const Text('Paylaş'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // vEvent bilgi kartı
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade300,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'vEvent QR Kodu Hakkında',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bu QR kodu tarayan kişiler otomatik olarak etkinliği takvimlerine ekleyebilir. Etkinlik başlığı zorunludur.',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Ham veri gösterimi
                    if (_titleController.text.isNotEmpty)
                      Card(
                        color: Theme.of(context).colorScheme.surface,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'vEvent Verisi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getVEventString(),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveEvent() async {
    try {
      // Etkinlik QR kod verisini metin dosyası olarak kaydet
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final title = _titleController.text.replaceAll(' ', '_');
      final fileName = 'Event_QR_$title$timestamp.txt';

      // Downloads klasörüne kaydet
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        _showErrorSnackBar('Downloads klasörü bulunamadı');
        return;
      }

      final file = File('${directory.path}/$fileName');
      final content =
          'Etkinlik QR Kodu (vEvent)\n'
          'Oluşturulma Tarihi: ${DateTime.now().toString()}\n'
          'Başlık: ${_titleController.text}\n'
          'Açıklama: ${_descriptionController.text}\n'
          'Konum: ${_locationController.text}\n'
          'Organizatör: ${_organizerController.text}\n'
          'Başlangıç: ${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startTime.format(context)}\n'
          'Bitiş: ${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endTime.format(context)}\n'
          'Ham Veri (vEvent): ${_getVEventString()}';

      await file.writeAsString(content);

      _showSuccessSnackBar('Etkinlik QR kodu kaydedildi: ${file.path}');
    } catch (e) {
      _showErrorSnackBar('Kaydetme hatası: $e');
    }
  }

  Future<void> _shareEvent() async {
    try {
      // Etkinlik QR kod verisini paylaş
      final content =
          'Etkinlik QR Kodu (vEvent)\n\n'
          'Başlık: ${_titleController.text}\n'
          'Açıklama: ${_descriptionController.text}\n'
          'Konum: ${_locationController.text}\n'
          'Organizatör: ${_organizerController.text}\n'
          'Başlangıç: ${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startTime.format(context)}\n'
          'Bitiş: ${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endTime.format(context)}\n'
          'Ham Veri (vEvent): ${_getVEventString()}\n'
          'Oluşturulma Tarihi: ${DateTime.now().toString()}';

      await Share.share(
        content,
        subject: 'Etkinlik QR Kodu - ${_titleController.text}',
      );

      _showSuccessSnackBar('Etkinlik QR kodu paylaşıldı');
    } catch (e) {
      _showErrorSnackBar('Paylaşma hatası: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
