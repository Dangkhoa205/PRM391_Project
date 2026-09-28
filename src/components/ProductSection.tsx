import { ArrowRight, PackageOpen } from "lucide-react";
import type { Product } from "@/data/products";
import { ProductCard } from "@/components/ProductCard";
import { Reveal } from "@/components/Reveal";
import { cn } from "@/utils/cn";

interface ProductSectionProps {
  id: string;
  title: string;
  eyebrow?: string;
  description?: string;
  items: Product[];
  onOpen: (p: Product) => void;
  alt?: boolean;
  variant?: "standard" | "trio";
  limit?: number;
  onViewAll?: () => void;
  viewAllLabel?: string;
}

export function ProductSection({
  id,
  title,
  eyebrow,
  description,
  items,
  onOpen,
  alt,
  variant = "standard",
  limit,
  onViewAll,
  viewAllLabel = "Xem tất cả sản phẩm",
}: ProductSectionProps) {
  const isTrio = variant === "trio";
  const displayItems = limit && limit > 0 ? items.slice(0, limit) : items;
  const hasMore = limit && items.length > limit;

  return (
    <section
      id={id}
      className={cn(
        "scroll-mt-[100px] px-4 py-16 sm:px-6 sm:py-20",
        alt ? "bg-white" : "bg-sand-50"
      )}
    >
      <div className={cn("mx-auto", isTrio ? "max-w-6xl" : "max-w-7xl")}>
        <Reveal className="mb-10 text-center">
          {eyebrow && (
            <p className="mb-2 text-[11px] font-bold uppercase tracking-[0.3em] text-clay-500">
              {eyebrow}
            </p>
          )}
          <h2 className="font-display text-3xl font-bold text-ink sm:text-4xl">{title}</h2>
          {description && (
            <p className="mx-auto mt-3 max-w-2xl text-sm leading-relaxed text-mute">
              {description}
            </p>
          )}
        </Reveal>

        {displayItems.length === 0 ? (
          <div className="flex flex-col items-center justify-center rounded-3xl border border-dashed border-sand-300 py-20 text-center text-mute">
            <PackageOpen className="mb-3 h-10 w-10 text-sand-300" strokeWidth={1.3} />
            <p className="text-base font-medium text-ink">Không tìm thấy sản phẩm phù hợp</p>
            <p className="mt-1 text-xs text-mute">Vui lòng điều chỉnh khoảng giá hoặc từ khóa tìm kiếm</p>
          </div>
        ) : isTrio ? (
          /* Centered 3-Column Trio Layout with even baseline and zero blank gaps */
          <div className="mx-auto grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6 sm:gap-8 max-w-5xl items-stretch justify-center">
            {displayItems.map((p, i) => (
              <div key={p.id} className="w-full flex flex-col">
                <ProductCard product={p} index={i} onOpen={onOpen} />
              </div>
            ))}
          </div>
        ) : (
          /* Standard Responsive Grid */
          <div className="grid grid-cols-2 gap-x-4 gap-y-8 sm:gap-x-6 md:grid-cols-3 lg:grid-cols-4">
            {displayItems.map((p, i) => (
              <ProductCard key={p.id} product={p} index={i} onOpen={onOpen} />
            ))}
          </div>
        )}

        {/* View all CTA Button */}
        {onViewAll && hasMore && (
          <div className="mt-12 text-center">
            <button
              onClick={onViewAll}
              className="inline-flex items-center gap-2 rounded-full border-2 border-ink bg-white px-8 py-3.5 text-xs font-bold uppercase tracking-wider text-ink shadow-sm transition hover:bg-ink hover:text-white active:scale-95"
            >
              <span>{viewAllLabel} ({items.length})</span>
              <ArrowRight className="h-4 w-4" />
            </button>
          </div>
        )}
      </div>
    </section>
  );
}
