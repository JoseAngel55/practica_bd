import 'package:flutter/material.dart';
import 'package:practica_bd/firebase/detalles_venta_firestore.dart';
import 'package:practica_bd/firebase/ventas_firestore.dart';
import 'package:practica_bd/models/detalle_venta.dart';
import 'package:practica_bd/models/venta_model.dart';
import 'package:practica_bd/screens/ventas_list_screen.dart';
import 'package:practica_bd/utils/theme_app.dart';

class DetalleVentaScreen extends StatefulWidget {
  final VentaDAO venta;
  const DetalleVentaScreen({super.key, required this.venta});
  @override
  State<DetalleVentaScreen> createState() => _DetalleVentaScreenState();
}

class _DetalleVentaScreenState extends State<DetalleVentaScreen> {
  final _ventasFS = VentasFirestore();
  final _detFS    = DetallesVentaFirestore();
  late VentaDAO _v;

  @override
  void initState() { super.initState(); _v = widget.venta; }

  Future<void> _cambiarEstatus(String est) async {
    await _ventasFS.updateVenta(_v.idVenta!, {'status': est});
    setState(() => _v.status = est);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('// ESTATUS → $est'.toUpperCase()),
        backgroundColor: AppTheme.bgElevated,
      ));
    }
  }

  Future<void> _eliminar() async {
    final ok = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(
        title: const Text('ELIMINAR ORDEN'),
        content: const Text('Esta acción es irreversible.',
            style: TextStyle(fontFamily: 'ShareTechMono',
                fontSize: 12, color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR',
                  style: TextStyle(fontFamily: 'ShareTechMono',
                      color: AppTheme.textMuted, fontSize: 10,
                      letterSpacing: 2))),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: AppTheme.neonRed.withOpacity(0.1),
                  border: Border.all(color: AppTheme.neonRed)),
              child: const Text('ELIMINAR',
                  style: TextStyle(fontFamily: 'ShareTechMono',
                      color: AppTheme.neonRed, fontSize: 11,
                      letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _detFS.deleteDetallesByVenta(_v.idVenta!);
      await _ventasFS.deleteVenta(_v.idVenta!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = AppTheme.colorEstatus(_v.status);
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text('> ${_v.nombreCliente?.toUpperCase() ?? 'ORDEN'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppTheme.neonRed.withOpacity(0.7),
            onPressed: _eliminar,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.borderIdle)),
      ),
      body: CustomScrollView(
        slivers: [

          // ── Header de la orden ──────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                border: Border(
                  left: BorderSide(color: col, width: 4),
                  top: const BorderSide(color: AppTheme.borderIdle),
                  right: const BorderSide(color: AppTheme.borderIdle),
                  bottom: const BorderSide(color: AppTheme.borderIdle),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Cliente + badge
                  Row(children: [
                    Expanded(
                      child: Text(
                        _v.nombreCliente?.toUpperCase() ?? '',
                        style: const TextStyle(
                            fontFamily: 'ShareTechMono', fontSize: 18,
                            color: AppTheme.textPrimary, letterSpacing: 1),
                      ),
                    ),
                    StatusBadge(estatus: _v.status ?? 'pendiente'),
                  ]),
                  const SizedBox(height: 14),
                  Container(height: 1, color: AppTheme.borderIdle),
                  const SizedBox(height: 12),

                  // Metadata en grid
                  Wrap(runSpacing: 10, spacing: 24, children: [
                    _DataField('TIPO', _v.tipo?.toUpperCase() ?? '—'),
                    _DataField('ENTREGA', _v.fechaEntrega ?? '—'),
                    _DataField('TELÉFONO',
                        _v.telefonoCliente?.isNotEmpty == true
                            ? _v.telefonoCliente!
                            : '—'),
                    if (_v.notas?.isNotEmpty == true)
                      _DataField('NOTAS', _v.notas!),
                  ]),

                  const SizedBox(height: 14),
                  Container(height: 1, color: AppTheme.borderIdle),
                  const SizedBox(height: 12),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL ORDEN',
                          style: TextStyle(fontFamily: 'ShareTechMono',
                              fontSize: 10, color: AppTheme.textMuted,
                              letterSpacing: 2)),
                      Text(
                        '\$${_v.total?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontFamily: 'ShareTechMono', fontSize: 24,
                          color: col,
                          shadows: [Shadow(color: col.withOpacity(0.5),
                              blurRadius: 8)],
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text('> DESGLOSE DE ÍTEMS',
                  style: TextStyle(fontFamily: 'ShareTechMono', fontSize: 10,
                      color: AppTheme.textMuted, letterSpacing: 2)),
            ),
          ),

          FutureBuilder<List<DetalleVentaDAO>>(
            future: _detFS.getDetallesByVenta(_v.idVenta!),
            builder: (_, snap) {
              if (!snap.hasData) return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator(
                      color: AppTheme.neonGreen)));
              final items = snap.data!;
              if (items.isEmpty) return const SliverToBoxAdapter(
                  child: Padding(padding: EdgeInsets.all(12),
                      child: Text('// sin ítems registrados',
                          style: TextStyle(fontFamily: 'ShareTechMono',
                              fontSize: 11, color: AppTheme.textMuted))));
              return SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  final d = items[i];
                  return Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppTheme.bgSurface,
                      border: Border(
                        left: BorderSide(color: AppTheme.neonBlue, width: 2),
                        top: BorderSide(color: AppTheme.borderIdle),
                        right: BorderSide(color: AppTheme.borderIdle),
                        bottom: BorderSide(color: AppTheme.borderIdle),
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        width: 28, height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.neonBlue.withOpacity(0.1),
                          border: Border.all(color: AppTheme.neonBlue),
                        ),
                        child: Text('${d.cantidad}',
                            style: const TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 11, color: AppTheme.neonBlue)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(d.nombreProducto ?? '',
                              style: const TextStyle(
                                  fontFamily: 'ShareTechMono',
                                  fontSize: 12, color: AppTheme.textPrimary)),
                          Text('\$${d.precioUnitario?.toStringAsFixed(2)} c/u',
                              style: const TextStyle(
                                  fontFamily: 'ShareTechMono', fontSize: 10,
                                  color: AppTheme.textMuted)),
                        ]),
                      ),
                      Text('\$${d.subtotal?.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontFamily: 'ShareTechMono', fontSize: 14,
                              color: AppTheme.neonBlue)),
                    ]),
                  );
                }, childCount: items.length),
              );
            },
          ),

          // ── Cambiar estatus ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 40),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('> CAMBIAR ESTATUS',
                    style: TextStyle(fontFamily: 'ShareTechMono', fontSize: 10,
                        color: AppTheme.textMuted, letterSpacing: 2)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _EstatusBtn(label: 'COMPLETADO',
                      color: AppTheme.neonBlue,
                      active: _v.status == 'completado',
                      onTap: () => _cambiarEstatus('completado'))),
                  const SizedBox(width: 6),
                  Expanded(child: _EstatusBtn(label: 'CANCELADO',
                      color: AppTheme.neonRed,
                      active: _v.status == 'cancelado',
                      onTap: () => _cambiarEstatus('cancelado'))),
                  const SizedBox(width: 6),
                  Expanded(child: _EstatusBtn(label: 'ACTIVO',
                      color: AppTheme.neonGreen,
                      active: _v.status == 'pendiente',
                      onTap: () => _cambiarEstatus('pendiente'))),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataField extends StatelessWidget {
  final String label, value;
  const _DataField(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontFamily: 'ShareTechMono',
        fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1.5)),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(fontFamily: 'ShareTechMono',
        fontSize: 12, color: AppTheme.textSecondary)),
  ]);
}

class _EstatusBtn extends StatelessWidget {
  final String label; final Color color;
  final bool active; final VoidCallback onTap;
  const _EstatusBtn({required this.label, required this.color,
      required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: active ? null : onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.12) : Colors.transparent,
        border: Border.all(color: active ? color : AppTheme.borderIdle),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'ShareTechMono',
          fontSize: 9, letterSpacing: 1.5,
          color: active ? color : AppTheme.textMuted)),
    ),
  );
}
