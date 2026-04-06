import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practica_bd/firebase/categorias_firestore.dart';
import 'package:practica_bd/firebase/productos_firestore.dart';
import 'package:practica_bd/models/categoria_model.dart';
import 'package:practica_bd/models/producto_model.dart';
import 'package:practica_bd/utils/theme_app.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});
  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

final _conNombre = TextEditingController();
final _conDesc   = TextEditingController();
final _conPrecio = TextEditingController();
final _conUnidad = TextEditingController();

class _ProductosScreenState extends State<ProductosScreen> {
  final _prodFS = ProductosFirestore();
  final _catFS  = CategoriasFirestore();
  String? _catFiltro;

  void _showAlert([ProductoDAO? prod]) {
    String? catId = prod?.idCategoria;
    if (prod != null) {
      _conNombre.text = prod.nombre ?? '';
      _conDesc.text   = prod.descripcion ?? '';
      _conPrecio.text = prod.precio?.toString() ?? '';
      _conUnidad.text = prod.unidad ?? '';
    } else {
      _conNombre.clear(); _conDesc.clear();
      _conPrecio.clear(); _conUnidad.clear();
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(prod == null ? '> NUEVO EQUIPO/SERVICIO' : '> EDITAR'),
          content: SizedBox(width: 300,
            child: ListView(shrinkWrap: true, children: [
              _DField(label: 'NOMBRE', controller: _conNombre),
              const SizedBox(height: 8),
              _DField(label: 'DESCRIPCIÓN', controller: _conDesc),
              const SizedBox(height: 8),
              _DField(label: 'PRECIO (MXN)', controller: _conPrecio,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 8),
              _DField(label: 'UNIDAD (pza, hr, kg…)', controller: _conUnidad),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: _catFS.getCategorias(),
                builder: (_, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  final cats = snap.data!.docs.map((d) =>
                      CategoriaDAO.fromMap(d.data() as Map<String, dynamic>, d.id))
                      .toList();
                  return Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CATEGORÍA', style: TextStyle(
                          fontFamily: 'ShareTechMono', fontSize: 9,
                          color: AppTheme.textMuted, letterSpacing: 2)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            border: Border.all(color: AppTheme.borderIdle)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: catId,
                            isExpanded: true,
                            dropdownColor: AppTheme.bgCard,
                            style: const TextStyle(color: AppTheme.textPrimary,
                                fontFamily: 'ShareTechMono', fontSize: 12),
                            hint: const Text('SELECCIONAR',
                                style: TextStyle(color: AppTheme.textMuted,
                                    fontFamily: 'ShareTechMono', fontSize: 11)),
                            items: cats.map((c) => DropdownMenuItem(
                                value: c.idCategoria,
                                child: Text(c.nombre?.toUpperCase() ?? ''))).toList(),
                            onChanged: (v) => setSt(() => catId = v),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCELAR',
                    style: TextStyle(fontFamily: 'ShareTechMono', fontSize: 10,
                        color: AppTheme.textMuted, letterSpacing: 2))),
            GestureDetector(
              onTap: () async {
                if (_conNombre.text.trim().isEmpty ||
                    _conPrecio.text.trim().isEmpty || catId == null) return;
                final data = {
                  'nombre': _conNombre.text.trim(),
                  'descripcion': _conDesc.text.trim(),
                  'precio': double.tryParse(_conPrecio.text) ?? 0,
                  'unidad': _conUnidad.text.trim(),
                  'idCategoria': catId,
                };
                final ok = prod == null
                    ? await _prodFS.insertProducto(data)
                    : await _prodFS.updateProducto(prod.idProducto!, data);
                if (ok && ctx.mounted) Navigator.pop(ctx);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.1),
                    border: Border.all(color: AppTheme.neonGreen)),
                child: const Text('GUARDAR',
                    style: TextStyle(fontFamily: 'ShareTechMono', fontSize: 11,
                        color: AppTheme.neonGreen, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _catFiltro != null
          ? _prodFS.getProductosByCategoria(_catFiltro!)
          : _prodFS.getProductos(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(
            child: CircularProgressIndicator(color: AppTheme.neonGreen));
        final prods = snap.data!.docs.map((d) =>
            ProductoDAO.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true, automaticallyImplyLeading: false,
              backgroundColor: AppTheme.bgDeep,
              title: Text('> EQUIPOS & SERVICIOS (${prods.length})',
                  style: const TextStyle(fontFamily: 'ShareTechMono',
                      fontSize: 13, color: AppTheme.neonGreen, letterSpacing: 2)),
              actions: [
                GestureDetector(
                  onTap: () => _showAlert(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.08),
                        border: Border.all(color: AppTheme.neonGreen)),
                    child: const Row(children: [
                      Icon(Icons.add, size: 14, color: AppTheme.neonGreen),
                      SizedBox(width: 4),
                      Text('AGREGAR', style: TextStyle(fontFamily: 'ShareTechMono',
                          fontSize: 10, color: AppTheme.neonGreen, letterSpacing: 1.5)),
                    ]),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _catFS.getCategorias(),
                  builder: (_, snap2) {
                    if (!snap2.hasData) return const SizedBox.shrink();
                    final cats = snap2.data!.docs.map((d) =>
                        CategoriaDAO.fromMap(d.data() as Map<String, dynamic>, d.id))
                        .toList();
                    return Container(
                      height: 44,
                      color: AppTheme.bgCard,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        children: [
                          _FilterChip(label: 'TODOS', selected: _catFiltro == null,
                              onTap: () => setState(() => _catFiltro = null)),
                          ...cats.map((c) => _FilterChip(
                              label: c.nombre?.toUpperCase() ?? '',
                              selected: _catFiltro == c.idCategoria,
                              onTap: () => setState(() => _catFiltro = c.idCategoria))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            if (prods.isEmpty)
              SliverFillRemaining(child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.router_outlined, size: 48,
                        color: AppTheme.textMuted.withOpacity(0.3)),
                    const SizedBox(height: 10),
                    const Text('// SIN PRODUCTOS',
                        style: TextStyle(fontFamily: 'ShareTechMono',
                            fontSize: 12, color: AppTheme.textMuted, letterSpacing: 2)),
                  ],
                ),
              ))
            else
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((_, i) {
                    final p = prods[i];
                    return GestureDetector(
                      onTap: () => _showAlert(p),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: const BoxDecoration(
                          color: AppTheme.bgCard,
                          border: Border(
                            left: BorderSide(color: AppTheme.neonBlue, width: 3),
                            top: BorderSide(color: AppTheme.borderIdle),
                            right: BorderSide(color: AppTheme.borderIdle),
                            bottom: BorderSide(color: AppTheme.borderIdle),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(children: [
                            const Icon(Icons.router_outlined, size: 20,
                                color: AppTheme.neonBlue),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(p.nombre?.toUpperCase() ?? '',
                                  style: const TextStyle(
                                      fontFamily: 'ShareTechMono', fontSize: 12,
                                      color: AppTheme.textPrimary)),
                              Text('${p.descripcion ?? ''}  //  ${p.unidad ?? ''}',
                                  style: const TextStyle(
                                      fontFamily: 'ShareTechMono', fontSize: 10,
                                      color: AppTheme.textMuted)),
                            ])),
                            Column(crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                              Text('\$${p.precio?.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontFamily: 'ShareTechMono', fontSize: 15,
                                      color: AppTheme.neonGreen)),
                              GestureDetector(
                                onTap: () => _prodFS.deleteProducto(p.idProducto!),
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(Icons.delete_outline,
                                      size: 14, color: AppTheme.neonRed),
                                ),
                              ),
                            ]),
                          ]),
                        ),
                      ),
                    );
                  }, childCount: prods.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppTheme.neonBlue.withOpacity(0.12) : Colors.transparent,
        border: Border.all(color: selected ? AppTheme.neonBlue : AppTheme.borderIdle),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'ShareTechMono',
          fontSize: 9, letterSpacing: 1.5,
          color: selected ? AppTheme.neonBlue : AppTheme.textMuted)),
    ),
  );
}

class _DField extends StatelessWidget {
  final String label; final TextEditingController controller;
  final TextInputType? keyboardType;
  const _DField({required this.label, required this.controller,
      this.keyboardType});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontFamily: 'ShareTechMono',
        fontSize: 9, color: AppTheme.textMuted, letterSpacing: 2)),
    const SizedBox(height: 5),
    TextField(controller: controller, keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textPrimary,
            fontFamily: 'ShareTechMono', fontSize: 12),
        decoration: const InputDecoration()),
  ]);
}
