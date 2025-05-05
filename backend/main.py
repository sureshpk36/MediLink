from fastapi import FastAPI, File, UploadFile, HTTPException, Body, Form
from fastapi.middleware.cors import CORSMiddleware
import easyocr
import numpy as np
import cv2
import io
from groq import Groq
from typing import List, Dict, Any, Optional, Union
import uuid
import re
import os
import json
from PIL import Image
import pytesseract
import pdf2image
import docx2txt
import tempfile
import shutil
from pymongo import MongoClient

app = FastAPI()

# Add CORS middleware to allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize EasyOCR reader with enhanced settings
reader = easyocr.Reader(
    ['en'],
    gpu=False,  # Set to True if GPU is available
    model_storage_directory=os.path.join(os.path.dirname(__file__), 'models'),
    download_enabled=True,
    quantize=True  # Use quantization for faster inference
)

# Initialize Groq client with API key
from groq import Groq
client = Groq(api_key="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")
# In-memory store for session data
sessions = {}

# MongoDB connection
mongo_client = MongoClient("mongodb://localhost:27017/")
db = mongo_client["MediLink"]
drugs_collection = db["Drugs"]

# Enhanced schema for lab report structured output with new feature fields
LAB_REPORT_SCHEMA = {
    "type": "object",
    "properties": {
        "summary": {
            "type": "string",
            "description": "Brief overview of the lab report findings in human-friendly language"
        },
        "test_results": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "test_name": {
                        "type": "string",
                        "description": "Name of the test"
                    },
                    "value": {
                        "type": "string",
                        "description": "Measured value with units"
                    },
                    "reference_range": {
                        "type": "string",
                        "description": "Normal/reference range for this test"
                    },
                    "status": {
                        "type": "string",
                        "enum": ["NORMAL", "HIGH", "LOW", "UNKNOWN"],
                        "description": "Status of the result compared to reference range"
                    },
                    "interpretation": {
                        "type": "string",
                        "description": "Brief interpretation of this result"
                    }
                },
                "required": ["test_name", "status"]
            }
        },
        "abnormal_values": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "test_name": {
                        "type": "string",
                        "description": "Name of the test with abnormal value"
                    },
                    "value": {
                        "type": "string",
                        "description": "Abnormal value with units"
                    },
                    "reference_range": {
                        "type": "string",
                        "description": "Normal/reference range for this test"
                    },
                    "status": {
                        "type": "string",
                        "enum": ["HIGH", "LOW"],
                        "description": "Whether the value is high or low"
                    },
                    "severity": {
                        "type": "string",
                        "enum": ["MILD", "MODERATE", "SEVERE"],
                        "description": "Severity of the abnormal finding"
                    },
                    "concerns": {
                        "type": "string",
                        "description": "Potential health concerns related to this abnormal value"
                    }
                },
                "required": ["test_name", "status", "severity"]
            }
        },
        "interpretation": {
            "type": "string",
            "description": "Overall interpretation of lab results in plain language"
        },
        
        "recommended_supplements": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "Name of recommended supplement or medicine"
                    },
                    "dosage": {
                        "type": "string",
                        "description": "Recommended dosage (e.g., 1000mg daily)"
                    },
                    "is_prescription": {
                        "type": "boolean",
                        "description": "Whether this requires a prescription (true) or is over-the-counter (false)"
                    },
                    "reason": {
                        "type": "string",
                        "description": "Why this supplement is recommended"
                    },
                    "warnings": {
                        "type": "string",
                        "description": "Any warnings or side effects to be aware of"
                    }
                },
                "required": ["name", "is_prescription", "reason"]
            }
        },
        "lifestyle_recommendations": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "category": {
                        "type": "string",
                        "enum": ["DIET", "EXERCISE", "SLEEP", "OTHER"],
                        "description": "Category of lifestyle recommendation"
                    },
                    "recommendations": {
                        "type": "array",
                        "items": {
                            "type": "string",
                            "description": "Specific recommendation within this category"
                        }
                    }
                },
                "required": ["category", "recommendations"]
            }
        },
        "follow_up_tests": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "test_name": {
                        "type": "string",
                        "description": "Name of recommended follow-up test"
                    },
                    "timeline": {
                        "type": "string",
                        "description": "When this test should be done (e.g., '3 months', 'After medication course')"
                    },
                    "reason": {
                        "type": "string",
                        "description": "Why this follow-up test is recommended"
                    }
                },
                "required": ["test_name", "timeline"]
            }
        },
        "doctor_questions": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "question": {
                        "type": "string",
                        "description": "Question to ask doctor based on these results"
                    },
                    "related_to": {
                        "type": "string",
                        "description": "Which test or finding this question relates to"
                    }
                },
                "required": ["question"]
            }
        },
        "report_tags": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "Tag name for categorizing this report"
                    },
                    "category": {
                        "type": "string",
                        "description": "Category this tag belongs to (e.g., Specialty, Test Type)"
                    }
                },
                "required": ["name"]
            }
        }
    },
    "required": ["summary", "test_results"]
}

# Enhanced schema for prescription structured output with new feature fields
PRESCRIPTION_SCHEMA = {
    "type": "object",
    "properties": {
        "summary": {
            "type": "string",
            "description": "Brief overview of the prescription in human-friendly language"
        },
        "medications": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "Name of the medication"
                    },
                    "dosage": {
                        "type": "string",
                        "description": "Dosage amount and units (e.g., 10mg, 5ml)"
                    },
                    "form": {
                        "type": "string",
                        "description": "Form of the medication (e.g., tablet, capsule, liquid)"
                    },
                    "frequency": {
                        "type": "string",
                        "description": "How often to take (e.g., twice daily, every 8 hours)"
                    },
                    "duration": {
                        "type": "string",
                        "description": "How long to take the medication (e.g., for 10 days, until finished)"
                    },
                    "instructions": {
                        "type": "string",
                        "description": "Special instructions for taking this medication"
                    }
                },
                "required": ["name"]
            }
        },
        "general_instructions": {
            "type": "array",
            "items": {
                "type": "string",
                "description": "General instructions for all medications"
            }
        },
        "warnings": {
            "type": "array",
            "items": {
                "type": "string",
                "description": "Warnings or precautions"
            }
        },
        "prescription_details": {
            "type": "object",
            "properties": {
                "date": {
                    "type": "string",
                    "description": "Date the prescription was written"
                },
                "prescribed_by": {
                    "type": "string",
                    "description": "Name or identifier of prescriber (no personal details)"
                },
                "refills": {
                    "type": "string",
                    "description": "Number of refills allowed"
                }
            }
        },
        
        "lifestyle_recommendations": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "category": {
                        "type": "string",
                        "enum": ["DIET", "EXERCISE", "SLEEP", "OTHER"],
                        "description": "Category of lifestyle recommendation"
                    },
                    "recommendations": {
                        "type": "array",
                        "items": {
                            "type": "string",
                            "description": "Specific recommendation within this category"
                        }
                    }
                },
                "required": ["category", "recommendations"]
            }
        },
        "doctor_questions": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "question": {
                        "type": "string",
                        "description": "Question to ask doctor related to this prescription"
                    },
                    "related_to": {
                        "type": "string",
                        "description": "Which medication or condition this question relates to"
                    }
                },
                "required": ["question"]
            }
        },
        "report_tags": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "Tag name for categorizing this prescription"
                    },
                    "category": {
                        "type": "string",
                        "description": "Category this tag belongs to (e.g., Medication Type, Condition)"
                    }
                },
                "required": ["name"]
            }
        }
    },
    "required": ["summary", "medications"]
}

@app.get("/")
async def root():
    return {"message": "OCR and AI API is running"}

def preprocess_image(img, scale_factor=1.5, is_handwritten=False):
    """Apply advanced preprocessing techniques to enhance OCR accuracy"""
    # Check for extremely large images and resize if necessary
    max_dimension = 3000  # Set a maximum dimension
    height, width = img.shape[:2]
    if height > max_dimension or width > max_dimension:
        # Calculate new dimensions while preserving aspect ratio
        if height > width:
            new_height = max_dimension
            new_width = int(width * (max_dimension / height))
        else:
            new_width = max_dimension
            new_height = int(height * (max_dimension / width))
        img = cv2.resize(img, (new_width, new_height), interpolation=cv2.INTER_AREA)
        
    # Continue with regular preprocessing
    # Resize image to zoom in (scale up) for better detail capture
    height, width = img.shape[:2]
    new_height, new_width = int(height * scale_factor), int(width * scale_factor)
    img = cv2.resize(img, (new_width, new_height), interpolation=cv2.INTER_CUBIC)
    
    # Convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Enhance contrast using CLAHE (Contrast Limited Adaptive Histogram Equalization)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(gray)
    
    # Apply bilateral filter to reduce noise while preserving edges
    filtered = cv2.bilateralFilter(enhanced, 9, 75, 75)
    
    if is_handwritten:
        # Special processing for handwritten text
        # Sharpen the image to enhance handwriting strokes
        kernel = np.array([[-1, -1, -1], [-1, 9, -1], [-1, -1, -1]])
        sharpened = cv2.filter2D(filtered, -1, kernel)
        
        # Apply Otsu's thresholding for handwritten content
        _, thresh = cv2.threshold(sharpened, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        
        # Apply morphological operations to connect broken strokes in handwriting
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2, 2))
        closed = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)
        
        return closed
    else:
        # For printed text, use adaptive thresholding
        thresh = cv2.adaptiveThreshold(
            filtered, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
            cv2.THRESH_BINARY, 11, 2
        )
        
        # Denoise the image
        denoised = cv2.fastNlMeansDenoising(thresh, None, 10, 7, 21)
        
        return denoised

async def extract_text_from_pdf(file_path: str) -> str:
    """Extract text from PDF with robust fallbacks"""
    try:
        # Try with pdf2image first (requires poppler)
        try:
            images = pdf2image.convert_from_path(file_path, dpi=300)
            extracted_texts = []
            
            for i, img in enumerate(images):
                img_np = np.array(img)
                img_np = cv2.cvtColor(img_np, cv2.COLOR_RGB2BGR)
                preprocessed = preprocess_image(img_np)
                results = reader.readtext(preprocessed, paragraph=True)
                page_text = " ".join([result[1] for result in results])
                
                if not page_text.strip():
                    page_text = pytesseract.image_to_string(Image.fromarray(preprocessed))
                
                extracted_texts.append(f"[Page {i+1}]: {page_text}")
            
            return "\n\n".join(extracted_texts)
        
        except Exception as e:
            if "poppler" in str(e).lower():
                # Try PyPDF2 as a fallback (no images but can extract text)
                try:
                    import PyPDF2
                    with open(file_path, "rb") as pdf_file:
                        reader = PyPDF2.PdfReader(pdf_file)
                        text = ""
                        for i, page in enumerate(reader.pages):
                            page_text = page.extract_text() or ""
                            text += f"[Page {i+1}]: {page_text}\n\n"
                        return text
                except Exception:
                    # Last resort: Use pdfplumber as a fallback
                    try:
                        import pdfplumber
                        text = ""
                        with pdfplumber.open(file_path) as pdf:
                            for i, page in enumerate(pdf.pages):
                                text += f"[Page {i+1}]: {page.extract_text() or ''}\n\n"
                        return text
                    except Exception:
                        raise ValueError("Failed to extract text from PDF. Please install poppler-utils or upload a different file format.")
            else:
                raise e
    except Exception as e:
        raise ValueError(f"PDF extraction error: {str(e)}")

async def extract_text_from_file(file: UploadFile) -> str:
    """Extract text from various file formats (image, PDF, DOCX)"""
    file_extension = os.path.splitext(file.filename)[1].lower() if file.filename else ""
    
    with tempfile.NamedTemporaryFile(delete=False) as temp_file:
        # Read the file data
        file_data = await file.read()
        temp_file.write(file_data)
        temp_path = temp_file.name
    
    try:
        # Process PDF files with enhanced error handling
        if file_extension == ".pdf":
            return await extract_text_from_pdf(temp_path)
            
        # Process DOCX files
        elif file_extension == ".docx":
            return docx2txt.process(temp_path)
            
        # Process image files (png, jpg, jpeg, etc.)
        else:
            try:
                img = cv2.imread(temp_path)
                if img is None:
                    raise ValueError("Could not read image")
                
                # First try EasyOCR with preprocessing
                preprocessed = preprocess_image(img)
                results = reader.readtext(preprocessed, paragraph=True)
                extracted_text = " ".join([result[1] for result in results])
                
                # If that doesn't work well, try the original image
                if not extracted_text.strip():
                    results = reader.readtext(img, paragraph=True)
                    extracted_text = " ".join([result[1] for result in results])
                
                # If EasyOCR doesn't work well, try Tesseract as fallback
                if not extracted_text.strip():
                    preprocessed_pil = Image.fromarray(preprocessed)
                    extracted_text = pytesseract.image_to_string(preprocessed_pil)
                    
                    # If still no results, try with original image
                    if not extracted_text.strip():
                        img_pil = Image.fromarray(img)
                        extracted_text = pytesseract.image_to_string(img_pil)
                
                return extracted_text
                
            except Exception as e:
                raise HTTPException(status_code=400, detail=f"Unsupported file format or corrupted file: {str(e)}")
    finally:
        # Clean up temporary file
        if os.path.exists(temp_path):
            os.unlink(temp_path)

def identify_document_type(text):
    """Enhanced document type identification with more robust patterns"""
    text_lower = text.lower()
    
    # Check for prescription indicators with more patterns
    prescription_keywords = [
        'prescription', 'rx', 'rx#', 'dosage', 'take', 'medicine', 'medication',
        'prescribed', 'pharmacy', 'refill', 'tablets', 'capsules', 'oral', 'topical',
        'mg', 'mcg', 'ml', 'once daily', 'twice daily', 'three times daily',
        'physician', 'dr\\.', 'doctor', 'dispense', 'substitution'
    ]
    
    # Enhanced lab report indicators
    lab_report_keywords = [
        'laboratory', 'lab report', 'test results', 'specimen', 'reference range',
        'blood test', 'urine test', 'cholesterol', 'glucose', 'wbc', 'rbc', 'hgb',
        'hemoglobin', 'hba1c', 'creatinine', 'normal range', 'reference', 'panel',
        'hematology', 'chemistry', 'lipid', 'thyroid', 'abnormal', 'elevated',
        'complete blood count', 'metabolic panel'
    ]
    
    # Calculate scores with weighted terms
    prescription_score = 0
    lab_report_score = 0
    
    for keyword in prescription_keywords:
        if keyword in text_lower:
            # Give higher weight to strong indicators
            if keyword in ['prescription', 'rx', 'prescribed', 'dosage', 'pharmacy']:
                prescription_score += 2
            else:
                prescription_score += 1
    
    for keyword in lab_report_keywords:
        if keyword in text_lower:
            # Give higher weight to strong indicators
            if keyword in ['laboratory', 'lab report', 'test results', 'reference range']:
                lab_report_score += 2
            else:
                lab_report_score += 1
    
    # Look for patterns typical in prescriptions
    if re.search(r'take\s+\d+\s+tablet', text_lower) or re.search(r'\d+\s+times?\s+daily', text_lower):
        prescription_score += 3
        
    # Look for patterns typical in lab reports
    if re.search(r'\b\d+\s*[-–]\s*\d+\s*[a-zA-Z\/]+\b', text_lower) or re.search(r'reference range', text_lower):
        lab_report_score += 3
    
    # Determine document type based on keyword matches
    if prescription_score > lab_report_score:
        return "prescription"
    elif lab_report_score > prescription_score:
        return "lab_report"
    else:
        return "unknown"

def redact_personal_info(text):
    """Enhanced redaction of potentially personal information from extracted text"""
    # Redact potential phone numbers with international formats
    text = re.sub(r'\b(?:\+?1[-. ]?)?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})\b', '[PHONE REDACTED]', text)
    
    # Redact potential emails with various domains
    text = re.sub(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', '[EMAIL REDACTED]', text)
    
    # Redact potential SSNs with various formats
    text = re.sub(r'\b\d{3}[-. ]?\d{2}[-. ]?\d{4}\b', '[SSN REDACTED]', text)
    
    # Redact dates of birth
    text = re.sub(r'\b(?:DOB|Date of Birth|Birth Date)[:;]\s*\d{1,2}[-/]\d{1,2}[-/]\d{2,4}\b', '[DOB REDACTED]', text)
    text = re.sub(r'\b(?:DOB|Date of Birth|Birth Date)[:;]\s*\w+ \d{1,2},? \d{4}\b', '[DOB REDACTED]', text)
    
    # Redact potential addresses
    text = re.sub(r'\b\d{1,5}\s+[A-Za-z0-9\s,.]+(?:Avenue|Ave|Boulevard|Blvd|Street|St|Road|Rd|Lane|Ln|Drive|Dr|Court|Ct|Place|Pl|Terrace|Ter)(?:\s+[A-Za-z0-9\s,.]*)?\b', '[ADDRESS REDACTED]', text, flags=re.IGNORECASE)
    
    return text

@app.post("/extract_text/")
async def extract_text(file: UploadFile = File(...), document_type: str = Form("lab_report")):
    """Extract text from various file formats and process with Groq AI"""
    try:
        # Check if the file has a supported extension
        filename = file.filename.lower() if file.filename else ""
        if not any(filename.endswith(ext) for ext in ['.jpg', '.jpeg', '.png', '.pdf', '.docx', '.bmp', '.tiff', '.tif', '.webp']):
            raise HTTPException(status_code=400, detail="Unsupported file format. Please upload an image, PDF, or DOCX file.")
        
        # Extract text from the file
        extracted_text = await extract_text_from_file(file)
        
        if not extracted_text or len(extracted_text.strip()) < 10:
            raise HTTPException(status_code=400, detail="Could not extract sufficient text from the file. Please try a clearer image or document.")
        
        # Redact potential personal information
        redacted_text = redact_personal_info(extracted_text)
        
        # Use provided document type instead of detection
        doc_type = document_type
        
        # Use automatic detection as fallback if "auto" is provided
        if doc_type == "auto":
            doc_type = identify_document_type(redacted_text)
        
        # Enhanced prompts for more comprehensive analysis
        if doc_type == "prescription":
            system_prompt = """You are a medical assistant AI specialized in interpreting prescriptions. 
            Analyze the provided prescription text and extract the information according to the specified JSON schema.
            
            IMPORTANT GUIDELINES:
            - Create a human-friendly summary that explains the prescription's purpose
            - NEVER include any personal information like patient names, addresses, or contact details
            - Add lifestyle recommendations based on common advice for patients on these medications
            - Suggest doctor questions the patient should ask about this prescription
            - Add relevant tags to categorize this prescription
            - If information is unclear or missing, use null values rather than guessing
            - Provide warnings about medication interactions or side effects where relevant
            """
            
            schema = json.dumps(PRESCRIPTION_SCHEMA, indent=2)
            
            # Use function calling format in Groq to get structured output
            completion = client.chat.completions.create(
                model="meta-llama/llama-4-scout-17b-16e-instruct",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"Extract information from this prescription according to the schema. Use strict JSON format.\n\nSCHEMA: {schema}\n\nPRESCRIPTION TEXT: {redacted_text}"}
                ],
                temperature=0.1,  # Lower temperature for more consistent results
                max_completion_tokens=2048,
                top_p=1,
                response_format={"type": "json_object"}
            )
            
        elif doc_type == "lab_report":
            system_prompt = """You are a medical assistant AI specialized in interpreting laboratory reports. 
            Analyze the provided lab report text and extract the information according to the specified JSON schema.
            
            IMPORTANT GUIDELINES:
            - Create a human-friendly executive summary that explains key findings in plain language
            - Categorize abnormal values with severity levels (MILD, MODERATE, SEVERE)
            - Suggest appropriate supplements or medications based on test results
            - Provide lifestyle and diet recommendations specific to these lab results
            - Recommend follow-up tests that would complement these findings
            - Generate questions the patient should ask their doctor
            - Add relevant tags to categorize this report
            - NEVER include any personal information like patient names, addresses, or contact details
            """
            
            schema = json.dumps(LAB_REPORT_SCHEMA, indent=2)
            
            # Use function calling format in Groq to get structured output
            completion = client.chat.completions.create(
                model="meta-llama/llama-4-scout-17b-16e-instruct",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"Extract information from this lab report according to the schema. Use strict JSON format.\n\nSCHEMA: {schema}\n\nLAB REPORT TEXT: {redacted_text}"}
                ],
                temperature=0.1,  # Lower temperature for more consistent results
                max_completion_tokens=2048,
                top_p=1,
                response_format={"type": "json_object"}
            )
            
        else:
            # Use regular prompt for non-specific medical documents
            system_prompt = """You are a medical assistant AI specialized in interpreting medical documents. 
            Analyze the provided medical document text and extract key information:

            ## TASK
            Identify the document type first, then extract and organize relevant medical information:
            1. DOCUMENT TYPE: Determine what kind of medical document this is
            2. KEY INFORMATION: Extract the most important medical details
            3. MEDICAL TERMS: Explain any specialized medical terminology
            4. SUMMARY: Provide a concise, plain-language overview
            
            ## IMPORTANT GUIDELINES
            - NEVER include any personal information like patient names, addresses, or contact details
            - Organize information in a logical, easy-to-understand format
            - Highlight important medical findings or recommendations
            - If information is unclear or missing, indicate this rather than guessing
            - Use formatting to improve readability
            """
            
            # Process with Groq AI using enhanced prompting
            completion = client.chat.completions.create(
                model="meta-llama/llama-4-scout-17b-16e-instruct",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"Here is the text extracted from a medical document. Please analyze it according to the instructions:\n\n{redacted_text}"}
                ],
                temperature=0.5,
                max_completion_tokens=1024,
                top_p=1
            )
        
        # Process AI response
        ai_response = completion.choices[0].message.content
        
        # For structured responses, validate JSON
        structured_data = None
        if doc_type in ["prescription", "lab_report"]:
            try:
                structured_data = json.loads(ai_response)
            except json.JSONDecodeError:
                # If JSON parsing fails, try to extract JSON from the text
                json_match = re.search(r'```json\s*(.*?)\s*```', ai_response, re.DOTALL)
                if json_match:
                    try:
                        structured_data = json.loads(json_match.group(1))
                    except json.JSONDecodeError:
                        structured_data = None
        
        # Generate a session ID
        session_id = str(uuid.uuid4())
        
        # Store the extracted text and initial conversation for this session
        sessions[session_id] = {
            "extracted_text": redacted_text,
            "document_type": doc_type,
            "structured_data": structured_data,
            "conversation": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"Here is the text extracted from a medical document: {redacted_text}"},
                {"role": "assistant", "content": ai_response}
            ]
        }
        
        # Return response with structured data if available
        response = {
            "session_id": session_id,
            "document_type": doc_type,
            "extracted_text": redacted_text,
            "initial_analysis": ai_response
        }
        
        if structured_data:
            response["structured_data"] = structured_data
            
        return response
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing document: {str(e)}")

@app.post("/chat/{session_id}")
async def chat(session_id: str, message: Dict[str, Any] = Body(...)):
    """Chat with AI using the context from the extracted text"""
    if session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    user_message = message.get("message", "")
    if not user_message:
        raise HTTPException(status_code=400, detail="Message cannot be empty")
    
    # Get the conversation history and context from the session
    conversation = sessions[session_id]["conversation"]
    doc_type = sessions[session_id]["document_type"]
    extracted_text = sessions[session_id]["extracted_text"]
    structured_data = sessions[session_id].get("structured_data")
    
    # Choose schema based on document type for structured responses
    use_schema = False
    schema_definition = None
    
    if "extract" in user_message.lower() or "summarize" in user_message.lower() or "list" in user_message.lower():
        use_schema = True
        if doc_type == "prescription":
            schema_definition = json.dumps(PRESCRIPTION_SCHEMA, indent=2)
        elif doc_type == "lab_report":
            schema_definition = json.dumps(LAB_REPORT_SCHEMA, indent=2)
    
    # Enhanced context reminder with document type, extracted text, and structured data
    if doc_type == "prescription":
        context_reminder = """You are analyzing a prescription document. 
        Remember the extracted information while answering additional questions.
        Maintain medical accuracy and refer to the structured data when relevant."""
    elif doc_type == "lab_report":
        context_reminder = """You are analyzing a laboratory report document. 
        Remember the extracted information while answering additional questions.
        Maintain medical accuracy when discussing test results and explain medical terms clearly."""
    else:
        context_reminder = """You are analyzing a medical document. 
        Remember the extracted information while answering additional questions.
        Maintain medical accuracy and clarity in your responses."""
    
    # Add structured data to the context if available
    structured_data_reminder = ""
    if structured_data:
        structured_data_summary = json.dumps(structured_data, indent=2)
        structured_data_reminder = f"\n\nStructured data extracted from the document:\n{structured_data_summary}"
    
    # Add a reminder of the extracted text (truncated to avoid token limits)
    text_reminder = f"Extracted text (truncated): {extracted_text[:200]}..."
    
    # Add an enhanced context message at the beginning if it's getting too long
    if len(conversation) > 6:  # Check if conversation is getting long
        # Replace the old context with a fresh one to avoid token limits
        conversation = [
            {"role": "system", "content": conversation[0]["content"]},
            {"role": "user", "content": f"{context_reminder}\n\n{text_reminder}{structured_data_reminder}"},
            {"role": "assistant", "content": "I'll continue assisting you with this medical document, keeping in mind the extracted information and our previous discussion."},
            # Keep the last 4 messages for immediate context
            conversation[-4],
            conversation[-3],
            conversation[-2],
            conversation[-1]
        ]
    
    # Add the new user message with better context
    conversation.append({
        "role": "user", 
        "content": f"Question about the medical document: {user_message}"
    })
    
    # Send to Groq AI with conversation context
    try:
        if use_schema and schema_definition:
            completion = client.chat.completions.create(
                model="meta-llama/llama-4-scout-17b-16e-instruct",
                messages=conversation,
                temperature=0.5,
                max_completion_tokens=1024,
                top_p=1,
                response_format={"type": "json_object"}
            )
        else:
            completion = client.chat.completions.create(
                model="meta-llama/llama-4-scout-17b-16e-instruct",
                messages=conversation,
                temperature=0.7,
                max_completion_tokens=1024,
                top_p=1,
            )
        
        # Get the response
        ai_response = completion.choices[0].message.content
        
        # Add the AI response to the conversation
        conversation.append({"role": "assistant", "content": ai_response})
        
        # Update the session
        sessions[session_id]["conversation"] = conversation
        
        return {"response": ai_response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error from AI service: {str(e)}")

@app.get("/drugs")
async def get_drugs(search: str = "", limit: int = 20, page: int = 0, id: str = ""):
    """Fetch drugs from MongoDB with pagination and search"""
    try:
        # If an ID is provided, fetch that specific drug
        if id:
            drug = drugs_collection.find_one({"_id": id})
            if drug:
                # Convert ObjectId to string
                drug["_id"] = str(drug["_id"])
                return {"drug": drug}
            return {"drug": None}

        # Create a search query
        query = {}
        if search:
            query = {"title": {"$regex": search, "$options": "i"}}

        # Fetch drugs with pagination
        drugs = list(drugs_collection.find(query)
                    .sort("title", 1)
                    .skip(page * limit)
                    .limit(limit))
        
        # Convert ObjectId to string for JSON serialization
        for drug in drugs:
            drug["_id"] = str(drug["_id"])

        # Get total count for pagination
        total = drugs_collection.count_documents(query)

        return {
            "drugs": drugs,
            "total": total,
            "page": page,
            "limit": limit,
            "totalPages": (total + limit - 1) // limit
        }
    except Exception as e:
        return {"error": f"Failed to fetch drugs: {str(e)}"}, 500

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
