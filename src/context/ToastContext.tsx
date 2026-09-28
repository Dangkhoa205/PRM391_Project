"use client";

import { AnimatePresence, motion } from "framer-motion";
import { createContext, useCallback, useContext, useLayoutEffect, useRef, useState } from "react";
import type { ReactNode } from "react";
import { createPortal } from "react-dom";
import { Check, Info } from "lucide-react";

export type ToastAnchor = "global" | "wishlist" | "cart";

interface ToastItem {
  id: number;
  msg: string;
  type?: "success" | "info";
  anchor: ToastAnchor;
}

interface ToastContextValue {
  showToast: (msg: string, type?: "success" | "info", anchor?: ToastAnchor) => void;
  toasts: ToastItem[];
}

const ToastContext = createContext<ToastContextValue | null>(null);

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([]);

  const showToast = useCallback(
    (msg: string, type: "success" | "info" = "success", anchor: ToastAnchor = "global") => {
      const id = Date.now() + Math.random();
      setToasts((t) => [...t.filter((x) => x.anchor !== anchor), { id, msg, type, anchor }]);
      window.setTimeout(() => {
        setToasts((prev) => prev.filter((it) => it.id !== id));
      }, 2400);
    },
    []
  );

  const globals = toasts.filter((t) => t.anchor === "global");

  return (
    <ToastContext.Provider value={{ showToast, toasts }}>
      {children}
      <div className="pointer-events-none fixed inset-x-0 top-[4.75rem] z-[5000] flex justify-center px-3 sm:top-20">
        <AnimatePresence>
          {globals.map((t) => (
            <motion.div
              key={t.id}
              initial={{ opacity: 0, y: -18, scale: 0.96 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -12, scale: 0.96 }}
              transition={{ type: "spring", stiffness: 420, damping: 28 }}
              className="flex max-w-[min(92vw,28rem)] items-center gap-2.5 rounded-2xl bg-ink px-4 py-3 text-[13px] font-semibold leading-snug text-white shadow-2xl shadow-ink/30 ring-1 ring-white/10"
            >
              <span className="flex h-5 w-5 items-center justify-center rounded-full bg-clay-500 text-white">
                {t.type === "info" ? (
                  <Info className="h-3 w-3" strokeWidth={2.5} />
                ) : (
                  <Check className="h-3 w-3" strokeWidth={2.5} />
                )}
              </span>
              <span>{t.msg}</span>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>
    </ToastContext.Provider>
  );
}

export function IconToast({
  anchor,
  side = "down",
}: {
  anchor: "wishlist" | "cart";
  side?: "down" | "up";
}) {
  const { toasts } = useToast();
  const toast = [...toasts].reverse().find((t) => t.anchor === anchor);
  const markRef = useRef<HTMLSpanElement>(null);
  const bubbleRef = useRef<HTMLDivElement>(null);
  const [box, setBox] = useState<{ top: number; left: number; width: number; height: number } | null>(null);
  const [place, setPlace] = useState<{ left: number; caret: number } | null>(null);

  useLayoutEffect(() => {
    const host = markRef.current?.parentElement;
    if (!host || !toast) {
      setBox(null);
      setPlace(null);
      return;
    }
    const measureHost = () => {
      const r = host.getBoundingClientRect();
      setBox({ top: r.top, left: r.left, width: r.width, height: r.height });
    };
    measureHost();
    window.addEventListener("resize", measureHost);
    window.addEventListener("scroll", measureHost, true);
    return () => {
      window.removeEventListener("resize", measureHost);
      window.removeEventListener("scroll", measureHost, true);
    };
  }, [toast?.id]);

  useLayoutEffect(() => {
    if (!toast || !box || !bubbleRef.current) {
      setPlace(null);
      return;
    }
    const width = bubbleRef.current.offsetWidth;
    const center = box.left + box.width / 2;
    const pad = 10;
    const left = Math.min(Math.max(center - width / 2, pad), window.innerWidth - width - pad);
    setPlace({ left, caret: center - left });
  }, [toast?.id, toast?.msg, box]);

  const bubble =
    toast && box ? (
      <motion.div
        key={toast.id}
        ref={bubbleRef}
        initial={{ opacity: 0, y: side === "down" ? -6 : 6, scale: 0.92 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        exit={{ opacity: 0, y: side === "down" ? -4 : 4, scale: 0.94 }}
        transition={{ duration: 0.18 }}
        className="pointer-events-none fixed z-[6000] w-max max-w-[220px]"
        style={
          side === "down"
            ? {
                top: box.top + box.height + 8,
                left: place?.left ?? Math.max(10, box.left + box.width / 2 - 80),
              }
            : {
                bottom: window.innerHeight - box.top + 8,
                left: place?.left ?? Math.max(10, box.left + box.width / 2 - 80),
              }
        }
      >
        <span
          className="absolute h-2 w-2 rotate-45 bg-ink"
          style={{
            left: place?.caret ?? 0,
            marginLeft: -4,
            ...(side === "down" ? { top: -4 } : { bottom: -4 }),
          }}
        />
        <div className="rounded-xl bg-ink px-2.5 py-1.5 text-[11px] font-semibold leading-snug text-white shadow-lg shadow-ink/25">
          {toast.msg}
        </div>
      </motion.div>
    ) : null;

  return (
    <>
      <span ref={markRef} className="pointer-events-none absolute inset-0" aria-hidden />
      {createPortal(<AnimatePresence>{bubble}</AnimatePresence>, document.body)}
    </>
  );
}

export function useToast() {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error("useToast must be used within ToastProvider");
  return ctx;
}
