import type { Product } from "@/data/products";

export const CATALOG_SLUGS = ["sunset", "ao", "quan"] as const;
export type CatalogSlug = (typeof CATALOG_SLUGS)[number];

export function isCatalogSlug(value: string | undefined): value is CatalogSlug {
  return !!value && (CATALOG_SLUGS as readonly string[]).includes(value);
}

export const CATALOG_LABEL: Record<string, string> = {
  all: "Bộ sưu tập",
  sunset: "Sunset",
  ao: "Áo & Đầm",
  quan: "Quần & Váy",
};

export function productCatalogSlug(product: Product): CatalogSlug {
  if (product.collection === "sunset" || product.isSummer) return "sunset";
  return product.type;
}

export const paths = {
  home: "/",
  catalog: (category: string = "all", page = 1) => {
    const base = !category || category === "all" ? "/bo-suu-tap" : `/bo-suu-tap/${category}`;
    return page > 1 ? `${base}?trang=${page}` : base;
  },
  product: (slug: string) => `/san-pham/${slug}`,
  lookup: (code?: string) =>
    code ? `/tra-cuu?ma=${encodeURIComponent(code)}` : "/tra-cuu",
  policy: (slug: string) => `/chinh-sach/${slug}`,
  story: "/#story",
};
