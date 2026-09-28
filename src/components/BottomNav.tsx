"use client";

import { AnimatePresence, motion } from "framer-motion";
import { Heart, House, LayoutGrid, ShoppingBag, Truck } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { IconToast } from "@/context/ToastContext";
import { paths } from "@/lib/paths";
import { cn } from "@/utils/cn";

interface BottomNavProps {
  onShop: () => void;
  onWishlist: () => void;
  onCart: () => void;
  onOrderLookup: () => void;
  cartCount: number;
  wishCount: number;
  hidden: boolean;
}

export function BottomNav({
  onShop,
  onWishlist,
  onCart,
  onOrderLookup,
  cartCount,
  wishCount,
  hidden,
}: BottomNavProps) {
  const navigate = useNavigate();

  const items = [
    { key: "home", icon: House, label: "Trang chủ", onClick: () => navigate(paths.home), badge: 0 },
    { key: "shop", icon: LayoutGrid, label: "Danh mục", onClick: onShop, badge: 0 },
    { key: "track", icon: Truck, label: "Tra cứu", onClick: onOrderLookup, badge: 0 },
    { key: "wish", icon: Heart, label: "Yêu thích", onClick: onWishlist, badge: wishCount },
    { key: "cart", icon: ShoppingBag, label: "Giỏ hàng", onClick: onCart, badge: cartCount },
  ];

  return (
    <AnimatePresence>
      {!hidden && (
        <motion.nav
          initial={{ y: 100, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: 100, opacity: 0 }}
          transition={{ type: "spring", stiffness: 360, damping: 32 }}
          className="pointer-events-none fixed inset-x-0 bottom-0 z-[1200] flex justify-center px-4 pb-[calc(env(safe-area-inset-bottom)+0.6rem)] lg:hidden"
        >
          <div className="pointer-events-auto flex items-center gap-1 rounded-full border border-sand-200 bg-sand-50/95 p-1.5 shadow-2xl shadow-ink/20 backdrop-blur-xl">
            {items.map((it) => {
              const Icon = it.icon;
              return (
                <button
                  key={it.key}
                  onClick={it.onClick}
                  aria-label={it.label}
                  className={cn(
                    "relative flex flex-col items-center gap-0.5 rounded-full px-3 py-1.5 transition active:scale-95 sm:px-4",
                    it.key === "cart" && it.badge > 0
                      ? "bg-clay-500 text-white"
                      : "text-ink hover:bg-sand-200/50"
                  )}
                >
                  <Icon className="h-5 w-5" strokeWidth={1.8} />
                  <span className="text-[9px] font-bold uppercase tracking-wider">
                    {it.label}
                  </span>
                  {it.badge > 0 && it.key !== "cart" && (
                    <span className="absolute right-1.5 top-1 flex h-4 min-w-[16px] items-center justify-center rounded-full bg-clay-500 px-1 text-[9px] font-bold text-white ring-1 ring-sand-50">
                      {it.badge}
                    </span>
                  )}
                  {it.key === "wish" && <IconToast anchor="wishlist" side="up" />}
                  {it.key === "cart" && <IconToast anchor="cart" side="up" />}
                </button>
              );
            })}
          </div>
        </motion.nav>
      )}
    </AnimatePresence>
  );
}
