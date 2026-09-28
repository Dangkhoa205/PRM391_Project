"use client";

import { motion } from "framer-motion";
import { Check, LayoutGrid, PersonStanding, Shirt, Sparkles, X } from "lucide-react";
import { useEffect } from "react";
import { cn } from "@/utils/cn";

const ITEMS = [
  { id: "all", label: "Tất cả sản phẩm", desc: "Toàn bộ 18 thiết kế boutique hè 2026", icon: LayoutGrid },
  { id: "sunset", label: "La Boutique VN Sunset", desc: "3 bộ set biểu tượng hè 2026", icon: Sparkles },
  { id: "ao", label: "Áo, Đầm & Cổ Yếm", desc: "Áo xô 2 dây, cổ yếm tơ xốp, sơ mi đũi", icon: Shirt },
  { id: "quan", label: "Quần & Chân váy", desc: "Chân váy lụa lửng, short linen, váy dệt kim", icon: PersonStanding },
];

interface CategorySheetProps {
  onClose: () => void;
  onSelect: (id: string) => void;
  current: string;
}

export function CategorySheet({ onClose, onSelect, current }: CategorySheetProps) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);

  return (
    <motion.div
      className="fixed inset-0 z-[3000]"
      initial="hidden"
      animate="show"
      exit="exit"
    >
      <motion.div
        variants={{ hidden: { opacity: 0 }, show: { opacity: 1 }, exit: { opacity: 0 } }}
        transition={{ duration: 0.25 }}
        onClick={onClose}
        className="absolute inset-0 bg-ink/55 backdrop-blur-sm"
      />
      <motion.div
        variants={{ hidden: { y: "100%" }, show: { y: 0 }, exit: { y: "100%" } }}
        transition={{ type: "spring", stiffness: 320, damping: 32 }}
        onClick={(e) => e.stopPropagation()}
        className="soft-scroll absolute inset-x-0 bottom-0 max-h-[85vh] overflow-y-auto rounded-t-3xl bg-sand-50 p-6 shadow-2xl"
      >
        <div className="mx-auto mb-5 h-1.5 w-12 rounded-full bg-sand-300" />

        <div className="flex items-center justify-between pb-3 border-b border-sand-200">
          <h3 className="font-display text-xl font-bold text-ink">Danh mục sản phẩm</h3>
          <button
            onClick={onClose}
            aria-label="Đóng"
            className="flex h-8 w-8 items-center justify-center rounded-full text-mute hover:bg-sand-200"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="mt-4 space-y-2">
          {ITEMS.map((item) => {
            const Icon = item.icon;
            const active = current === item.id;
            return (
              <button
                key={item.id}
                onClick={() => onSelect(item.id)}
                className={cn(
                  "flex w-full items-center gap-3.5 rounded-2xl p-4 text-left transition active:scale-98",
                  active
                    ? "bg-clay-500 text-white shadow-md"
                    : "bg-white text-ink ring-1 ring-sand-200 hover:bg-sand-100"
                )}
              >
                <div
                  className={cn(
                    "flex h-11 w-11 shrink-0 items-center justify-center rounded-xl",
                    active ? "bg-white/20 text-white" : "bg-clay-50 text-clay-600"
                  )}
                >
                  <Icon className="h-5 w-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-bold text-sm leading-tight">{item.label}</p>
                  <p
                    className={cn(
                      "text-xs mt-0.5",
                      active ? "text-white/80" : "text-mute"
                    )}
                  >
                    {item.desc}
                  </p>
                </div>
                {active && <Check className="h-5 w-5 text-white" />}
              </button>
            );
          })}
        </div>
      </motion.div>
    </motion.div>
  );
}
