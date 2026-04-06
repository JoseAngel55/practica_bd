import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practica_bd/firebase/categorias_firestore.dart';
import 'package:practica_bd/models/categoria_model.dart';
import 'package:practica_bd/utils/theme_app.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});
  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

final _conNombre = TextEditingController();
final _conDesc   = TextEditingController();

class _CategoriasScreenState extends State<CategoriasScreen> {
  final _catFS = CategoriasFirestore();

  void _showAlert([CategoriaDAO? cat]) {
    if (cat != null) {
      _conNombre.text = cat.nombre ?? '';
      _conDesc.text   = cat.descripcion ?? '';
    } else {
      _conNombre.clear(); _conDesc.clear();
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(cat == null ? '> NUEVA CATEGORÍA' : '> EDITAR CATEGORÍA'),
        content: SizedBox(width: 300, child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(label: 'NOMBRE', controller: _conNombre),
            const SizedBox(height: 10),
            _DialogField(label: 'DESCRIPCIÓN', controller: _conDesc),
          ],
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR',
                  style: TextStyle(fontFamily: 'ShareTechMono',
                      fontSize: 10, color: AppTheme.textMuted, letterSpacing: 2))),
          GestureDetector(
            onTap: () async {
              if (_conNombre.text.trim().isEmpty) return;
              final data = {'nombre': _conNombre.text.trim(),
                  'descripcion': _conDesc.text.trim()};
              final ok = cat == null
                  ? await _catFS.insertCategoria(data)
                  : await _catFS.updateCategoria(cat.idCategoria!, data);
              if (ok && context.mounted) Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.1),
                  border: Border.all(color: AppTheme.neonGreen)),
              child: const Text('GUARDAR',
                  style: TextStyle(fontFamily: 'ShareTechMono',
                      fontSize: 11, color: AppTheme.neonGreen, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _catFS.getCategorias(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(
            child: CircularProgressIndicator(color: AppTheme.neonGreen));
        final cats = snap.data!.docs.map((d) =>
            CategoriaDAO.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true, automaticallyImplyLeading: false,
              backgroundColor: AppTheme.bgDeep,
              title: Text('> CATEGORÍAS (${cats.length})',
                  style: const TextStyle(fontFamily: 'ShareTechMono',
                      fontSize: 13, color: AppTheme.neonGreen, letterSpacing: 2)),
              actions: [
                GestureDetector(
                  onTap: () => _showAlert(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.08),
                        border: Border.all(color: AppTheme.neonGreen)),
                    child: const Row(children: [
                      Icon(Icons.add, size: 14, color: AppTheme.neonGreen),
                      SizedBox(width: 4),
                      Text('NUEVA', style: TextStyle(fontFamily: 'ShareTechMono',
                          fontSize: 10, color: AppTheme.neonGreen,
                          letterSpacing: 1.5)),
                    ]),
                  ),
                ),
              ],
              bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(1),
                  child: Divider(height: 1, color: AppTheme.borderIdle)),
            ),

            if (cats.isEmpty)
              SliverFillRemaining(child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 48,
                        color: AppTheme.textMuted.withOpacity(0.3)),
                    const SizedBox(height: 10),
                    const Text('// SIN CATEGORÍAS',
                        style: TextStyle(fontFamily: 'ShareTechMono',
                            fontSize: 12, color: AppTheme.textMuted,
                            letterSpacing: 2)),
                  ],
                ),
              ))
            else
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 8,
                      crossAxisSpacing: 8, childAspectRatio: 1.1),
                  delegate: SliverChildBuilderDelegate((_, i) {
                    final c = cats[i];
                    return GestureDetector(
                      onTap: () => _showAlert(c),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          border: Border.all(color: AppTheme.borderIdle),
                        ),
                        child: Stack(children: [
                          // Acento superior
                          Positioned(top: 0, left: 0, right: 0,
                              child: Container(height: 2,
                                  color: AppTheme.neonGreen.withOpacity(0.5))),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              const Icon(Icons.lan_outlined, size: 24,
                                  color: AppTheme.neonGreen),
                              const Spacer(),
                              Text(c.nombre?.toUpperCase() ?? '',
                                  style: const TextStyle(
                                      fontFamily: 'ShareTechMono', fontSize: 13,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: 0.5),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (c.descripcion?.isNotEmpty == true)
                                Text(c.descripcion!,
                                    style: const TextStyle(
                                        fontFamily: 'ShareTechMono',
                                        fontSize: 10,
                                        color: AppTheme.textMuted),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(children: [
                                const Spacer(),
                                GestureDetector(
                                  onTap: () async {
                                    await _catFS.deleteCategoria(c.idCategoria!);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppTheme.neonRed.withOpacity(0.4))),
                                    child: const Icon(Icons.delete_outline,
                                        size: 12, color: AppTheme.neonRed),
                                  ),
                                ),
                              ]),
                            ]),
                          ),
                        ]),
                      ),
                    );
                  }, childCount: cats.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}

class _DialogField extends StatelessWidget {
  final String label; final TextEditingController controller;
  const _DialogField({required this.label, required this.controller});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontFamily: 'ShareTechMono',
        fontSize: 9, color: AppTheme.textMuted, letterSpacing: 2)),
    const SizedBox(height: 5),
    TextField(controller: controller,
        style: const TextStyle(color: AppTheme.textPrimary,
            fontFamily: 'ShareTechMono', fontSize: 13),
        decoration: const InputDecoration()),
  ]);
}
