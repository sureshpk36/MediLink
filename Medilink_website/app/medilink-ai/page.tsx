"use client";

import React from "react";
import {
  Stethoscope,
  Upload,
  FileText,
  FlaskConical,
  Pill,
  AlertCircle,
  ChevronDown,
  ChevronUp,
  Calendar,
  Clock,
  User,
  ArrowRight,
  Hourglass,
  FileType,
  File,
  AlertTriangle,
  MessageSquare,
  Search,
  LayoutDashboard,
  Settings,
  History,
  LogOut,
  PanelLeft,
  PanelRight,
  X,
  Download,
  BarChart,
  NotebookPen,
  Brain,
  Apple,
  Activity,
  PanelLeftClose,
  Heart,
  ChevronRight,
  Coffee,
  Utensils,
} from "lucide-react";
import { useState, useRef, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { saveAs } from "file-saver";
import { PDFDocument, rgb } from "pdf-lib";
import Chart from "chart.js/auto";

// Add structured data type definitions to match backend schemas
interface TestResult {
  test_name: string;
  value?: string;
  reference_range?: string;
  status: "NORMAL" | "HIGH" | "LOW" | "UNKNOWN";
  interpretation?: string;
  severity?: "MILD" | "MODERATE" | "SEVERE";
}

interface AbnormalValue {
  test_name: string;
  value?: string;
  reference_range?: string;
  status: "HIGH" | "LOW";
  concerns?: string;
  severity?: "MILD" | "MODERATE" | "SEVERE";
}

// New interfaces for enhanced features
interface RecommendedSupplement {
  name: string;
  dosage: string;
  is_prescription: boolean;
  reason: string;
  warnings?: string;
}

interface LifestyleRecommendation {
  category: "DIET" | "EXERCISE" | "SLEEP" | "OTHER";
  recommendations: string[];
}

interface FollowUpTest {
  test_name: string;
  timeline: string;
  reason: string;
}

interface DoctorQuestion {
  question: string;
  related_to: string;
}

interface ReportTag {
  name: string;
  category: string;
}

// Enhanced lab report data with new fields
interface LabReportData {
  summary: string;
  test_results: TestResult[];
  abnormal_values?: AbnormalValue[];
  interpretation?: string;

  // New fields for enhanced features
  recommended_supplements?: RecommendedSupplement[];
  lifestyle_recommendations?: LifestyleRecommendation[];
  follow_up_tests?: FollowUpTest[];
  doctor_questions?: DoctorQuestion[];
  report_tags?: ReportTag[];
}

interface Medication {
  name: string;
  dosage?: string;
  form?: string;
  frequency?: string;
  duration?: string;
  instructions?: string;
}

interface PrescriptionDetails {
  date?: string;
  prescribed_by?: string;
  refills?: string;
}

interface PrescriptionData {
  summary: string;
  medications: Medication[];
  general_instructions?: string[];
  warnings?: string[];
  prescription_details?: PrescriptionDetails;

  // New fields
  lifestyle_recommendations?: LifestyleRecommendation[];
  doctor_questions?: DoctorQuestion[];
  report_tags?: ReportTag[];
}

export default function MedilinkAI() {
  const [message, setMessage] = useState("");
  const [chatHistory, setChatHistory] = useState<
    { role: "user" | "assistant"; content: string }[]
  >([]);
  const [isLoading, setIsLoading] = useState(false);
  const [uploadedFile, setUploadedFile] = useState<File | null>(null);
  const [fileName, setFileName] = useState("");
  const [extractedText, setExtractedText] = useState("");
  const [sessionId, setSessionId] = useState("");
  const [isProcessing, setIsProcessing] = useState(false);
  const [reportType, setReportType] = useState<
    "prescription" | "lab" | "other" | null
  >(null);
  const [selectedDocType, setSelectedDocType] = useState<
    "lab_report" | "prescription"
  >("lab_report");
  const [reportData, setReportData] = useState<any>(null);
  const [expandedSections, setExpandedSections] = useState<string[]>([
    "summary",
  ]);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const chatContainerRef = useRef<HTMLDivElement>(null);
  const [fileError, setFileError] = useState<string | null>(null);
  const [fileProcessing, setFileProcessing] = useState<{
    status: "idle" | "loading" | "success" | "error";
    message: string;
  }>({ status: "idle", message: "" });
  const [initialAnalysis, setInitialAnalysis] = useState<string>("");
  const [previousChats, setPreviousChats] = useState([
    {
      id: "1",
      type: "prescription",
      title: "Lisinopril Prescription",
      date: "Today",
    },
    {
      id: "2",
      type: "lab",
      title: "Blood Work Results",
      date: "Yesterday",
    },
    {
      id: "3",
      type: "other",
      title: "Hospital Discharge Report",
      date: "Sep 30, 2023",
    },
  ]);

  // New state variables for enhanced features
  const [canGeneratePdf, setCanGeneratePdf] = useState(false);
  const [isGeneratingPdf, setIsGeneratingPdf] = useState(false);
  const chartRef = useRef<HTMLCanvasElement>(null);
  const [reportHistory, setReportHistory] = useState<any[]>([]);
  const [showTrends, setShowTrends] = useState(false);

  useEffect(() => {
    if (chatContainerRef.current) {
      chatContainerRef.current.scrollTop =
        chatContainerRef.current.scrollHeight;
    }
  }, [chatHistory]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFileError(null);

    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      const fileSize = file.size / (1024 * 1024); // Convert to MB

      // Check file size (limit to 10MB)
      if (fileSize > 10) {
        setFileError(
          "File is too large. Please upload a file smaller than 10MB."
        );
        return;
      }

      // Check file type
      const validTypes = [
        "image/jpeg",
        "image/jpg",
        "image/png",
        "image/bmp",
        "image/tiff",
        "image/webp",
        "application/pdf",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      ];

      if (!validTypes.includes(file.type)) {
        setFileError(
          "Invalid file type. Please upload an image (JPG, PNG, BMP, TIFF, WebP), PDF, or DOCX file."
        );
        return;
      }

      setUploadedFile(file);
      setFileName(file.name);
    }
  };

  const handleUploadClick = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  const toggleSection = (section: string) => {
    if (expandedSections.includes(section)) {
      setExpandedSections(expandedSections.filter((s) => s !== section));
    } else {
      setExpandedSections([...expandedSections, section]);
    }
  };

  const handleUploadSubmit = async () => {
    if (!uploadedFile) return;

    setIsProcessing(true);
    setChatHistory([]);
    setReportData(null);
    setReportType(null);
    setExpandedSections(["summary"]);
    setFileProcessing({
      status: "loading",
      message: "Processing your document...",
    });

    try {
      const formData = new FormData();
      formData.append("file", uploadedFile);
      formData.append("document_type", selectedDocType);

      setFileProcessing({
        status: "loading",
        message: `Extracting text from ${
          uploadedFile.type.includes("image")
            ? "image"
            : uploadedFile.type.includes("pdf")
            ? "PDF document"
            : "document"
        }...`,
      });

      const response = await fetch("http://localhost:8000/extract_text/", {
        method: "POST",
        body: formData,
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || "Failed to process document");
      }

      const data = await response.json();

      setSessionId(data.session_id);
      setExtractedText(data.extracted_text);

      const reportType =
        data.document_type === "prescription"
          ? "prescription"
          : data.document_type === "lab_report"
          ? "lab"
          : "other";
      setReportType(reportType);

      // Store the initial analysis but don't add it to chat history
      setInitialAnalysis(data.initial_analysis);

      // Use structured data when available from backend
      if (data.structured_data) {
        setReportData(data.structured_data);
        // Expand relevant sections based on data availability
        const sectionsToExpand = ["summary"];
        if (
          reportType === "prescription" &&
          data.structured_data.medications?.length > 0
        ) {
          sectionsToExpand.push("medications");
        }
        if (
          reportType === "prescription" &&
          data.structured_data.general_instructions?.length > 0
        ) {
          sectionsToExpand.push("instructions");
        }
        if (
          reportType === "prescription" &&
          data.structured_data.warnings?.length > 0
        ) {
          sectionsToExpand.push("warnings");
        }
        if (
          reportType === "lab" &&
          data.structured_data.test_results?.length > 0
        ) {
          sectionsToExpand.push("tests");
        }
        if (
          reportType === "lab" &&
          data.structured_data.abnormal_values?.length > 0
        ) {
          sectionsToExpand.push("abnormal");
        }
        if (reportType === "lab" && data.structured_data.interpretation) {
          sectionsToExpand.push("interpretation");
        }
        setExpandedSections(sectionsToExpand);
      } else {
        // Fallback to existing extraction methods if structured data is not available
        if (reportType === "prescription") {
          setReportData({
            summary: extractSummary(data.initial_analysis),
            medications: extractMedications(data.initial_analysis).map(
              (text) => ({ name: text })
            ),
            general_instructions: extractInstructions(data.initial_analysis),
            prescription_details: extractPrescriptionDetails(
              data.initial_analysis
            ),
          });
        } else if (reportType === "lab") {
          setReportData({
            summary: extractSummary(data.initial_analysis),
            test_results: extractTestResults(data.initial_analysis).map(
              (text) => ({
                test_name: text,
                status:
                  /abnormal|elevated|high|low|outside|above|below|critical/i.test(
                    text
                  )
                    ? "ABNORMAL"
                    : "NORMAL",
              })
            ),
            abnormal_values: extractAbnormalValues(data.initial_analysis).map(
              (text) => ({
                test_name: text,
                status: /high|elevated|above|excess/i.test(text)
                  ? "HIGH"
                  : "LOW",
              })
            ),
          });
        } else {
          setReportData({
            content: data.initial_analysis,
          });
        }
      }

      // Don't add initial analysis to chat history
      // Instead show a welcome message to encourage user questions
      setChatHistory([
        {
          role: "assistant",
          content:
            "I've analyzed your document. What would you like to know about it?",
        },
      ]);

      setFileProcessing({
        status: "success",
        message: "Document processed successfully!",
      });
      setTimeout(
        () => setFileProcessing({ status: "idle", message: "" }),
        2000
      );

      // After successful processing, enable PDF generation
      if (data.structured_data) {
        setCanGeneratePdf(true);
      }
    } catch (error: any) {
      console.error("Error:", error);
      setChatHistory([
        {
          role: "assistant",
          content: `Sorry, there was an error processing your document: ${error.message}`,
        },
      ]);
      setFileProcessing({
        status: "error",
        message: error.message || "Error processing document",
      });
      setTimeout(
        () => setFileProcessing({ status: "idle", message: "" }),
        3000
      );
    } finally {
      setIsProcessing(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message.trim() || !sessionId) return;

    const newMessage = { role: "user" as const, content: message };
    setChatHistory([...chatHistory, newMessage]);
    setMessage("");
    setIsLoading(true);

    try {
      const response = await fetch(`http://localhost:8000/chat/${sessionId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ message }),
      });

      if (!response.ok) {
        throw new Error("Failed to get response");
      }

      const data = await response.json();

      setChatHistory((prev) => [
        ...prev,
        { role: "assistant", content: data.response },
      ]);
    } catch (error) {
      console.error("Error:", error);
      setChatHistory((prev) => [
        ...prev,
        {
          role: "assistant",
          content: "Sorry, I couldn't process your request. Please try again.",
        },
      ]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleGeneratePDF = async () => {
    if (!reportData) return;

    setIsGeneratingPdf(true);

    try {
      const pdfDoc = await PDFDocument.create();
      const page = pdfDoc.addPage([612, 792]);

      // Add content to PDF based on reportType and reportData
      const { width, height } = page.getSize();

      // Add header
      page.drawText("MediLink AI Report Summary", {
        x: 50,
        y: height - 50,
        size: 24,
        color: rgb(0, 0, 0.7),
      });

      // Add report type
      page.drawText(
        reportType === "lab"
          ? "Lab Report Analysis"
          : reportType === "prescription"
          ? "Prescription Analysis"
          : "Medical Document Analysis",
        {
          x: 50,
          y: height - 80,
          size: 16,
          color: rgb(0.3, 0.3, 0.3),
        }
      );

      // Add summary
      page.drawText("Summary:", {
        x: 50,
        y: height - 120,
        size: 14,
        color: rgb(0, 0, 0),
      });

      page.drawText(
        reportData.summary?.substring(0, 300) || "No summary available",
        {
          x: 50,
          y: height - 140,
          size: 12,
          color: rgb(0.3, 0.3, 0.3),
        }
      );

      // Add abnormal values for lab reports
      let yPosition = height - 190;

      if (reportType === "lab" && reportData.abnormal_values?.length) {
        page.drawText("Key Abnormal Findings:", {
          x: 50,
          y: yPosition,
          size: 14,
          color: rgb(0.8, 0.2, 0.2),
        });

        yPosition -= 25;

        reportData.abnormal_values
          .slice(0, 5)
          .forEach((item: AbnormalValue) => {
            page.drawText(
              `• ${item.test_name}: ${item.value || ""} (${item.status})`,
              {
                x: 50,
                y: yPosition,
                size: 12,
                color: rgb(0.3, 0.3, 0.3),
              }
            );

            yPosition -= 20;
          });

        yPosition -= 20;
      }

      // Add medications for prescriptions
      if (reportType === "prescription" && reportData.medications?.length) {
        page.drawText("Medications:", {
          x: 50,
          y: yPosition,
          size: 14,
          color: rgb(0, 0.4, 0.8),
        });

        yPosition -= 25;

        reportData.medications.slice(0, 5).forEach((item: Medication) => {
          page.drawText(`• ${item.name} ${item.dosage || ""}`, {
            x: 50,
            y: yPosition,
            size: 12,
            color: rgb(0.3, 0.3, 0.3),
          });

          yPosition -= 20;
        });

        yPosition -= 20;
      }

      // Add recommended supplements if available
      if (reportData.recommended_supplements?.length) {
        page.drawText("Recommended Supplements:", {
          x: 50,
          y: yPosition,
          size: 14,
          color: rgb(0, 0.6, 0.3),
        });

        yPosition -= 25;

        reportData.recommended_supplements
          .slice(0, 3)
          .forEach((item: RecommendedSupplement) => {
            page.drawText(`• ${item.name}: ${item.dosage}`, {
              x: 50,
              y: yPosition,
              size: 12,
              color: rgb(0.3, 0.3, 0.3),
            });

            yPosition -= 20;
          });

        yPosition -= 20;
      }

      // Add lifestyle recommendations if available
      if (reportData.lifestyle_recommendations?.length) {
        page.drawText("Lifestyle & Diet Recommendations:", {
          x: 50,
          y: yPosition,
          size: 14,
          color: rgb(0.6, 0.4, 0),
        });

        yPosition -= 25;

        reportData.lifestyle_recommendations
          .slice(0, 3)
          .forEach((category: LifestyleRecommendation) => {
            category.recommendations.slice(0, 2).forEach((rec: string) => {
              page.drawText(`• ${rec}`, {
                x: 50,
                y: yPosition,
                size: 12,
                color: rgb(0.3, 0.3, 0.3),
              });

              yPosition -= 20;
            });
          });
      }

      // Add footer
      page.drawText(
        "Generated by MediLink AI - For informational purposes only",
        {
          x: 50,
          y: 40,
          size: 10,
          color: rgb(0.5, 0.5, 0.5),
        }
      );

      // Save the PDF
      const pdfBytes = await pdfDoc.save();
      const blob = new Blob([pdfBytes], { type: "application/pdf" });
      saveAs(blob, "MediLink-Report-Summary.pdf");
    } catch (error) {
      console.error("Error generating PDF:", error);
    } finally {
      setIsGeneratingPdf(false);
    }
  };

  const formatAIResponse = (content: string) => {
    let processedContent = content
      .replace(
        /^#+\s*(.*?):\s*$/gim,
        '<span class="font-semibold text-lg">$1:</span>'
      )
      .replace(/^[\*\-]+\*?\*?\s*/gim, "• ")
      .replace(/\*\*/g, "");

    processedContent = processedContent
      .replace(
        /^(.*test results:.*)/im,
        '<span class="text-amber-600 font-medium">$1</span>'
      )
      .replace(
        /^(.*medications?:.*)/im,
        '<span class="text-blue-600 font-medium">$1</span>'
      )
      .replace(
        /^(.*abnormal values:.*)/im,
        '<span class="text-red-600 font-medium">$1</span>'
      )
      .replace(
        /^(.*summary:.*)/im,
        '<span class="text-green-600 font-medium">$1</span>'
      )
      .replace(
        /^(.*instructions:.*)/im,
        '<span class="text-purple-600 font-medium">$1</span>'
      )
      .replace(
        /^(.*warnings?:.*)/im,
        '<span class="text-orange-600 font-medium">$1</span>'
      )
      .replace(
        /^(.*recommendations?:.*)/im,
        '<span class="text-teal-600 font-medium">$1</span>'
      );

    const lines = processedContent.split("\n");

    return lines.map((line, i) => {
      if (
        line.includes("## SUMMARY:") ||
        line.includes("## MEDICATIONS:") ||
        line.includes("## INSTRUCTIONS:") ||
        line.includes("## TEST RESULTS:") ||
        line.includes("## ABNORMAL VALUES:")
      ) {
        return null;
      }
      if (line.includes("<span")) {
        return (
          <p
            key={i}
            dangerouslySetInnerHTML={{ __html: line }}
            className="font-medium my-2"
          />
        );
      } else if (line.trim() === "") {
        return <div key={i} className="h-2" />;
      } else if (line.trim().startsWith("•")) {
        return (
          <p key={i} className="ml-4 flex">
            <span className="mr-2">•</span>
            {line.trim().substring(1).trim()}
          </p>
        );
      } else {
        return (
          <p key={i} className="ml-1">
            {line}
          </p>
        );
      }
    });
  };

  const extractMedications = (text: string) => {
    const medications = [];
    const sections = text.split(/\n\n|\r\n\r\n|\n/);

    for (const section of sections) {
      if (
        (section.toLowerCase().includes("medication") ||
          section.toLowerCase().includes("prescribed") ||
          section.toLowerCase().includes("drug") ||
          section.match(
            /\d+\s*mg|\d+\s*mcg|\d+\s*ml|\d+\s*tablet|\d+\s*cap/i
          )) &&
        !section.toLowerCase().includes("summary") &&
        section.length > 10
      ) {
        medications.push(section.trim());
      }
    }

    return medications.length > 0
      ? medications
      : ["No medication details found"];
  };

  const extractInstructions = (text: string) => {
    const instructions = [];
    const sections = text.split(/\n\n|\r\n\r\n|\n/);

    for (const section of sections) {
      if (
        (section.toLowerCase().includes("instruction") ||
          section.toLowerCase().includes("take") ||
          section.toLowerCase().includes("use") ||
          section.toLowerCase().includes("direction") ||
          section.toLowerCase().includes("daily") ||
          section.toLowerCase().includes("times a day") ||
          section.match(/\btake\s+\d+/i)) &&
        !section.toLowerCase().includes("summary") &&
        section.length > 10
      ) {
        instructions.push(section.trim());
      }
    }

    return instructions.length > 0 ? instructions : ["No instructions found"];
  };

  const extractTestResults = (text: string) => {
    const tests = [];
    const sections = text.split(/\n\n|\r\n\r\n|\n/);

    for (const section of sections) {
      if (
        (section.toLowerCase().includes("test") ||
          section.toLowerCase().includes("result") ||
          section.toLowerCase().includes("level") ||
          section.toLowerCase().includes("count") ||
          section.match(
            /\d+\s*mg\/dl|\d+\s*mmol|\d+\s*u\/l|\d+\s*g\/dl|\d+\s*mcg|\d+\s*pmol/i
          )) &&
        !section.toLowerCase().includes("summary") &&
        section.length > 10
      ) {
        tests.push(section.trim());
      }
    }

    return tests.length > 0 ? tests : ["No test results found"];
  };

  const extractAbnormalValues = (text: string) => {
    const abnormal = [];
    const sections = text.split(/\n\n|\r\n\r\n/);

    for (const section of sections) {
      if (
        section.toLowerCase().includes("abnormal") ||
        section.toLowerCase().includes("elevated") ||
        section.toLowerCase().includes("high") ||
        section.toLowerCase().includes("low")
      ) {
        abnormal.push(section);
      }
    }

    return abnormal.length > 0 ? abnormal : ["No abnormal values highlighted"];
  };

  const extractSummary = (text: string) => {
    const sections = text.split(/\n\n|\r\n\r\n/);

    for (const section of sections) {
      if (
        section.toLowerCase().includes("summary") ||
        section.toLowerCase().includes("impression")
      ) {
        return section;
      }
    }

    const firstParagraph = text.split(/\n\n|\r\n\r\n/)[0];
    return firstParagraph || "No summary available";
  };

  const extractPrescriptionDetails = (analysis: string) => {
    const details: Record<string, string> = {
      date: "",
      prescribedBy: "",
      duration: "",
      refills: "",
    };

    const dateMatch = analysis.match(
      /(?:prescribed|date|written)(?:\s+on)?:\s*([A-Za-z]+ \d+,? \d{4}|\d{1,2}\/\d{1,2}\/\d{2,4}|\d{1,2}-\d{1,2}-\d{2,4})/i
    );
    if (dateMatch) details.date = dateMatch[1];

    const prescriberMatch = analysis.match(
      /(?:prescribed by|prescriber|doctor|physician|dr\.?):\s*([^,\n\.]+)/i
    );
    if (prescriberMatch) details.prescribedBy = prescriberMatch[1].trim();

    const durationMatch = analysis.match(
      /(?:duration|for|take for|period|course):\s*([^,\n\.]+\s+(?:days?|weeks?|months?))/i
    );
    if (durationMatch) details.duration = durationMatch[1].trim();

    const refillMatch = analysis.match(
      /(?:refills?|repeats?):\s*(\d+|zero|one|two|three|four|five|no\s+refills?)/i
    );
    if (refillMatch) details.refills = refillMatch[1].trim();

    return details;
  };

  const renderPrescriptionMedications = () => {
    if (!reportData || reportType !== "prescription") return null;

    const medications = reportData.medications || [];

    return (
      <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
        <button
          onClick={() => toggleSection("medications")}
          className="w-full flex items-center justify-between p-3 text-left"
        >
          <div className="flex items-center gap-2">
            <div className="bg-blue-500/10 w-8 h-8 rounded-full flex items-center justify-center">
              <Pill className="h-4 w-4 text-blue-500" />
            </div>
            <span className="font-medium">
              Medications ({medications.length})
            </span>
          </div>
          {expandedSections.includes("medications") ? (
            <ChevronUp className="h-5 w-5" />
          ) : (
            <ChevronDown className="h-5 w-5" />
          )}
        </button>

        {expandedSections.includes("medications") && (
          <div className="p-4 border-t border-border">
            <ul className="space-y-3">
              {medications.map((med: Medication, index: number) => (
                <li
                  key={index}
                  className="bg-background p-4 rounded-lg border border-border"
                >
                  <div className="flex items-start">
                    <div className="h-6 w-6 rounded-full bg-blue-500/10 flex items-center justify-center mr-2">
                      <Pill className="h-3 w-3 text-blue-500" />
                    </div>
                    <div className="flex-1">
                      <div className="flex flex-wrap gap-2 mb-1">
                        {med.name && (
                          <h4 className="font-semibold">{med.name}</h4>
                        )}
                        {med.dosage && (
                          <span className="text-xs font-medium bg-blue-500/10 text-blue-700 rounded px-2 py-0.5">
                            {med.dosage}
                          </span>
                        )}
                        {med.form && (
                          <span className="text-xs font-medium bg-purple-500/10 text-purple-700 rounded px-2 py-0.5">
                            {med.form}
                          </span>
                        )}
                        {med.frequency && (
                          <span className="text-xs font-medium bg-green-500/10 text-green-700 rounded px-2 py-0.5">
                            {med.frequency}
                          </span>
                        )}
                      </div>
                      {med.duration && (
                        <p className="text-sm text-muted-foreground mb-2">
                          Duration: {med.duration}
                        </p>
                      )}
                      {med.instructions && (
                        <p className="text-sm">{med.instructions}</p>
                      )}
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>
    );
  };

  const renderPrescriptionInstructions = () => {
    if (
      !reportData ||
      reportType !== "prescription" ||
      !reportData.general_instructions?.length
    )
      return null;

    return (
      <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
        <button
          onClick={() => toggleSection("instructions")}
          className="w-full flex items-center justify-between p-3 text-left"
        >
          <div className="flex items-center gap-2">
            <div className="bg-blue-500/10 w-8 h-8 rounded-full flex items-center justify-center">
              <FileText className="h-4 w-4 text-blue-500" />
            </div>
            <span className="font-medium">General Instructions</span>
          </div>
          {expandedSections.includes("instructions") ? (
            <ChevronUp className="h-5 w-5" />
          ) : (
            <ChevronDown className="h-5 w-5" />
          )}
        </button>

        {expandedSections.includes("instructions") && (
          <div className="p-4 border-t border-border">
            <ul className="space-y-3">
              {reportData.general_instructions.map(
                (instruction: string, index: number) => (
                  <li
                    key={index}
                    className="bg-background p-4 rounded-lg border border-border"
                  >
                    <div className="flex items-start">
                      <div className="h-6 w-6 rounded-full bg-purple-500/10 flex items-center justify-center mr-2">
                        <Clock className="h-3 w-3 text-purple-500" />
                      </div>
                      <p className="whitespace-pre-line">{instruction}</p>
                    </div>
                  </li>
                )
              )}
            </ul>
          </div>
        )}
      </div>
    );
  };

  const renderPrescriptionWarnings = () => {
    if (
      !reportData ||
      reportType !== "prescription" ||
      !reportData.warnings?.length
    )
      return null;

    return (
      <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
        <button
          onClick={() => toggleSection("warnings")}
          className="w-full flex items-center justify-between p-3 text-left"
        >
          <div className="flex items-center gap-2">
            <div className="bg-orange-500/10 w-8 h-8 rounded-full flex items-center justify-center">
              <AlertCircle className="h-4 w-4 text-orange-500" />
            </div>
            <span className="font-medium">Warnings</span>
          </div>
          {expandedSections.includes("warnings") ? (
            <ChevronUp className="h-5 w-5" />
          ) : (
            <ChevronDown className="h-5 w-5" />
          )}
        </button>

        {expandedSections.includes("warnings") && (
          <div className="p-4 border-t border-border">
            <ul className="space-y-3">
              {reportData.warnings.map((warning: string, index: number) => (
                <li
                  key={index}
                  className="bg-orange-50 dark:bg-orange-900/10 p-4 rounded-lg border border-orange-200 dark:border-orange-800/20"
                >
                  <div className="flex items-start">
                    <div className="h-6 w-6 rounded-full bg-orange-500/10 flex items-center justify-center mr-2">
                      <AlertCircle className="h-3 w-3 text-orange-500" />
                    </div>
                    <p className="whitespace-pre-line">{warning}</p>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>
    );
  };

  const renderLabTestResults = () => {
    if (!reportData || reportType !== "lab") return null;

    const testResults = reportData.test_results || [];

    return (
      <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
        <button
          onClick={() => toggleSection("tests")}
          className="w-full flex items-center justify-between p-3 text-left"
        >
          <div className="flex items-center gap-2">
            <div className="bg-amber-500/10 w-8 h-8 rounded-full flex items-center justify-center">
              <FlaskConical className="h-4 w-4 text-amber-500" />
            </div>
            <span className="font-medium">
              Test Results ({testResults.length})
            </span>
          </div>
          {expandedSections.includes("tests") ? (
            <ChevronUp className="h-5 w-5" />
          ) : (
            <ChevronDown className="h-5 w-5" />
          )}
        </button>

        {expandedSections.includes("tests") && (
          <div className="p-4 border-t border-border">
            <div className="space-y-3">
              {testResults.map((test: TestResult, index: number) => {
                const isAbnormal =
                  test.status === "HIGH" || test.status === "LOW";

                return (
                  <div
                    key={index}
                    className="bg-background p-4 rounded-lg border border-border"
                  >
                    <div className="flex items-start">
                      <div
                        className={`h-6 w-6 rounded-full flex items-center justify-center mr-2 ${
                          isAbnormal ? "bg-red-500/10" : "bg-amber-500/10"
                        }`}
                      >
                        <FlaskConical
                          className={`h-3 w-3 ${
                            isAbnormal ? "text-red-500" : "text-amber-500"
                          }`}
                        />
                      </div>
                      <div className="flex-1">
                        <div className="flex justify-between items-start">
                          <h4 className="font-medium">{test.test_name}</h4>
                          {isAbnormal && (
                            <span
                              className={`text-xs font-bold ${
                                test.status === "HIGH"
                                  ? "text-red-500"
                                  : "text-blue-500"
                              }`}
                            >
                              {test.status}
                            </span>
                          )}
                        </div>

                        {test.value && (
                          <div className="mt-1 flex items-center gap-2">
                            <span
                              className={`text-sm font-medium rounded px-2 py-0.5 ${
                                isAbnormal
                                  ? "bg-red-500/10 text-red-700"
                                  : "bg-green-500/10 text-green-700"
                              }`}
                            >
                              {test.value}
                            </span>
                            {test.reference_range && (
                              <span className="text-xs text-muted-foreground">
                                (Reference: {test.reference_range})
                              </span>
                            )}
                          </div>
                        )}

                        {test.interpretation && (
                          <p className="text-sm mt-2">{test.interpretation}</p>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </div>
    );
  };

  const renderLabInterpretation = () => {
    if (!reportData || reportType !== "lab" || !reportData.interpretation)
      return null;

    return (
      <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
        <button
          onClick={() => toggleSection("interpretation")}
          className="w-full flex items-center justify-between p-3 text-left"
        >
          <div className="flex items-center gap-2">
            <div className="bg-green-500/10 w-8 h-8 rounded-full flex items-center justify-center">
              <FileText className="h-4 w-4 text-green-500" />
            </div>
            <span className="font-medium">Interpretation</span>
          </div>
          {expandedSections.includes("interpretation") ? (
            <ChevronUp className="h-5 w-5" />
          ) : (
            <ChevronDown className="h-5 w-5" />
          )}
        </button>

        {expandedSections.includes("interpretation") && (
          <div className="p-4 border-t border-border">
            <p className="whitespace-pre-line">{reportData.interpretation}</p>
          </div>
        )}
      </div>
    );
  };

  const renderFileUploadSection = () => {
    return (
      <div className="bg-card rounded-xl shadow-sm border border-border p-5">
        <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
          <FileText className="h-5 w-5 text-primary" />
          Medical Document Upload
        </h2>

        <div className="flex flex-col space-y-4">
          <div className="flex items-center gap-4">
            <div className="flex-1 relative">
              <input
                type="text"
                placeholder="Choose a medical document..."
                className={`w-full px-4 py-3 rounded-lg border ${
                  fileError ? "border-red-500" : "border-input"
                } bg-background focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary pl-10`}
                value={fileName}
                readOnly
              />
              <FileType className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
              <input
                type="file"
                accept=".jpg,.jpeg,.png,.bmp,.tiff,.webp,.pdf,.docx"
                ref={fileInputRef}
                onChange={handleFileChange}
                className="hidden"
              />
            </div>
            <div className="flex flex-col space-y-2">
              <select
                id="docType"
                className="w-full px-2 py-3 rounded-lg border border-input bg-background focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary"
                value={selectedDocType}
                onChange={(e) =>
                  setSelectedDocType(
                    e.target.value as "lab_report" | "prescription"
                  )
                }
              >
                <option value="lab_report">Lab Report</option>
                <option value="prescription">Prescription</option>
              </select>
            </div>
            <div className="flex gap-2">
              <button
                className="px-4 py-3 bg-background focus:outline-none focus:ring-2 border border-input focus:ring-primary focus:border-primary rounded-lg flex items-center gap-2 font-medium"
                onClick={handleUploadClick}
                disabled={isProcessing}
              >
                <Upload className="w-4 h-4" />
                Select
              </button>

              {uploadedFile && (
                <button
                  className="px-4 py-3 bg-primary text-primary-foreground hover:bg-primary/90 transition-colors rounded-lg font-medium flex items-center gap-2"
                  onClick={handleUploadSubmit}
                  disabled={isProcessing}
                >
                  {isProcessing ? (
                    <>
                      <span className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></span>
                      Processing...
                    </>
                  ) : (
                    <>Analyze</>
                  )}
                </button>
              )}
            </div>
          </div>

          <AnimatePresence>
            {fileProcessing.status !== "idle" && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0 }}
                className={`px-4 py-3 rounded-lg flex items-center gap-2 text-sm ${
                  fileProcessing.status === "loading"
                    ? "bg-blue-500/10 text-blue-700 border border-blue-200"
                    : fileProcessing.status === "success"
                    ? "bg-green-500/10 text-green-700 border border-green-200"
                    : "bg-red-500/10 text-red-700 border border-red-200"
                }`}
              >
                {fileProcessing.status === "loading" ? (
                  <div className="animate-spin h-4 w-4 border-2 border-blue-500 rounded-full border-t-transparent" />
                ) : fileProcessing.status === "success" ? (
                  <svg
                    className="h-4 w-4 text-green-500"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M5 13l4 4L19 7"
                    />
                  </svg>
                ) : (
                  <AlertTriangle className="h-4 w-4 text-red-500" />
                )}
                {fileProcessing.message}
              </motion.div>
            )}
          </AnimatePresence>

          {fileError && (
            <div className="text-red-500 text-sm flex items-center gap-2">
              <AlertTriangle className="h-4 w-4" />
              {fileError}
            </div>
          )}

          <div className="text-xs text-muted-foreground">
            <p>
              Supported formats: JPG, PNG, PDF, DOCX, BMP, TIFF, WebP | Max
              size: 10MB
            </p>
            <p className="mt-1">
              <strong>Tip:</strong> For best results, use clear images with good
              lighting and focus
            </p>
          </div>
        </div>

        {extractedText && (
          <div className="mt-4 p-3 bg-muted/50 rounded-lg border border-border">
            <p className="text-xs font-medium text-muted-foreground mb-1">
              Extracted Text
            </p>
            <div className="text-xs max-h-[60px] overflow-y-auto custom-scrollbar">
              {extractedText.substring(0, 300)}
              {extractedText.length > 300 ? "..." : ""}
            </div>
          </div>
        )}
      </div>
    );
  };

  const renderReportActions = () => {
    if (!canGeneratePdf) return null;

    return (
      <div className="flex items-center gap-2 ml-auto">
        <button
          onClick={handleGeneratePDF}
          disabled={isGeneratingPdf}
          className={`text-xs px-3 py-1.5 rounded-lg flex items-center gap-2 transition-colors ${
            isGeneratingPdf
              ? "bg-muted text-muted-foreground"
              : "bg-primary text-primary-foreground hover:bg-primary/90"
          }`}
        >
          {isGeneratingPdf ? (
            <>
              <div className="h-3 w-3 rounded-full border-2 border-t-transparent animate-spin" />
              Generating...
            </>
          ) : (
            <>
              <Download className="h-3 w-3" />
              Download PDF Summary
            </>
          )}
        </button>
      </div>
    );
  };

  const renderReportTags = () => {
    if (!reportData || !reportData.report_tags?.length) return null;

    return (
      <div className="flex flex-wrap gap-2 mt-4">
        {reportData.report_tags.map((tag: ReportTag, index: number) => (
          <span
            key={index}
            className="text-xs font-medium bg-primary/10 text-primary rounded-full px-3 py-1 flex items-center gap-1"
          >
            <span>#{tag.name}</span>
          </span>
        ))}
      </div>
    );
  };

  const renderTrendsSection = () => {
    if (!showTrends) return null;

    return (
      <div className="bg-card rounded-xl shadow-sm border border-border p-5 mb-6">
        <h3 className="text-lg font-medium mb-4">Health Metrics Trends</h3>
        <p className="text-sm text-muted-foreground mb-6">
          Upload multiple reports over time to see your health metrics trends.
        </p>

        <div className="aspect-video bg-muted/30 rounded-lg flex items-center justify-center">
          <canvas ref={chartRef} />
        </div>
      </div>
    );
  };

  const renderAbnormalValues = () => {
    if (
      !reportData ||
      reportType !== "lab" ||
      !reportData.abnormal_values?.length
    )
      return null;

    return (
      <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
        <button
          onClick={() => toggleSection("abnormal")}
          className="w-full flex items-center justify-between p-3 text-left"
        >
          <div className="flex items-center gap-2">
            <div className="bg-red-500/10 w-8 h-8 rounded-full flex items-center justify-center">
              <AlertCircle className="h-4 w-4 text-red-500" />
            </div>
            <span className="font-medium">
              Key Abnormal Findings ({reportData.abnormal_values.length})
            </span>
          </div>
          {expandedSections.includes("abnormal") ? (
            <ChevronUp className="h-5 w-5" />
          ) : (
            <ChevronDown className="h-5 w-5" />
          )}
        </button>

        {expandedSections.includes("abnormal") && (
          <div className="p-4 border-t border-border">
            <div className="border rounded-lg overflow-hidden">
              <table className="min-w-full divide-y divide-border">
                <thead className="bg-muted/50">
                  <tr>
                    <th
                      scope="col"
                      className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider"
                    >
                      Test
                    </th>
                    <th
                      scope="col"
                      className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider"
                    >
                      Result
                    </th>
                    <th
                      scope="col"
                      className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider"
                    >
                      Normal Range
                    </th>
                    <th
                      scope="col"
                      className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider"
                    >
                      Severity
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-background divide-y divide-border">
                  {reportData.abnormal_values.map(
                    (abnormal: AbnormalValue, index: number) => (
                      <tr key={index}>
                        <td className="px-4 py-3 whitespace-nowrap text-sm font-medium">
                          {abnormal.test_name}
                        </td>
                        <td className="px-4 py-3 whitespace-nowrap text-sm">
                          <span
                            className={`${
                              abnormal.status === "HIGH"
                                ? "text-red-600"
                                : "text-blue-600"
                            } font-medium`}
                          >
                            {abnormal.value || "N/A"}
                          </span>
                        </td>
                        <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                          {abnormal.reference_range || "N/A"}
                        </td>
                        <td className="px-4 py-3 whitespace-nowrap">
                          <span
                            className={`text-xs font-bold px-2 py-1 rounded ${
                              abnormal.severity === "SEVERE"
                                ? "bg-red-100 text-red-800"
                                : abnormal.severity === "MODERATE"
                                ? "bg-orange-100 text-orange-800"
                                : "bg-amber-100 text-amber-800"
                            }`}
                          >
                            {abnormal.severity === "SEVERE"
                              ? "🔴 Severe"
                              : abnormal.severity === "MODERATE"
                              ? "⚠️ Moderate"
                              : "⚠️ Mild"}
                          </span>
                        </td>
                      </tr>
                    )
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    );
  };

  const renderRecommendedSupplements = () => {
    if (!reportData || !reportData.recommended_supplements?.length) return null;

    return (
      <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
        <button
          onClick={() => toggleSection("supplements")}
          className="w-full flex items-center justify-between p-3 text-left"
        >
          <div className="flex items-center gap-2">
            <div className="bg-green-500/10 w-8 h-8 rounded-full flex items-center justify-center">
              <Pill className="h-4 w-4 text-green-500" />
            </div>
            <span className="font-medium">Recommended Supplements</span>
          </div>
          {expandedSections.includes("supplements") ? (
            <ChevronUp className="h-5 w-5" />
          ) : (
            <ChevronDown className="h-5 w-5" />
          )}
        </button>

        {expandedSections.includes("supplements") && (
          <div className="p-4 border-t border-border">
            <ul className="space-y-3">
              {reportData.recommended_supplements.map(
                (supplement: RecommendedSupplement, index: number) => (
                  <li
                    key={index}
                    className="bg-background p-4 rounded-lg border border-border"
                  >
                    <div className="flex items-start">
                      <div
                        className={`h-6 w-6 rounded-full ${
                          supplement.is_prescription
                            ? "bg-blue-500/10"
                            : "bg-green-500/10"
                        } flex items-center justify-center mr-2`}
                      >
                        <Pill
                          className={`h-3 w-3 ${
                            supplement.is_prescription
                              ? "text-blue-500"
                              : "text-green-500"
                          }`}
                        />
                      </div>
                      <div className="flex-1">
                        <div className="flex justify-between items-start">
                          <div>
                            <h4 className="font-medium">{supplement.name}</h4>
                            <p className="text-sm text-muted-foreground">
                              {supplement.dosage}
                            </p>
                          </div>
                          {supplement.is_prescription ? (
                            <span className="text-xs font-medium bg-blue-500/10 text-blue-700 rounded px-2 py-0.5">
                              Rx Required
                            </span>
                          ) : (
                            <span className="text-xs font-medium bg-green-500/10 text-green-700 rounded px-2 py-0.5">
                              Over-the-counter
                            </span>
                          )}
                        </div>

                        {supplement.reason && (
                          <p className="text-sm mt-2">
                            For: {supplement.reason}
                          </p>
                        )}

                        {supplement.warnings && (
                          <p className="text-xs mt-2 text-amber-700 bg-amber-50 p-2 rounded">
                            ⚠️ {supplement.warnings}
                          </p>
                        )}
                      </div>
                    </div>
                  </li>
                )
              )}
            </ul>
          </div>
        )}
      </div>
    );
  };

  const renderLifestyleRecommendations = () => {
    if (!reportData || !reportData.lifestyle_recommendations?.length)
      return null;

    const getIconForCategory = (category: string) => {
      switch (category) {
        case "DIET":
          return <Utensils className="h-4 w-4 text-orange-500" />;
        case "EXERCISE":
          return <Activity className="h-4 w-4 text-blue-500" />;
        case "SLEEP":
          return <Clock className="h-4 w-4 text-purple-500" />;
        default:
          return <Coffee className="h-4 w-4 text-green-500" />;
      }
    };

    return (
      <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
        <button
          onClick={() => toggleSection("lifestyle")}
          className="w-full flex items-center justify-between p-3 text-left"
        >
          <div className="flex items-center gap-2">
            <div className="bg-orange-500/10 w-8 h-8 rounded-full flex items-center justify-center">
              <Apple className="h-4 w-4 text-orange-500" />
            </div>
            <span className="font-medium">
              Lifestyle & Diet Recommendations
            </span>
          </div>
          {expandedSections.includes("lifestyle") ? (
            <ChevronUp className="h-5 w-5" />
          ) : (
            <ChevronDown className="h-5 w-5" />
          )}
        </button>

        {expandedSections.includes("lifestyle") && (
          <div className="p-4 border-t border-border">
            {reportData.lifestyle_recommendations.map(
              (category: LifestyleRecommendation, index: number) => (
                <div key={index} className="mb-4">
                  <h4 className="flex items-center gap-2 text-sm font-medium mb-2">
                    {getIconForCategory(category.category)}
                    {category.category}
                  </h4>
                  <ul className="space-y-2">
                    {category.recommendations.map(
                      (rec: string, recIndex: number) => (
                        <li
                          key={recIndex}
                          className="bg-background p-3 rounded-lg border border-border flex items-center gap-2"
                        >
                          <ChevronRight className="h-3.5 w-3.5 text-muted-foreground flex-shrink-0" />
                          <span>{rec}</span>
                        </li>
                      )
                    )}
                  </ul>
                </div>
              )
            )}
          </div>
        )}
      </div>
    );
  };

  const renderFollowUpTests = () => {
    if (!reportData || !reportData.follow_up_tests?.length) return null;

    return (
      <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
        <button
          onClick={() => toggleSection("followup")}
          className="w-full flex items-center justify-between p-3 text-left"
        >
          <div className="flex items-center gap-2">
            <div className="bg-purple-500/10 w-8 h-8 rounded-full flex items-center justify-center">
              <Calendar className="h-4 w-4 text-purple-500" />
            </div>
            <span className="font-medium">Recommended Follow-Up Tests</span>
          </div>
          {expandedSections.includes("followup") ? (
            <ChevronUp className="h-5 w-5" />
          ) : (
            <ChevronDown className="h-5 w-5" />
          )}
        </button>

        {expandedSections.includes("followup") && (
          <div className="p-4 border-t border-border">
            <ul className="space-y-3">
              {reportData.follow_up_tests.map(
                (test: FollowUpTest, index: number) => (
                  <li
                    key={index}
                    className="bg-background p-4 rounded-lg border border-border"
                  >
                    <div className="flex items-start">
                      <div className="h-6 w-6 rounded-full bg-purple-500/10 flex items-center justify-center mr-2">
                        <Calendar className="h-3 w-3 text-purple-500" />
                      </div>
                      <div className="flex-1">
                        <div className="flex justify-between items-start">
                          <h4 className="font-medium">{test.test_name}</h4>
                          <span className="text-xs font-medium bg-purple-500/10 text-purple-700 rounded px-2 py-0.5">
                            {test.timeline}
                          </span>
                        </div>

                        {test.reason && (
                          <p className="text-sm mt-2">{test.reason}</p>
                        )}
                      </div>
                    </div>
                  </li>
                )
              )}
            </ul>
          </div>
        )}
      </div>
    );
  };

  const renderDoctorQuestions = () => {
    if (!reportData || !reportData.doctor_questions?.length) return null;

    return (
      <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
        <button
          onClick={() => toggleSection("questions")}
          className="w-full flex items-center justify-between p-3 text-left"
        >
          <div className="flex items-center gap-2">
            <div className="bg-cyan-500/10 w-8 h-8 rounded-full flex items-center justify-center">
              <NotebookPen className="h-4 w-4 text-cyan-500" />
            </div>
            <span className="font-medium">Doctor Discussion Guide</span>
          </div>
          {expandedSections.includes("questions") ? (
            <ChevronUp className="h-5 w-5" />
          ) : (
            <ChevronDown className="h-5 w-5" />
          )}
        </button>

        {expandedSections.includes("questions") && (
          <div className="p-4 border-t border-border">
            <ul className="space-y-3">
              {reportData.doctor_questions.map(
                (item: DoctorQuestion, index: number) => (
                  <li
                    key={index}
                    className="bg-background p-4 rounded-lg border border-border"
                  >
                    <div className="flex items-start">
                      <div className="h-6 w-6 rounded-full bg-cyan-500/10 flex items-center justify-center mr-2">
                        <NotebookPen className="h-3 w-3 text-cyan-500" />
                      </div>
                      <div className="flex-1">
                        <p className="text-sm font-medium">{item.question}</p>
                        <p className="text-xs text-muted-foreground mt-1">
                          Related to: {item.related_to}
                        </p>
                      </div>
                    </div>
                  </li>
                )
              )}
            </ul>
          </div>
        )}
      </div>
    );
  };

  const getChatIcon = (type: string) => {
    switch (type) {
      case "prescription":
        return <Pill className="h-4 w-4 text-blue-500" />;
      case "lab":
        return <FlaskConical className="h-4 w-4 text-amber-500" />;
      default:
        return <FileText className="h-4 w-4 text-slate-500" />;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-background to-muted/20">
      <div className="flex h-screen">
        <AnimatePresence>
          {sidebarOpen && (
            <motion.div
              initial={{ width: 0, opacity: 0 }}
              animate={{ width: 300, opacity: 1 }}
              exit={{ width: 0, opacity: 0 }}
              className="h-screen bg-card border-r border-border overflow-hidden flex flex-col"
            >
              <div className="p-4 border-b border-border">
                <div className="flex items-center gap-2">
                  <Stethoscope className="h-5 w-5 text-primary" />
                  <h2 className="font-semibold text-lg">MediLink AI</h2>
                  <X
                    className="h-5 w-5 text-gray-900 cursor-pointer ml-auto"
                    onClick={() => setSidebarOpen(false)}
                  />
                </div>
                <div className="relative mt-3">
                  <input
                    type="text"
                    placeholder="Search conversations..."
                    className="w-full bg-muted/50 py-2 pl-8 pr-4 rounded-md text-sm"
                  />
                  <Search className="h-4 w-4 text-muted-foreground absolute left-2 top-2.5" />
                </div>
              </div>

              <div className="flex-1 overflow-y-auto p-2">
                <div className="mb-2 px-2">
                  <button className="w-full py-2 bg-primary text-primary-foreground rounded-md flex items-center justify-center gap-2 hover:bg-primary/90 transition-all">
                    <Upload className="h-4 w-4" />
                    <span>New Analysis</span>
                  </button>
                </div>

                <div className="mt-4">
                  <h3 className="text-xs font-medium text-muted-foreground px-3 mb-1">
                    RECENT CHATS
                  </h3>
                  <div className="space-y-1">
                    {previousChats.map((chat) => (
                      <button
                        key={chat.id}
                        className="w-full px-3 py-2 hover:bg-muted/50 rounded-md text-left flex items-start gap-2 transition-all group"
                      >
                        <div className="h-5 w-5 rounded-full bg-muted/50 flex items-center justify-center flex-shrink-0 mt-0.5">
                          {getChatIcon(chat.type)}
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium truncate">
                            {chat.title}
                          </p>
                          <p className="text-xs text-muted-foreground">
                            {chat.date}
                          </p>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              <div className="p-3 border-t border-border">
                <button className="w-full py-2 text-muted-foreground hover:bg-muted/50 rounded-md flex items-center px-3 gap-2 text-sm">
                  <Settings className="h-4 w-4" />
                  <span>Settings</span>
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        <div className="flex-1 flex flex-col overflow-hidden">
          <div className="p-2 flex items-center">
            <button
              className="p-2 hover:bg-muted rounded-md"
              onClick={() => setSidebarOpen(!sidebarOpen)}
            >
              {sidebarOpen ? (
                <PanelLeftClose className="h-5 w-5" />
              ) : (
                <PanelRight className="h-5 w-5" />
              )}
            </button>
          </div>

          <div className="flex-1 overflow-y-auto">
            <div className="container mx-auto p-4 max-w-5xl">
              <motion.div
                className="flex flex-col items-center mb-6"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5 }}
              >
                <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mb-4">
                  <Stethoscope className="h-8 w-8 text-primary" />
                </div>
                <h1 className="text-3xl md:text-4xl font-bold text-primary mb-2 text-center">
                  MediLink AI
                </h1>
                <p className="text-lg text-muted-foreground text-center max-w-md">
                  Your intelligent assistant for understanding medical reports
                </p>
              </motion.div>

              <motion.div
                className="mb-6"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: 0.1 }}
              >
                {renderFileUploadSection()}
              </motion.div>

              <AnimatePresence>
                {reportType && reportData && (
                  <motion.div
                    className="mb-6"
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: "auto" }}
                    exit={{ opacity: 0, height: 0 }}
                    transition={{ duration: 0.3 }}
                  >
                    <div className="bg-card rounded-xl shadow-sm border border-border overflow-hidden">
                      <div
                        className={`p-4 flex items-start gap-3 border-b border-border ${
                          reportType === "prescription"
                            ? "bg-blue-500/10"
                            : reportType === "lab"
                            ? "bg-amber-500/10"
                            : "bg-slate-500/10"
                        }`}
                      >
                        <div className="mt-1">
                          {reportType === "prescription" ? (
                            <Pill className="h-7 w-7 text-blue-500" />
                          ) : reportType === "lab" ? (
                            <FlaskConical className="h-7 w-7 text-amber-500" />
                          ) : (
                            <FileText className="h-7 w-7 text-slate-500" />
                          )}
                        </div>
                        <div className="flex-1">
                          <h2 className="text-xl font-semibold">
                            {reportType === "prescription"
                              ? "Prescription Details"
                              : reportType === "lab"
                              ? "Lab Report Analysis"
                              : "Document Analysis"}
                          </h2>
                          <p className="text-sm text-muted-foreground">
                            {reportType === "prescription"
                              ? "Medications and dosage instructions"
                              : reportType === "lab"
                              ? "Test results and interpretations"
                              : "Document content and summary"}
                          </p>

                          {reportType === "prescription" &&
                            reportData.prescription_details && (
                              <div className="mt-3 grid grid-cols-2 gap-2">
                                {reportData.prescription_details.date && (
                                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                                    <Calendar className="h-3.5 w-3.5" />
                                    <span>
                                      Date:{" "}
                                      {reportData.prescription_details.date}
                                    </span>
                                  </div>
                                )}
                                {reportData.prescription_details.duration && (
                                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                                    <Hourglass className="h-3.5 w-3.5" />
                                    <span>
                                      Duration:{" "}
                                      {reportData.prescription_details.duration}
                                    </span>
                                  </div>
                                )}
                                {reportData.prescription_details
                                  .prescribed_by && (
                                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                                    <User className="h-3.5 w-3.5" />
                                    <span>
                                      Prescribed by:{" "}
                                      {
                                        reportData.prescription_details
                                          .prescribed_by
                                      }
                                    </span>
                                  </div>
                                )}
                                {reportData.prescription_details.refills && (
                                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                                    <Clock className="h-3.5 w-3.5" />
                                    <span>
                                      Refills:{" "}
                                      {reportData.prescription_details.refills}
                                    </span>
                                  </div>
                                )}
                              </div>
                            )}
                        </div>

                        {renderReportActions()}
                      </div>

                      <div className="p-4 space-y-4">
                        {renderReportTags()}

                        <div className="bg-muted/30 border border-border rounded-lg overflow-hidden">
                          <button
                            onClick={() => toggleSection("summary")}
                            className="w-full flex items-center justify-between p-3 text-left"
                          >
                            <div className="flex items-center gap-2">
                              <div className="bg-primary/10 w-8 h-8 rounded-full flex items-center justify-center">
                                <FileText className="h-4 w-4 text-primary" />
                              </div>
                              <span className="font-medium">
                                Executive Summary
                              </span>
                            </div>
                            {expandedSections.includes("summary") ? (
                              <ChevronUp className="h-5 w-5" />
                            ) : (
                              <ChevronDown className="h-5 w-5" />
                            )}
                          </button>

                          {expandedSections.includes("summary") && (
                            <div className="p-4 border-t border-border">
                              <p className="whitespace-pre-line">
                                {reportData.summary}
                              </p>
                            </div>
                          )}
                        </div>

                        {renderAbnormalValues()}
                        {renderRecommendedSupplements()}
                        {renderLifestyleRecommendations()}
                        {renderFollowUpTests()}
                        {renderDoctorQuestions()}

                        {reportType === "prescription" && (
                          <>
                            {renderPrescriptionMedications()}
                            {renderPrescriptionInstructions()}
                            {renderPrescriptionWarnings()}
                          </>
                        )}

                        {reportType === "lab" && (
                          <>
                            {renderLabTestResults()}
                            {renderLabInterpretation()}
                          </>
                        )}

                        {reportType === "other" && (
                          <div className="bg-muted/30 border border-border rounded-lg p-4">
                            <p className="whitespace-pre-line">
                              {reportData.content}
                            </p>
                          </div>
                        )}
                      </div>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>

              {renderTrendsSection()}

              <motion.div
                className="mb-6"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: 0.2 }}
              >
                <div className="bg-card rounded-xl shadow-sm border border-border p-5 flex flex-col min-h-[400px]">
                  <div className="flex items-center justify-between mb-4">
                    <h2 className="text-xl font-semibold">Interactive Chat</h2>
                    {sessionId && (
                      <button
                        className="text-xs bg-primary/10 hover:bg-primary/20 text-primary px-3 py-1 rounded-full transition-colors"
                        onClick={() => {
                          /* Reset conversation logic */
                        }}
                      >
                        New Chat
                      </button>
                    )}
                  </div>

                  {!sessionId && !chatHistory.length && (
                    <div className="flex-1 flex flex-col items-center justify-center text-center p-6 text-muted-foreground">
                      <div className="bg-muted/50 w-16 h-16 rounded-full flex items-center justify-center mb-4">
                        <Stethoscope className="h-6 w-6" />
                      </div>
                      <h3 className="text-lg font-medium mb-2">
                        Upload a medical document to begin
                      </h3>
                      <p className="max-w-sm">
                        I can analyze prescriptions, lab reports, and other
                        medical documents to help you understand them better.
                      </p>
                    </div>
                  )}

                  {(sessionId || chatHistory.length > 0) && (
                    <div
                      ref={chatContainerRef}
                      className="flex-1 overflow-y-auto mb-4 space-y-4 pr-2 custom-scrollbar"
                    >
                      {chatHistory.map((msg, i) => (
                        <div
                          key={i}
                          className={`flex ${
                            msg.role === "user"
                              ? "justify-end"
                              : "justify-start"
                          } mb-3`}
                        >
                          {msg.role === "assistant" && (
                            <div className="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center mr-2 flex-shrink-0 self-start mt-1">
                              <Stethoscope className="h-4 w-4 text-primary" />
                            </div>
                          )}

                          <div
                            className={`max-w-[90%] rounded-xl ${
                              msg.role === "user"
                                ? "bg-primary text-primary-foreground rounded-tr-none"
                                : "bg-muted text-foreground rounded-tl-none border border-border"
                            } p-3`}
                          >
                            <div
                              className={`${
                                msg.role === "assistant"
                                  ? "prose prose-sm max-w-none"
                                  : ""
                              }`}
                            >
                              {msg.role === "assistant"
                                ? formatAIResponse(msg.content)
                                : msg.content}
                            </div>
                          </div>

                          {msg.role === "user" && (
                            <div className="h-8 w-8 rounded-full bg-primary flex items-center justify-center ml-2 flex-shrink-0 self-start mt-1">
                              <User className="h-4 w-4 text-primary-foreground" />
                            </div>
                          )}
                        </div>
                      ))}
                      {isLoading && (
                        <div className="flex justify-start">
                          <div className="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center mr-2 flex-shrink-0 self-start mt-1">
                            <Stethoscope className="h-4 w-4 text-primary" />
                          </div>
                          <div className="max-w-[90%] rounded-xl rounded-tl-none p-3 bg-muted text-foreground border border-border">
                            <div className="flex space-x-2 items-center h-6">
                              <div className="w-2 h-2 rounded-full bg-primary animate-bounce"></div>
                              <div
                                className="w-2 h-2 rounded-full bg-primary animate-bounce"
                                style={{ animationDelay: "0.2s" }}
                              ></div>
                              <div
                                className="w-2 h-2 rounded-full bg-primary animate-bounce"
                                style={{ animationDelay: "0.4s" }}
                              ></div>
                            </div>
                          </div>
                        </div>
                      )}
                    </div>
                  )}

                  <form onSubmit={handleSubmit} className="relative">
                    <input
                      type="text"
                      placeholder={
                        sessionId
                          ? "Ask questions about your medical report..."
                          : "Upload a report to start chatting..."
                      }
                      className="w-full px-4 py-3 rounded-lg border border-input bg-background focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary pr-12"
                      value={message}
                      onChange={(e) => setMessage(e.target.value)}
                      disabled={!sessionId || isLoading}
                    />
                    <button
                      type="submit"
                      className={`absolute right-3 top-1/2 -translate-y-1/2 w-8 h-8 flex items-center justify-center rounded-full 
                        ${
                          !sessionId || isLoading || !message.trim()
                            ? "text-muted-foreground bg-transparent"
                            : "text-white bg-primary hover:bg-primary/90"
                        } transition-colors`}
                      disabled={!sessionId || isLoading || !message.trim()}
                    >
                      <ArrowRight className="w-4 h-4" />
                    </button>
                  </form>
                </div>
              </motion.div>

              {!sessionId && (
                <motion.div
                  className="mb-6"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.5, delay: 0.3 }}
                >
                  <div className="bg-card rounded-xl shadow-sm border border-border p-5">
                    <h3 className="text-lg font-medium mb-3">
                      How to use MediLink AI
                    </h3>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div className="p-4 bg-muted/30 rounded-lg border border-border">
                        <div className="h-8 w-8 rounded-full bg-blue-500/10 flex items-center justify-center mb-3">
                          <Upload className="h-4 w-4 text-blue-500" />
                        </div>
                        <h4 className="text-sm font-medium mb-2">
                          1. Upload Document
                        </h4>
                        <p className="text-sm text-muted-foreground">
                          Upload your medical report, prescription, or lab
                          results for analysis.
                        </p>
                      </div>

                      <div className="p-4 bg-muted/30 rounded-lg border border-border">
                        <div className="h-8 w-8 rounded-full bg-green-500/10 flex items-center justify-center mb-3">
                          <FileText className="h-4 w-4 text-green-500" />
                        </div>
                        <h4 className="text-sm font-medium mb-2">
                          2. Review Analysis
                        </h4>
                        <p className="text-sm text-muted-foreground">
                          Get an instant breakdown of your medical document with
                          highlighted key information.
                        </p>
                      </div>

                      <div className="p-4 bg-muted/30 rounded-lg border border-border">
                        <div className="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center mb-3">
                          <MessageSquare className="h-4 w-4 text-primary" />
                        </div>
                        <h4 className="text-sm font-medium mb-2">
                          3. Ask Questions
                        </h4>
                        <p className="text-sm text-muted-foreground">
                          Chat with MediLink AI to get answers about your
                          medical information in simple terms.
                        </p>
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}
            </div>
          </div>
        </div>
      </div>

      <style jsx global>{`
        .custom-scrollbar::-webkit-scrollbar {
          width: 6px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
          background: transparent;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
          background-color: rgba(0, 0, 0, 0.2);
          border-radius: 3px;
        }
      `}</style>
    </div>
  );
}
