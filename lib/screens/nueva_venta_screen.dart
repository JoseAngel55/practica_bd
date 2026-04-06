import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practica_bd/firebase/categorias_firestore.dart';
import 'package:practica_bd/firebase/detalles_venta_firestore.dart';
import 'package:practica_bd/firebase/email_auth.dart';
import 'package:practica_bd/firebase/productos_firestore.dart';
import 'package:practica_bd/firebase/ventas_firestore.dart';
import 'package:practica_bd/listeners/value_listener.dart';
import 'package:practica_bd/models/categoria_model.dart';
import 'package:practica_bd/models/detalle_venta.dart';
import 'package:practica_bd/models/producto_model.dart';
import 'package:practica_bd/utils/notifications_service.dart';
import 'package:practica_bd/utils/theme_app.dart';

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({super.key});
  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaScreenState();
}

class _NuevaVentaScreenState extends State<NuevaVentaScreen> {
  final _ventasFS   = VentasFirestore();
  final _catFS      = CategoriasFirestore();
  final _prodFS     = ProductosFirestore();
  final _detFS      = DetallesVentaFirestore();
  final _auth       = EmailAuth();

  final _conCliente  = TextEditingController();
  final _conTelefono = TextEditingController();
  final _conNotas    = TextEditingController();
  final _conFecha    = TextEditingController();

  String _tipo = 'servicio';
  CategoriaDAO? _catSel;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    // Diferir al siguiente frame para evitar modificar ValueNotifier durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ValueListener.limpiarCarrito();
    });
  }

  @override
  void dispose() {
    _conCliente.dispose();
    _conTelefono.dispose();
    _conNotas.dispose();
    _conFecha.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final f = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: AppTheme.darkTheme().copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonGreen,
              onPrimary: AppTheme.bgDeep,
              surface: AppTheme.bgCard),
        ),
        child: child!,
      ),
    );
    if (f != null) _conFecha.text = DateFormat('yyyy-MM-dd').format(f);
  }

  Future<void> _guardar() async {
    if (_conCliente.text.trim().isEmpty || _conFecha.text.isEmpty) {
      _snack('// ERROR: cliente y fecha son obligatorios', AppTheme.neonRed);
      return;
    }
    if (ValueListener.carrito.value.isEmpty) {
      _snack('// ERROR: agrega al menos un ítem al carrito', AppTheme.neonRed);
      return;
    }
    setState(() => _guardando = true);

    // ✅ CORREGIDO: las claves ahora coinciden exactamente con VentaDAO.fromMap
    final data = {
      'nombreCliente':   _conCliente.text.trim(),
      'telefonoCliente': _conTelefono.text.trim(),
      'tipo':            _tipo,
      'status':          'pendiente',   // era 'estatus' — campo incorrecto
      'fechaEntrega':    _conFecha.text,
      'notas':           _conNotas.text.trim(),
      'total':           ValueListener.totalCarrito,
      'idUsuario':       _auth.currentUserId ?? '',
      'fechaCreacion':   DateTime.now().toIso8601String(),
    };

    final idVenta = await _ventasFS.insertVenta(data);
    if (idVenta != null) {
      for (final item in ValueListener.carrito.value) {
        await _detFS.insertDetalle({
          'idVenta':         idVenta,
          'idProducto':      item.idProducto,
          'nombreProducto':  item.nombreProducto,
          'precioUnitario':  item.precioUnitario,
          'cantidad':        item.cantidad,
          'subtotal':        item.subtotal,
        });
      }
      final fechaE = DateTime.tryParse(_conFecha.text);
      if (fechaE != null) {
        await NotificationsService.programarRecordatorio(
          id: idVenta.hashCode.abs(),
          titulo: 'RECORDATORIO: ${_conCliente.text}',
          cuerpo: 'Orden $_tipo programada para ${_conFecha.text}',
          fechaEntrega: fechaE,
        );
      }
      ValueListener.limpiarCarrito();
      if (mounted) {
        _snack('// ORDEN REGISTRADA OK', AppTheme.neonGreen);
        Navigator.pop(context);
      }
    } else {
      _snack('// ERROR al guardar', AppTheme.neonRed);
    }
    if (mounted) setState(() => _guardando = false);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.bgElevated,
      showCloseIcon: true,
      closeIconColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: const Text('> NUEVA ORDEN'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.borderIdle),
        ),
      ),
      body: CustomScrollView(
        slivers: [

          // ── Formulario ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Selector de tipo
                _SectionLabel('TIPO DE ORDEN'),
                const SizedBox(height: 8),
                Row(children: [
                  _TypeBtn(label: 'SERVICIO', icon: Icons.build_outlined,
                      selected: _tipo == 'servicio',
                      onTap: () => setState(() => _tipo = 'servicio')),
                  const SizedBox(width: 8),
                  _TypeBtn(label: 'VENTA', icon: Icons.router_outlined,
                      selected: _tipo == 'venta',
                      onTap: () => setState(() => _tipo = 'venta')),
                ]),

                const SizedBox(height: 18),
                _SectionLabel('DATOS DEL CLIENTE'),
                const SizedBox(height: 8),

                _TermField(label: 'NOMBRE / EMPRESA',
                    controller: _conCliente, icon: Icons.person_outline),
                const SizedBox(height: 10),
                _TermField(label: 'TELÉFONO',
                    controller: _conTelefono, icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _TermField(label: 'FECHA DE ENTREGA / VISITA',
                    controller: _conFecha, icon: Icons.event_outlined,
                    readOnly: true, onTap: _seleccionarFecha),
                const SizedBox(height: 10),
                _TermField(label: 'NOTAS TÉCNICAS',
                    controller: _conNotas, icon: Icons.terminal,
                    maxLines: 2),

                const SizedBox(height: 20),
                _SectionLabel('CATEGORÍA DE PRODUCTOS/SERVICIOS'),
                const SizedBox(height: 8),
              ]),
            ),
          ),

          // ── Categorías scroll horizontal ─────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 72,
              child: StreamBuilder<QuerySnapshot>(
                stream: _catFS.getCategorias(),
                builder: (_, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  final cats = snap.data!.docs.map((d) =>
                      CategoriaDAO.fromMap(
                          d.data() as Map<String, dynamic>, d.id)).toList();
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: cats.length,
                    itemBuilder: (_, i) {
                      final c = cats[i];
                      final sel = _catSel?.idCategoria == c.idCategoria;
                      return GestureDetector(
                        onTap: () => setState(() => _catSel = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppTheme.neonGreen.withOpacity(0.1)
                                : AppTheme.bgCard,
                            border: Border.all(
                                color: sel
                                    ? AppTheme.neonGreen
                                    : AppTheme.borderIdle,
                                width: sel ? 1.5 : 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(c.nombre?.toUpperCase() ?? '',
                                  style: TextStyle(
                                    fontFamily: 'ShareTechMono',
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                    color: sel
                                        ? AppTheme.neonGreen
                                        : AppTheme.textSecondary,
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // ── Productos de la categoría ─────────────────────────
          if (_catSel != null) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
              sliver: SliverToBoxAdapter(
                child: _SectionLabel(
                    '${_catSel!.nombre?.toUpperCase()} — SELECCIONAR ÍTEMS'),
              ),
            ),
            SliverToBoxAdapter(
              child: StreamBuilder<QuerySnapshot>(
                stream: _prodFS
                    .getProductosByCategoria(_catSel!.idCategoria!),
                builder: (_, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  final prods = snap.data!.docs.map((d) =>
                      ProductoDAO.fromMap(
                          d.data() as Map<String, dynamic>, d.id)).toList();
                  if (prods.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        '// Sin productos en esta categoría',
                        style: const TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 11,
                            color: AppTheme.textMuted),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: prods
                          .map((p) => _ProductoChip(producto: p))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],

          // ── Carrito / resumen ─────────────────────────────────
          SliverToBoxAdapter(
            child: ValueListenableBuilder<List<CarritoItem>>(
              valueListenable: ValueListener.carrito,
              builder: (_, carrito, __) {
                if (carrito.isEmpty) {
                  return const SizedBox(height: 100);
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(height: 1, color: AppTheme.borderIdle),
                    const SizedBox(height: 12),
                    _SectionLabel('ÍTEMS EN ORDEN'),
                    const SizedBox(height: 8),
                    ...carrito.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: const BoxDecoration(
                            color: AppTheme.bgSurface,
                            border: Border(
                                left: BorderSide(
                                    color: AppTheme.neonGreen, width: 2),
                                top: BorderSide(color: AppTheme.borderIdle),
                                right: BorderSide(color: AppTheme.borderIdle),
                                bottom: BorderSide(color: AppTheme.borderIdle)),
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(item.nombreProducto,
                                    style: const TextStyle(
                                        fontFamily: 'ShareTechMono',
                                        fontSize: 12,
                                        color: AppTheme.textPrimary)),
                                Text(
                                    '${item.cantidad} ${item.unidad}  ×  '
                                    '\$${item.precioUnitario.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontFamily: 'ShareTechMono',
                                        fontSize: 10,
                                        color: AppTheme.textMuted)),
                              ]),
                            ),
                            Text(
                                '\$${item.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontFamily: 'ShareTechMono',
                                    fontSize: 14,
                                    color: AppTheme.neonGreen)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => ValueListener
                                  .quitarDelCarrito(item.idProducto),
                              child: const Icon(Icons.close,
                                  size: 14, color: AppTheme.neonRed),
                            ),
                          ]),
                        )),
                    const SizedBox(height: 8),
                    Container(height: 1, color: AppTheme.borderIdle),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                        const Text('TOTAL:',
                            style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 12, color: AppTheme.textMuted,
                                letterSpacing: 2)),
                        Text(
                          '\$${ValueListener.totalCarrito.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 22,
                            color: AppTheme.neonGreen,
                            shadows: [Shadow(
                                color: AppTheme.neonGreen, blurRadius: 8)],
                          ),
                        ),
                      ]),
                    ),
                  ]),
                );
              },
            ),
          ),

          // ── Botón guardar ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 40),
              child: GestureDetector(
                onTap: _guardando ? null : _guardar,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.1),
                    border: Border.all(
                        color: _guardando
                            ? AppTheme.borderIdle
                            : AppTheme.neonGreen,
                        width: 1.5),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: AppTheme.neonGreen, strokeWidth: 1.5))
                      : Text('> REGISTRAR ORDEN',
                          style: TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 13, letterSpacing: 3,
                            color: AppTheme.neonGreen,
                            shadows: [Shadow(
                                color: AppTheme.neonGreen.withOpacity(0.5),
                                blurRadius: 8)],
                          )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets reutilizables ────────────────────────────────────────────────────

class QuantitySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _TermBtn(
        label: '−',
        onTap: value > min ? () => onChanged(value - 1) : null,
      ),
      Container(
        width: 52,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppTheme.bgSurface,
          border: Border.symmetric(
              horizontal: BorderSide(color: AppTheme.borderIdle)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(
            '$value',
            key: ValueKey(value),
            style: const TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 18,
                color: AppTheme.neonGreen),
          ),
        ),
      ),
      _TermBtn(
        label: '+',
        onTap: value < max ? () => onChanged(value + 1) : null,
      ),
    ]);
  }
}

class _TermBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _TermBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? AppTheme.neonGreen.withOpacity(0.08)
              : AppTheme.bgSurface,
          border: Border.all(
              color: active ? AppTheme.neonGreen : AppTheme.borderIdle),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 18,
                color: active ? AppTheme.neonGreen : AppTheme.textMuted)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
      '> $text',
      style: const TextStyle(fontFamily: 'ShareTechMono', fontSize: 10,
          color: AppTheme.textSecondary, letterSpacing: 2));
}

class _TermField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  const _TermField({required this.label, required this.controller,
      required this.icon, this.keyboardType, this.readOnly = false,
      this.onTap, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontFamily: 'ShareTechMono',
        fontSize: 9, color: AppTheme.textMuted, letterSpacing: 2)),
    const SizedBox(height: 5),
    TextField(controller: controller, readOnly: readOnly, onTap: onTap,
        keyboardType: keyboardType, maxLines: maxLines,
        style: const TextStyle(color: AppTheme.textPrimary,
            fontFamily: 'ShareTechMono', fontSize: 13),
        decoration: InputDecoration(prefixIcon: Icon(icon, size: 14))),
  ]);
}

class _TypeBtn extends StatelessWidget {
  final String label; final IconData icon;
  final bool selected; final VoidCallback onTap;
  const _TypeBtn({required this.label, required this.icon,
      required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppTheme.neonGreen.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
            color: selected ? AppTheme.neonGreen : AppTheme.borderIdle)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14,
            color: selected ? AppTheme.neonGreen : AppTheme.textMuted),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontFamily: 'ShareTechMono',
            fontSize: 11, letterSpacing: 1.5,
            color: selected ? AppTheme.neonGreen : AppTheme.textMuted)),
      ]),
    ),
  );
}

class _ProductoChip extends StatelessWidget {
  final ProductoDAO producto;
  const _ProductoChip({required this.producto});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _dialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          border: Border.all(color: AppTheme.borderIdle),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add, size: 12, color: AppTheme.neonGreen),
          const SizedBox(width: 6),
          Text('${producto.nombre}',
              style: const TextStyle(fontFamily: 'ShareTechMono',
                  fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(width: 8),
          Text('\$${producto.precio?.toStringAsFixed(2)}',
              style: const TextStyle(fontFamily: 'ShareTechMono',
                  fontSize: 11, color: AppTheme.neonGreen)),
        ]),
      ),
    );
  }

  void _dialog(BuildContext context) {
    int cantidad = 1;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(producto.nombre?.toUpperCase() ?? ''),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('\$${producto.precio?.toStringAsFixed(2)} / ${producto.unidad ?? 'pza'}',
                style: const TextStyle(fontFamily: 'ShareTechMono',
                    fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            QuantitySelector(value: cantidad,
                onChanged: (v) => setSt(() => cantidad = v)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppTheme.neonGreen, width: 1))),
              child: Text(
                'SUBTOTAL  \$${((producto.precio ?? 0) * cantidad).toStringAsFixed(2)}',
                style: const TextStyle(fontFamily: 'ShareTechMono',
                    fontSize: 14, color: AppTheme.neonGreen),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCELAR',
                    style: TextStyle(fontFamily: 'ShareTechMono',
                        fontSize: 10, color: AppTheme.textMuted,
                        letterSpacing: 2))),
            GestureDetector(
              onTap: () {
                ValueListener.agregarAlCarrito(CarritoItem(
                  idProducto: producto.idProducto!,
                  nombreProducto: producto.nombre!,
                  precioUnitario: producto.precio!,
                  cantidad: cantidad,
                  unidad: producto.unidad ?? 'pza',
                ));
                Navigator.pop(ctx);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.1),
                    border: Border.all(color: AppTheme.neonGreen)),
                child: const Text('AGREGAR',
                    style: TextStyle(fontFamily: 'ShareTechMono',
                        fontSize: 11, color: AppTheme.neonGreen,
                        letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}