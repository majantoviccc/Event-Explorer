// components/EmptyState.tsx
export default function EmptyState() {
  return (
    <div className="flex flex-col items-center justify-center py-24 text-center col-span-full">
      <span className="text-6xl mb-4">🔍</span>
      <h3 className="text-xl font-bold text-white mb-2">No events found</h3>
      <p className="text-gray-500 max-w-sm text-sm">
        No events match your current filters. Try adjusting your search or clear
        all filters.
      </p>
    </div>
  );
}
