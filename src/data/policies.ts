export interface PolicySection {
  heading: string;
  body: string[];
}

export interface PolicyDoc {
  slug: string;
  title: string;
  eyebrow: string;
  summary: string;
  updated: string;
  sections: PolicySection[];
}

export const policies: PolicyDoc[] = [
  {
    slug: "doi-tra",
    title: "Chính sách đổi trả trong 7 ngày",
    eyebrow: "Hậu mãi",
    summary:
      "LA BOUTIQUE VN nhận đổi size hoặc đổi mẫu trong 7 ngày kể từ ngày nàng nhận hàng, với điều kiện sản phẩm còn nguyên tem, chưa qua sử dụng và giặt ủi.",
    updated: "19/08/2026",
    sections: [
      {
        heading: "Thời hạn",
        body: [
          "7 ngày tính từ thời điểm đơn được giao thành công.",
          "Liên hệ hotline 0909 123 456 hoặc dùng trang Tra cứu đơn hàng, nêu rõ mã đơn và lý do đổi.",
        ],
      },
      {
        heading: "Điều kiện nhận đổi",
        body: [
          "Còn nguyên tem, nhãn, bao bì boutique và hóa đơn / mã đơn.",
          "Chưa mặc ra ngoài, chưa giặt, không dây bẩn, không mùi nước hoa hay biến dạng form.",
          "Đổi được: sai size, lỗi đường may, giao nhầm mẫu.",
        ],
      },
      {
        heading: "Không áp dụng đổi trả",
        body: [
          "Sản phẩm đã qua sử dụng, mất tem hoặc tự ý cắt chỉnh.",
          "Đơn sale cuối mùa được ghi chú không đổi trả trên trang sản phẩm.",
        ],
      },
      {
        heading: "Cách thức",
        body: [
          "Boutique xác nhận trong 24 giờ làm việc, hướng dẫn gửi về 126 Nguyễn Trãi, Phường Bến Thành, Quận 1, TP.HCM.",
          "Phí ship chiều gửi lại do nàng thanh toán, trừ trường hợp lỗi từ phía boutique.",
          "Hàng đổi được gửi lại trong 2–4 ngày làm việc sau khi boutique nhận và kiểm.",
        ],
      },
    ],
  },
  {
    slug: "thanh-toan",
    title: "Hướng dẫn thanh toán & Freeship QR",
    eyebrow: "Thanh toán",
    summary:
      "Hai hình thức: chuyển khoản VietQR (miễn phí vận chuyển toàn quốc) hoặc COD khi nhận hàng.",
    updated: "21/08/2026",
    sections: [
      {
        heading: "VietQR — freeship toàn quốc",
        body: [
          "Chọn thanh toán QR tại bước đặt hàng, quét mã trên màn hình xác nhận.",
          "Nội dung chuyển khoản điền đúng mã gợi ý trên hóa đơn để boutique đối soát nhanh.",
          "Đơn QR hợp lệ được miễn phí giao hàng toàn quốc.",
        ],
      },
      {
        heading: "COD — thanh toán khi nhận",
        body: [
          "Nàng kiểm tra hộp hàng trước khi thanh toán cho đơn vị vận chuyển.",
          "Phí ship COD 30.000đ, thu cùng giá trị đơn, hiển thị rõ ở bước thanh toán.",
        ],
      },
      {
        heading: "Xác nhận đơn",
        body: [
          "Đơn QR: xác nhận sau khi boutique đối soát giao dịch.",
          "Đơn COD: xác nhận sau khi boutique kiểm thông tin SĐT và địa chỉ.",
          "Theo dõi tiến độ bất cứ lúc nào tại Tra cứu đơn hàng bằng mã đơn hoặc số điện thoại đặt hàng.",
        ],
      },
    ],
  },
  {
    slug: "bao-mat",
    title: "Chính sách bảo mật thông tin",
    eyebrow: "Quyền riêng tư",
    summary:
      "Boutique chỉ dùng thông tin để xử lý đơn, chăm sóc khách và cải thiện trải nghiệm mua sắm. Không bán dữ liệu cho bên thứ ba.",
    updated: "19/08/2026",
    sections: [
      {
        heading: "Thông tin thu thập",
        body: [
          "Họ tên, số điện thoại, địa chỉ giao hàng, email (nếu nàng điền), nội dung ghi chú đơn.",
          "Lịch sử đơn và danh sách yêu thích lưu trên trình duyệt của nàng (localStorage), không đưa lên máy chủ.",
        ],
      },
      {
        heading: "Mục đích sử dụng",
        body: [
          "Xác nhận đơn, giao hàng, đổi trả và trả lời hotline.",
          "Gửi thông tin bộ sưu tập khi nàng chủ động đăng ký nhận tin ở cuối trang.",
        ],
      },
      {
        heading: "Lưu trữ & chia sẻ",
        body: [
          "Chia sẻ tối thiểu với đối tác vận chuyển và cổng thanh toán — đúng phạm vi giao hàng / đối soát.",
          "Không bán, không cho thuê danh sách khách hàng.",
        ],
      },
      {
        heading: "Quyền của nàng",
        body: [
          "Yêu cầu xem, sửa hoặc xóa thông tin đã cung cấp qua email contact@laboutique.vn hoặc hotline 0909 123 456.",
          "Gỡ đăng ký nhận tin bất cứ lúc nào bằng cách phản hồi email ưu đãi.",
        ],
      },
    ],
  },
  {
    slug: "chat-luong",
    title: "Cam kết chất lượng vải & nguồn gốc",
    eyebrow: "Chất liệu",
    summary:
      "Từng mẫu Sunset và tủ đồ hè được chọn vải theo phom: lụa tơ tằm, tơ xốp, xô muslin, linen organic và cotton đũi thoáng khí.",
    updated: "19/08/2026",
    sections: [
      {
        heading: "Chất liệu trên từng sản phẩm",
        body: [
          "Trang chi tiết ghi rõ thành phần và hướng dẫn bảo quản. Đây là thông tin nàng nên đọc trước khi đặt.",
          "Lụa và tơ xốp được kiểm độ rủ, độ bóng; linen / đũi được kiểm độ thoáng và độ bền sợi trước khi lên form.",
        ],
      },
      {
        heading: "May và kiểm hàng",
        body: [
          "Mỗi chiếc được kiểm đường may, khóa, dây cột và điểm cắt trước khi đóng hộp.",
          "Phát hiện lỗi may sau khi nhận: đổi mới theo chính sách 7 ngày, boutique chịu chiều vận chuyển.",
        ],
      },
      {
        heading: "Bảo quản đúng cách",
        body: [
          "Ưu tiên giặt tay nước mát, không vắt mạnh, phơi bóng râm — đúng hướng dẫn trên từng mẫu.",
          "Ủi mặt trái, nhiệt thấp. Lụa chỉ ủi hơi nước.",
          "Bảo quản đúng giúp form và màu giữ được qua nhiều mùa biển.",
        ],
      },
    ],
  },
];

export function getPolicy(slug: string | undefined) {
  return policies.find((p) => p.slug === slug) ?? null;
}
