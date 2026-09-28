function offsetTop(id: string) {
  if (id === "top") return 0;
  const el = document.getElementById(id);
  if (!el) return null;
  return Math.max(0, el.getBoundingClientRect().top + window.scrollY - 64);
}

export function scrollToId(id: string) {
  const top = offsetTop(id);
  if (top == null) return;
  window.scrollTo({ top, behavior: "smooth" });
}

/** Instant jump — used after pagination so a shorter page cannot land on the footer. */
export function jumpToId(id: string) {
  const top = offsetTop(id);
  if (top == null) return;
  const html = document.documentElement;
  const prev = html.style.scrollBehavior;
  html.style.scrollBehavior = "auto";
  window.scrollTo(0, top);
  html.style.scrollBehavior = prev;
}
