// app/layout.tsx
import type { Metadata } from "next";
import "./globals.css";
import Navbar from "@/app/components/Navbar";
import Footer from "@/app/components/Footer";

export const metadata: Metadata = {
  title: "Event Explorer",
  description: "Where Your Event Dreams Come to Life",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      {/* bg-black je Tailwind klasa za crnu pozadinu - isto kao background-color: #000 u CSS-u */}
      <body className="bg-black text-white min-h-screen flex flex-col">
        <Navbar />
        {/* "flex-1" znači da main sekcija zauzima sav preostali prostor između Navbar-a i Footer-a */}
        <main className="flex-1">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
