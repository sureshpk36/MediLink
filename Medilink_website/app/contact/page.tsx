import type { Metadata } from "next"
import ContactPageClient from "./ContactPageClient"

export const metadata: Metadata = {
  title: "Contact Us | MediLink",
  description: "Get in touch with the MediLink team for support or partnership inquiries",
}

export default function ContactPage() {
  return <ContactPageClient />
}
