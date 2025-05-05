"use client"

import { createContext, useContext, useState, useEffect, type ReactNode } from "react"

type Language = {
  code: string
  name: string
}

type LanguageContextType = {
  currentLanguage: Language
  setLanguage: (language: Language) => void
  languages: Language[]
}

const languages: Language[] = [
  { code: "en", name: "English" },
  { code: "hi", name: "हिन्दी (Hindi)" },
  { code: "bn", name: "বাংলা (Bengali)" },
  { code: "te", name: "తెలుగు (Telugu)" },
  { code: "ta", name: "தமிழ் (Tamil)" },
  { code: "mr", name: "मराठी (Marathi)" },
  { code: "gu", name: "ગુજરાતી (Gujarati)" },
  { code: "kn", name: "ಕನ್ನಡ (Kannada)" },
  { code: "ml", name: "മലയാളം (Malayalam)" },
  { code: "pa", name: "ਪੰਜਾਬੀ (Punjabi)" },
]

const LanguageContext = createContext<LanguageContextType | undefined>(undefined)

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [currentLanguage, setCurrentLanguage] = useState<Language>(languages[0])
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    // Check if there's a saved language preference
    const savedLanguage = localStorage.getItem("language")
    if (savedLanguage) {
      const lang = languages.find((l) => l.code === savedLanguage)
      if (lang) {
        setCurrentLanguage(lang)
      }
    }
    setMounted(true)
  }, [])

  const setLanguage = (language: Language) => {
    setCurrentLanguage(language)
    // Save language preference
    if (typeof window !== "undefined") {
      localStorage.setItem("language", language.code)
    }
    // Here you would typically update the app's locale/translations
  }

  // Provide the actual value only after mounting to avoid hydration mismatch
  const value = mounted
    ? { currentLanguage, setLanguage, languages }
    : { currentLanguage: languages[0], setLanguage, languages }

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>
}

export function useLanguage() {
  const context = useContext(LanguageContext)
  if (context === undefined) {
    throw new Error("useLanguage must be used within a LanguageProvider")
  }
  return context
}
