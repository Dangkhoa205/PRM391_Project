"use client";

import { motion } from "framer-motion";
import { Ruler, Sparkles, X } from "lucide-react";
import { useEffect } from "react";

interface SizeGuideModalProps {
  onClose: () => void;
}

const AO_ROWS = [
  { size: "S", weight: "Dưới 45 kg", chest: "78 — 82", waist: "60 — 64" },
  { size: "M", weight: "46 — 52 kg", chest: "83 — 87", waist: "65 — 69" },
  { size: "L", weight: "53 — 60 kg", chest: "88 — 92", waist: "70 — 74" },
];

const QUAN_ROWS = [
  { size: "S", waist: "60 — 64", hip: "84 — 88", length: "98" },
  { size: "M", waist: "65 — 69", hip: "89 — 93", length: "100" },
  { size: "L", waist: "70 — 74", hip: "94 — 98", length: "102" },
];

export function SizeGuideModal({ onClose }: SizeGuideModalProps) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      onClick={onClose}
      className="fixed inset-0 z-[3200] flex items-center justify-center bg-ink/65 p-4 backdrop-blur-sm"
    >
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 16 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.97, y: 8 }}
        transition={{ duration: 0.28, ease: [0.22, 1, 0.36, 1] }}
        onClick={(e) => e.stopPropagation()}
        className="soft-scroll relative max-h-[88vh] w-full max-w-lg overflow-y-auto rounded-3xl bg-white p-6 shadow-2xl sm:p-8"
      >
        <button
          onClick={onClose}
          aria-label="Đóng"
          className="absolute right-4 top-4 flex h-9 w-9 items-center justify-center rounded-full text-mute transition hover:bg-sand-100 hover:text-ink"
        >
          <X className="h-5 w-5" strokeWidth={1.8} />
        </button>

        <div className="flex items-center gap-2 text-clay-500 text-xs font-bold uppercase tracking-wider">
          <Ruler className="h-4 w-4" />
          <span>LA BOUTIQUE VN · Fit Guide</span>
        </div>

        <h2 className="mt-1 font-display text-2xl font-semibold text-ink">
          Bảng thông số chọn size
        </h2>
        <p className="mt-1 text-xs text-mute">Gợi ý kích cỡ chuẩn cho form dáng phụ nữ Việt Nam</p>

        {/* Áo & Đầm */}
        <h3 className="mt-6 mb-2.5 flex items-center gap-1.5 text-xs font-bold uppercase tracking-wider text-clay-600">
          <Sparkles className="h-3.5 w-3.5" />
          1 · Áo, Áo khoác & Đầm lụa
        </h3>
        <table className="w-full border-collapse overflow-hidden rounded-xl text-xs">
          <thead>
            <tr className="bg-sand-100 text-left text-ink">
              <th className="border border-sand-200 px-3.5 py-2.5 font-bold">Size</th>
              <th className="border border-sand-200 px-3.5 py-2.5 font-bold">Cân nặng</th>
              <th className="border border-sand-200 px-3.5 py-2.5 font-bold">Vòng ngực</th>
              <th className="border border-sand-200 px-3.5 py-2.5 font-bold">Vòng eo</th>
            </tr>
          </thead>
          <tbody>
            {AO_ROWS.map((r) => (
              <tr key={r.size} className="text-mute hover:bg-sand-50">
                <td className="border border-sand-200 px-3.5 py-2.5 font-bold text-ink bg-sand-50/50">{r.size}</td>
                <td className="border border-sand-200 px-3.5 py-2.5 font-medium">{r.weight}</td>
                <td className="border border-sand-200 px-3.5 py-2.5">{r.chest} cm</td>
                <td className="border border-sand-200 px-3.5 py-2.5">{r.waist} cm</td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* Quần & Chân váy */}
        <h3 className="mt-7 mb-2.5 flex items-center gap-1.5 text-xs font-bold uppercase tracking-wider text-clay-600">
          <Sparkles className="h-3.5 w-3.5" />
          2 · Quần Linen & Chân váy
        </h3>
        <table className="w-full border-collapse overflow-hidden rounded-xl text-xs">
          <thead>
            <tr className="bg-sand-100 text-left text-ink">
              <th className="border border-sand-200 px-3.5 py-2.5 font-bold">Size</th>
              <th className="border border-sand-200 px-3.5 py-2.5 font-bold">Vòng eo</th>
              <th className="border border-sand-200 px-3.5 py-2.5 font-bold">Vòng mông</th>
              <th className="border border-sand-200 px-3.5 py-2.5 font-bold">Chiều dài</th>
            </tr>
          </thead>
          <tbody>
            {QUAN_ROWS.map((r) => (
              <tr key={r.size} className="text-mute hover:bg-sand-50">
                <td className="border border-sand-200 px-3.5 py-2.5 font-bold text-ink bg-sand-50/50">{r.size}</td>
                <td className="border border-sand-200 px-3.5 py-2.5 font-medium">{r.waist} cm</td>
                <td className="border border-sand-200 px-3.5 py-2.5">{r.hip} cm</td>
                <td className="border border-sand-200 px-3.5 py-2.5">{r.length} cm</td>
              </tr>
            ))}
          </tbody>
        </table>

        <div className="mt-5 rounded-2xl bg-sand-50 p-4 border border-sand-200 text-xs leading-relaxed text-mute">
          <p className="font-semibold text-ink mb-1">Mẹo nhỏ từ chuyên viên LA Boutique:</p>
          <p>
            Thông số có thể xê dịch 1–2cm do đo thủ công. Nếu bạn thích mặc thoải mái để đi biển, hãy ưu tiên chọn tăng 1 size để có độ rủ bay bổng nhất.
          </p>
        </div>
      </motion.div>
    </motion.div>
  );
}
