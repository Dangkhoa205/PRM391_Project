import { PhoneCall, RefreshCw, ShieldCheck, Truck } from "lucide-react";

const ITEMS = [
  {
    icon: Truck,
    title: "Freeship khi quét QR",
    desc: "Chuyển khoản QR — miễn phí ship toàn quốc",
  },
  {
    icon: RefreshCw,
    title: "Đổi trả trong 7 ngày",
    desc: "Hỗ trợ đổi size tận tâm, tiện lợi",
  },
  {
    icon: ShieldCheck,
    title: "Thanh toán linh hoạt",
    desc: "QR freeship hoặc COD khi nhận hàng",
  },
  {
    icon: PhoneCall,
    title: "Tư vấn chọn size 24/7",
    desc: "Hotline & Zalo: 0909 123 456",
  },
];

export function ValueStrip() {
  return (
    <div className="border-b border-sand-200 bg-sand-50">
      <div className="mx-auto grid max-w-7xl grid-cols-2 divide-x divide-y divide-sand-200 sm:grid-cols-4 sm:divide-y-0">
        {ITEMS.map(({ icon: Icon, title, desc }) => (
          <div
            key={title}
            className="flex items-center gap-3.5 border-sand-200 px-4 py-5 sm:border-l sm:first:border-l-0 sm:px-6"
          >
            <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-clay-50 text-clay-600 ring-1 ring-clay-200">
              <Icon className="h-5 w-5" strokeWidth={1.8} />
            </span>
            <div className="min-w-0">
              <p className="truncate text-[13px] font-semibold leading-tight text-ink">
                {title}
              </p>
              <p className="truncate text-xs text-mute mt-0.5">{desc}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
