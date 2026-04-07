// components/FiltersPanel.tsx
// "use client" je obavezan jer ova komponenta šalje podatke gore prema roditelju
// putem callback funkcija (onChange props).
"use client";

export type SortOption = "newest" | "oldest" | "price-asc" | "price-desc";

interface FiltersPanelProps {
  cities: string[];
  categories: string[];
  selectedCity: string;
  selectedCategory: string;
  sortOption: SortOption;
  featuredOnly: boolean;
  onCityChange: (value: string) => void;
  onCategoryChange: (value: string) => void;
  onSortChange: (value: SortOption) => void;
  onFeaturedToggle: (value: boolean) => void;
  onClear: () => void;
}

// Zajednički stil za sve select elemente - tamna pozadina, pink border
const selectClass =
  "w-full bg-black border border-[#ff1f5a] text-white text-sm px-3 py-2 rounded focus:outline-none focus:ring-1 focus:ring-[#ff1f5a] cursor-pointer";

export default function FiltersPanel({
  cities,
  categories,
  selectedCity,
  selectedCategory,
  sortOption,
  featuredOnly,
  onCityChange,
  onCategoryChange,
  onSortChange,
  onFeaturedToggle,
  onClear,
}: FiltersPanelProps) {
  return (
    // max-w-sm centrira panel i ograničava širinu kao na screenshotu
    <div className="max-w-sm mx-auto bg-[#111111] border border-[#2a2a2a] rounded-xl p-6 my-8">
      {/* Naslov panela u pink boji */}
      <h2 className="text-[#ff1f5a] font-bold text-lg mb-5">Filters Panel</h2>

      {/* City filter */}
      <div className="mb-4">
        <label className="block text-white text-sm font-semibold mb-1">
          City
        </label>
        <select
          value={selectedCity}
          onChange={(e) => onCityChange(e.target.value)}
          className={selectClass}
        >
          <option value="">All ▾</option>
          {cities.map((city) => (
            <option key={city} value={city}>
              {city}
            </option>
          ))}
        </select>
      </div>

      {/* Category filter */}
      <div className="mb-4">
        <label className="block text-white text-sm font-semibold mb-1">
          Category
        </label>
        <select
          value={selectedCategory}
          onChange={(e) => onCategoryChange(e.target.value)}
          className={selectClass}
        >
          <option value="">All ▾</option>
          {categories.map((cat) => (
            <option key={cat} value={cat}>
              {cat}
            </option>
          ))}
        </select>
      </div>

      {/* Sort by */}
      <div className="mb-5">
        <label className="block text-white text-sm font-semibold mb-1">
          Sort by
        </label>
        <select
          value={sortOption}
          onChange={(e) => onSortChange(e.target.value as SortOption)}
          className={selectClass}
        >
          <option value="newest">All ▾</option>
          <option value="newest">Newest first</option>
          <option value="oldest">Oldest first</option>
          <option value="price-asc">Price: low to high</option>
          <option value="price-desc">Price: high to low</option>
        </select>
      </div>

      {/* Featured Only checkbox */}
      <div className="flex items-center gap-2 mb-6">
        <input
          type="checkbox"
          id="featured-only"
          checked={featuredOnly}
          onChange={(e) => onFeaturedToggle(e.target.checked)}
          // accent-[#ff1f5a] boji checkbox u pink (Tailwind arbitrary value)
          className="w-4 h-4 accent-[#ff1f5a] cursor-pointer"
        />
        <label
          htmlFor="featured-only"
          className="text-white text-sm cursor-pointer"
        >
          Featured Only
        </label>
      </div>

      {/* Clear Filters dugme */}
      <button
        onClick={onClear}
        className="w-full bg-[#ff1f5a] hover:bg-[#e0174d] text-white font-bold py-2 rounded-lg transition-colors"
      >
        Clear Filters
      </button>
    </div>
  );
}
