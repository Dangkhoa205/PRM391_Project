"use client";

import { motion } from "framer-motion";

const STATS = [
  { value: "10+", label: "Thiết kế độc quyền" },
  { value: "COD", label: "Thanh toán khi nhận hàng" },
  { value: "7 ngày", label: "Hỗ trợ đổi trả tận tâm" },
];

export function BrandStory() {
  return (
    <section id="story" className="relative scroll-mt-[100px] overflow-hidden">
      <img
        src="/images/products/sunset-main-4.jpg"
        alt="Tinh thần La Boutique Sunset — LA BOUTIQUE VN"
        className="absolute inset-0 h-full w-full object-cover object-[center_25%]"
      />
      <div className="absolute inset-0 bg-gradient-to-b from-ink/80 via-ink/75 to-ink/90" />

      <div className="relative mx-auto max-w-3xl px-6 py-24 text-center text-white sm:py-32">
        <motion.p
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="mb-4 text-[11px] font-bold uppercase tracking-[0.3em] text-clay-300"
        >
          Câu chuyện thương hiệu
        </motion.p>

        <motion.h2
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7, delay: 0.1 }}
          className="font-display text-3xl font-bold leading-tight sm:text-5xl"
        >
          Tinh thần La Boutique Sunset
        </motion.h2>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7, delay: 0.2 }}
          className="mx-auto mt-5 max-w-xl text-sm leading-relaxed text-white/90 sm:text-base font-light"
        >
          LA BOUTIQUE VN sinh ra từ tình yêu với những bờ biển rực rỡ và ánh hoàng hôn
          ấm áp. Mỗi thiết kế là lời mời gọi nàng cất bước — tự do, bản năng và
          đầy khao khát khám phá những chân trời mới.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7, delay: 0.3 }}
          className="mx-auto mt-10 grid max-w-lg grid-cols-3 gap-4 border-t border-white/20 pt-8"
        >
          {STATS.map((s) => (
            <div key={s.label} className="text-center">
              <p className="font-display text-2xl font-bold tracking-tight text-clay-300 sm:text-3xl">
                {s.value}
              </p>
              <p className="mt-1 text-xs text-white/80">{s.label}</p>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
