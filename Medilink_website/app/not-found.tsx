"use client"

import { motion } from "framer-motion"
import Link from "next/link"
import { Button } from "@/components/ui/button"

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[70vh] px-4 text-center">
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.5 }} className="relative">
        <motion.h1
          className="font-display text-8xl md:text-9xl font-bold text-primary"
          animate={{
            x: [0, -10, 10, -10, 10, 0],
            filter: ["blur(0px)", "blur(4px)", "blur(0px)"],
          }}
          transition={{
            duration: 1.5,
            repeat: Number.POSITIVE_INFINITY,
            repeatType: "reverse",
            repeatDelay: 5,
          }}
        >
          404
        </motion.h1>
        <div className="absolute inset-0 bg-primary/20 blur-3xl -z-10 opacity-50" />
      </motion.div>

      <motion.h2
        className="mt-6 text-2xl md:text-3xl font-display font-bold"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2, duration: 0.5 }}
      >
        Page Not Found
      </motion.h2>

      <motion.p
        className="mt-4 text-muted-foreground max-w-md"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4, duration: 0.5 }}
      >
        The page you're looking for doesn't exist or has been moved.
      </motion.p>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6, duration: 0.5 }}
        className="mt-8"
      >
        <Link href="/">
          <Button className="shadow-glow-sm hover:shadow-glow">Return to Home</Button>
        </Link>
      </motion.div>
    </div>
  )
}
