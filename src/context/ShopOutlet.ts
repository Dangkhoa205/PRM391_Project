import type { CartItem } from "@/context/CartContext";

export type CheckoutIntent = "buynow" | "cart";

export type ShopOutletContext = {
  openCart: () => void;
  openCheckout: (directItems?: CartItem[], intent?: CheckoutIntent) => void;
  openSizeGuide: () => void;
};
