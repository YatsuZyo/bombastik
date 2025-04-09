import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/order.dart';
import 'package:bombastik/presentation/providers/commerce-providers/orders/orders_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/presentation/providers/commerce-providers/products/products_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<OrderStatus> _tabs = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.delivering,
    OrderStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        ref.read(currentCommerceIdProvider.notifier).state = user.uid;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendientes';
      case OrderStatus.accepted:
        return 'Aceptados';
      case OrderStatus.preparing:
        return 'En Preparación';
      case OrderStatus.ready:
        return 'Listos';
      case OrderStatus.delivering:
        return 'En Entrega';
      case OrderStatus.completed:
        return 'Completados';
      case OrderStatus.cancelled:
        return 'Cancelados';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((status) {
            final count = ref.watch(orderCountProvider(status));
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getStatusText(status)),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((status) => _OrderList(status: status)).toList(),
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  final OrderStatus status;

  const _OrderList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orders = ref.watch(filteredOrdersProvider(status));

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay pedidos ${_getStatusText(status).toLowerCase()}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order);
      },
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendientes';
      case OrderStatus.accepted:
        return 'Aceptados';
      case OrderStatus.preparing:
        return 'En Preparación';
      case OrderStatus.ready:
        return 'Listos';
      case OrderStatus.delivering:
        return 'En Entrega';
      case OrderStatus.completed:
        return 'Completados';
      case OrderStatus.cancelled:
        return 'Cancelados';
    }
  }
}

class _OrderCard extends ConsumerWidget {
  final CommerceOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado con información del cliente
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.clientName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (order.isDelivery && order.deliveryAddress != null)
                        Text(
                          order.deliveryAddress!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total: ${order.total.toStringAsFixed(2)} Bs.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${order.items.length} productos',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Lista de productos
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return ListTile(
                leading: item.imageUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(item.imageUrl!),
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.shopping_bag_outlined),
                      ),
                title: Text(item.name),
                subtitle: item.notes != null ? Text(item.notes!) : null,
                trailing: Text(
                  '${item.quantity}x ${item.price.toStringAsFixed(2)} Bs.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == OrderStatus.pending) ...[
                  OutlinedButton(
                    onPressed: () => _showCancelDialog(context, ref, order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: const Text('Rechazar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _updateOrderStatus(ref, order.id, OrderStatus.accepted),
                    child: const Text('Aceptar'),
                  ),
                ] else if (order.status != OrderStatus.completed && 
                          order.status != OrderStatus.cancelled) ...[
                  FilledButton(
                    onPressed: () => _showNextStatusDialog(context, ref, order),
                    child: const Text('Actualizar Estado'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(WidgetRef ref, String orderId, OrderStatus newStatus) {
    ref.read(orderRepositoryProvider).updateOrderStatus(orderId, newStatus);
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, CommerceOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Pedido'),
        content: Text('¿Estás seguro de rechazar el pedido de ${order.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _updateOrderStatus(ref, order.id, OrderStatus.cancelled);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  void _showNextStatusDialog(BuildContext context, WidgetRef ref, CommerceOrder order) {
    OrderStatus nextStatus;
    String actionText;

    switch (order.status) {
      case OrderStatus.accepted:
        nextStatus = OrderStatus.preparing;
        actionText = 'Comenzar Preparación';
        break;
      case OrderStatus.preparing:
        nextStatus = OrderStatus.ready;
        actionText = 'Marcar como Listo';
        break;
      case OrderStatus.ready:
        nextStatus = order.isDelivery ? OrderStatus.delivering : OrderStatus.completed;
        actionText = order.isDelivery ? 'Iniciar Entrega' : 'Marcar como Entregado';
        break;
      case OrderStatus.delivering:
        nextStatus = OrderStatus.completed;
        actionText = 'Marcar como Entregado';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Estado'),
        content: Text('¿Deseas $actionText?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              _updateOrderStatus(ref, order.id, nextStatus);
              Navigator.pop(context);
            },
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
} 