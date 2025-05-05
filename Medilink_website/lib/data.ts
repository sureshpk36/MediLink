import { Stethoscope, FileText, Calendar, Pill, Activity, MessageSquare, Shield } from "lucide-react"
import type { Feature, Testimonial } from "./types"

export const features: Feature[] = [
  {
    title: "Telemedicine",
    slug: "telemedicine",
    description: "Connect with healthcare providers through secure video consultations",
    overview:
      "Our telemedicine feature allows patients to consult with doctors from the comfort of their homes. With high-quality video and audio, secure messaging, and integrated prescription services, getting medical advice has never been easier.",
    icon: Stethoscope,
    image1: "/placeholder.svg?height=500&width=800&text=Telemedicine",
    image2: "/placeholder.svg?height=500&width=800&text=Video+Consultation",
    bannerImage: "/placeholder.svg?height=400&width=1200&text=Telemedicine+Banner",
    benefits: [
      "Consult with specialists without travel",
      "Reduce waiting time for appointments",
      "Get prescriptions delivered to your doorstep",
      "Follow-up consultations at your convenience",
      "Access to specialists across the country",
    ],
  },
  {
    title: "Health Records",
    slug: "health-records",
    description: "Store and access your medical records securely in one place",
    overview:
      "MediLink's Health Records feature provides a centralized repository for all your medical information. From lab results to prescriptions, imaging reports to vaccination records, everything is securely stored and easily accessible when you need it.",
    icon: FileText,
    image1: "/placeholder.svg?height=500&width=800&text=Health+Records",
    image2: "/placeholder.svg?height=500&width=800&text=Medical+History",
    bannerImage: "/placeholder.svg?height=400&width=1200&text=Health+Records+Banner",
    benefits: [
      "Centralized storage for all medical documents",
      "Share records securely with healthcare providers",
      "Track health metrics over time",
      "Receive alerts for important health events",
      "Family health management in one account",
    ],
  },
  {
    title: "Appointment Booking",
    slug: "appointment-booking",
    description: "Schedule appointments with healthcare providers seamlessly",
    overview:
      "Our appointment booking system makes scheduling medical visits effortless. Find available slots, book appointments, receive reminders, and manage your healthcare schedule all in one place.",
    icon: Calendar,
    image1: "/placeholder.svg?height=500&width=800&text=Appointment+Booking",
    image2: "/placeholder.svg?height=500&width=800&text=Calendar+View",
    bannerImage: "/placeholder.svg?height=400&width=1200&text=Appointment+Booking+Banner",
    benefits: [
      "Real-time availability of healthcare providers",
      "Instant confirmation of appointments",
      "Automated reminders via SMS and email",
      "Easy rescheduling and cancellation",
      "Check-in status updates",
    ],
  },
  {
    title: "Medication Tracking",
    slug: "medication-tracking",
    description: "Never miss a dose with personalized medication reminders",
    overview:
      "MediLink's medication tracking feature helps patients maintain their medication schedules with timely reminders, refill alerts, and detailed information about their prescriptions.",
    icon: Pill,
    image1: "/placeholder.svg?height=500&width=800&text=Medication+Tracking",
    image2: "/placeholder.svg?height=500&width=800&text=Reminder+System",
    bannerImage: "/placeholder.svg?height=400&width=1200&text=Medication+Tracking+Banner",
    benefits: [
      "Customizable medication reminders",
      "Track medication adherence",
      "Automatic refill reminders",
      "Drug interaction warnings",
      "Medication history for doctor visits",
    ],
  },
  {
    title: "Vital Signs Monitoring",
    slug: "vital-signs-monitoring",
    description: "Track your health metrics and share them with your doctor",
    overview:
      "Monitor vital health metrics like blood pressure, heart rate, blood glucose, and more. Connect with compatible devices for automatic data syncing or manually log your readings.",
    icon: Activity,
    image1: "/placeholder.svg?height=500&width=800&text=Vital+Signs+Monitoring",
    image2: "/placeholder.svg?height=500&width=800&text=Health+Metrics",
    bannerImage: "/placeholder.svg?height=400&width=1200&text=Vital+Signs+Banner",
    benefits: [
      "Integration with health monitoring devices",
      "Visualize health trends over time",
      "Set custom alerts for abnormal readings",
      "Share reports directly with healthcare providers",
      "Personalized insights based on your data",
    ],
  },
  {
    title: "Secure Messaging",
    slug: "secure-messaging",
    description: "Communicate with your healthcare team securely and privately",
    overview:
      "Our HIPAA-compliant messaging system enables secure communication between patients and healthcare providers. Ask questions, share updates, and receive guidance without compromising privacy.",
    icon: MessageSquare,
    image1: "/placeholder.svg?height=500&width=800&text=Secure+Messaging",
    image2: "/placeholder.svg?height=500&width=800&text=Private+Chat",
    bannerImage: "/placeholder.svg?height=400&width=1200&text=Secure+Messaging+Banner",
    benefits: [
      "End-to-end encrypted communications",
      "Share images and documents securely",
      "Quick responses to non-emergency questions",
      "Message history for reference",
      "Multi-provider conversations",
    ],
  },
  {
    title: "Privacy & Security",
    slug: "privacy-security",
    description: "Your health data is protected with enterprise-grade security",
    overview:
      "MediLink employs state-of-the-art security measures to protect your sensitive health information. With end-to-end encryption, strict access controls, and regular security audits, your data remains private and secure.",
    icon: Shield,
    image1: "/placeholder.svg?height=500&width=800&text=Privacy+Features",
    image2: "/placeholder.svg?height=500&width=800&text=Security+Measures",
    bannerImage: "/placeholder.svg?height=400&width=1200&text=Privacy+Security+Banner",
    benefits: [
      "HIPAA and GDPR compliant platform",
      "End-to-end encryption for all data",
      "Granular access control for shared records",
      "Detailed audit logs of data access",
      "Two-factor authentication",
    ],
  },
]

export const testimonials: Testimonial[] = [
  {
    name: "Priya Sharma",
    location: "Delhi",
    language: "Hindi",
    quote:
      "MediLink has transformed how I manage my diabetes. The medication reminders and vital tracking features have helped me maintain better control of my health.",
    avatar: "/placeholder.svg?height=60&width=60&text=PS",
    rating: 5,
  },
  {
    name: "Dr. Rajesh Kumar",
    location: "Mumbai",
    language: "Marathi",
    quote:
      "As a physician, MediLink has streamlined my practice. The telemedicine feature allows me to see more patients and provide better follow-up care.",
    avatar: "/placeholder.svg?height=60&width=60&text=RK",
    rating: 5,
  },
  {
    name: "Ananya Patel",
    location: "Ahmedabad",
    language: "Gujarati",
    quote:
      "Managing my family's health records was always a challenge until I found MediLink. Now everything is organized and accessible whenever we need it.",
    avatar: "/placeholder.svg?height=60&width=60&text=AP",
    rating: 4,
  },
  {
    name: "Vikram Singh",
    location: "Jaipur",
    language: "Hindi",
    quote:
      "The appointment booking system is so convenient! No more waiting on hold to schedule a doctor's visit. I can see available slots and book instantly.",
    avatar: "/placeholder.svg?height=60&width=60&text=VS",
    rating: 5,
  },
  {
    name: "Dr. Lakshmi Nair",
    location: "Kochi",
    language: "Malayalam",
    quote:
      "The secure messaging feature has improved communication with my patients. I can answer questions quickly without scheduling unnecessary appointments.",
    avatar: "/placeholder.svg?height=60&width=60&text=LN",
    rating: 4,
  },
  {
    name: "Arjun Reddy",
    location: "Hyderabad",
    language: "Telugu",
    quote:
      "After my heart surgery, MediLink helped me stay connected with my healthcare team and track my recovery progress. It's been invaluable.",
    avatar: "/placeholder.svg?height=60&width=60&text=AR",
    rating: 5,
  },
  {
    name: "Meera Desai",
    location: "Pune",
    language: "Marathi",
    quote:
      "The multilingual support makes it easy for my elderly parents to use the app in their native language. The interface is intuitive and accessible.",
    avatar: "/placeholder.svg?height=60&width=60&text=MD",
    rating: 4,
  },
  {
    name: "Dr. Sanjay Gupta",
    location: "Kolkata",
    language: "Bengali",
    quote:
      "MediLink's health records feature has improved my diagnostic accuracy. Having access to a patient's complete medical history makes a significant difference.",
    avatar: "/placeholder.svg?height=60&width=60&text=SG",
    rating: 5,
  },
  {
    name: "Kavita Krishnan",
    location: "Chennai",
    language: "Tamil",
    quote:
      "The medication tracking feature has been a lifesaver for managing my mother's complex medication schedule. The reminders are reliable and easy to set up.",
    avatar: "/placeholder.svg?height=60&width=60&text=KK",
    rating: 5,
  },
]
