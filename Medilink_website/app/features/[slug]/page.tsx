import type { Metadata } from "next"
import { notFound } from "next/navigation"
import Image from "next/image"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { features } from "@/lib/data"
import { FeatureChart } from "@/components/features/FeatureChart"

type Props = {
  params: { slug: string }
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const feature = features.find((f) => f.slug === params.slug)

  if (!feature) {
    return {
      title: "Feature Not Found | MediLink",
    }
  }

  return {
    title: `${feature.title} | MediLink Features`,
    description: feature.description,
  }
}

export async function generateStaticParams() {
  return features.map((feature) => ({
    slug: feature.slug,
  }))
}

export default function FeaturePage({ params }: Props) {
  const feature = features.find((f) => f.slug === params.slug)

  if (!feature) {
    notFound()
  }

  return (
    <div className="relative">
      {/* Hero Banner */}
      <div className="relative h-[40vh] w-full overflow-hidden">
        <Image
          src={feature.bannerImage || "/placeholder.svg"}
          alt={feature.title}
          fill
          className="object-cover"
          priority
        />
        <div className="absolute inset-0 bg-gradient-to-r from-primary/80 to-secondary/80 mix-blend-multiply" />
        <div className="absolute inset-0 flex items-center justify-center">
          <h1 className="font-display text-4xl md:text-6xl font-bold text-white text-center">{feature.title}</h1>
        </div>
      </div>

      {/* Content */}
      <div className="container mx-auto px-4 py-16">
        <p className="text-xl text-center max-w-3xl mx-auto mb-12 text-muted-foreground">{feature.description}</p>

        <Tabs defaultValue="overview" className="w-full max-w-4xl mx-auto">
          <TabsList className="grid w-full grid-cols-3 glassmorphism mb-8">
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="benefits">Benefits</TabsTrigger>
            <TabsTrigger value="demo">Interactive Demo</TabsTrigger>
          </TabsList>
          <TabsContent value="overview" className="glassmorphism p-6 rounded-xl">
            <div className="prose prose-lg dark:prose-invert max-w-none">
              <h2>About {feature.title}</h2>
              <p>{feature.overview}</p>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mt-8">
                <Image
                  src={feature.image1 || "/placeholder.svg"}
                  alt={`${feature.title} screenshot 1`}
                  width={500}
                  height={300}
                  className="rounded-lg shadow-glow"
                />
                <Image
                  src={feature.image2 || "/placeholder.svg"}
                  alt={`${feature.title} screenshot 2`}
                  width={500}
                  height={300}
                  className="rounded-lg shadow-glow"
                />
              </div>
            </div>
          </TabsContent>
          <TabsContent value="benefits" className="glassmorphism p-6 rounded-xl">
            <div className="prose prose-lg dark:prose-invert max-w-none">
              <h2>Key Benefits</h2>
              <ul>
                {feature.benefits.map((benefit, index) => (
                  <li key={index}>{benefit}</li>
                ))}
              </ul>
            </div>
          </TabsContent>
          <TabsContent value="demo" className="glassmorphism p-6 rounded-xl">
            <h2 className="text-2xl font-display font-bold mb-6">Interactive Demo</h2>
            <div className="aspect-video relative bg-muted rounded-lg overflow-hidden">
              <FeatureChart feature={feature} />
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
