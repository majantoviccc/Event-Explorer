// app/page.tsx
// Prava Home stranica - više nije samo redirect na /events.
// "use client" je potreban jer koristimo useState za sort i useEffect za fetch.
"use client";

import { useState, useEffect, useMemo } from "react";
import { Event } from "@/app/types/event";
import { getEvents } from "@/app/lib/api";
import HeroBanner from "@/app/components/HeroBanner";
import FeaturedCarousel from "@/app/components/FeaturedCarousel";
import EventList from "@/app/components/EventList";
import LoadingSpinner from "@/app/components/LoadingSpinner";

// SortOption za Home stranicu - samo "Show: Newest/Oldest"
type HomeSortOption = "newest" | "oldest";

export default function HomePage() {
  const [allEvents, setAllEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sortOption, setSortOption] = useState<HomeSortOption>("newest");

  useEffect(() => {
    async function fetchEvents() {
      try {
        const data = await getEvents();
        setAllEvents(data);
      } catch (err) {
        setError("Could not load events. Is the server running?");
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    fetchEvents();
  }, []);

  // Featured eventi za karusel
  const featuredEvents = useMemo(
    () => allEvents.filter((e) => e.isFeatured),
    [allEvents],
  );

  // Sortirani eventi za grid
  const sortedEvents = useMemo(() => {
    const copy = [...allEvents];
    if (sortOption === "newest") {
      return copy.sort(
        (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime(),
      );
    }
    return copy.sort(
      (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime(),
    );
  }, [allEvents, sortOption]);

  return (
    <div>
      {/* Hero sekcija - puna širina, bez padding-a sa strane */}
      <HeroBanner />

      {/* Sadržaj ispod hero-a */}
      <div className="max-w-7xl mx-auto px-6 py-10">
        {/* Featured Events sekcija */}
        {!loading && featuredEvents.length > 0 && (
          <section className="mb-12">
            <h2 className="text-2xl font-bold text-white mb-1">
              Discover our Featured Events
            </h2>
            <p className="text-gray-400 text-sm mb-6">
              Check out new and upcoming events on the Events Explorer.
            </p>
            <FeaturedCarousel events={featuredEvents} />
          </section>
        )}

        {/* Show / Sort kontrola */}
        {!loading && (
          <div className="flex items-center gap-2 mb-6">
            <span className="text-white font-semibold">Show:</span>
            <button
              onClick={() =>
                setSortOption((prev) =>
                  prev === "newest" ? "oldest" : "newest",
                )
              }
              className="text-[#ff1f5a] font-semibold hover:text-white transition-colors flex items-center gap-1"
            >
              {sortOption === "newest" ? "Newest" : "Oldest"} ▾
            </button>
          </div>
        )}

        {/* Stanja: loading, greška, ili lista */}
        {loading && <LoadingSpinner />}

        {error && (
          <div className="text-center py-20">
            <p className="text-[#ff1f5a] font-semibold">{error}</p>
          </div>
        )}

        {!loading && !error && <EventList events={sortedEvents} />}
      </div>
    </div>
  );
}
