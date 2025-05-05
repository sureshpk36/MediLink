import type { LucideIcon } from "lucide-react"

export interface Feature {
  title: string
  slug: string
  description: string
  overview: string
  icon: LucideIcon
  image1: string
  image2: string
  bannerImage: string
  benefits: string[]
}

export interface Testimonial {
  name: string
  location: string
  language: string
  quote: string
  avatar: string
  rating: number
}
