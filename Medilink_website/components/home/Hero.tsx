"use client"

import { useRef } from "react"
import { motion, useScroll, useTransform } from "framer-motion"
import Link from "next/link"
import Image from "next/image"
import { Button } from "@/components/ui/button"
import { ArrowRight } from "lucide-react"

export default function Hero() {
  const ref = useRef(null)
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"],
  })

  const y = useTransform(scrollYProgress, [0, 1], [0, 200])
  const opacity = useTransform(scrollYProgress, [0, 0.5], [1, 0])

  return (
    <section ref={ref} className="relative min-h-screen flex items-center justify-center overflow-hidden py-20 md:py-0">
      {/* Background Elements */}
      <motion.div className="absolute inset-0 -z-10" style={{ y, opacity }}>
        <div className="absolute top-0 left-0 right-0 h-full bg-gradient-to-b from-background to-transparent opacity-90" />
        <div className="absolute inset-0 bg-[url('/images/grid.png')] bg-center opacity-10" />
        <div className="absolute top-1/4 -left-20 w-80 h-80 bg-green-light/20 rounded-full filter blur-3xl" />
        <div className="absolute bottom-1/4 -right-20 w-80 h-80 bg-green-dark/20 rounded-full filter blur-3xl" />
      </motion.div>

      <div className="container mx-auto px-4 grid md:grid-cols-2 gap-12 items-center">
        {/* Text Content */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center md:text-left"
        >
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.2, duration: 0.5 }}
            className="inline-block px-4 py-1 mb-6 rounded-full bg-primary/10 text-sm font-medium"
          >
            Transforming Healthcare in India
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.5 }}
            className="text-4xl md:text-5xl lg:text-6xl font-bold mb-6 leading-tight"
          >
            Healthcare, <span className="text-gradient">Reimagined</span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4, duration: 0.5 }}
            className="text-xl text-muted-foreground mb-8 max-w-lg mx-auto md:mx-0"
          >
            Connect with top healthcare providers, manage your medical records, and take control of your health
            journey—all in one secure platform.
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.5 }}
            className="flex flex-col sm:flex-row gap-4 justify-center md:justify-start"
          >
            <Button size="lg" className="shadow-glow-sm hover:shadow-glow">
              Get Started <ArrowRight className="ml-2 h-4 w-4" />
            </Button>
            <Button size="lg" variant="outline">
              Learn More
            </Button>
          </motion.div>

          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.6, duration: 0.5 }}
            className="mt-8 flex items-center justify-center md:justify-start"
          >
            <div className="flex -space-x-2">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="w-8 h-8 rounded-full border-2 border-background overflow-hidden">
                  <Image
                    src={`/placeholder.svg?height=32&width=32&text=${i}`}
                    alt={`User ${i}`}
                    width={32}
                    height={32}
                  />
                </div>
              ))}
            </div>
            <div className="ml-4 text-sm">
              <span className="font-bold">1M+</span> users across India
            </div>
          </motion.div>
        </motion.div>

        {/* Hero Image/Illustration */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
          className="relative"
        >
          <div className="relative w-full aspect-square max-w-md mx-auto">
            <div className="absolute inset-0 bg-gradient-to-r from-green-light/20 to-green-dark/20 rounded-full filter blur-3xl" />
            <div className="glassmorphism rounded-2xl overflow-hidden w-full h-full flex items-center justify-center">
              <Image
                src="/placeholder.svg?height=500&width=500&text=MediLink+App"
                alt="MediLink App"
                width={500}
                height={500}
                className="object-cover"
              />
            </div>

            {/* Floating elements */}
            <motion.div
              className="absolute -top-6 -right-6 glassmorphism p-4 rounded-lg shadow-glow-sm"
              animate={{ y: [0, -10, 0] }}
              transition={{ duration: 4, repeat: Number.POSITIVE_INFINITY, repeatType: "reverse" }}
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-green-500 flex items-center justify-center text-white">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path
                      d="M20 6L9 17L4 12"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                </div>
                <div>
                  <p className="text-sm font-medium">Appointment Confirmed</p>
                  <p className="text-xs text-muted-foreground">Dr. Sharma, 2:30 PM</p>
                </div>
              </div>
            </motion.div>

            <motion.div
              className="absolute -bottom-6 -left-6 glassmorphism p-4 rounded-lg shadow-glow-sm"
              animate={{ y: [0, 10, 0] }}
              transition={{ duration: 5, repeat: Number.POSITIVE_INFINITY, repeatType: "reverse" }}
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-green-600 flex items-center justify-center text-white">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path
                      d="M12 8V12L15 15"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                    <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2" />
                  </svg>
                </div>
                <div>
                  <p className="text-sm font-medium">Medication Reminder</p>
                  <p className="text-xs text-muted-foreground">Take Insulin, 8:00 AM</p>
                </div>
              </div>
            </motion.div>
          </div>

          <div className="mt-8 flex justify-center gap-4">
            <Link
              href="#"
              className="flex items-center justify-center glassmorphism px-4 py-2 rounded-lg hover:shadow-glow-sm transition-all"
            >
              <span>Try Demo</span>
            </Link>
          </div>
        </motion.div>
      </div>
    </section>
  )
}
