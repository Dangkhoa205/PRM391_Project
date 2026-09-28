export function Marquee() {
  const phrases = [
    "La Boutique Sunset",
    "Hè 2026",
    "Đồ Đi Biển Cao Cấp",
    "Giao hàng toàn quốc · COD",
    "Thiết Kế Độc Quyền",
    "Lụa Tơ Tằm & Tơ Xốp Tự Nhiên",
  ];
  const row = [...phrases, ...phrases, ...phrases, ...phrases];

  return (
    <div
      aria-hidden="true"
      className="overflow-hidden border-y border-clay-600/30 bg-clay-500 py-3.5 text-sand-50 shadow-inner"
    >
      <div className="flex w-max animate-marquee items-center gap-10 whitespace-nowrap pr-10">
        {row.map((t, i) => (
          <span
            key={i}
            className="flex items-center gap-8 font-display text-base italic tracking-wider sm:text-lg"
          >
            <span>{t}</span>
            <span className="h-1.5 w-1.5 rotate-45 bg-white/70" />
          </span>
        ))}
      </div>
    </div>
  );
}
