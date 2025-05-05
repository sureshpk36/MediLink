"use client"

import Link from "next/link"
import { ArrowRight } from "lucide-react"
import { useEffect, useState, useRef } from "react"
import { motion, useInView } from "framer-motion"
import { Button } from "@/components/ui/button"

export default function Home() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })
  const [chartData, setChartData] = useState<{ x: number; y: number }[]>([])

  useEffect(() => {
    // Generate sample chart data
    const data = Array.from({ length: 20 }, (_, i) => ({
      x: i,
      y: Math.sin(i * 0.5) * 20 + 80 + Math.random() * 5,
    }))
    setChartData(data)
  }, [])

  return (
    <div className="min-h-screen overflow-x-hidden">
      <div className="container mx-auto px-4 py-12 md:py-20">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <motion.div
            className="space-y-6"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <div className="inline-flex items-center px-3 py-1 rounded-full bg-primary/10 text-primary text-sm">
              <svg className="w-4 h-4 mr-2" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 6V12L16 14" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="2" />
              </svg>
              Next-Gen Healthcare Technology
            </div>

            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-primary leading-tight">
              Precision Medicine.
              <br />
              Perfect Dosage.
            </h1>

            <p className="text-xl text-muted-foreground">AI-powered personalized medication management</p>

            <div className="flex flex-wrap gap-4">
              <Link href="/dosage-ai">
                <Button size="lg" className="group">
                  Try Dosage AI
                  <ArrowRight className="ml-2 h-5 w-5 transition-transform group-hover:translate-x-1" />
                </Button>
              </Link>

              <Link href="/demo">
                <Button size="lg" variant="outline">
                  Book a Demo
                </Button>
              </Link>
            </div>
          </motion.div>

          <motion.div
            ref={ref}
            className="card shadow-lg rounded-xl border bg-card text-card-foreground"
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            <div className="p-6">
              <div className="flex items-center gap-4 mb-6">
                <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center">
                  <svg
                    className="w-6 h-6 text-primary"
                    viewBox="0 0 24 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="M9 12L11 14L15 10"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                    <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="2" />
                  </svg>
                </div>
                <div>
                  <h2 className="text-xl font-bold">DosageAI Dashboard</h2>
                  <p className="text-sm text-muted-foreground">Patient: John D.</p>
                </div>
                <div className="ml-auto px-3 py-1 bg-primary/10 text-primary text-sm rounded-full">Optimized</div>
              </div>

              <div className="grid grid-cols-3 gap-4 mb-8">
                <div>
                  <p className="text-sm text-muted-foreground">Current Dose</p>
                  <p className="text-2xl font-bold text-primary">
                    125 <span className="text-sm font-normal">mg</span>
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Recommended</p>
                  <p className="text-2xl font-bold text-primary">
                    140 <span className="text-sm font-normal">mg</span>
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Efficacy</p>
                  <p className="text-2xl font-bold text-blue-600 dark:text-blue-400">
                    87 <span className="text-sm font-normal">%</span>
                  </p>
                </div>
              </div>

              <div className="h-40 bg-muted/30 rounded-lg flex items-center justify-center mb-6 overflow-hidden">
                <svg width="100%" height="100%" viewBox="0 0 400 160" preserveAspectRatio="none">
                  <defs>
                    <linearGradient id="chartGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="var(--primary)" stopOpacity="0.3" />
                      <stop offset="100%" stopColor="var(--primary)" stopOpacity="0" />
                    </linearGradient>
                  </defs>
                  {/* Chart line */}
                  <path
                    d={`M0,${160 - chartData[0]?.y || 80} ${chartData.map((point, i) => `L${(i * 400) / 19},${160 - point.y}`).join(" ")}`}
                    fill="none"
                    stroke="var(--primary)"
                    strokeWidth="2"
                  />
                  {/* Area under the line */}
                  <path
                    d={`M0,${160 - chartData[0]?.y || 80} ${chartData.map((point, i) => `L${(i * 400) / 19},${160 - point.y}`).join(" ")} L400,160 L0,160 Z`}
                    fill="url(#chartGradient)"
                  />
                  {/* Data points */}
                  {chartData.map((point, i) => (
                    <circle key={i} cx={(i * 400) / 19} cy={160 - point.y} r="3" fill="var(--primary)" />
                  ))}
                </svg>
              </div>

              <div className="flex items-center justify-between">
                <button className="text-muted-foreground hover:text-foreground transition-colors font-medium">
                  Patient History
                </button>
                <button className="px-4 py-2 bg-primary text-primary-foreground rounded-full text-sm hover:bg-primary/90 transition-colors">
                  Apply Recommendation
                </button>
              </div>
            </div>
          </motion.div>
        </div>
      </div>

      <div className="container mx-auto px-4 py-12 md:py-20">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          viewport={{ once: true, amount: 0.2 }}
          className="text-center mb-12"
        >
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            How <span className="text-primary">MediLink</span> Works
          </h2>
          <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
            Our AI-powered platform optimizes medication dosages for better patient outcomes
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {[
            {
              title: "Upload Medical Data",
              description: "Securely upload patient medical records, test results, and current medications",
              icon: (
                <svg className="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path
                    d="M21 15V19C21 19.5304 20.7893 20.0391 20.4142 20.4142C20.0391 20.7893 19.5304 21 19 21H5C4.46957 21 3.96086 20.7893 3.58579 20.4142C3.21071 20.0391 3 19.5304 3 19V15"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M7 10L12 15L17 10"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M12 15V3"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              ),
            },
            {
              title: "AI Analysis",
              description: "Our advanced algorithms analyze patient data to determine optimal medication dosages",
              icon: (
                <svg className="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path
                    d="M12 16C14.2091 16 16 14.2091 16 12C16 9.79086 14.2091 8 12 8C9.79086 8 8 9.79086 8 12C8 14.2091 9.79086 16 12 16Z"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M12 2V4"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M12 20V22"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M4.93 4.93L6.34 6.34"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M17.66 17.66L19.07 19.07"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M2 12H4"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M20 12H22"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M4.93 19.07L6.34 17.66"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <path
                    d="M17.66 6.34L19.07 4.93"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              ),
            },
            {
              title: "Personalized Recommendations",
              description: "Receive tailored dosage recommendations and medication schedules for optimal results",
              icon: (
                <svg className="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path
                    d="M9 12L11 14L15 10"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                  <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="2" />
                </svg>
              ),
            },
          ].map((step, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              viewport={{ once: true, amount: 0.2 }}
              className="bg-card border rounded-xl p-6 shadow-sm hover:shadow-md transition-shadow"
            >
              <div className="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center mb-4">
                {step.icon}
              </div>
              <h3 className="text-xl font-bold mb-2">{step.title}</h3>
              <p className="text-muted-foreground">{step.description}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </div>
  )
}
