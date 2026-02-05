import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/admin_service.dart';
import '../../services/api_service.dart';
import '../../widgets/admin/admin_theme.dart';

class ArticleManager extends StatefulWidget {
  @override
  State<ArticleManager> createState() => _ArticleManagerState();
}

class _ArticleManagerState extends State<ArticleManager> {
  final _adminService = AdminService();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  File? _selectedImage;
  List<dynamic> _articles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);
    try {
      final result = await _adminService.getAllArticles();
      setState(() {
        _articles = result?['articles'] ?? result?['data'] ?? (result is List ? result : []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading articles: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> article) async {
    final editTitleController = TextEditingController(text: article['title'] ?? '');
    final editDescriptionController = TextEditingController(text: article['description'] ?? '');
    File? editImage;
    String? editImageUrl = article['image'] ?? article['imageUrl'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Article'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setDialogState(() {
                        editImage = File(pickedFile.path);
                        editImageUrl = null;
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: AdminTheme.uploadSectionDecoration(context),
                    child: editImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(editImage!, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: AdminTheme.editOverlayColor(context),
                                  borderRadius: BorderRadius.circular(20),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        setDialogState(() {
                                          editImage = File(pickedFile.path);
                                          editImageUrl = null;
                                        });
                                      }
                                    },
                                    padding: const EdgeInsets.all(6),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : editImageUrl != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(editImageUrl!, fit: BoxFit.cover),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Material(
                                      color: AdminTheme.editOverlayColor(context),
                                      borderRadius: BorderRadius.circular(20),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                        onPressed: () async {
                                          final picker = ImagePicker();
                                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                          if (pickedFile != null) {
                                            setDialogState(() {
                                              editImage = File(pickedFile.path);
                                              editImageUrl = null;
                                            });
                                          }
                                        },
                                        padding: const EdgeInsets.all(6),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 48, color: AdminTheme.fieldTextMuted(context)),
                                  const SizedBox(height: 8),
                                  Text('Tap to select image', style: TextStyle(color: AdminTheme.fieldTextMuted(context))),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editTitleController,
                  decoration: AdminTheme.inputDecoration(context, labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editDescriptionController,
                  decoration: AdminTheme.inputDecoration(context, labelText: 'Description'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _adminService.updateArticle(
                    articleId: article['_id'] ?? article['id'] ?? '',
                    image: editImage,
                    imageUrl: editImageUrl,
                    title: editTitleController.text.isEmpty
                        ? null
                        : editTitleController.text,
                    description: editDescriptionController.text.isEmpty
                        ? null
                        : editDescriptionController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Article updated successfully')),
                    );
                    _loadArticles();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createArticle() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _adminService.createArticle(
        image: _selectedImage,
        imageUrl: null,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article created successfully')),
      );
      
      _titleController.clear();
      _descriptionController.clear();
      setState(() => _selectedImage = null);
      _loadArticles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating article: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Article',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: AdminTheme.uploadSectionDecoration(context),
                      child: _selectedImage != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_selectedImage!, fit: BoxFit.cover),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    color: AdminTheme.editOverlayColor(context),
                                    borderRadius: BorderRadius.circular(20),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                      onPressed: _pickImage,
                                      padding: const EdgeInsets.all(6),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 48, color: AdminTheme.fieldTextMuted(context)),
                                const SizedBox(height: 8),
                                Text('Tap to upload image', style: TextStyle(color: AdminTheme.fieldTextMuted(context))),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Title *'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Description (Optional)'),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createArticle,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Article'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Articles List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Articles List',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _articles.isEmpty
                          ? const Center(child: Text('No articles found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _articles.length,
                              itemBuilder: (context, index) {
                                final article = _articles[index];
                                return ListTile(
                                  leading: article['image'] != null || article['imageUrl'] != null
                                      ? Image.network(
                                          article['image'] ?? article['imageUrl'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.article),
                                        )
                                      : const Icon(Icons.article),
                                  title: Text(article['title'] ?? 'Unknown'),
                                  subtitle: Text(article['description'] ?? ''),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditDialog(article),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Article'),
                                              content: const Text('Are you sure you want to delete this article?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true) {
                                            try {
                                              await _adminService.deleteArticle(
                                                articleId: article['_id'] ?? article['id'] ?? '',
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Article deleted successfully')),
                                                );
                                                _loadArticles();
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error deleting article: ${e.toString()}')),
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

