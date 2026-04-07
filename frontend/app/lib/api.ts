// lib/api.ts
// NAPOMENA: Promijenili smo Event tip - "category: string" je sada "categories: string[]".
// Tvoj Phoenix bekend mora vraćati polje "categories" kao JSON array, npr:
// { "categories": ["Tech", "Business"] }

import { Event } from "@/app/types/event";

const API_URL = process.env.NEXT_PUBLIC_API_URL!;

export async function getEvents(): Promise<Event[]> {
  const response = await fetch(`${API_URL}/api/events`);

  if (!response.ok) {
    throw new Error(`Greška pri dohvatanju evenata: ${response.status}`);
  }

  const data = await response.json();
  return data as Event[];
}

export async function getEventById(id: number): Promise<Event | null> {
  const response = await fetch(`${API_URL}/api/events/${id}`);

  if (response.status === 404) return null;
  if (!response.ok) {
    throw new Error(`Greška pri dohvatanju eventa ${id}: ${response.status}`);
  }

  const data = await response.json();
  return data as Event;
}
