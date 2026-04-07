// components/LoadingSpinner.tsx
export default function LoadingSpinner() {
  return (
    <div className="flex flex-col items-center justify-center py-24 gap-4">
      <div className="w-10 h-10 border-4 border-[#2a2a2a] border-t-[#ff1f5a] rounded-full animate-spin" />
      <p className="text-gray-500 text-sm">Loading events...</p>
    </div>
  );
}
