import 'package:flutter/material.dart';
import 'package:practica_bd/models/detalle_venta.dart';
import 'package:practica_bd/utils/theme_app.dart';
import '../listeners/value_listener.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: const Text('> CARRITO DE ORDEN'),
        actions: [
          GestureDetector(
            onTap: () {
              ValueListener.limpiarCarrito();
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppTheme.neonRed.withOpacity(0.08),
                border: Border.all(color: AppTheme.neonRed.withOpacity(0.5)),
              ),
              child: const Row(children: [
                Icon(Icons.delete_sweep_outlined,
                    size: 13, color: AppTheme.neonRed),
                SizedBox(width: 5),
                Text('VACIAR',
                    style: TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize: 10,
                        color: AppTheme.neonRed,
                        letterSpacing: 1.5)),
              ]),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.borderIdle),
        ),
      ),
      body: ValueListenableBuilder<List<CarritoItem>>(
        valueListenable: ValueListener.carrito,
        builder: (_, carrito, __) {
          if (carrito.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 52,
                      color: AppTheme.textMuted.withOpacity(0.3)),
                  const SizedBox(height: 14),
                  const Text(
                    '// CARRITO VACÍO',
                    style: TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        letterSpacing: 2),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // ── Header de conteo ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                  child: Row(children: [
                    const Text(
                      '> ÍTEMS EN ORDEN:',
                      style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 10,
                          color: AppTheme.textMuted,
                          letterSpacing: 2),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.1),
                        border:
                            Border.all(color: AppTheme.neonGreen, width: 1),
                      ),
                      child: Text(
                        '${ValueListener.totalItemsCarrito}',
                        style: const TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 11,
                            color: AppTheme.neonGreen),
                      ),
                    ),
                  ]),
                ),
              ),

              // ── Lista de ítems ────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final item = carrito[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: const BoxDecoration(
                          color: AppTheme.bgCard,
                          border: Border(
                            left: BorderSide(
                                color: AppTheme.neonGreen, width: 3),
                            top: BorderSide(color: AppTheme.borderIdle),
                            right: BorderSide(color: AppTheme.borderIdle),
                            bottom: BorderSide(color: AppTheme.borderIdle),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(children: [
                            // Cantidad badge
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppTheme.neonGreen.withOpacity(0.1),
                                border: Border.all(
                                    color: AppTheme.neonGreen, width: 1),
                              ),
                              child: Text(
                                '${item.cantidad}',
                                style: const TextStyle(
                                    fontFamily: 'ShareTechMono',
                                    fontSize: 13,
                                    color: AppTheme.neonGreen),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Nombre + detalle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nombreProducto.toUpperCase(),
                                    style: const TextStyle(
                                        fontFamily: 'ShareTechMono',
                                        fontSize: 12,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.cantidad} ${item.unidad}  ×  '
                                    '\$${item.precioUnitario.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontFamily: 'ShareTechMono',
                                        fontSize: 10,
                                        color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),

                            // Subtotal
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${item.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'ShareTechMono',
                                    fontSize: 15,
                                    color: AppTheme.neonGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => ValueListener
                                      .quitarDelCarrito(item.idProducto),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppTheme.neonRed
                                              .withOpacity(0.4)),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 11,
                                      color: AppTheme.neonRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      );
                    },
                    childCount: carrito.length,
                  ),
                ),
              ),

              // ── Total ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: [
                    Container(height: 1, color: AppTheme.borderIdle),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL ESTIMADO',
                          style: TextStyle(
                              fontFamily: 'ShareTechMono',
                              fontSize: 10,
                              color: AppTheme.textMuted,
                              letterSpacing: 2),
                        ),
                        Text(
                          '\$${ValueListener.totalCarrito.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 28,
                            color: AppTheme.neonGreen,
                            shadows: [
                              Shadow(
                                  color: AppTheme.neonGreen,
                                  blurRadius: 10)
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(height: 1, color: AppTheme.neonGreen,),
                  ]),
                ),
              ),

              // ── Nota informativa ─────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '// Regresa a Nueva Orden para registrar la venta',
                    style: TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize: 10,
                        color: AppTheme.textMuted,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          );
        },
      ),
    );
  }
}
