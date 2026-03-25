import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/utils/access_policy.dart'; 

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isPublic = false;
  String _selectedCategory = "Mechanical";
  final List<String> _categories = ["Mechanical", "Electronical", "Software"];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');

    _isPublic = widget.log?.isPublic ?? false;
    
    if (widget.log != null && _categories.contains(widget.log!.category)) {
      _selectedCategory = widget.log!.category;
    }

    // Listener agar Pratinjau Markdown terupdate otomatis saat ngetik
    _descController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan Deskripsi tidak boleh kosong!')),
      );
      return;
    }

    if (widget.log != null) {
      final canEdit = AccessPolicy.canEditOrDelete(
        currentUserId: widget.controller.username,  
        logOwnerId: widget.log!.authorId,
      );

      if (!canEdit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda tidak punya akses untuk edit catatan orang lain!'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, false);
        return;
      }
    }

    if (widget.log == null) {
      // Tambah Baru
      await widget.controller.addLog(
        _titleController.text,
        _descController.text,
        _selectedCategory,
        _isPublic, 
      );
    } else {
      // Update
      await widget.controller.updateLog(
        widget.index!,
        _titleController.text,
        _descController.text,
        _selectedCategory,
        _isPublic,
      );
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil disimpan!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); 
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          backgroundColor: Colors.blue.shade300,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit), text: "Editor"),
              Tab(icon: Icon(Icons.preview), text: "Pratinjau"),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _save)
          ],
        ),
        body: TabBarView(
          children: [
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Judul Catatan",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _categories.map((String val) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                 
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CheckboxListTile(
                      title: const Text("Bagikan ke Tim (Public)"),
                      subtitle: const Text("Jika dimatikan, hanya Anda yang bisa lihat"),
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: _descController,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: """Tulis dengan format Markdown...

                                    # Heading 1
                                    ## Heading 2  
                                    ### Heading 3

                                    **Bold text**
                                    *Italic text*

                                    - List item 1
                                    - List item 2

                                    Tekan Enter untuk baris baru
                                    Gunakan spasi untuk indentasi""",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab 2: Markdown Preview
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _descController.text.isEmpty
                  ? const Center(child: Text("Belum ada teks untuk dipratinjau.", style: TextStyle(color: Colors.grey)))
                  : SingleChildScrollView(
                      child: MarkdownBody(
                        data: _descController.text,
                        softLineBreak: true, 
                        styleSheet: MarkdownStyleSheet(
                          
                          h1: const TextStyle(
                            fontSize: 28, 
                            fontWeight: FontWeight.w900, 
                            color: Colors.black,
                            height: 1.3,
                          ),
                          h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
                          
                          h2: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.w800, 
                            color: Colors.black87,
                            height: 1.3,
                          ),
                          h2Padding: const EdgeInsets.only(top: 14, bottom: 6),
                          
                          h3: const TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                          h3Padding: const EdgeInsets.only(top: 12, bottom: 4),
                          
                          strong: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          
                          em: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          
                          
                          p: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6, 
                          ),
                          
                         
                          listBullet: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          
                         
                          code: const TextStyle(
                            backgroundColor: Color(0xFFE8E8E8),
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          
                         
                          codeblockPadding: const EdgeInsets.all(12),
                          codeblockDecoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}