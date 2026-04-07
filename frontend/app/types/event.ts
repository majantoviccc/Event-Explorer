// types/event.ts
// IZMJENA: "category" je sada "categories" - niz stringova.
// Ovo je zbog toga što jedan event može imati više kategorija (npr. ["Business", "Tech"]).
// Tvoj Phoenix bekend mora vraćati polje "categories" kao array u JSON-u.

export interface Event {
  id: number;
  title: string;
  date: string; // Format: "2026-05-15"
  time: string; // Format: "18:00"
  city: string;
  venue: string;
  categories: string[]; // Niz kategorija, npr. ["Music", "Live"]
  price: number; // 0 = besplatan
  image: string;
  description: string;
  isFeatured: boolean;
}
