"use client"

import { useRef } from "react"
import { motion, useInView } from "framer-motion"
import { CheckCircle2 } from "lucide-react"

const steps = [
  {
    title: "Sign Up",
    description: "Create your secure account with basic information and verify your identity",
    icon: CheckCircle2,
  },
  {
    title: "Complete Your Profile",
    description: "Add your medical history, current medications, and health concerns",
    icon: CheckCircle2,
  },
  {
    title: "Connect & Consult",
    description: "Find healthcare providers, book appointments, and get the care you need",
    icon: CheckCircle2,
  },
]

export default function HowItWorks() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })

  return (
    <section className="py-20 md:py-32 bg-muted/50">
      <div className="container mx-auto px-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5 }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            How <span className="text-gradient">MediLink</span> Works
          </h2>
          <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
            Get started with MediLink in three simple steps
          </p>
        </motion.div>

        <div ref={ref} className="relative">
          {/* Timeline line */}
          <div className="absolute top-0 bottom-0 left-1/2 w-0.5 bg-border -translate-x-1/2 hidden md:block" />

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {steps.map((step, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{ duration: 0.5, delay: index * 0.2 }}
                className="relative"
              >
                <div className="glassmorphism p-6 rounded-xl h-full">
                  <div className="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center mb-4">
                    <step.icon className="h-6 w-6 text-primary" />
                  </div>

                  <div className="absolute top-6 left-6 -ml-6 w-12 h-12 rounded-full bg-background border-4 border-primary flex items-center justify-center z-10 hidden md:flex">
                    <span className="font-bold">{index + 1}</span>
                  </div>

                  <h3 className="text-xl font-bold mb-2">{step.title}</h3>
                  <p className="text-muted-foreground">{step.description}</p>
                </div>

                {/* Glow effect on hover */}
                <div className="absolute inset-0 bg-primary/5 rounded-xl filter blur-xl opacity-0 transition-opacity duration-300 group-hover:opacity-100" />
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}
