"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { Bell, Menu, X } from "lucide-react"
import Image from "next/image"
import { cn } from "@/lib/utils"
import { ModeToggle } from "@/components/ModeToggle"

const navItems = [
  { name: "Home", path: "/" },
  { name: "Dashboard", path: "/dashboard" },
  { name: "Dosage AI", path: "/dosage-ai" },
  { name: "MediLink AI", path: "/medilink-ai" },
  { name: "Drug DB", path: "/drug-db" },
  { name: "My Doctor", path: "/my-doctor" },
  { name: "Appointment", path: "/appointment" },
]

export default function Header() {
  const pathname = usePathname()
  const [notifications, setNotifications] = useState(3)
  const [isScrolled, setIsScrolled] = useState(false)
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10)
    }

    window.addEventListener("scroll", handleScroll)
    return () => window.removeEventListener("scroll", handleScroll)
  }, [])

  return (
    <header
      className={cn(
        "sticky top-0 z-50 w-full transition-all duration-300",
        isScrolled ? "bg-background/95 backdrop-blur-sm border-b shadow-sm" : "bg-background/90 backdrop-blur-sm border-b",
      )}
    >
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <div className="flex items-center gap-6">
          <Link href="/" className="flex items-center gap-2">
            <div className="relative h-10 w-36 flex items-center justify-center">
              <Image 
                src="/logo.png" 
                alt="MediLink Logo" 
                width={150} 
                height={60} 
                className="object-contain w-full h-full" 
                priority 
              />
            </div>
          </Link>

          <nav className="hidden md:flex items-center gap-1 overflow-x-auto max-w-[calc(100vw-320px)] scrollbar-thin">
            {navItems.map((item) => (
              <Link key={item.path} href={item.path} className={cn("nav-link whitespace-nowrap", pathname === item.path && "active")}>
                {item.name}
              </Link>
            ))}
          </nav>
        </div>

        <div className="flex items-center gap-4">
          <ModeToggle />
          <div className="relative">
            <Bell className="h-5 w-5 text-muted-foreground hover:text-foreground transition-colors cursor-pointer" />
            {notifications > 0 && (
              <span className="absolute -top-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full bg-primary text-[10px] text-primary-foreground">
                {notifications}
              </span>
            )}
          </div>

          <div className="h-8 w-8 rounded-full bg-muted flex items-center justify-center">
            <span className="sr-only">User profile</span>
          </div>

          <button
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            className="md:hidden p-2 text-muted-foreground hover:text-foreground transition-colors"
            aria-label="Toggle menu"
          >
            {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      {isMobileMenuOpen && (
        <div className="md:hidden bg-background/95 backdrop-blur-sm border-t">
          <nav className="container mx-auto px-4 py-4 flex flex-col">
            {navItems.map((item) => (
              <Link
                key={item.path}
                href={item.path}
                className={cn(
                  "py-3 border-b border-border",
                  pathname === item.path ? "text-primary font-medium" : "text-muted-foreground",
                )}
                onClick={() => setIsMobileMenuOpen(false)}
              >
                {item.name}
              </Link>
            ))}
          </nav>
        </div>
      )}
    </header>
  )
}
