"use client"

import { Pill, Filter, ChevronRight, AlertCircle, Clock, Link2, Search, Loader2 } from "lucide-react"
import { useState, useEffect } from "react"
import { motion } from "framer-motion"

// FastAPI backend URL - you might want to put this in an environment variable
const BACKEND_URL = "http://localhost:8000";

interface Drug {
  _id: string;
  link: string;
  title: string;
  price: string;
  meta: string;
  desc: string;
  detail: string;
  sideEffect: string;
}

export default function DrugDB() {
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedMed, setSelectedMed] = useState<Drug | null>(null)
  const [medications, setMedications] = useState<Drug[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const [totalDrugs, setTotalDrugs] = useState(0)

  // Fetch drugs from the FastAPI backend
  useEffect(() => {
    const fetchDrugs = async () => {
      try {
        setLoading(true)
        // Use FastAPI endpoint with query parameters
        const res = await fetch(`${BACKEND_URL}/drugs?search=${encodeURIComponent(searchTerm)}&limit=20`)
        
        if (!res.ok) {
          throw new Error('Failed to fetch drugs')
        }
        
        const data = await res.json()
        setMedications(data.drugs)
        setTotalDrugs(data.total)
        
        // Select the first drug if none is selected
        if (data.drugs.length > 0 && !selectedMed) {
          setSelectedMed(data.drugs[0])
        }
      } catch (err) {
        console.error('Error fetching drugs:', err)
        setError("Failed to load medications. Please try again.")
      } finally {
        setLoading(false)
      }
    }

    // Debounce search to avoid too many requests
    const timer = setTimeout(() => {
      fetchDrugs()
    }, 300)

    return () => clearTimeout(timer)
  }, [searchTerm])

  // Filter medications based on search term
  const filteredMeds = medications

  // Function to format side effects as a list
  const formatSideEffects = (sideEffects: string) => {
    if (!sideEffects) return ["No side effects listed"]
    
    // If it's already a well-formatted list, return as is
    if (sideEffects.includes('\n')) {
      return sideEffects.split('\n').filter(item => item.trim() !== '')
    }
    
    // Otherwise, try to split by commas or periods
    return sideEffects.split(/[,.]+/).filter(item => item.trim() !== '')
  }

  return (
    <div className="min-h-screen py-12">
      <div className="container mx-auto px-4">
        <motion.div
          className="mb-8"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <h1 className="text-3xl font-bold text-primary mb-2">Drug Database</h1>
          <p className="text-muted-foreground">
            Comprehensive information on medications and AI-optimized dosage recommendations
          </p>
        </motion.div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <motion.div
            className="lg:col-span-1"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
          >
            <div className="mb-4">
              <div className="relative">
                <input
                  type="text"
                  placeholder="Search medications..."
                  className="w-full px-4 py-3 rounded-lg border border-input bg-background focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary pl-10"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
                <Search
                  className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground"
                />
              </div>
            </div>

            <div className="flex gap-2 mb-4">
              <button className="px-4 py-2 bg-primary/10 text-primary rounded-full text-sm font-medium">
                All Medications
              </button>
              <button className="px-4 py-2 bg-background border border-input rounded-full text-sm font-medium text-muted-foreground hover:bg-muted/50 transition-colors">
                Favorites
              </button>
            </div>

            <div className="flex justify-between items-center mb-4">
              <p className="text-sm text-muted-foreground">{totalDrugs} medications found</p>
              <button className="flex items-center gap-1 text-sm text-foreground hover:text-primary transition-colors">
                <Filter className="h-4 w-4" />
                Filter
              </button>
            </div>

            <div className="space-y-2 max-h-[400px] overflow-y-auto pr-2 scrollbar-thin">
              {loading ? (
                <div className="flex justify-center items-center py-8">
                  <Loader2 className="h-8 w-8 animate-spin text-primary" />
                </div>
              ) : error ? (
                <div className="text-center py-4 text-red-500">{error}</div>
              ) : filteredMeds.length > 0 ? (
                filteredMeds.map((med) => (
                  <div
                    key={med._id}
                    className={`flex items-center justify-between p-3 rounded-lg cursor-pointer transition-colors ${
                      selectedMed?._id === med._id
                        ? "bg-primary/10 border border-primary/20"
                        : "bg-card border border-input hover:bg-muted/50"
                    }`}
                    onClick={() => setSelectedMed(med)}
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center">
                        <Pill className="h-4 w-4 text-primary" />
                      </div>
                      <span>{med.title}</span>
                    </div>
                    <ChevronRight className="h-4 w-4 text-muted-foreground" />
                  </div>
                ))
              ) : (
                <p className="text-center py-4 text-muted-foreground">No medications found</p>
              )}
            </div>
          </motion.div>

          <motion.div
            className="lg:col-span-2"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            {selectedMed ? (
              <>
                <div className="mb-6 flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center">
                    <Pill className="h-6 w-6 text-primary" />
                  </div>
                  <div>
                    <h2 className="text-2xl font-bold">{selectedMed.title}</h2>
                    <p className="text-muted-foreground">{selectedMed.meta}</p>
                  </div>
                </div>

                <h3 className="text-xl font-bold mb-4">Overview</h3>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                  <div className="bg-card border rounded-lg p-6">
                    <div className="flex items-center gap-2 text-primary mb-4">
                      <Clock className="h-5 w-5" />
                      <h4 className="font-bold">Dosage Information</h4>
                    </div>

                    <div className="space-y-2">
                      <div>
                        <p className="text-sm text-muted-foreground">Form:</p>
                        <p className="text-foreground">
                          {selectedMed.title.split(" ").pop() || "Tablet"}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-muted-foreground">Details:</p>
                        <p className="text-foreground line-clamp-3">{selectedMed.detail || "No details available"}</p>
                        {selectedMed.link && selectedMed.detail && (
                          <a href={selectedMed.link} target="_blank" rel="noopener noreferrer" className="text-primary text-sm hover:underline">
                            Read more
                          </a>
                        )}
                      </div>
                      <div>
                        <p className="text-sm text-muted-foreground">Price:</p>
                        <p className="text-foreground">{selectedMed.price || "Price not available"}</p>
                      </div>
                    </div>
                  </div>

                  <div className="bg-card border rounded-lg p-6">
                    <div className="flex items-center gap-2 text-amber-600 dark:text-amber-400 mb-4">
                      <AlertCircle className="h-5 w-5" />
                      <h4 className="font-bold">Description</h4>
                    </div>

                    <p className="text-foreground line-clamp-6">
                      {selectedMed.desc || "No description available"}
                    </p>
                    {selectedMed.link && selectedMed.desc && (
                      <a href={selectedMed.link} target="_blank" rel="noopener noreferrer" className="text-primary text-sm hover:underline mt-1">
                        Read more
                      </a>
                    )}
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="bg-card border rounded-lg p-6">
                    <div className="flex items-center gap-2 text-primary mb-4">
                      <AlertCircle className="h-5 w-5" />
                      <h4 className="font-bold">Side Effects</h4>
                    </div>

                    <ul className="list-disc list-inside text-foreground">
                      {formatSideEffects(selectedMed.sideEffect).slice(0, 3).map((effect, idx) => (
                        <li key={idx}>{effect.trim()|| "No side effects listed"}</li>
                      ))}
                    </ul>
                    {selectedMed.link && formatSideEffects(selectedMed.sideEffect).length > 3 && (
                      <a href={selectedMed.link} target="_blank" rel="noopener noreferrer" className="text-primary text-sm hover:underline mt-2 block">
                        Read more
                      </a>
                    )}
                  </div>

                  <div className="bg-card border rounded-lg p-6">
                    <div className="flex items-center gap-2 text-amber-600 dark:text-amber-400 mb-4">
                      <Link2 className="h-5 w-5" />
                      <h4 className="font-bold">More Information</h4>
                    </div>

                    {selectedMed.link ? (
                      <a 
                        href={selectedMed.link} 
                        target="_blank" 
                        rel="noopener noreferrer"
                        className="text-primary hover:underline flex items-center gap-2"
                      >
                        Visit product page <ChevronRight className="h-4 w-4" />
                      </a>
                    ) : (
                      <p className="text-foreground">No additional information available</p>
                    )}
                  </div>
                </div>
              </>
            ) : loading ? (
              <div className="flex justify-center items-center h-full">
                <Loader2 className="h-12 w-12 animate-spin text-primary" />
              </div>
            ) : (
              <div className="flex justify-center items-center h-full text-muted-foreground">
                Select a medication to view details
              </div>
            )}
          </motion.div>
        </div>
      </div>
    </div>
  )
}
