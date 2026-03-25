import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart'; 
import 'package:logbook_app_001/services/mongo_services.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'package:logbook_app_001/utils/access_policy.dart';
import 'package:logbook_app_001/features/logbook/log_editor_page.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart'; 

class LogView extends StatefulWidget {
  final String? username; 
  const LogView({super.key, this.username}); 

  @override
  State<LogView> createState() => _LogViewState();
}


class _LogViewState extends State<LogView> {
  
  bool _isLoading = false;
  bool _isOffline = false;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription; 

  late LogController _controller;

  Future<List<LogModel>>? _logsFuture;


  Future<List<LogModel>> _fetchLogs() async {
    try {
      //ambil data dari MongoDB dengan privacy filter
      final cloudLogs = await MongoService().getLogsWithPrivacy(
        widget.username ?? "default_user",
        'team_ceria', 
      );
      return cloudLogs;
      
    } catch (e) {
      //kalau gagal, ambil dari lokal (Hive) dengan privacy filter
      debugPrint("Gagal fetch dari Cloud, memuat data lokal...");
      await _controller.loadLogsWithPrivacy('team_ceria');
      return _controller.logs; 
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = LogController(widget.username ?? "default_user"); 

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (result) => _handleConnectivityChange(result),
    );

    Future.microtask(() => _initDatabase());
  } 

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await LogHelper.writeLog(
        "UI: Memulai inisialisasi database...",
        source: "log_view.dart",
      );

      await LogHelper.writeLog(
        "UI: Menghubungi MongoService.connect()...",
        source: "log_view.dart",
      );


      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          "Koneksi Cloud Timeout. Periksa sinyal/IP Whitelist.",
        ),
      );

      await LogHelper.writeLog(
        "UI: Koneksi MongoService BERHASIL.",
        source: "log_view.dart",
      );

      // Mengambil data log dari Cloud
      await LogHelper.writeLog(
        "UI: Memanggil controller.loadFromDisk() dan fetch Future...",
        source: "log_view.dart",
      );

      await _controller.syncOfflineData();

      await _controller.loadFromDisk();
      
      if (mounted) {
        setState(() {
          _isOffline = false;
          _logsFuture = _fetchLogs();
        });
      }
    } catch (e) {
      await LogHelper.writeLog(
          "UI: Error - $e",
          source: "log_view.dart",
          level: 1,
        );

        await _controller.loadFromDisk();

        if (mounted) {
          setState(() {
            _isOffline = true;
            _logsFuture = Future.value(_controller.logs);
          });
        }
      } finally {
      
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
  }


  void _handleConnectivityChange(List<ConnectivityResult> result) {
    final isOnline = !result.contains(ConnectivityResult.none);
    
    if (isOnline && _isOffline) {
      
      debugPrint("Koneksi kembali! Auto-refetch data...");
      
      if (mounted) {
        setState(() {
          _isLoading = true;
          _isOffline = false;
        });
        
       
        _initDatabase();
      }
    } else if (!isOnline && !_isOffline) {
      
      debugPrint("Koneksi hilang!");
      
      if (mounted) {
        setState(() {
          _isOffline = true;
        });
      }
    }
  }

  Future<void> _goToEditor({LogModel? log, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _logsFuture = _fetchLogs();
      });
    }
  }

  
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingView()), 
                (route) => false,
              );
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  
  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text("Apakah Anda yakin ingin menghapus catatan ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), 
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true), 
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook - ${widget.username ?? 'User'}"),
        backgroundColor: Colors.blue.shade300,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          )
        ]
      ),
      body: Column(
        children: [

          if (_isOffline)
            Container(
              color: Colors.orange.shade800,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: const [
                  Icon(Icons.wifi_off, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Offline Mode, Tidak ada koneksi internet.",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => _controller.searchLog(value),
              decoration: const InputDecoration(
                labelText: "Cari Catatan...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            
            child: ValueListenableBuilder<List<LogModel>>(
              
              valueListenable: _controller.filteredLogs, 
              builder: (context, currentLogs, _) {
                
              
                if (_isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Memuat data..."),
                      ],
                    ),
                  );
                }

                
                if (currentLogs.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      
                      await _controller.loadFromDisk();
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                      
                        Image.asset(
                          'assets/images/emptyfolder.png',
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),
                        
                        const Text(
                          "Belum ada aktivitas hari ini?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Mulai catat logbook pertama Anda!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: ElevatedButton(
                            onPressed: () => _goToEditor(),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Buat Catatan Pertama",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                
                return RefreshIndicator(
                  onRefresh: () async {
                    await _controller.loadFromDisk();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemCount: currentLogs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final log = currentLogs[index];
                      return Dismissible(
                        
                        key: Key('${log.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white, size: 30),
                        ),
                        confirmDismiss: (direction) async {
                          return await _confirmDelete();
                        },
                        onDismissed: (direction) async {
                          await _controller.removeLog(index);
                          
                        },
                        child: Card(
                          color: log.getCategoryColor(), 
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(
                              log.isSynced ? Icons.cloud_done : Icons.cloud_off,
                              color: log.isSynced ? Colors.green : Colors.grey,
                            ),
                              
                            title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.category, style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: log.isPublic ? Colors.orange.shade100 : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    log.isPublic ? "PUBLIK" : "PRIVAT",
                                    style: TextStyle(
                                      fontSize: 10, 
                                      fontWeight: FontWeight.bold,
                                      color: log.isPublic ? Colors.orange.shade700 : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                
                                
                                const SizedBox(height: 4),
                              

                                MarkdownBody(
                                  data: log.description,
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(fontSize: 12, color: Colors.black87),
                                    listBullet: const TextStyle(fontSize: 12),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Text(
                                  "Dibuat pada: ${DateFormat('dd MMM yyyy, HH:mm').format(log.date)}", 
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            
                                const SizedBox(width: 8),

                                if (AccessPolicy.canEditOrDelete(
                                    currentUserId: widget.username ?? "default_user",
                                    logOwnerId: log.authorId,
                                  ))
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _goToEditor(log: log, index: index),
                                    ),

                                  if (AccessPolicy.canEditOrDelete(
                                    currentUserId: widget.username ?? "default_user",
                                    logOwnerId: log.authorId,
                                  ))
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await _confirmDelete();
                                        if (confirm == true) {
                                          await _controller.removeLog(index);
                                          if (mounted) {
                                            setState(() {
                                              _logsFuture = _fetchLogs();
                                            });
                                          }
                                        }
                                      },
                                    ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}

