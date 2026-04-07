// components/FeaturedCarousel.tsx
// "use client" je obavezan jer karusel koristi useState za praćenje trenutnog slajda.
"use client";

import { useState } from "react";
import { Event } from "@/app/types/event";
import Image from "next/image";

interface FeaturedCarouselProps {
  events: Event[];
}

export default function FeaturedCarousel({ events }: FeaturedCarouselProps) {
  // currentIndex prati koji je slajd trenutno prikazan (0 = prvi, 1 = drugi, itd.)
  const [currentIndex, setCurrentIndex] = useState(0);

  // Ako nema featured evenata, ne prikazujemo ništa
  if (events.length === 0) return null;

  // Idemo na prethodni slajd.
  // "% events.length" je modulo operator - kada dođemo do kraja, vraćamo se na početak.
  // Ako smo na indexu 0, idemo na zadnji (events.length - 1).
  const prev = () =>
    setCurrentIndex((i) => (i - 1 + events.length) % events.length);

  const next = () => setCurrentIndex((i) => (i + 1) % events.length);

  // Prikazujemo max 3 slajda odjednom (ili manje ako ih ima manje)
  const visibleCount = Math.min(3, events.length);

  // Generišemo indekse za vidljive slajdove kružno
  const visibleIndexes = Array.from(
    { length: visibleCount },
    (_, i) => (currentIndex + i) % events.length,
  );

  return (
    <div className="relative overflow-hidden">
      {/* Kontejner za vidljive slajdove */}
      <div className="flex gap-2 h-64 sm:h-80">
        {visibleIndexes.map((idx, position) => {
          const event = events[idx];
          // Srednji slajd je veći (ako ima 3 slajda, srednji je index 1)
          const isCenter = visibleCount === 3 && position === 1;
          return (
            <div
              key={event.id}
              className={`relative overflow-hidden rounded-lg transition-all duration-300 ${
                isCenter ? "flex-2" : "flex-1 opacity-70"
              }`}
            >
              <Image
                src={event.image}
                alt={event.title}
                fill
                className="object-cover"
              />
              {/* Gradijent i naslov na dnu slike */}
              <div className="absolute bottom-0 left-0 right-0 bg-linear-to-t from-black/80 to-transparent p-3">
                <p className="text-white text-sm font-semibold line-clamp-1">
                  {event.title}
                </p>
                <p className="text-gray-400 text-xs">{event.city}</p>
              </div>
            </div>
          );
        })}
      </div>

      {/* Strelica lijevo */}
      <button
        onClick={prev}
        className="absolute left-2 top-1/2 -translate-y-1/2 w-9 h-9 bg-black/70 border border-[#2a2a2a] rounded-full flex items-center justify-center text-white hover:bg-[#ff1f5a] transition-colors z-10"
        aria-label="Prethodni"
      >
        ‹
      </button>

      {/* Strelica desno */}
      <button
        onClick={next}
        className="absolute right-2 top-1/2 -translate-y-1/2 w-9 h-9 bg-black/70 border border-[#2a2a2a] rounded-full flex items-center justify-center text-white hover:bg-[#ff1f5a] transition-colors z-10"
        aria-label="Sljedeći"
      >
        ›
      </button>

      {/* Dot indikatori - mali krugovi koji pokazuju koji je slajd aktivan */}
      <div className="flex justify-center gap-2 mt-4">
        {events.map((_, idx) => (
          <button
            key={idx}
            onClick={() => setCurrentIndex(idx)}
            className={`w-2 h-2 rounded-full transition-colors ${
              idx === currentIndex ? "bg-[#ff1f5a]" : "bg-[#444]"
            }`}
            aria-label={`Idi na slajd ${idx + 1}`}
          />
        ))}
      </div>
    </div>
  );
}
