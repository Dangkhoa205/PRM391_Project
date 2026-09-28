import { ChevronRight } from "lucide-react";
import { Link } from "react-router-dom";
import { cn } from "@/utils/cn";

export type Crumb = { label: string; to?: string };

export function Breadcrumb({ items, className }: { items: Crumb[]; className?: string }) {
  return (
    <nav aria-label="Đường dẫn" className={cn("flex min-w-0 flex-wrap items-center gap-x-1.5 gap-y-1", className)}>
      {items.map((item, i) => {
        const last = i === items.length - 1;
        return (
          <span key={`${item.label}-${i}`} className="flex min-w-0 items-center gap-1.5">
            {i > 0 && <ChevronRight className="h-3 w-3 shrink-0 text-sand-400" strokeWidth={2.2} />}
            {item.to && !last ? (
              <Link
                to={item.to}
                className="truncate text-[11px] font-semibold text-mute transition hover:text-clay-600 sm:text-xs"
              >
                {item.label}
              </Link>
            ) : (
              <span
                className={cn(
                  "truncate text-[11px] sm:text-xs",
                  last ? "font-bold text-ink" : "font-semibold text-mute"
                )}
              >
                {item.label}
              </span>
            )}
          </span>
        );
      })}
    </nav>
  );
}
