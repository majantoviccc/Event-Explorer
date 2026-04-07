// components/Navbar.tsx
// Server komponenta - nema interakcije, samo navigacioni linkovi.

import Link from "next/link";

export default function Navbar() {
  return (
    // "sticky top-0 z-50" = navbar ostaje na vrhu ekrana dok skroluješ
    // z-50 = visok z-index da bude iznad svega drugog
    <nav className="sticky top-0 z-50 bg-black border-b border-[#2a2a2a]">
      <div className="max-w-7xl mx-auto px-6 py-3 flex items-center justify-between">
        {/* Logo - gamepad ikonica u crvenom krugu */}
        <Link href="/" className="flex items-center">
          <div className="w-9 h-9 bg-[#ff1f5a] rounded-full flex items-center justify-center text-white text-lg">
            🎮
          </div>
        </Link>

        {/* Desna strana - navigacioni linkovi */}
        <div className="flex items-center gap-8">
          {/* "Home" link je uvijek obojen akcentom */}
          <Link
            href="/"
            className="text-[#ff1f5a] font-semibold hover:text-white transition-colors"
          >
            Home
          </Link>
          <Link
            href="/events"
            className="text-white font-semibold hover:text-[#ff1f5a] transition-colors"
          >
            Events
          </Link>
        </div>
      </div>
    </nav>
  );
}
