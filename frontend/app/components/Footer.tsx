// components/Footer.tsx
// "use client" je potreban zbog accordion (otvori/zatvori sekcije) koji koristi useState.
"use client";

import { useState } from "react";
import Link from "next/link";

// Definišemo sekcije accordiona - naziv i sadržaj
const accordionSections = [
  "ABOUT US",
  "EVENTS",
  "PROMOTIONS",
  "ONLINE SERVICES",
  "COMPANY",
  "RESOURCES",
];

// Mala komponenta za jednu accordion sekciju.
// Drži vlastiti "open" state jer svaka sekcija nezavisno otvara/zatvara.
function AccordionItem({ title }: { title: string }) {
  const [open, setOpen] = useState(false);

  return (
    <div className="border-t border-[#2a2a2a]">
      <button
        onClick={() => setOpen((prev) => !prev)}
        className="w-full flex items-center justify-between py-4 px-0 text-white font-bold text-sm tracking-widest hover:text-[#ff1f5a] transition-colors"
      >
        {title}
        {/* Rotiramo "+" u "×" kada je sekcija otvorena */}
        <span className="text-xl text-gray-400">{open ? "×" : "+"}</span>
      </button>
      {/* Prikazujemo sadržaj samo ako je "open" === true */}
      {open && (
        <div className="pb-4 text-gray-400 text-sm">
          <p>Coming soon.</p>
        </div>
      )}
    </div>
  );
}

export default function Footer() {
  return (
    <footer className="bg-black border-t border-[#2a2a2a] mt-16">
      <div className="max-w-7xl mx-auto px-6 pt-12 pb-6">
        {/* Store sekcija - naslov + social ikone */}
        <div className="text-center mb-10">
          <p className="text-white font-bold tracking-widest mb-4">STORE</p>
          <div className="flex justify-center gap-4">
            {/* Facebook */}
            <a
              href="#"
              className="w-10 h-10 bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg flex items-center justify-center text-white hover:border-[#ff1f5a] hover:text-[#ff1f5a] transition-all"
              aria-label="Facebook"
            >
              f
            </a>
            {/* Twitter/X */}
            <a
              href="#"
              className="w-10 h-10 bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg flex items-center justify-center text-white hover:border-[#ff1f5a] hover:text-[#ff1f5a] transition-all"
              aria-label="Twitter"
            >
              𝕏
            </a>
            {/* LinkedIn */}
            <a
              href="#"
              className="w-10 h-10 bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg flex items-center justify-center text-white hover:border-[#ff1f5a] hover:text-[#ff1f5a] transition-all"
              aria-label="LinkedIn"
            >
              in
            </a>
          </div>
        </div>

        {/* Accordion sekcije */}
        <div className="mb-8">
          {accordionSections.map((section) => (
            <AccordionItem key={section} title={section} />
          ))}
        </div>

        {/* Copyright tekst */}
        <p className="text-gray-500 text-xs text-center mb-6 leading-relaxed">
          © 2026, Event Explorer, Inc. All rights reserved. Events, the Events
          Explorer logo, and all related marks are trademarks or registered
          trademarks of Event Explorer, Inc.
        </p>

        {/* Linkovi na dnu */}
        <div className="flex flex-wrap justify-center gap-x-6 gap-y-2 text-gray-500 text-xs mb-8">
          <Link href="#" className="hover:text-white transition-colors">
            About Us
          </Link>
          <Link href="#" className="hover:text-white transition-colors">
            Privacy Policy
          </Link>
          <Link href="#" className="hover:text-white transition-colors">
            Help
          </Link>
          <Link href="#" className="hover:text-white transition-colors">
            Conditions of Use
          </Link>
          <Link href="#" className="hover:text-white transition-colors">
            Publisher Index
          </Link>
        </div>

        {/* Back to top dugme */}
        <div className="text-center">
          <button
            onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })}
            className="bg-[#ff1f5a] hover:bg-[#e0174d] text-white text-sm font-bold px-6 py-2 rounded-full transition-colors"
          >
            Back to top ↑
          </button>
        </div>
      </div>
    </footer>
  );
}
