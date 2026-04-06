import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practica_bd/firebase/email_auth.dart';
import 'package:practica_bd/firebase/ventas_firestore.dart';
import 'package:practica_bd/models/venta_model.dart';
import 'package:practica_bd/screens/detalle_venta_screen.dart';
import 'package:practica_bd/utils/theme_app.dart';

class VentasListScreen extends StatefulWidget {
  const VentasListScreen({super.key});
  @override
  State<VentasListScreen> createState() => _VentasListScreenState();
}

class _VentasListScreenState extends State<VentasListScreen> {
  final _ventasFS = VentasFirestore();
  final _auth = EmailAuth();
  String _filtro = 'todos';

  static const _filtros = ['todos', 'pendiente', 'completado', 'cancelado'];

  Stream<QuerySnapshot> get _stream {
    final uid = _auth.currentUserId ?? '';
    return _filtro == 'todos'
        ? _ventasFS.getVentas(uid)
        : _ventasFS.getVentasByEstatus(uid, _filtro);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.neonGreen));
        }
        if (snapshot.hasError) {
          return Center(child: Text('// ERROR: ${snapshot.error}',
              style: const TextStyle(color: AppTheme.neonRed,
                  fontFamily: 'ShareTechMono')));
        }

        final ventas = snapshot.data!.docs
            .map((d) => VentaDAO.fromMap(
                d.data() as Map<String, dynamic>, d.id))
            .toList();

        final pendientes  = ventas.where((v) => v.status == 'pendiente').length;
        final completados = ventas.where((v) => v.status == 'completado').length;
        final cancelados  = ventas.where((v) => v.status == 'cancelado').length;

        return CustomScrollView(
          slivers: [

            // ── Métricas ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(children: [
                  Expanded(child: InfoCard(titulo: 'Activos',
                      valor: '$pendientes', icono: Icons.radio_button_checked,
                      color: AppTheme.neonGreen)),
                  const SizedBox(width: 8),
                  Expanded(child: InfoCard(titulo: 'Completados',
                      valor: '$completados', icono: Icons.check_circle_outline,
                      color: AppTheme.neonBlue)),
                  const SizedBox(width: 8),
                  Expanded(child: InfoCard(titulo: 'Cancelados',
                      valor: '$cancelados', icono: Icons.block,
                      color: AppTheme.neonRed)),
                ]),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
                child: Row(children: [
                  const Text('> FILTRO:',
                      style: TextStyle(fontFamily: 'ShareTechMono',
                          fontSize: 10, color: AppTheme.textMuted,
                          letterSpacing: 2)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filtros.map((f) {
                          final sel = _filtro == f;
                          final col = AppTheme.colorEstatus(f);
                          return GestureDetector(
                            onTap: () => setState(() => _filtro = f),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: sel
                                    ? col.withOpacity(0.12)
                                    : Colors.transparent,
                                border: Border.all(
                                    color: sel ? col : AppTheme.borderIdle),
                              ),
                              child: Text(f.toUpperCase(),
                                  style: TextStyle(
                                      fontFamily: 'ShareTechMono',
                                      fontSize: 9,
                                      letterSpacing: 1.5,
                                      color: sel ? col : AppTheme.textMuted)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            if (ventas.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 48,
                          color: AppTheme.textMuted.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      const Text('// SIN REGISTROS',
                          style: TextStyle(fontFamily: 'ShareTechMono',
                              fontSize: 12, color: AppTheme.textMuted,
                              letterSpacing: 2)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _OrdenCard(
                        venta: ventas[i],
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetalleVentaScreen(
                                    venta: ventas[i])))),
                    childCount: ventas.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
class InfoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const InfoCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          left: BorderSide(color: color, width: 3),
          top: BorderSide(color: AppTheme.borderIdle, width: 1),
          right: BorderSide(color: AppTheme.borderIdle, width: 1),
          bottom: BorderSide(color: AppTheme.borderIdle, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(height: 8),
          Text(valor,
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 26,
                color: color,
                shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 8)],
              )),
          const SizedBox(height: 2),
          Text(titulo.toUpperCase(),
              style: const TextStyle(
                  fontFamily: 'ShareTechMono',
                  fontSize: 9,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

class StatusBadge extends StatefulWidget {
  final String estatus;
  final bool compact;
  const StatusBadge({super.key, required this.estatus, this.compact = false});
  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.estatus == 'pendiente') {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.colorEstatus(widget.estatus);
    final label = widget.estatus.toUpperCase();

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 8 : 10,
            vertical: widget.compact ? 3 : 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(
              color: color.withOpacity(
                  widget.estatus == 'pendiente' ? _pulse.value : 0.7),
              width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          // Dot LED
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(
                  widget.estatus == 'pendiente' ? _pulse.value : 0.9),
              boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 4)],
            ),
          ),
          if (!widget.compact) ...[
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontFamily: 'ShareTechMono',
                    fontSize: 10,
                    color: color,
                    letterSpacing: 1.5)),
          ],
        ]),
      ),
    );
  }
}


class _OrdenCard extends StatelessWidget {
  final VentaDAO venta;
  final VoidCallback onTap;
  const _OrdenCard({required this.venta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.colorEstatus(venta.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(
            left: BorderSide(color: color, width: 3),
            top: const BorderSide(color: AppTheme.borderIdle),
            right: const BorderSide(color: AppTheme.borderIdle),
            bottom: const BorderSide(color: AppTheme.borderIdle),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Fila superior: cliente + badge
              Row(children: [
                Expanded(
                  child: Text(
                    venta.nombreCliente?.toUpperCase() ?? '—',
                    style: const TextStyle(
                      fontFamily: 'ShareTechMono',
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(estatus: venta.status ?? 'pendiente'),
              ]),

              const SizedBox(height: 10),

              // Fila inferior: metadata
              Row(children: [
                _Meta(Icons.router_outlined, venta.tipo?.toUpperCase() ?? ''),
                const SizedBox(width: 16),
                _Meta(Icons.calendar_today_outlined, venta.fechaEntrega ?? '—'),
                const Spacer(),
                Text(
                  '\$${venta.total?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontFamily: 'ShareTechMono',
                    fontSize: 15,
                    color: color,
                    shadows: [Shadow(color: color.withOpacity(0.4), blurRadius: 6)],
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppTheme.textMuted),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(
          fontFamily: 'ShareTechMono', fontSize: 10,
          color: AppTheme.textSecondary, letterSpacing: 0.5)),
    ],
  );
}
