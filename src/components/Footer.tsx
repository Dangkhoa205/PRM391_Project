"use client";

import { ArrowRight, Mail, MapPin, PhoneCall, ShieldCheck } from "lucide-react";
import { useState, type FormEvent, type MouseEvent as ReactMouseEvent } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useToast } from "@/context/ToastContext";
import { Facebook, Instagram, TikTok } from "@/components/icons";
import { paths } from "@/lib/paths";
import { scrollToId } from "@/lib/scroll";

const SHOP_LINKS = [
  { label: "La Boutique VN Sunset Collection", to: paths.catalog("sunset") },
  { label: "Áo, Đầm & Cổ Yếm Nữ", to: paths.catalog("ao") },
  { label: "Quần & Chân Váy Nữ", to: paths.catalog("quan") },
  { label: "Câu chuyện thương hiệu", to: paths.story, hash: "story" },
];

const POLICIES = [
  { label: "Chính sách đổi trả trong 7 ngày", slug: "doi-tra" },
  { label: "Hướng dẫn thanh toán & Freeship QR", slug: "thanh-toan" },
  { label: "Chính sách bảo mật thông tin", slug: "bao-mat" },
  { label: "Cam kết chất lượng vải & nguồn gốc", slug: "chat-luong" },
];

export function Footer({ onOpenLookup }: { onOpenLookup?: () => void }) {
  const { showToast } = useToast();
  const [email, setEmail] = useState("");
  const location = useLocation();
  const navigate = useNavigate();

  const subscribe = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!email.trim() || !email.includes("@")) return;
    showToast("Cảm ơn nàng đã đăng ký nhận tin từ LA BOUTIQUE VN!");
    setEmail("");
  };

  const goStory = (e: ReactMouseEvent<HTMLAnchorElement>) => {
    if (location.pathname === "/") {
      e.preventDefault();
      scrollToId("story");
    } else {
      navigate(paths.story);
    }
  };

  return (
    <footer id="footer" className="scroll-mt-[100px] bg-ink text-sand-100">
      <div className="mx-auto max-w-7xl px-4 py-16 pb-28 sm:px-6 sm:py-20 lg:pb-16">
        <div className="grid gap-10 md:grid-cols-2 lg:grid-cols-4">
          <div className="lg:col-span-1">
            <p className="font-display text-2xl font-bold tracking-[0.14em] text-white">
              LA BOUTIQUE <span className="text-clay-400 font-black">VN</span>
            </p>
            <p className="mt-3.5 max-w-xs text-xs leading-relaxed text-sand-100/70">
              Lan tỏa tinh thần tự do và khao khát khám phá qua từng thiết kế đồ
              đi biển cao cấp. Tỉ mỉ từ chất liệu tơ tằm, linen organic đến từng đường may tinh tế.
            </p>

            <div className="mt-5 flex gap-3">
              {[
                { icon: Facebook, label: "Facebook", href: "https://www.facebook.com/share/1EoLSNmMyP/?mibextid=wwXIfr" },
                { icon: Instagram, label: "Instagram", href: "https://www.instagram.com/laboutique.vn" },
                { icon: TikTok, label: "TikTok", href: "https://www.tiktok.com/@laboutiquevn" },
              ].map(({ icon: Icon, label, href }, i) => (
                <a
                  key={i}
                  href={href}
                  target="_blank"
                  rel="noreferrer"
                  title={label}
                  aria-label={label}
                  className="flex h-10 w-10 items-center justify-center rounded-full border border-white/15 text-sand-100/80 transition hover:border-clay-400 hover:bg-clay-500/20 hover:text-clay-300 active:scale-95"
                >
                  <Icon className="h-4 w-4" />
                </a>
              ))}
            </div>
          </div>

          <div>
            <h3 className="text-xs font-bold uppercase tracking-wider text-white">
              Danh mục mua sắm
            </h3>
            <ul className="mt-4 space-y-2.5">
              {SHOP_LINKS.map((item) => (
                <li key={item.label}>
                  <Link
                    to={item.to}
                    onClick={item.hash === "story" ? goStory : undefined}
                    className="text-xs text-sand-100/70 transition hover:text-clay-300 hover:underline text-left"
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h3 className="text-xs font-bold uppercase tracking-wider text-white">
              Boutique & Showroom
            </h3>
            <ul className="mt-4 space-y-3 text-xs text-sand-100/70">
              <li className="flex items-start gap-2.5">
                <MapPin className="h-4 w-4 shrink-0 text-clay-400 mt-0.5" />
                <span>126 Nguyễn Trãi, Phường Bến Thành, Quận 1, TP. Hồ Chí Minh</span>
              </li>
              <li className="flex items-center gap-2.5">
                <PhoneCall className="h-4 w-4 shrink-0 text-clay-400" />
                <a href="tel:0909123456" className="hover:text-white transition">
                  Hotline: 0909 123 456
                </a>
              </li>
              <li className="flex items-center gap-2.5">
                <Mail className="h-4 w-4 shrink-0 text-clay-400" />
                <span>Email: contact@laboutique.vn</span>
              </li>
              <li className="flex items-center gap-2.5 text-emerald-400 font-medium">
                <ShieldCheck className="h-4 w-4 shrink-0" />
                <span>Đã chứng nhận thương hiệu độc quyền</span>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="text-xs font-bold uppercase tracking-wider text-white">
              Nhận ưu đãi độc quyền
            </h3>
            <p className="mt-3 text-xs leading-relaxed text-sand-100/70">
              Đăng ký để nhận thông báo về các bộ sưu tập hè giới hạn và nhận mã voucher giảm 10% cho đơn hàng đầu tiên.
            </p>
            <form onSubmit={subscribe} className="mt-4 flex flex-col gap-2">
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Nhập email của bạn..."
                className="rounded-full border border-white/20 bg-white/10 px-4 py-2.5 text-xs text-white outline-none placeholder:text-sand-100/40 focus:border-clay-400 focus:bg-white/20"
              />
              <button
                type="submit"
                className="flex items-center justify-center gap-2 rounded-full bg-clay-500 py-2.5 text-xs font-bold uppercase tracking-wider text-white transition hover:bg-clay-600 active:scale-95"
              >
                <span>Đăng ký nhận ưu đãi</span>
                <ArrowRight className="h-3.5 w-3.5" />
              </button>
            </form>
          </div>
        </div>

        <div className="mt-14 flex flex-col items-center justify-between gap-4 border-t border-white/10 pt-8 text-xs text-sand-100/50 sm:flex-row">
          <p>© 2026 LA BOUTIQUE VN. All rights reserved. Thiết kế thời trang du mục cao cấp.</p>
          <div className="flex flex-wrap justify-center gap-x-4 gap-y-2">
            {POLICIES.map((p) => (
              <Link
                key={p.slug}
                to={paths.policy(p.slug)}
                className="hover:text-sand-100/80 transition"
              >
                {p.label}
              </Link>
            ))}
          </div>
        </div>
      </div>
    </footer>
  );
}
