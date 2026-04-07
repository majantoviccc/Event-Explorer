// components/HeroBanner.tsx
// Server komponenta - prikazuje dramatičan hero sa slikom i naslovom.
// Koristi se i na Home i na Events stranici.
import Image from "next/image";
export default function HeroBanner() {
  return (
    // "relative" je potreban da bismo mogli apsolutno pozicionirati tekst iznad slike.
    // h-72 = visina 288px, sm:h-96 = na većim ekranima 384px
    <div className="relative h-72 sm:h-96 overflow-hidden">
      {/* Hero slika - zamijeni URL sa svojom slikom ako imaš */}
      <Image
        src="https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=1600"
        alt="Events hero"
        fill
        sizes="100vw"
        className="object-cover object-center"
      />

      {/* Tamni gradijent sa lijeve strane da tekst bude čitljiv.
          "absolute inset-0" = pokriva cijeli parent div */}
      <div className="absolute inset-0 bg-linear-to-t from-black/80 via-black/40 to-transparent" />

      {/* Tekst koji lebdi iznad slike */}
      <div className="absolute bottom-8 left-6 sm:left-10 max-w-2xl">
        <h1 className="text-3xl sm:text-5xl font-extrabold text-white leading-tight">
          {/* Samo riječ "Event" je obojena akcentom */}
          Where Your <span className="text-[#ff1f5a]">Event</span> Dreams Come
          to Life!
        </h1>
      </div>
    </div>
  );
}
