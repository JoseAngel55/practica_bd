import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:practica_bd/firebase/email_auth.dart';
import 'package:practica_bd/listeners/value_listener.dart';
import 'package:practica_bd/models/detalle_venta.dart';
import 'package:practica_bd/screens/calendario_screen.dart';
import 'package:practica_bd/screens/carrito_screen.dart';
import 'package:practica_bd/screens/categorias_screen.dart';
import 'package:practica_bd/screens/nueva_venta_screen.dart';
import 'package:practica_bd/screens/productos_screen.dart';
import 'package:practica_bd/screens/ventas_list_screen.dart';
import 'package:practica_bd/utils/theme_app.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final EmailAuth _auth = EmailAuth();

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.format_list_bulleted, 'ÓRDENES'),
    _NavItem(Icons.grid_view_rounded, 'AGENDA'),
    _NavItem(Icons.category_outlined, 'CATEGORÍAS'),
    _NavItem(Icons.router_outlined, 'EQUIPOS'),
  ];

  final List<Widget> _screens = const [
    VentasListScreen(),
    CalendarioScreen(),
    CategoriasScreen(),
    ProductosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(children: [
          Container(width: 3, height: 20, color: AppTheme.neonGreen),
          const SizedBox(width: 10),
          const Text('NETCORE  //  PANEL DE CONTROL'),
        ]),
        actions: [
          // Badge carrito
          ValueListenableBuilder<List<CarritoItem>>(
            valueListenable: ValueListener.carrito,
            builder: (_, carrito, __) {
              final count = ValueListener.totalItemsCarrito;
              return badges.Badge(
                  showBadge: count > 0,
                  position: badges.BadgePosition.topEnd(top: 6, end: 6),
                  badgeStyle: badges.BadgeStyle(
                      badgeColor: AppTheme.neonAmber,
                      padding: const EdgeInsets.all(4)),
                  badgeContent: Text('$count',
                      style: const TextStyle(
                          color: AppTheme.bgDeep,
                          fontSize: 9,
                          fontFamily: 'ShareTechMono',
                          fontWeight: FontWeight.bold)),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                    color: AppTheme.textSecondary,
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CarritoScreen())),
                  ),
                );
            },
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new, size: 18),
            color: AppTheme.neonRed.withOpacity(0.7),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await _auth.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderIdle),
        ),
      ),

      body: _screens[_currentIndex],

      // ── Barra de navegación tipo terminal ──────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(top: BorderSide(color: AppTheme.borderIdle, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final selected = _currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Indicador superior
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 2,
                          width: selected ? 28 : 0,
                          color: AppTheme.neonGreen,
                          margin: const EdgeInsets.only(bottom: 6),
                        ),
                        Icon(item.icon,
                            size: 18,
                            color: selected
                                ? AppTheme.neonGreen
                                : AppTheme.textMuted),
                        const SizedBox(height: 4),
                        Text(item.label,
                            style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 8,
                              letterSpacing: 1,
                              color: selected
                                  ? AppTheme.neonGreen
                                  : AppTheme.textMuted,
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),

      // ── FAB estilo terminal ────────────────────────────────────
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NuevaVentaScreen())),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.1),
                  border: Border.all(color: AppTheme.neonGreen, width: 1.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.add, color: AppTheme.neonGreen, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'NUEVA ORDEN',
                    style: TextStyle(
                      fontFamily: 'ShareTechMono',
                      fontSize: 11,
                      letterSpacing: 2,
                      color: AppTheme.neonGreen,
                      shadows: [
                        Shadow(
                            color: AppTheme.neonGreen.withOpacity(0.5),
                            blurRadius: 6)
                      ],
                    ),
                  ),
                ]),
              ),
            )
          : null,
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
