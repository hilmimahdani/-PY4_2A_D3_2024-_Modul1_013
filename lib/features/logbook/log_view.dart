import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart'; 


class LogView extends StatefulWidget {
  final String? username; 
  const LogView({super.key, this.username}); 

  @override
  State<LogView> createState() => _LogViewState();
}


class _LogViewState extends State<LogView> {
  String _selectedCategory = "Umum";
  final List<String> _categories = ["Umum", "Pekerjaan", "Urgent", "Pribadi"];
  

  late LogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LogController(widget.username ?? "default_user"); 
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
                  onPressed: () {
                    _controller.addLog(
                      _titleController.text,
                      _contentController.text,
                      _selectedCategory,
                    );
                    _titleController.clear();
                    _contentController.clear();
                    Navigator.pop(context);
                    
                    
                    setState(() {}); 
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
                  onPressed: () {
                    _controller.updateLog(
                      index,
                      _titleController.text,
                      _contentController.text,
                      _selectedCategory,
                    );
                    _titleController.clear();
                    _contentController.clear();
                    Navigator.pop(context);
                    
                    
                    setState(() {}); 
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
        title: Text("Log Notes - ${widget.username ?? 'User'}"),
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
              builder: (context, currentLogs, child) {
                
                if (currentLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/emptyfolder.png', height: 300),
                        const Text("Belum ada catatan."),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: currentLogs.length,
                  separatorBuilder: (context, index) => const SizedBox (height: 8),
                  itemBuilder: (context, index) {

                    final log = currentLogs[index];
                    
                    
                    return Dismissible(
                    
                      key: Key('${log.title}_$index'), 
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
                      
                    
                      onDismissed: (direction) {
                        setState(() => _controller.removeLog(index));
                      },
                      
                      child: Card(
                        color: log.getCategoryColor(),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.note),
                          title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          
                        
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontStyle: FontStyle.italic, 
                                    color: Colors.blueGrey,      
                                  ),
                                ),
                                const SizedBox(height: 4), 
                                Text(log.description),
                              ],
                            ),
                          ),
                        

                          isThreeLine: true,
                          trailing: Wrap(
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
                                    setState(() => _controller.removeLog(index));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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

