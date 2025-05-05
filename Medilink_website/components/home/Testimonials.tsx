"use client"

import { useRef } from "react"
import { motion, useInView } from "framer-motion"
import Image from "next/image"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { ArrowRight, Quote } from "lucide-react"
import { testimonials } from "@/lib/data"

export default function Testimonials() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })

  return (
    <section className="py-20 md:py-32">
      <div className="container mx-auto px-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5 }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            What Our <span className="text-gradient">Users</span> Say
          </h2>
          <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
            Hear from patients and healthcare providers across India
          </p>
        </motion.div>

        <div ref={ref} className="relative overflow-hidden">
          <div className="flex overflow-x-auto pb-8 -mx-4 px-4 space-x-6 no-scrollbar">
            {testimonials.slice(0, 5).map((testimonial, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, x: 50 }}
                animate={isInView ? { opacity: 1, x: 0 } : {}}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="glassmorphism p-6 rounded-xl min-w-[300px] md:min-w-[350px] flex-shrink-0 transition-all duration-300 hover:shadow-glow-sm"
              >
                <Quote className="h-8 w-8 text-primary/50 mb-4" />

                <p className="italic mb-6">{testimonial.quote}</p>

                <div className="flex items-center">
                  <Image
                    src={testimonial.avatar || "/placeholder.svg"}
                    alt={testimonial.name}
                    width={50}
                    height={50}
                    className="rounded-full border-2 border-primary"
                  />
                  <div className="ml-4">
                    <h3 className="font-bold">{testimonial.name}</h3>
                    <p className="text-sm text-muted-foreground">{testimonial.location}</p>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>

          <div className="absolute top-0 right-0 bottom-0 w-24 bg-gradient-to-l from-background to-transparent" />
        </div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.5 }}
          className="flex justify-center mt-8"
        >
          <Link href="/testimonials">
            <Button variant="outline" className="group">
              View All Testimonials
              <ArrowRight className="ml-2 h-4 w-4 transition-transform group-hover:translate-x-1" />
            </Button>
          </Link>
        </motion.div>
      </div>
    </section>
  )
}
