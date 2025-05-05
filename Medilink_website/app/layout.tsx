import type React from "react"
import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"
import Header from "@/components/layout/Header"
import { ThemeProvider } from "@/components/theme-provider"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "MediLink - Precision Medicine Platform",
  description: "AI-powered personalized medication management",
    generator: 'v0.dev'
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider 
          attribute="class" 
          defaultTheme="system" 
          enableSystem
          disableTransitionOnChange
        >
          {/* Background elements */}
          <div className="grid-overlay"></div>
          <div className="floating-element-1"></div>
          <div className="floating-element-2"></div>
          <div className="floating-element-3"></div>
          
          {/* DNA animation */}
          <div className="dna-container">
            <div className="dna-strand">
              <div className="dna-helix-1"></div>
              <div className="dna-helix-2"></div>
            </div>
          </div>
          
          {/* Molecule animation */}
          <div className="molecule">
            <div className="molecule-center"></div>
            <div className="molecule-orbit">
              <div className="molecule-particle"></div>
              <div className="molecule-particle"></div>
              <div className="molecule-particle"></div>
              <div className="molecule-particle"></div>
            </div>
          </div>
          
          <div className="flex min-h-screen flex-col">
            <Header />
            <main className="flex-1">{children}</main>
          </div>
        </ThemeProvider>
      </body>
    </html>
  )
}
