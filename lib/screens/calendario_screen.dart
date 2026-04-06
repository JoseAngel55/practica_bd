import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practica_bd/firebase/email_auth.dart';
import 'package:practica_bd/firebase/ventas_firestore.dart';
import 'package:practica_bd/models/venta_model.dart';
import 'package:practica_bd/screens/ventas_list_screen.dart';
import 'package:practica_bd/utils/theme_app.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});
  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  final _ventasFS = VentasFirestore();
  final _auth = EmailAuth();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<VentaDAO>> _eventos = {};

  @override
  void initState() {
    super.initState();
    _ventasFS.getVentas(_auth.currentUserId ?? '').listen((snap) {
      final Map<DateTime, List<VentaDAO>> mapa = {};
      for (final doc in snap.docs) {
        final v = VentaDAO.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        if (v.fechaEntrega != null) {
          final f = DateTime.tryParse(v.fechaEntrega!);
          if (f != null) {
            final k = DateTime(f.year, f.month, f.day);
            mapa.putIfAbsent(k, () => []).add(v);
          }
        }
      }
      if (mounted) setState(() => _eventos = mapa);
    });
  }

  List<VentaDAO> _getForDay(DateTime day) =>
      _eventos[DateTime(day.year, day.month, day.day)] ?? [];

  void _showModal(DateTime dia, List<VentaDAO> ventas) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgCard,
            border: Border(
                top: BorderSide(color: AppTheme.neonGreen, width: 2)),
          ),
          child: Column(children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(children: [
                Container(width: 3, height: 20,
                    color: AppTheme.neonGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                      DateFormat("dd.MM.yyyy").format(dia),
                      style: const TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 18, color: AppTheme.neonGreen,
                          letterSpacing: 2),
                    ),
                    Text(
                      '${ventas.length} ORDEN(ES) PROGRAMADA(S)',
                      style: const TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 9, color: AppTheme.textMuted,
                          letterSpacing: 2),
                    ),
                  ]),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: AppTheme.textMuted,
                      size: 18),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Container(height: 1, color: AppTheme.borderIdle),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: ventas.length,
                itemBuilder: (_, i) {
                  final v = ventas[i];
                  final col = AppTheme.colorEstatus(v.status);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      border: Border(left: BorderSide(color: col, width: 3),
                          top: const BorderSide(color: AppTheme.borderIdle),
                          right: const BorderSide(color: AppTheme.borderIdle),
                          bottom: const BorderSide(color: AppTheme.borderIdle)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Expanded(
                            child: Text(
                              v.nombreCliente?.toUpperCase() ?? '',
                              style: const TextStyle(
                                  fontFamily: 'ShareTechMono',
                                  fontSize: 13, color: AppTheme.textPrimary),
                            ),
                          ),
                          StatusBadge(estatus: v.status ?? 'pendiente'),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          _Tag(Icons.router_outlined,
                              v.tipo?.toUpperCase() ?? ''),
                          const SizedBox(width: 12),
                          _Tag(Icons.phone_outlined,
                              v.telefonoCliente ?? '—'),
                          const Spacer(),
                          Text('\$${v.total?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                  fontFamily: 'ShareTechMono',
                                  fontSize: 14, color: col)),
                        ]),
                        if (v.notas?.isNotEmpty == true) ...[
                          const SizedBox(height: 6),
                          Text('// ${v.notas}',
                              style: const TextStyle(
                                  fontFamily: 'ShareTechMono',
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              border: Border.all(color: AppTheme.borderIdle),
            ),
            child: TableCalendar<VentaDAO>(
              locale: 'es_MX',
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
              eventLoader: _getForDay,
              onDaySelected: (sel, foc) {
                setState(() { _selectedDay = sel; _focusedDay = foc; });
                final ev = _getForDay(sel);
                if (ev.isNotEmpty) _showModal(sel, ev);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.2),
                    border: Border.all(color: AppTheme.neonGreen)),
                todayTextStyle: const TextStyle(
                    color: AppTheme.neonGreen, fontFamily: 'ShareTechMono'),
                selectedDecoration: const BoxDecoration(
                    color: AppTheme.neonGreen),
                selectedTextStyle: const TextStyle(
                    color: AppTheme.bgDeep, fontFamily: 'ShareTechMono'),
                defaultTextStyle: const TextStyle(
                    color: AppTheme.textSecondary, fontFamily: 'ShareTechMono'),
                weekendTextStyle: const TextStyle(
                    color: AppTheme.textMuted, fontFamily: 'ShareTechMono'),
                outsideTextStyle: const TextStyle(
                    color: AppTheme.textMuted, fontFamily: 'ShareTechMono'),
                markersMaxCount: 0,
                rowDecoration: const BoxDecoration(color: Colors.transparent),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                    fontFamily: 'ShareTechMono',
                    fontSize: 13, color: AppTheme.textPrimary,
                    letterSpacing: 2),
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: AppTheme.textSecondary),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                decoration: BoxDecoration(color: AppTheme.bgSurface),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                    fontFamily: 'ShareTechMono', fontSize: 10,
                    color: AppTheme.textMuted, letterSpacing: 1),
                weekendStyle: TextStyle(
                    fontFamily: 'ShareTechMono', fontSize: 10,
                    color: AppTheme.textMuted, letterSpacing: 1),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (_, day, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.take(4).map((v) {
                        final col = AppTheme.colorEstatus(v.status);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, color: col,
                            boxShadow: [BoxShadow(color: col.withOpacity(0.7),
                                blurRadius: 3)],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Leyenda
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LedLeyenda(AppTheme.neonGreen, 'ACTIVO'),
                const SizedBox(width: 20),
                _LedLeyenda(AppTheme.neonBlue, 'COMPLETADO'),
                const SizedBox(width: 20),
                _LedLeyenda(AppTheme.neonRed, 'CANCELADO'),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon; final String text;
  const _Tag(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppTheme.textMuted),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontFamily: 'ShareTechMono',
          fontSize: 10, color: AppTheme.textSecondary)),
    ]);
}

class _LedLeyenda extends StatelessWidget {
  final Color color; final String label;
  const _LedLeyenda(this.color, this.label);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 7, height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color,
              boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 4)])),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontFamily: 'ShareTechMono',
          fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1.5)),
    ]);
}
