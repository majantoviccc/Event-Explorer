// components/EventCard.tsx
// Kompletno redizajnirana kartica - tamna pozadina, pink city badge, kompaktni izgled.

import Link from "next/link";
import { Event } from "@/app/types/event";
import Image from "next/image";

interface EventCardProps {
  event: Event;
}

function formatPrice(price: number): string {
  if (price === 0) return "$Free";
  return `$${price}`;
}

export default function EventCard({ event }: EventCardProps) {
  return (
    // Tamna kartica sa suptilnim borderom - hover podiže border na akcentnu boju
    <Link href={`/events/${event.id}`}>
      <div className="bg-[#111111] border border-[#2a2a2a] rounded-xl overflow-hidden hover:border-[#ff1f5a] transition-all duration-200 cursor-pointer group">
        {/* Slika - relativno mala, kvadratnog oblika */}
        <div className="relative w-full h-36 sm:h-96 overflow-hidden group">
          <Image
            src={event.image}
            alt={event.title}
            fill
            className="object-cover w-full h-full group-hover:scale-105 transition-transform duration-300"
          />
        </div>

        {/* Sadržaj kartice */}
        <div className="p-3">
          {/* Naslov */}
          <h3 className="text-white font-bold text-sm leading-snug mb-2 line-clamp-2">
            {event.title}
          </h3>

          {/* Datum i vrijeme - mali sivi tekst */}
          <p className="text-gray-400 text-xs mb-1">{event.date}</p>
          <p className="text-gray-400 text-xs mb-3">{event.time}</p>

          {/* City badge - pink zaobljena pločica sa pin ikonom */}
          <div className="inline-flex items-center gap-1 bg-[#ff1f5a] rounded-full px-2 py-0.5 mb-2">
            <span className="text-white text-xs">📍</span>
            <span className="text-white text-xs font-semibold">
              {event.city}
            </span>
          </div>

          {/* Cijena */}
          <p className="text-white text-sm font-bold">
            {formatPrice(event.price)}
          </p>
        </div>
      </div>
    </Link>
  );
}
