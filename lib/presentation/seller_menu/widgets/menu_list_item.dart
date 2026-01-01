import 'package:flutter/material.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/currency_format.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/menu.model.dart';

class MenuListItem extends StatelessWidget {
  const MenuListItem({
    super.key,
    required this.menu,
    required this.onEdit,
    required this.onDelete,
    required this.isDeleting,
  });

  final MenuModel menu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MasterColor.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: MasterColor.dark_10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: menu.imageUrl != null && menu.imageUrl!.isNotEmpty
                  ? Image.network(
                      menu.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.restaurant_menu,
                          color: MasterColor.dark_30,
                        );
                      },
                    )
                  : const Icon(
                      Icons.restaurant_menu,
                      color: MasterColor.dark_30,
                    ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${formatIdr(menu.price)}',
                  style: const TextStyle(
                    color: MasterColor.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  menu.category?.name ?? '-',
                  style: const TextStyle(
                    color: MasterColor.dark_40,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  menu.stock == null
                      ? 'Stok: tidak terbatas'
                      : 'Stok: ${menu.stock}',
                  style: const TextStyle(
                    color: MasterColor.dark_40,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: MasterColor.primary),
          ),
          IconButton(
            onPressed: isDeleting ? null : onDelete,
            icon: isDeleting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MasterColor.danger,
                    ),
                  )
                : const Icon(
                    Icons.delete,
                    color: MasterColor.danger,
                  ),
          ),
        ],
      ),
    );
  }
}
