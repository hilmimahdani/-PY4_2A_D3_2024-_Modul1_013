import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart'; 
import 'package:logbook_app_001/services/mongo_services.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:intl/intl.dart'; 

class LogView extends StatefulWidget {
  final String? username; 
  const LogView({super.key, this.username}); 

  @override
  State<LogView> createState() => _LogViewState();
}


class _LogViewState extends State<LogView> {
  String _selectedCategory = "Umum";
  final List<String> _categories = ["Umum", "Pekerjaan", "Urgent", "Pribadi"];
  
  bool _isLoading = false;
  bool _isOffline = false;

  late LogController _controller;

  Future<List<LogModel>>? _logsFuture;

   Future<List<LogModel>> _fetchLogs() async {
    return await MongoService().getLogsByUser(widget.username ?? "default_user");
  }

  @override
  void initState() {
    super.initState();
    _controller = LogController(widget.username ?? "default_user"); 

    // Memberikan kesempatan UI merender widget awal sebelum proses berat dimulai
    Future.microtask(() => _initDatabase());
  } 

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await LogHelper.writeLog(
        "UI: Memulai inisialisasi database...",
        source: "log_view.dart",
      );

      //mencoba koneksi ke MongoDB Atlas (Cloud)
      await LogHelper.writeLog(
        "UI: Menghubungi MongoService.connect()...",
        source: "log_view.dart",
      );

      // Mengaktifkan kembali koneksi dengan timeout 15 detik
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

      await _controller.loadFromDisk();
      
      if (mounted) {
        setState(() {
          _logsFuture = _fetchLogs();
        });
      }
  } catch (e) {
    await LogHelper.writeLog(
        "UI: Error - $e",
        source: "log_view.dart",
        level: 1,
      );
      if (mounted) {
        _isOffline = true;
      }
  } finally {
    
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();
    _selectedCategory = "Umum"; 
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) { 
            return AlertDialog(
              title: const Text("Tambah Catatan Baru"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: "Judul Catatan"),
                  ),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(hintText: "Isi Deskripsi"),
                  ),
                  const SizedBox(height: 10),

                
                  DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories.map((String val) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (String? newValue) {
                      
                      setStateDialog(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _titleController.clear();
                    _contentController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _controller.addLog(
                      _titleController.text,
                      _contentController.text,
                      _selectedCategory,
                    );

                    if (mounted) {
                      setState(() {
                        _logsFuture = _fetchLogs();
                      });
                    }

                    if(!context.mounted) return; 

                    _titleController.clear();
                    _contentController.clear();
                    Navigator.pop(context);

                    if (mounted) {
                      setState(() {}); 
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    
    if (_categories.contains(log.category)) {
      _selectedCategory = log.category;
    } else {
      _selectedCategory = "Umum";
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) { 
            return AlertDialog(
              title: const Text("Edit Catatan"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Judul"),
                  ),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: "Deskripsi"),
                  ),

                  DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories.map((String val) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (val) {
                
                      setStateDialog(() {
                        _selectedCategory = val!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _titleController.clear();
                    _contentController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _controller.updateLog(
                      index,
                      _titleController.text,
                      _contentController.text,
                      _selectedCategory,
                    );

                    if (mounted) {
                      setState(() {
                        _logsFuture = _fetchLogs();
                      });
                    }

                    if (!context.mounted) return;

                      _titleController.clear();
                      _contentController.clear();
                      Navigator.pop(context);

                      if (mounted) {
                        setState(() {}); 
                      }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          }
        );
      },
    );
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
                MaterialPageRoute(builder: (context) => const OnboardingView()), // Pastikan nama class benar
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
              onPressed: () => Navigator.pop(context, false), // Return false
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true), // Return true
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
          child: FutureBuilder<List<LogModel>>(
            future: _logsFuture,
            builder: (context, snapshot) {
              if (_isLoading || snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Menghubungkan ke MongoDB Atlas..."),
                    ],
                  ),
                );
              }

              final currentLogs = snapshot.data ?? [];

              if (_controller.logs != currentLogs) {
                _controller.logsNotifier.value = currentLogs;
                _controller.filteredLogs.value = currentLogs;
              }

              if (currentLogs.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    if (mounted) {
                      setState(() {
                        _logsFuture = _fetchLogs();
                      });
                    } 
                    await _logsFuture;
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      const Center(child: Text("Belum ada catatan di Cloud.")),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: ElevatedButton(
                          onPressed: _showAddLogDialog,
                          child: const Text("Buat Catatan Pertama"),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  if (mounted) {
                    setState(() {
                      _logsFuture = _fetchLogs();
                    });
                  }
                  await _logsFuture;
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: currentLogs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = currentLogs[index];
                    return Dismissible(
                      key: Key('${log.title}_${DateTime.now().millisecondsSinceEpoch}'),
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
                        if (mounted) {
                          setState(() {
                            _logsFuture = _fetchLogs();
                          });
                        }
                      },
                      child: Card(
                        color: log.getCategoryColor(),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.cloud_done, color: Colors.green),
                          title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.category, style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                              const SizedBox(height: 4),
                              Text(log.description),
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
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditLogDialog(index, log),
                              ),
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
      onPressed: _showAddLogDialog,
      child: const Icon(Icons.add),
    ),
  );
}

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

