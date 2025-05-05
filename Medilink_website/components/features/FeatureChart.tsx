"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import {
  LineChart,
  Line,
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts"
import type { Feature } from "@/lib/types"

const vitalSignsData = [
  { name: "Jan", heartRate: 72, bloodPressure: 120, temperature: 98.6 },
  { name: "Feb", heartRate: 74, bloodPressure: 122, temperature: 98.4 },
  { name: "Mar", heartRate: 73, bloodPressure: 119, temperature: 98.7 },
  { name: "Apr", heartRate: 75, bloodPressure: 121, temperature: 98.5 },
  { name: "May", heartRate: 71, bloodPressure: 118, temperature: 98.8 },
  { name: "Jun", heartRate: 73, bloodPressure: 120, temperature: 98.6 },
]

const medicationData = [
  { name: "Mon", adherence: 100 },
  { name: "Tue", adherence: 100 },
  { name: "Wed", adherence: 75 },
  { name: "Thu", adherence: 100 },
  { name: "Fri", adherence: 100 },
  { name: "Sat", adherence: 50 },
  { name: "Sun", adherence: 100 },
]

const appointmentData = [
  { name: "Jan", completed: 4, scheduled: 5 },
  { name: "Feb", completed: 3, scheduled: 3 },
  { name: "Mar", completed: 5, scheduled: 6 },
  { name: "Apr", completed: 4, scheduled: 4 },
  { name: "May", completed: 3, scheduled: 5 },
  { name: "Jun", completed: 6, scheduled: 6 },
]

export function FeatureChart({ feature }: { feature: Feature }) {
  const [activeIndex, setActiveIndex] = useState(0)

  const renderChart = () => {
    switch (feature.slug) {
      case "telemedicine":
        return (
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={appointmentData}>
              <defs>
                <linearGradient id="colorCompleted" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--green-light))" stopOpacity={0.8} />
                  <stop offset="95%" stopColor="hsl(var(--green-light))" stopOpacity={0} />
                </linearGradient>
                <linearGradient id="colorScheduled" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--green-dark))" stopOpacity={0.8} />
                  <stop offset="95%" stopColor="hsl(var(--green-dark))" stopOpacity={0} />
                </linearGradient>
              </defs>
              <XAxis dataKey="name" />
              <YAxis />
              <CartesianGrid strokeDasharray="3 3" />
              <Tooltip />
              <Area
                type="monotone"
                dataKey="completed"
                stroke="hsl(var(--green-light))"
                fillOpacity={1}
                fill="url(#colorCompleted)"
              />
              <Area
                type="monotone"
                dataKey="scheduled"
                stroke="hsl(var(--green-dark))"
                fillOpacity={1}
                fill="url(#colorScheduled)"
              />
            </AreaChart>
          </ResponsiveContainer>
        )
      case "health-records":
        return (
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={vitalSignsData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="heartRate" stroke="hsl(var(--green-light))" activeDot={{ r: 8 }} />
              <Line type="monotone" dataKey="bloodPressure" stroke="hsl(var(--green-medium))" />
              <Line type="monotone" dataKey="temperature" stroke="hsl(var(--green-dark))" />
            </LineChart>
          </ResponsiveContainer>
        )
      case "medication-tracking":
        return (
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={medicationData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="adherence" fill="hsl(var(--green-medium))" />
            </BarChart>
          </ResponsiveContainer>
        )
      default:
        return (
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={vitalSignsData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="heartRate" stroke="hsl(var(--green-medium))" activeDot={{ r: 8 }} />
            </LineChart>
          </ResponsiveContainer>
        )
    }
  }

  return (
    <div className="p-4">
      <div className="flex justify-between items-center mb-6">
        <h3 className="text-lg font-bold">{feature.title} Analytics</h3>
        <div className="flex space-x-2">
          {["Day", "Week", "Month", "Year"].map((period, index) => (
            <button
              key={index}
              onClick={() => setActiveIndex(index)}
              className={`px-3 py-1 text-sm rounded-md transition-colors ${
                activeIndex === index
                  ? "bg-primary text-primary-foreground"
                  : "bg-muted text-muted-foreground hover:bg-muted/80"
              }`}
            >
              {period}
            </button>
          ))}
        </div>
      </div>

      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.5 }}>
        {renderChart()}
      </motion.div>
    </div>
  )
}
