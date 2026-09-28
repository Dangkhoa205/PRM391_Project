"use client";

import { useEffect } from "react";

export function useScrollLock(locked: boolean) {
  useEffect(() => {
    if (!locked) return;
    const orig = document.body.style.overflow;
    const origPad = document.body.style.paddingRight;
    const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;

    document.body.style.overflow = "hidden";
    if (scrollbarWidth > 0) {
      document.body.style.paddingRight = `${scrollbarWidth}px`;
    }

    return () => {
      document.body.style.overflow = orig;
      document.body.style.paddingRight = origPad;
    };
  }, [locked]);
}
