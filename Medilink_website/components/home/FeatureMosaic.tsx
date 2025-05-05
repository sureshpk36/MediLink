"use client"

import { useRef } from "react"
import { motion, useInView } from "framer-motion"
import Image from "next/image"
import Link from "next/link"
import { ArrowRight } from "lucide-react"
import { features } from "@/lib/data"

export default function FeatureMosaic() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })

  const containerVariants = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0, transition: { duration: 0.5 } },
  }

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
            Comprehensive Healthcare <span className="text-gradient">Features</span>
          </h2>
          <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
            Everything you need to manage your health journey in one secure platform
          </p>
        </motion.div>

        <motion.div
          ref={ref}
          variants={containerVariants}
          initial="hidden"
          animate={isInView ? "show" : "hidden"}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
        >
          {features.map((feature, index) => (
            <motion.div
              key={feature.slug}
              variants={itemVariants}
              className="group relative glassmorphism rounded-xl overflow-hidden h-[300px] transition-all duration-300 hover:shadow-glow-sm"
            >
              <div className="absolute inset-0 p-6 flex flex-col justify-between z-10 transition-all duration-500 group-hover:opacity-0">
                <div className="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center mb-4">
                  <feature.icon className="h-6 w-6 text-primary" />
                </div>
                <div>
                  <h3 className="text-xl font-bold mb-2">{feature.title}</h3>
                  <p className="text-muted-foreground">{feature.description}</p>
                </div>
              </div>

              <div className="absolute inset-0 p-6 flex flex-col justify-between opacity-0 transition-all duration-500 group-hover:opacity-100">
                <div>
                  <h3 className="text-xl font-bold mb-2">{feature.title}</h3>
                  <p className="text-muted-foreground mb-4">{feature.description}</p>
                  <ul className="space-y-2 mb-6">
                    {feature.benefits.slice(0, 3).map((benefit, i) => (
                      <li key={i} className="flex items-start">
                        <svg
                          className="h-5 w-5 text-primary mr-2 mt-0.5"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                        >
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
                        </svg>
                        <span className="text-sm">{benefit}</span>
                      </li>
                    ))}
                  </ul>
                </div>
                <Link
                  href={`/features/${feature.slug}`}
                  className="inline-flex items-center text-primary hover:underline"
                >
                  Learn more <ArrowRight className="ml-1 h-4 w-4" />
                </Link>
              </div>

              <div className="absolute inset-0 -z-10 opacity-20 group-hover:opacity-10 transition-opacity duration-500">
                <Image src={feature.image1 || "/placeholder.svg"} alt={feature.title} fill className="object-cover" />
              </div>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}
