"use client";

import { motion } from "framer-motion";
import {
  Check,
  Copy,
  MapPin,
  Phone,
  Printer,
  ShoppingBag,
  Sparkles,
  Truck,
  User,
  X,
} from "lucide-react";
import { useEffect, useState } from "react";
import confetti from "canvas-confetti";
import type { OrderRecord } from "@/context/CartContext";
import { useToast } from "@/context/ToastContext";
import { formatMoney } from "@/lib/format";

interface SuccessModalProps {
  orderData?: OrderRecord | null;
  onClose: () => void;
  onTrackOrder?: (code: string) => void;
}

export function SuccessModal({ orderData, onClose, onTrackOrder }: SuccessModalProps) {
  const { showToast } = useToast();
  const [copied, setCopied] = useState(false);

  const orderNumber = orderData?.orderNumber || "LBVN-2608-SUNSET";

  useEffect(() => {
    // Launch festive confetti
    confetti({
      particleCount: 90,
      spread: 80,
      origin: { y: 0.55 },
      colors: ["#bd6638", "#dabf9b", "#4f7e7c", "#f4ddd0", "#ecdcc6"],
    });

    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);

  const copyOrderCode = async () => {
    const text = orderNumber.trim();
    let ok = false;

    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(text);
        ok = true;
      }
    } catch {
      ok = false;
    }

    if (!ok) {
      const ta = document.createElement("textarea");
      ta.value = text;
      ta.setAttribute("readonly", "");
      ta.style.cssText = "position:fixed;top:0;left:-9999px;opacity:0";
      document.body.appendChild(ta);
      ta.focus();
      ta.select();
      ta.setSelectionRange(0, text.length);
      try {
        ok = document.execCommand("copy");
      } catch {
        ok = false;
      }
      document.body.removeChild(ta);
    }

    if (ok) {
      setCopied(true);
      showToast("Đã sao chép mã đơn hàng!");
      window.setTimeout(() => setCopied(false), 2000);
    } else {
      showToast("Không sao chép được. Hãy bôi đen mã rồi Ctrl + C.", "info");
    }
  };

  const handlePrint = () => {
    const items = orderData?.items ?? [];
    const escape = (s: string) =>
      s
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;");

    const rows = items
      .map(
        (it) => `
        <tr>
          <td>
            <div class="item">
              <img src="${escape(it.img)}" alt="" />
              <div>
                <strong>${escape(it.name)}</strong>
                <span>Size ${escape(it.size)} · SL ${it.qty}</span>
              </div>
            </div>
          </td>
          <td class="right">${formatMoney(it.price * it.qty)}</td>
        </tr>`
      )
      .join("");

    const html = `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8" />
  <title>Hóa đơn ${escape(orderNumber)}</title>
  <style>
    @page { size: A4; margin: 14mm; }
    * { box-sizing: border-box; }
    html, body { margin: 0; padding: 0; background: #fff; }
    body {
      font-family: Montserrat, "Segoe UI", sans-serif;
      color: #2a2019;
      font-size: 12px;
      line-height: 1.45;
    }
    .sheet { max-width: 720px; margin: 0 auto; }
    .brand { text-align: center; border-bottom: 1px solid #ecdcc6; padding-bottom: 14px; margin-bottom: 16px; }
    .brand h1 { font-family: "Playfair Display", Georgia, serif; font-size: 22px; letter-spacing: 0.14em; margin: 0; }
    .brand h1 span { color: #bd6638; }
    .brand p { margin: 4px 0 0; color: #6e5e51; font-size: 11px; }
    .code { background: #f5eee2; border: 1px solid #ecdcc6; border-radius: 10px; padding: 10px 14px; margin-bottom: 14px; }
    .code small { display: block; text-transform: uppercase; letter-spacing: 0.12em; color: #6e5e51; font-size: 10px; }
    .code strong { font-family: ui-monospace, monospace; font-size: 16px; color: #a1542e; }
    table { width: 100%; border-collapse: collapse; }
    td { padding: 8px 0; vertical-align: middle; border-bottom: 1px solid #f5eee2; }
    .right { text-align: right; white-space: nowrap; font-weight: 700; color: #a1542e; }
    .item { display: flex; gap: 10px; align-items: center; }
    .item img { width: 40px; height: 52px; object-fit: cover; border-radius: 6px; background: #f5eee2; }
    .item span { display: block; color: #6e5e51; font-size: 11px; }
    .meta { margin: 14px 0; color: #2a2019; }
    .meta p { margin: 4px 0; }
    .totals { margin-top: 10px; }
    .totals div { display: flex; justify-content: space-between; padding: 4px 0; color: #6e5e51; }
    .totals .grand { border-top: 1px solid #ecdcc6; margin-top: 6px; padding-top: 8px; color: #2a2019; font-size: 14px; font-weight: 700; }
    .foot { margin-top: 18px; text-align: center; color: #6e5e51; font-size: 11px; }
  </style>
</head>
<body>
  <div class="sheet">
    <div class="brand">
      <h1>LA BOUTIQUE <span>VN</span></h1>
      <p>Hóa đơn đặt hàng · ${orderData?.paymentMethod === "qr" ? "VietQR" : "COD"}</p>
    </div>
    <div class="code">
      <small>Mã tra cứu đơn hàng</small>
      <strong>${escape(orderNumber)}</strong>
    </div>
    <div class="meta">
      <p><strong>Người nhận:</strong> ${escape(orderData?.customerName || "Khách hàng")}</p>
      <p><strong>Điện thoại:</strong> ${escape(orderData?.phone || "")}</p>
      <p><strong>Địa chỉ:</strong> ${escape(orderData?.address || "")}</p>
      ${orderData?.note ? `<p><strong>Ghi chú:</strong> ${escape(orderData.note)}</p>` : ""}
    </div>
    <table>
      <tbody>${rows}</tbody>
    </table>
    <div class="totals">
      <div><span>Tạm tính</span><span>${formatMoney(orderData?.subtotal || 0)}</span></div>
      <div><span>Phí giao hàng</span><span>${formatMoney(orderData?.shippingFee || 30000)}</span></div>
      <div class="grand"><span>Tổng thanh toán</span><span>${formatMoney(orderData?.total || 0)}</span></div>
    </div>
    <p class="foot">Cảm ơn nàng đã chọn LA BOUTIQUE VN.</p>
  </div>
</body>
</html>`;

    const iframe = document.createElement("iframe");
    iframe.setAttribute("aria-hidden", "true");
    iframe.style.cssText = "position:fixed;right:0;bottom:0;width:0;height:0;border:0;";
    document.body.appendChild(iframe);

    const doc = iframe.contentDocument;
    if (!doc) {
      iframe.remove();
      return;
    }
    doc.open();
    doc.write(html);
    doc.close();

    const run = () => {
      iframe.contentWindow?.focus();
      iframe.contentWindow?.print();
      window.setTimeout(() => iframe.remove(), 800);
    };

    if (iframe.contentWindow?.document.readyState === "complete") {
      window.setTimeout(run, 80);
    } else {
      iframe.onload = () => window.setTimeout(run, 80);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      onClick={onClose}
      className="fixed inset-0 z-[3200] flex items-center justify-center bg-ink/70 p-3 backdrop-blur-sm sm:p-5 print:static print:bg-white print:p-0"
    >
      <motion.div
        initial={{ opacity: 0, scale: 0.94, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.96, y: 10 }}
        transition={{ duration: 0.32, ease: [0.22, 1, 0.36, 1] }}
        onClick={(e) => e.stopPropagation()}
        className="soft-scroll relative flex max-h-[92vh] w-full max-w-lg flex-col overflow-y-auto rounded-3xl bg-white p-6 shadow-2xl sm:p-8 print:max-h-none print:max-w-none print:overflow-visible print:rounded-none print:p-0 print:shadow-none"
      >
        <button
          onClick={onClose}
          aria-label="Đóng"
          className="no-print absolute right-4 top-4 z-10 flex h-9 w-9 items-center justify-center rounded-full text-mute transition hover:bg-sand-100 hover:text-ink"
        >
          <X className="h-5 w-5" strokeWidth={1.8} />
        </button>

        {/* Digital Receipt Container */}
        <div className="text-left">
          {/* Header checkmark */}
          <div className="text-center">
            <div className="relative mx-auto mb-4 flex h-16 w-16 items-center justify-center">
              <motion.span
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: "spring", stiffness: 340, damping: 18 }}
                className="flex h-16 w-16 items-center justify-center rounded-full bg-emerald-600 text-white shadow-lg shadow-emerald-600/30"
              >
                <Check className="h-8 w-8" strokeWidth={3} />
              </motion.span>
            </div>

            <div className="inline-flex items-center gap-1.5 rounded-full bg-clay-50 px-3 py-1 text-[11px] font-bold uppercase tracking-wider text-clay-700">
              <Sparkles className="h-3 w-3" />
              <span>Hóa đơn đặt hàng thành công</span>
            </div>

            <h2 className="mt-2 font-display text-2xl font-bold text-ink sm:text-3xl">
              Cảm ơn nàng đã chọn LA BOUTIQUE
            </h2>
            <p className="mt-1 text-xs text-mute">
              Đơn hàng của bạn đã được tiếp nhận và chuyển đến bộ phận đóng gói.
            </p>
          </div>

          {/* Luxury Ticket / Receipt Box */}
          <div className="mt-6 overflow-hidden rounded-2xl border border-sand-200 bg-sand-50/70 shadow-sm">
            {/* Top Bar with Code */}
            <div className="flex items-center justify-between border-b border-sand-200 bg-sand-100/80 px-4 py-3">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-mute">
                  Mã tra cứu đơn hàng
                </span>
                <p
                  className="font-mono text-base font-bold text-clay-600 tracking-wide select-all"
                  onDoubleClick={() => void copyOrderCode()}
                >
                  {orderNumber}
                </p>
              </div>
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  void copyOrderCode();
                }}
                className="no-print flex items-center gap-1 rounded-xl bg-white px-2.5 py-1.5 text-xs font-bold text-ink shadow-sm ring-1 ring-sand-200 transition hover:bg-clay-50 hover:text-clay-700"
              >
                {copied ? <Check className="h-3.5 w-3.5 text-emerald-600" /> : <Copy className="h-3.5 w-3.5" />}
                <span>{copied ? "Đã chép" : "Sao chép"}</span>
              </button>
            </div>

            {/* Recipient Details */}
            <div className="p-4 space-y-2 text-xs border-b border-sand-200 bg-white">
              <p className="text-[11px] font-bold uppercase tracking-wider text-mute">
                Thông tin người nhận:
              </p>
              <div className="grid gap-1 text-ink">
                <div className="flex items-center gap-2">
                  <User className="h-3.5 w-3.5 text-clay-500 shrink-0" />
                  <span className="font-semibold">{orderData?.customerName || "Khách hàng"}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Phone className="h-3.5 w-3.5 text-clay-500 shrink-0" />
                  <span>{orderData?.phone || "0909 123 456"}</span>
                </div>
                <div className="flex items-start gap-2">
                  <MapPin className="h-3.5 w-3.5 text-clay-500 shrink-0 mt-0.5" />
                  <span className="leading-relaxed">{orderData?.address || "Hồ Chí Minh, Việt Nam"}</span>
                </div>
                {orderData?.note && (
                  <div className="mt-1 rounded-lg bg-sand-50 p-2 text-mute text-[11px]">
                    <strong>Ghi chú:</strong> {orderData.note}
                  </div>
                )}
              </div>
            </div>

            {/* Purchased Items Breakdown */}
            <div className="p-4 bg-white">
              <p className="text-[11px] font-bold uppercase tracking-wider text-mute mb-2.5">
                Chi tiết sản phẩm ({orderData?.items?.length || 0} mẫu):
              </p>
              <div className="space-y-2.5 max-h-48 overflow-y-auto soft-scroll">
                {orderData?.items?.map((it, idx) => (
                  <div
                    key={idx}
                    className="flex items-center justify-between gap-3 rounded-xl border border-sand-100 bg-sand-50/50 p-2.5"
                  >
                    <img
                      src={it.img}
                      alt={it.name}
                      className="h-12 w-10 shrink-0 rounded-lg object-cover ring-1 ring-sand-200"
                    />
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-bold text-ink truncate">{it.name}</p>
                      <div className="mt-0.5 flex items-center gap-2 text-[11px] text-mute">
                        <span className="font-semibold text-clay-700 bg-clay-100 px-1.5 py-0.2 rounded">
                          Size {it.size}
                        </span>
                        <span>Số lượng: {it.qty}</span>
                      </div>
                    </div>
                    <div className="text-right shrink-0">
                      <p className="text-xs font-bold tabular-nums text-clay-600">
                        {formatMoney(it.price * it.qty)}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Payment & Total Breakdown */}
            <div className="border-t border-sand-200 bg-sand-50 p-4 text-xs tabular-nums space-y-1.5">
              <div className="flex justify-between text-mute">
                <span>Tạm tính tiền hàng:</span>
                <span>{formatMoney(orderData?.subtotal || 0)}</span>
              </div>
              <div className="flex justify-between text-mute">
                <span className="flex items-center gap-1">
                  <Truck className="h-3.5 w-3.5" /> Phí giao hàng:
                </span>
                <span className={orderData?.shippingFee === 0 ? "font-bold text-emerald-700" : ""}>
                  {orderData?.shippingFee === 0
                    ? "0đ (Freeship QR)"
                    : formatMoney(orderData?.shippingFee ?? 30000)}
                </span>
              </div>
              <div className="flex justify-between text-mute">
                <span>Hình thức thanh toán:</span>
                <span className="font-bold text-ink">
                  {orderData?.paymentMethod === "qr"
                    ? "Chuyển khoản VietQR"
                    : "COD (Thanh toán khi nhận hàng)"}
                </span>
              </div>

              <div className="flex justify-between border-t border-sand-200 pt-2 text-sm font-bold text-ink">
                <span>Tổng tiền thanh toán:</span>
                <span className="font-display text-lg font-bold text-clay-600">
                  {formatMoney(orderData?.total || 0)}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="no-print mt-6 flex flex-col gap-2.5">
          {onTrackOrder && (
            <button
              onClick={() => {
                onClose();
                onTrackOrder(orderNumber);
              }}
              className="flex items-center justify-center gap-2 rounded-full border border-clay-500 bg-clay-50 py-3.5 text-xs font-bold uppercase tracking-wider text-clay-700 transition hover:bg-clay-100 active:scale-95"
            >
              <Truck className="h-4 w-4" />
              <span>Theo dõi tiến trình vận chuyển</span>
            </button>
          )}

          <div className="flex gap-2">
            <button
              onClick={handlePrint}
              className="flex flex-1 items-center justify-center gap-1.5 rounded-full border border-sand-300 bg-white py-3.5 text-xs font-bold uppercase tracking-wider text-ink transition hover:bg-sand-100"
            >
              <Printer className="h-4 w-4" />
              <span>In hóa đơn</span>
            </button>

            <button
              onClick={onClose}
              className="flex flex-1 items-center justify-center gap-1.5 rounded-full bg-ink py-3.5 text-xs font-bold uppercase tracking-wider text-white shadow-lg transition hover:bg-clay-600 active:scale-95"
            >
              <ShoppingBag className="h-4 w-4" />
              <span>Tiếp tục mua sắm</span>
            </button>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
}
