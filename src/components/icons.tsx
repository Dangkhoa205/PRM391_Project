interface IconProps {
  className?: string;
}

export function Facebook({ className }: IconProps) {
  return (
    <svg viewBox="0 0 24 24" className={className} fill="currentColor" aria-hidden="true">
      <path d="M22 12.06C22 6.5 17.52 2 12 2S2 6.5 2 12.06c0 5 3.66 9.15 8.44 9.94v-7.03H7.9v-2.9h2.54V9.85c0-2.5 1.49-3.89 3.77-3.89 1.1 0 2.24.2 2.24.2v2.46h-1.26c-1.24 0-1.63.77-1.63 1.56v1.88h2.78l-.44 2.9h-2.34V22c4.78-.79 8.44-4.94 8.44-9.94z" />
    </svg>
  );
}

export function Instagram({ className }: IconProps) {
  return (
    <svg
      viewBox="0 0 24 24"
      className={className}
      fill="none"
      stroke="currentColor"
      strokeWidth={1.8}
      aria-hidden="true"
    >
      <rect x="3" y="3" width="18" height="18" rx="5" />
      <circle cx="12" cy="12" r="4" />
      <circle cx="17.3" cy="6.7" r="1.1" fill="currentColor" stroke="none" />
    </svg>
  );
}

export function TikTok({ className }: IconProps) {
  return (
    <svg viewBox="0 0 24 24" className={className} fill="currentColor" aria-hidden="true">
      <path d="M16.5 3c.32 2.07 1.5 3.62 3.5 3.93v2.45c-1.2.1-2.42-.22-3.5-.8v6.12c0 3.2-2.6 5.8-5.8 5.8S4.9 17.9 4.9 14.7s2.6-5.8 5.8-5.8c.31 0 .61.02.9.07v2.54a3.34 3.34 0 0 0-.9-.13c-1.83 0-3.32 1.49-3.32 3.32s1.49 3.32 3.32 3.32 3.32-1.49 3.32-3.32V3h2.58z" />
    </svg>
  );
}

export function ZaloIcon({ className }: IconProps) {
  return (
    <svg viewBox="0 0 24 24" className={className} fill="currentColor" aria-hidden="true">
      <path d="M12 2C6.48 2 2 6.03 2 11c0 2.87 1.48 5.42 3.79 7.08-.2 1.4-.95 3.02-.99 3.1-.06.13-.02.28.09.37.07.06.16.09.25.09.05 0 .1-.01.15-.03 1.93-.83 3.64-1.74 4.39-2.18.74.19 1.52.3 2.32.3 5.52 0 10-4.03 10-9s-4.48-9-10-9z" />
    </svg>
  );
}
