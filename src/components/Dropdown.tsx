"use client";

import { AnimatePresence, motion } from "framer-motion";
import { Check, ChevronDown } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { cn } from "@/utils/cn";

export interface DropdownOption {
  id: string;
  label: string;
}

interface DropdownProps {
  value: string;
  options: DropdownOption[];
  onChange: (v: string) => void;
  icon?: LucideIcon;
  align?: "left" | "right";
  size?: "sm" | "md";
  active?: boolean;
  className?: string;
}

export function Dropdown({
  value,
  options,
  onChange,
  icon: Icon,
  align = "right",
  size = "md",
  active = false,
  className,
}: DropdownProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const current = options.find((o) => o.id === value);

  useEffect(() => {
    if (!open) return;
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, [open]);

  return (
    <div className={cn("relative", className)} ref={ref}>
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className={cn(
          "flex w-full items-center gap-1.5 rounded-full border px-3.5 text-xs font-medium transition sm:text-sm",
          size === "sm" ? "h-[38px]" : "h-[42px]",
          open || active
            ? "border-clay-400 bg-clay-50 text-clay-700 font-semibold"
            : "border-sand-200 bg-white text-ink hover:border-sand-300"
        )}
      >
        {Icon && <Icon className="h-4 w-4 shrink-0" strokeWidth={1.8} />}
        <span className="truncate">{current?.label ?? "Chọn"}</span>
        <ChevronDown
          className={cn("h-4 w-4 shrink-0 transition-transform", open && "rotate-180")}
          strokeWidth={1.8}
        />
      </button>

      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            transition={{ duration: 0.16 }}
            className={cn(
              "absolute top-[calc(100%+8px)] z-[950] min-w-[12rem] rounded-2xl border border-sand-200 bg-white p-1.5 shadow-xl shadow-ink/10",
              align === "right" ? "right-0" : "left-0"
            )}
          >
            {options.map((o) => (
              <button
                key={o.id}
                type="button"
                onClick={() => {
                  onChange(o.id);
                  setOpen(false);
                }}
                className={cn(
                  "flex w-full items-center justify-between gap-3 rounded-xl px-3 py-2 text-left text-sm transition",
                  o.id === value
                    ? "bg-clay-50 font-semibold text-clay-700"
                    : "text-ink hover:bg-sand-50"
                )}
              >
                <span>{o.label}</span>
                {o.id === value && <Check className="h-4 w-4 text-clay-500" strokeWidth={2.4} />}
              </button>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
