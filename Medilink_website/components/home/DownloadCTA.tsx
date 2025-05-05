"use client"

import { useRef } from "react"
import { motion, useInView } from "framer-motion"
import Image from "next/image"
import Link from "next/link"
import { Button } from "@/components/ui/button"

export default function DownloadCTA() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })

  return (
    <section className="py-20 md:py-32 bg-muted/50">
      <div className="container mx-auto px-4">
        <div ref={ref} className="grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.5 }}
          >
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              Experience MediLink <span className="text-gradient">Today</span>
            </h2>
            <p className="text-xl text-muted-foreground mb-8">
              Try our interactive demo to see how MediLink can transform your healthcare experience.
            </p>

            <div className="flex flex-col sm:flex-row gap-4">
              <Link href="#">
                <Button size="lg" className="w-full sm:w-auto shadow-glow-sm hover:shadow-glow">
                  Try Demo
                </Button>
              </Link>
            </div>

            <div className="mt-8 flex items-center">
              <div className="flex">
                {[1, 2, 3, 4, 5].map((star) => (
                  <svg key={star} className="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-.181h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                ))}
              </div>
              <div className="ml-2">
                <span className="font-bold">4.9/5</span>
                <span className="text-muted-foreground ml-1">from 10,000+ reviews</span>
              </div>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="relative"
          >
            <div className="relative mx-auto w-full max-w-sm">
              <div className="absolute inset-0 bg-gradient-to-r from-green-light/20 to-green-dark/20 rounded-full filter blur-3xl" />
              <div className="glassmorphism rounded-3xl overflow-hidden shadow-glow-sm">
                <Image
                  src="/placeholder.svg?height=600&width=300&text=MediLink+App"
                  alt="MediLink Mobile App"
                  width={300}
                  height={600}
                  className="w-full"
                />
              </div>

              {/* Floating notification */}
              <motion.div
                className="absolute top-1/4 -right-16 glassmorphism p-3 rounded-lg shadow-glow-sm max-w-[180px]"
                animate={{ y: [0, -10, 0] }}
                transition={{ duration: 4, repeat: Number.POSITIVE_INFINITY, repeatType: "reverse" }}
              >
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
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
                    <p className="text-xs font-medium">Appointment Reminder</p>
                    <p className="text-xs text-muted-foreground">In 30 minutes</p>
                  </div>
                </div>
              </motion.div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}
