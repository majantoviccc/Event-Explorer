// components/EventList.tsx
import { Event } from "@/app/types/event";
import EventCard from "./EventCard";
import EmptyState from "./EmptyState";

interface EventListProps {
  events: Event[];
}

export default function EventList({ events }: EventListProps) {
  if (events.length === 0) return <EmptyState />;

  return (
    // grid-cols-2 na malim ekranima, 3 na md, 4 na lg, 5 na xl (kao na screenshotu)
    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 xl:grid-cols-5 gap-4">
      {events.map((event) => (
        <EventCard key={event.id} event={event} />
      ))}
    </div>
  );
}
