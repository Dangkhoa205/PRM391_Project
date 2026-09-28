"use client";

import { AnimatePresence, motion } from "framer-motion";
import { Heart, ShoppingBag, X } from "lucide-react";
import { useState } from "react";
import { SIZES } from "@/data/products";
import type { Product } from "@/data/products";
import { useCart } from "@/context/CartContext";
import { useToast } from "@/context/ToastContext";
import { formatMoney } from "@/lib/format";
import { cn } from "@/utils/cn";

const TYPE_LABEL: Record<string, string> = {
  ao: "Áo & Đầm",
  quan: "Quần & Váy",
};

interface ProductCardProps {
  product: Product;
  onOpen: (p: Product) => void;
  index?: number;
}

export function ProductCard({ product, onOpen, index = 0 }: ProductCardProps) {
  const { isWished, toggleWishlist, addItem } = useCart();
  const { showToast } = useToast();
  const [quick, setQuick] = useState(false);
  const wished = isWished(product.id);

  const quickAdd = (size: string) => {
    addItem(product, size, 1);
    showToast("Đã thêm vào giỏ", "success", "cart");
    setQuick(false);
  };

  return (
    <motion.article
      initial={{ opacity: 0, y: 16 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-30px" }}
      transition={{
        duration: 0.4,
        delay: Math.min(index * 0.03, 0.2),
        ease: [0.22, 1, 0.36, 1],
      }}
      className="group flex flex-col h-full"
    >
      <div className="relative aspect-[3/4] w-full overflow-hidden rounded-xl sm:rounded-2xl bg-sand-200 ring-1 ring-sand-200/80 shadow-xs">
        <button
          onClick={() => onOpen(product)}
          className="relative block h-full w-full text-left"
          aria-label={`Xem chi tiết ${product.name}`}
        >
          <img
            src={product.img}
            alt={product.name}
            loading="lazy"
            className="h-full w-full object-cover object-center transition-transform duration-[600ms] ease-out group-hover:scale-[1.04]"
          />
          {!quick && (
            <div className="pointer-events-none absolute inset-0 hidden items-center justify-center bg-gradient-to-t from-ink/60 via-ink/10 to-transparent opacity-0 transition-opacity duration-300 group-hover:opacity-100 md:flex">
              <span className="rounded-full bg-white/95 px-4 py-1.5 text-[10px] font-bold uppercase tracking-wider text-ink shadow-md backdrop-blur-sm">
                Xem chi tiết
              </span>
            </div>
          )}
        </button>

        {product.tag && (
          <span
            className={cn(
              "absolute left-2 top-2 sm:left-3 sm:top-3 z-10 rounded-full px-2 py-0.5 sm:px-2.5 sm:py-1 text-[9px] sm:text-[10px] font-bold uppercase tracking-wider text-white shadow-sm",
              product.tag === "Signature"
                ? "bg-amber-600 ring-1 ring-amber-400/50"
                : product.tag === "Hot"
                ? "bg-rose-600"
                : "bg-clay-500"
            )}
          >
            {product.tag}
          </span>
        )}

        {/* Yêu thích */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            toggleWishlist(product.id);
            if (!wished) {
              showToast("Đã thêm yêu thích", "success", "wishlist");
            }
          }}
          aria-label={wished ? "Bỏ yêu thích" : "Thêm yêu thích"}
          className={cn(
            "absolute right-2 top-2 sm:right-3 sm:top-3 z-10 flex h-7 w-7 sm:h-8 sm:w-8 items-center justify-center rounded-full shadow-sm backdrop-blur transition active:scale-90",
            wished ? "bg-clay-500 text-white" : "bg-white/85 text-ink hover:bg-white"
          )}
        >
          <Heart
            className="h-3.5 w-3.5 sm:h-4 sm:w-4"
            fill={wished ? "currentColor" : "none"}
            strokeWidth={1.8}
          />
        </button>

        {/* Làm mờ nền khi bật quick add */}
        <AnimatePresence>
          {quick && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setQuick(false)}
              className="absolute inset-0 z-[5] bg-ink/40 backdrop-blur-[2px]"
            />
          )}
        </AnimatePresence>

        {/* Thêm nhanh vào giỏ */}
        <div
          className={cn(
            "absolute inset-x-0 bottom-0 z-10 flex flex-col items-center gap-1.5 bg-gradient-to-t from-ink/80 via-ink/40 to-transparent p-2 sm:p-2.5 transition-opacity duration-300",
            quick ? "opacity-100" : "opacity-100 md:opacity-0 md:group-hover:opacity-100"
          )}
        >
          <AnimatePresence>
            {quick && (
              <motion.div
                initial={{ opacity: 0, y: 8, scale: 0.95 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: 8, scale: 0.95 }}
                className="flex items-center gap-1 rounded-full bg-ink/95 p-1 backdrop-blur shadow-md"
              >
                {SIZES.map((s) => (
                  <button
                    key={s}
                    onClick={() => quickAdd(s)}
                    className="flex h-7 w-7 items-center justify-center rounded-full text-[11px] font-bold text-white transition hover:bg-clay-500 active:scale-95"
                  >
                    {s}
                  </button>
                ))}
              </motion.div>
            )}
          </AnimatePresence>

          <button
            onClick={() => setQuick((v) => !v)}
            aria-label="Thêm nhanh vào giỏ hàng"
            className={cn(
              "flex items-center gap-1 rounded-full px-2.5 py-1.5 text-[10px] font-bold uppercase tracking-wider shadow-sm transition active:scale-95",
              quick ? "bg-white text-ink" : "bg-white/95 text-ink hover:bg-clay-500 hover:text-white"
            )}
          >
            {quick ? (
              <>
                <X className="h-3 w-3" strokeWidth={2} /> Đóng size
              </>
            ) : (
              <>
                <ShoppingBag className="h-3 w-3" strokeWidth={1.8} /> Thêm nhanh
              </>
            )}
          </button>
        </div>
      </div>

      <div className="mt-2 sm:mt-2.5 flex flex-1 flex-col px-0.5">
        <p className="text-[9px] sm:text-[10px] font-bold uppercase tracking-[0.14em] text-mute">
          {TYPE_LABEL[product.type]}
        </p>
        <button onClick={() => onOpen(product)} className="mt-0.5 block w-full text-left">
          <h3 className="line-clamp-2 font-display text-[13px] sm:text-[14px] font-bold leading-snug text-ink transition-colors group-hover:text-clay-600">
            {product.name}
          </h3>
        </button>
        <div className="mt-auto pt-1 flex items-baseline gap-1.5">
          <p className="text-[13px] sm:text-[15px] font-bold tabular-nums text-clay-600">
            {formatMoney(product.price)}
          </p>
          {product.originalPrice && product.originalPrice > product.price && (
            <p className="text-[10px] sm:text-xs text-mute/70 line-through tabular-nums">
              {formatMoney(product.originalPrice)}
            </p>
          )}
        </div>
      </div>
    </motion.article>
  );
}
