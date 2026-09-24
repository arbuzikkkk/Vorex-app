import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../services/product_service.dart';
import '../../widgets/glass_card.dart';
import '../catalog/catalog_screen.dart' show kCategories;

class SellScreen extends StatefulWidget {
  final AppUser? user;
  const SellScreen({super.key, required this.user});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  String _category = kCategories[1];
  final List<String> _photos = [];
  bool _submitting = false;

  Future<void> _pickPhoto() async {
    if (_photos.length >= 10) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _photos.add(file.path));
  }

  Future<void> _submit() async {
    final user = widget.user;
    if (user == null) return;
    final title = _title.text.trim();
    final desc = _description.text.trim();
    final price = double.tryParse(_price.text.replaceAll(',', '.'));

    if (title.isEmpty || desc.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля корректно'), backgroundColor: VorexColors.danger),
      );
      return;
    }

    setState(() => _submitting = true);
    await ProductService().createProduct(
      sellerId: user.id,
      title: title,
      description: desc,
      price: price,
      category: _category,
      photoPaths: _photos,
    );
    setState(() {
      _submitting = false;
      _title.clear();
      _description.clear();
      _price.clear();
      _photos.clear();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Товар выставлен на продажу!'), backgroundColor: VorexColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Продать товар', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(hintText: 'Название товара'),
                  style: const TextStyle(color: VorexColors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Описание'),
                  style: const TextStyle(color: VorexColors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Цена, ₽'),
                  style: const TextStyle(color: VorexColors.white),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _category,
                  dropdownColor: VorexColors.bgPanel,
                  decoration: const InputDecoration(),
                  items: kCategories.skip(1).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Фото (до 10)', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._photos.map((path) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(path), height: 90, width: 90, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2, right: 2,
                            child: GestureDetector(
                              onTap: () => setState(() => _photos.remove(path)),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: VorexColors.danger,
                                child: Icon(Icons.close, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                if (_photos.length < 10)
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      height: 90, width: 90,
                      decoration: BoxDecoration(
                        color: VorexColors.bgPanel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: VorexColors.glassBorder),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined, color: VorexColors.greyText),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Выставить на продажу'),
            ),
          ),
        ],
      ),
    );
  }
}
