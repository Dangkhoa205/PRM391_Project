"use client";

import { AnimatePresence, motion } from "framer-motion";
import { ArrowRight, Sparkles } from "lucide-react";
import { useEffect, useState } from "react";
import { scrollToId } from "@/lib/scroll";

const SLIDES = [
  "/images/products/sunset-main-1.jpg",
  "/images/products/sunset-main-3.jpg",
  "/images/products/sunset-main-4.jpg",
  "/images/products/sunset-main-5.jpg",
];

const ease = [0.22, 1, 0.36, 1] as const;

export function Hero({ onExplore }: { onExplore: () => void }) {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const t = window.setInterval(
      () => setIndex((i) => (i + 1) % SLIDES.length),
      6000
    );
    return () => window.clearInterval(t);
  }, []);

  return (
    <section className="relative h-[92svh] min-h-[520px] sm:h-[100svh] sm:min-h-[600px] w-full overflow-hidden bg-ink">
      <AnimatePresence mode="popLayout">
        <motion.div
          key={`hero-slide-${index}`}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 1.2, ease: "easeInOut" }}
          className="absolute inset-0"
        >
          <motion.img
            src={SLIDES[index]}
            alt="La Boutique Sunset — Bộ sưu tập hè 2026"
            initial={{ scale: 1.06 }}
            animate={{ scale: 1 }}
            transition={{ duration: 6.2, ease: "easeOut" }}
            className="h-full w-full object-cover object-[center_16%] sm:object-[center_18%] md:object-[center_20%]"
          />
        </motion.div>
      </AnimatePresence>

      <div className="absolute inset-0 bg-gradient-to-b from-ink/75 via-ink/20 to-ink/80 pointer-events-none" />
      <div className="absolute inset-x-0 bottom-0 h-28 sm:h-36 bg-gradient-to-t from-sand-50 via-sand-50/40 to-transparent pointer-events-none" />

      <div className="relative z-10 mx-auto flex h-full max-w-5xl flex-col items-center justify-center px-4 sm:px-6 text-center text-white">
        <motion.div
          initial={{ opacity: 0, y: 14 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease, delay: 0.2 }}
          className="mb-3.5 sm:mb-5 inline-flex items-center gap-1.5 sm:gap-2 rounded-full border border-white/30 bg-black/30 px-3.5 py-1 sm:px-4 sm:py-1.5 text-[10px] sm:text-[11px] font-bold uppercase tracking-[0.25em] backdrop-blur-md shadow-md"
        >
          <Sparkles className="h-3 w-3 sm:h-3.5 sm:w-3.5 text-amber-300" />
          <span>Bộ sưu tập Hè 2026</span>
          <span className="h-1 w-1 rounded-full bg-white/60" />
          <span className="text-amber-200">Signature Edition</span>
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.75, ease, delay: 0.35 }}
          className="font-display text-4xl font-bold uppercase leading-[1.02] tracking-[0.03em] drop-shadow-[0_4px_24px_rgba(0,0,0,0.7)] sm:text-6xl md:text-7xl lg:text-8xl"
        >
          La Boutique Sunset
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, ease, delay: 0.5 }}
          className="mt-3.5 sm:mt-5 max-w-lg text-xs sm:text-sm md:text-base font-light leading-relaxed text-white/95 drop-shadow-md px-2"
        >
          Hành trình mùa hè của người nữ du mục — tự do, bản năng và đầy khao
          khát khám phá những bờ biển mới cùng lụa tơ tằm & linen tự nhiên.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, ease, delay: 0.65 }}
          className="mt-6 sm:mt-9 flex flex-col items-center gap-2.5 sm:gap-3.5 sm:flex-row w-full max-w-xs sm:max-w-none justify-center"
        >
          <button
            onClick={onExplore}
            className="group flex w-full sm:w-auto items-center justify-center gap-2 rounded-full bg-clay-500 px-6 py-3 sm:px-8 sm:py-3.5 text-xs sm:text-[13px] font-bold uppercase tracking-wider text-white shadow-xl shadow-clay-950/40 transition hover:bg-clay-600 active:scale-95"
          >
            <span>Khám phá bộ sưu tập</span>
            <ArrowRight
              className="h-3.5 w-3.5 sm:h-4 sm:w-4 transition-transform group-hover:translate-x-1"
              strokeWidth={2.2}
            />
          </button>
          <button
            onClick={() => scrollToId("story")}
            className="w-full sm:w-auto rounded-full border border-white/40 bg-black/30 px-6 py-3 sm:px-8 sm:py-3.5 text-xs sm:text-[13px] font-bold uppercase tracking-wider text-white backdrop-blur-md transition hover:bg-white hover:text-ink active:scale-95 shadow-sm"
          >
            Câu chuyện thương hiệu
          </button>
        </motion.div>
      </div>

      <div className="absolute bottom-6 sm:bottom-9 left-1/2 z-10 flex -translate-x-1/2 items-center gap-2">
        {SLIDES.map((_, i) => (
          <button
            key={i}
            onClick={() => setIndex(i)}
            aria-label={`Chuyển đến hình ${i + 1}`}
            className="group relative h-2 w-2 sm:h-2.5 sm:w-2.5 rounded-full bg-white/40 transition hover:bg-white/70"
          >
            {i === index && (
              <motion.span
                layoutId="hero-dot"
                className="absolute inset-0 rounded-full bg-white ring-2 ring-white/50"
                transition={{ type: "spring", stiffness: 400, damping: 30 }}
              />
            )}
          </button>
        ))}
      </div>
    </section>
  );
}
