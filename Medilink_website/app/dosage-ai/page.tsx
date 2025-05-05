"use client"

import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { CheckCircle } from "lucide-react"
import { motion } from "framer-motion"

export default function DosageAI() {
  return (
    <div className="min-h-screen py-12">
      <div className="container mx-auto px-4">
        <motion.h1
          className="text-3xl font-bold text-primary mb-6"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          Dosage AI
        </motion.h1>

        <div className="max-w-4xl mx-auto">
          <motion.div
            className="mb-8"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
          >
            <Tabs defaultValue="recommendations">
              <TabsList className="w-full justify-start border-b bg-transparent">
                <TabsTrigger
                  value="diagnosis"
                  className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none"
                >
                  Diagnosis
                </TabsTrigger>
                <TabsTrigger
                  value="recommendations"
                  className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none"
                >
                  Recommendations
                </TabsTrigger>
                <TabsTrigger
                  value="side-effects"
                  className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none"
                >
                  Side Effects
                </TabsTrigger>
                <TabsTrigger
                  value="alternatives"
                  className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none"
                >
                  Alternatives
                </TabsTrigger>
                <TabsTrigger
                  value="lifestyle"
                  className="data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none"
                >
                  Lifestyle
                </TabsTrigger>
              </TabsList>

              <TabsContent value="recommendations" className="pt-6">
                <div className="bg-primary/5 rounded-lg p-6">
                  <div className="flex items-center gap-3 mb-6">
                    <CheckCircle className="h-6 w-6 text-primary" />
                    <h2 className="text-xl font-bold text-primary">Recommendations</h2>
                  </div>

                  <div className="space-y-6">
                    <div className="bg-card rounded-lg p-4 shadow-sm border">
                      <p className="text-foreground">
                        <span className="font-medium">dosage:</span> 1000 mg once daily after meals,
                        <span className="font-medium"> for:</span> Borderline F deficiency,
                        <br />
                        <span className="font-medium">medicine:</span> Omega-3 Fatty Acid Supplement
                      </p>
                    </div>

                    <div className="bg-card rounded-lg p-4 shadow-sm border">
                      <p className="text-foreground">
                        <span className="font-medium">dosage:</span> 1 sachet in 200ml water, twice daily,
                        <span className="font-medium"> for:</span> Dehydration indicated by pale yellow urine,
                        <br />
                        <span className="font-medium">medicine:</span> Electrolyte Hydration Sachets
                      </p>
                    </div>
                  </div>
                </div>
              </TabsContent>

              <TabsContent value="diagnosis">
                <div className="pt-6">
                  <p className="text-muted-foreground">Diagnosis information will appear here.</p>
                </div>
              </TabsContent>

              <TabsContent value="side-effects">
                <div className="pt-6">
                  <p className="text-muted-foreground">Side effects information will appear here.</p>
                </div>
              </TabsContent>

              <TabsContent value="alternatives">
                <div className="pt-6">
                  <p className="text-muted-foreground">Alternative medications will appear here.</p>
                </div>
              </TabsContent>

              <TabsContent value="lifestyle">
                <div className="pt-6">
                  <p className="text-muted-foreground">Lifestyle recommendations will appear here.</p>
                </div>
              </TabsContent>
            </Tabs>
          </motion.div>
        </div>
      </div>
    </div>
  )
}
