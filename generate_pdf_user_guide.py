import os
import sys
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY

class NumberedCanvas(canvas.Canvas):
    """
    Two-pass canvas that computes total page count dynamically
    and paints corporate running headers and footers on pages 2+.
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        if self._pageNumber == 1:
            # Suppress running header/footer on cover page
            return

        self.saveState()
        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(colors.HexColor("#475569"))

        # Running Header
        self.drawString(40, 755, "ANTIGRAVITY ENTERPRISE DQMS  |  PRODUCTION CUSTOMER USER GUIDE")
        self.setFont("Helvetica", 8)
        self.drawRightString(572, 755, "VERSION 1.1.0 (ENTERPRISE RESILIENCE)")
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.6)
        self.line(40, 747, 572, 747)

        # Running Footer
        self.line(40, 42, 572, 42)
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))
        self.drawString(40, 30, "CONFIDENTIAL & PROPRIETARY  •  ANTIGRAVITY ENTERPRISE SYSTEMS INC.")
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(572, 30, page_str)
        self.restoreState()


def build_pdf():
    pdf_filename = "DQMS_Enterprise_User_Guide.pdf"
    doc = SimpleDocTemplate(
        pdf_filename,
        pagesize=letter,
        rightMargin=40,
        leftMargin=40,
        topMargin=55,
        bottomMargin=55
    )

    styles = getSampleStyleSheet()

    # Premium Enterprise Palette
    c_primary = colors.HexColor("#1E40AF")     # Deep Corporate Blue
    c_secondary = colors.HexColor("#3B82F6")   # Electric Accent
    c_dark = colors.HexColor("#0F172A")        # Slate 900
    c_surface = colors.HexColor("#1E293B")     # Slate 800
    c_text = colors.HexColor("#1E293B")        # Charcoal body
    c_muted = colors.HexColor("#64748B")       # Slate 500
    c_border = colors.HexColor("#CBD5E1")      # Slate 300
    c_bg_subtle = colors.HexColor("#F8FAFC")   # Slate 50
    c_green = colors.HexColor("#059669")       # Emerald 600
    c_amber = colors.HexColor("#D97706")       # Amber 600
    c_red = colors.HexColor("#DC2626")         # Rose 600
    c_purple = colors.HexColor("#7C3AED")      # Violet 600

    # Custom Typography Styles
    style_cover_badge = ParagraphStyle(
        'CoverBadge',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=12,
        textColor=c_primary,
        alignment=TA_CENTER
    )

    style_cover_title = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=26,
        leading=32,
        textColor=c_dark,
        alignment=TA_CENTER
    )

    style_cover_sub = ParagraphStyle(
        'CoverSub',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=13,
        leading=18,
        textColor=c_muted,
        alignment=TA_CENTER
    )

    style_h1 = ParagraphStyle(
        'H1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=15,
        leading=19,
        textColor=c_primary,
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True
    )

    style_h2 = ParagraphStyle(
        'H2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=11.5,
        leading=15,
        textColor=c_surface,
        spaceBefore=9,
        spaceAfter=4,
        keepWithNext=True
    )

    style_h3 = ParagraphStyle(
        'H3',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=13,
        textColor=colors.HexColor("#334155"),
        spaceBefore=6,
        spaceAfter=2,
        keepWithNext=True
    )

    style_body = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12.5,
        textColor=c_text,
        spaceBefore=2.5,
        spaceAfter=3.5
    )

    style_body_bold = ParagraphStyle(
        'BodyBold',
        parent=style_body,
        fontName='Helvetica-Bold'
    )

    style_callout = ParagraphStyle(
        'Callout',
        parent=styles['Normal'],
        fontName='Helvetica-Oblique',
        fontSize=8,
        leading=11.5,
        textColor=colors.HexColor("#0F172A")
    )

    style_code = ParagraphStyle(
        'CodeStyle',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=7.5,
        leading=9.5,
        textColor=colors.HexColor("#1E293B")
    )

    style_code_bold = ParagraphStyle(
        'CodeStyleBold',
        parent=styles['Normal'],
        fontName='Courier-Bold',
        fontSize=7.5,
        leading=9.5,
        textColor=c_primary
    )

    style_table_header = ParagraphStyle(
        'TableHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10.5,
        textColor=colors.white
    )

    style_table_cell = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.5,
        leading=10.5,
        textColor=c_text
    )

    style_table_cell_bold = ParagraphStyle(
        'TableCellBold',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=10.5,
        textColor=c_text
    )

    story = []

    # =========================================================================
    # COVER PAGE
    # =========================================================================
    story.append(Spacer(1, 20))
    story.append(Paragraph("★ ENTERPRISE PRODUCTION RELEASE • V1.1.0 RESILIENCE & OPERATIONS EDITION ★", style_cover_badge))
    story.append(Spacer(1, 8))
    story.append(Paragraph("AntiGravity Enterprise DQMS", style_cover_title))
    story.append(Spacer(1, 6))
    story.append(Paragraph("Digital Queue Management System — Complete Operations & Customer User Guide", style_cover_sub))
    story.append(Spacer(1, 14))
    story.append(HRFlowable(width="100%", thickness=2.5, color=c_primary, spaceBefore=2, spaceAfter=14))

    # Cover Summary Box
    doc_meta_data = [
        [Paragraph("<b>Document Title:</b>", style_table_cell_bold), Paragraph("Enterprise Production Operations & Complete Customer Manual", style_table_cell),
         Paragraph("<b>Target Roles:</b>", style_table_cell_bold), Paragraph("Visitors, Tellers, Shift Supervisors, Safety Officers, IT Admins", style_table_cell)],
        [Paragraph("<b>Product Version:</b>", style_table_cell_bold), Paragraph("v1.1.0 Commercial Enterprise Release", style_table_cell),
         Paragraph("<b>Backend Engine:</b>", style_table_cell_bold), Paragraph("C# .NET 8 Web API + Dapper Micro-ORM", style_table_cell)],
        [Paragraph("<b>Primary Database:</b>", style_table_cell_bold), Paragraph("MySQL 8.0 (`dnaqms`) & MSSQL LocalDB", style_table_cell),
         Paragraph("<b>Edge Resilience:</b>", style_table_cell_bold), Paragraph("SQLite Autonomous Local Replicas (`edge_dqms.db`)", style_table_cell)],
        [Paragraph("<b>Security Standard:</b>", style_table_cell_bold), Paragraph("PBKDF2-SHA256, 512-bit JWT & HMAC-SHA256", style_table_cell),
         Paragraph("<b>Signage & Safety:</b>", style_table_cell_bold), Paragraph("Audio-Ducked Video Promos & PIN Emergency Override", style_table_cell)]
    ]
    t_doc_meta = Table(doc_meta_data, colWidths=[95, 170, 95, 172])
    t_doc_meta.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), c_bg_subtle),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_doc_meta)
    story.append(Spacer(1, 10))

    # Revision History
    story.append(Paragraph("Document Control & Revision History:", style_h2))
    rev_data = [
        [Paragraph("Version", style_table_header), Paragraph("Date", style_table_header), Paragraph("Primary Authors", style_table_header), Paragraph("Approved By", style_table_header), Paragraph("Summary of Operational Scope", style_table_header)],
        [Paragraph("<b>v0.9.0</b>", style_table_cell_bold), Paragraph("Oct 2026", style_table_cell), Paragraph("Architecture Team", style_table_cell), Paragraph("Lead Architect", style_table_cell), Paragraph("Initial Prototype specification and UI mockups.", style_table_cell)],
        [Paragraph("<b>v1.0.0</b>", style_table_cell_bold), Paragraph("Nov 2026", style_table_cell), Paragraph("Full-Stack Eng.", style_table_cell), Paragraph("QA Manager", style_table_cell), Paragraph("Commercial Production Release: Authenticated PBKDF2 engine, route aliases, seeded TV templates, local disk storage.", style_table_cell)],
        [Paragraph("<b>v1.1.0</b>", style_table_cell_bold), Paragraph("Nov 2026", style_table_cell), Paragraph("Enterprise Systems", style_table_cell), Paragraph("Chief Info Officer", style_table_cell), Paragraph("<b>Enterprise Operations Edition:</b> Comprehensive 'How to Use It' guides for N-Level Workflows, Webhook Engine with HMAC, Offline Edge Resilience, and PIN-verified Emergency Broadcasts.", style_table_cell)],
    ]
    t_rev = Table(rev_data, colWidths=[48, 55, 95, 85, 249])
    t_rev.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_surface),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(t_rev)
    story.append(Spacer(1, 10))

    # Executive Overview
    story.append(Paragraph("Executive System Overview:", style_h2))
    story.append(Paragraph(
        "The AntiGravity Digital Queue Management System (DQMS) is a multi-tier, zero-deadlock facility orchestration and customer flow automation platform designed for high-density public venues including Hospitals, Outpatient Clinics, Banking Networks, Telecom Flagships, and Municipal Service Centers.",
        style_body
    ))
    story.append(Paragraph(
        "DQMS unifies self-service touchscreen kiosks, mobile QR code real-time tracking, 4K split-screen waiting room TVs with digital signage, rapid-dispatch staff consoles with POS keyboard hotkeys, automated webhook event delivery, and an autonomous offline edge sync engine capable of operating during complete WAN internet blackouts.",
        style_body
    ))

    # =========================================================================
    # SECTION 1: ARCHITECTURE & TOPOLOGY
    # =========================================================================
    story.append(PageBreak())
    story.append(Paragraph("1. System Architecture & Network Topology", style_h1))
    story.append(Paragraph(
        "DQMS follows Clean Architecture and Domain-Driven Design principles, segregating touchpoints, presentation logic, business workflows, and redundant database layers:",
        style_body
    ))

    arch_data = [
        [Paragraph("Architecture Layer", style_table_header), Paragraph("Technology Stack", style_table_header), Paragraph("Core Responsibilities & Capabilities", style_table_header)],
        [
            Paragraph("<b>Presentation Client</b>", style_table_cell_bold),
            Paragraph("Flutter 3.x (Riverpod + Dio)", style_table_cell),
            Paragraph("Single responsive codebase compiled for Web, Mobile, and Desktop. Features glassmorphic high-density layouts, audio-ducked media zone player, offline edge sync status banner, and emergency alert overlays.", style_table_cell)
        ],
        [
            Paragraph("<b>Application & API</b>", style_table_cell_bold),
            Paragraph("C# .NET 8 Web API Core", style_table_cell),
            Paragraph("High-throughput RESTful controllers, strict 512-bit JWT authorization policies, Swagger OpenAPI documentation, HMAC-SHA256 webhook dispatcher, and automated edge sync reconciler.", style_table_cell)
        ],
        [
            Paragraph("<b>Data Access Tier</b>", style_table_cell_bold),
            Paragraph("Dapper Micro-ORM + Stored Procs", style_table_cell),
            Paragraph("Optimized SQL stored procedures (`PR_IU_IssueToken`, `PR_IU_CallNextToken`, `PR_IU_ForwardToken`, `PR_S_PublicDisplayBoard`) ensuring zero transaction deadlocks under heavy concurrent load.", style_table_cell)
        ],
        [
            Paragraph("<b>Database Persistence</b>", style_table_cell_bold),
            Paragraph("MySQL 8.0 & MSSQL LocalDB", style_table_cell),
            Paragraph("Dual database engine support abstracted via `IDapperDBFactory`. Primary production runs on MySQL database `dnaqms` on port 3306.", style_table_cell)
        ],
        [
            Paragraph("<b>Edge Resilience Tier</b>", style_table_cell_bold),
            Paragraph("SQLite Autonomous Replicas", style_table_cell),
            Paragraph("Embedded local SQLite databases (`edge_dqms.db`) deployed on clinic/branch edge nodes. Guarantees 100% uninterrupted ticketing and counter service during WAN failure with automatic replay queue draining.", style_table_cell)
        ],
        [
            Paragraph("<b>File & Asset Storage</b>", style_table_cell_bold),
            Paragraph("Local File Provider + Audit Log", style_table_cell),
            Paragraph("Production-ready local disk storage storing profile avatars, company logos, and digital signage video campaigns in `App_Data/Uploads` with audit logging in `FileAuditLog`.", style_table_cell)
        ]
    ]
    t_arch = Table(arch_data, colWidths=[105, 120, 307])
    t_arch.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_primary),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_arch)
    story.append(Spacer(1, 8))

    # Network Ports & Endpoints
    story.append(Paragraph("Network Topology & Port Map:", style_h2))
    net_data = [
        [Paragraph("Service Component", style_table_header), Paragraph("Host / URL", style_table_header), Paragraph("Port", style_table_header), Paragraph("Protocol / Security Standard", style_table_header)],
        [Paragraph("Backend Web API", style_table_cell), Paragraph("<code>http://localhost</code> (or Server IP)", style_table_cell), Paragraph("5026", style_table_cell), Paragraph("HTTP/HTTPS (Bearer JWT / Master API Key)", style_table_cell)],
        [Paragraph("Flutter Web Frontend", style_table_cell), Paragraph("<code>http://localhost</code>", style_table_cell), Paragraph("8080", style_table_cell), Paragraph("Web Browser (HTML5 Canvas / CanvasKit)", style_table_cell)],
        [Paragraph("MySQL Database Service", style_table_cell), Paragraph("<code>127.0.0.1</code>", style_table_cell), Paragraph("3306", style_table_cell), Paragraph("Native MySQL 8.0 Protocol (Encrypted)", style_table_cell)],
        [Paragraph("Overhead TV Display Feed", style_table_cell), Paragraph("<code>http://[server-ip]:5026/api/v1/public/display-board</code>", style_table_cell), Paragraph("5026", style_table_cell), Paragraph("Public Unauthenticated Stream", style_table_cell)],
        [Paragraph("Mobile QR Web Tracker", style_table_cell), Paragraph("<code>http://[server-ip]:5026/api/v1/public/ticket-status/{id}</code>", style_table_cell), Paragraph("5026", style_table_cell), Paragraph("Public Mobile Browser Stream", style_table_cell)],
        [Paragraph("Edge Node Reconciler", style_table_cell), Paragraph("<code>http://[edge-ip]:5028/api/v1/edge/sync</code>", style_table_cell), Paragraph("5028", style_table_cell), Paragraph("Local Network Encrypted Sync Channel", style_table_cell)],
    ]
    t_net = Table(net_data, colWidths=[110, 185, 45, 192])
    t_net.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_surface),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_net)

    # =========================================================================
    # SECTION 2: PRODUCTION CREDENTIALS & ROLES
    # =========================================================================
    story.append(Spacer(1, 10))
    story.append(Paragraph("2. Production Credentials & Role-Based Access Control", style_h1))
    cred_data = [
        [Paragraph("Credential Type", style_table_header), Paragraph("Identifier / Key", style_table_header), Paragraph("Secret / Password", style_table_header), Paragraph("Assigned Role / Functional Scope", style_table_header)],
        [Paragraph("System Super Admin", style_table_cell_bold), Paragraph("<code>admin@dnaqms.com</code>", style_code_bold), Paragraph("<code>Welc0me@555</code>", style_code), Paragraph("Global Super Admin (Full Configuration & Security RBAC)", style_table_cell)],
        [Paragraph("Shift Supervisor", style_table_cell_bold), Paragraph("<code>supervisor@dnaqms.com</code>", style_code_bold), Paragraph("<code>Welc0me@555</code>", style_code), Paragraph("Queue Oversight, TAT Heatmaps, Emergency Authorization", style_table_cell)],
        [Paragraph("Counter Teller", style_table_cell_bold), Paragraph("<code>teller1@dnaqms.com</code>", style_code_bold), Paragraph("<code>Welc0me@555</code>", style_code), Paragraph("Operational Counter Desk, Call Next, Serve, Forward, Complete", style_table_cell)],
        [Paragraph("Safety / Security Officer", style_table_cell_bold), Paragraph("<code>security@dnaqms.com</code>", style_code_bold), Paragraph("<code>Welc0me@555</code>", style_code), Paragraph("Incident Command, Emergency Broadcast with PIN (9999 / 1234)", style_table_cell)],
        [Paragraph("Master System API Key", style_table_cell_bold), Paragraph("<code>X-Api-Key</code> Header", style_table_cell), Paragraph("<code>dnaqms_live_system_admin_key_112233</code>", style_code), Paragraph("Hardware Kiosks, TV Screens, Automated Webhook Listeners", style_table_cell)],
    ]
    t_cred = Table(cred_data, colWidths=[105, 135, 145, 147])
    t_cred.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_primary),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_cred)

    # =========================================================================
    # SECTION 3: END-TO-END OPERATIONAL GUIDE ("HOW TO USE IT")
    # =========================================================================
    story.append(PageBreak())
    story.append(Paragraph("3. End-to-End Operational Guide ('How to Use It')", style_h1))
    story.append(Paragraph(
        "This section delivers explicit, step-by-step instructions for all facility personas—from walk-in visitors to counter tellers, safety officers, shift supervisors, and IT administrators.",
        style_body
    ))

    # 3.1 Visitor Touchpoints
    story.append(Paragraph("3.1 Walk-In Visitor & Patient Touchpoints", style_h2))
    visitor_steps = [
        [Paragraph("Step #", style_table_header), Paragraph("Customer Action", style_table_header), Paragraph("Touchscreen & System Reaction", style_table_header), Paragraph("Operational Result", style_table_header)],
        [
            Paragraph("<b>1</b>", style_table_cell_bold),
            Paragraph("<b>Select Department</b>", style_table_cell_bold),
            Paragraph("Visitor taps high-contrast service tile on the self-service kiosk (e.g., <i>Doctor Consultation</i>, <i>Phlebotomy Lab</i>, <i>Pharmacy</i>).", style_table_cell),
            Paragraph("Routes ticket into department's specific process queue.", style_table_cell)
        ],
        [
            Paragraph("<b>2</b>", style_table_cell_bold),
            Paragraph("<b>Choose Priority Tier</b>", style_table_cell_bold),
            Paragraph("Selects classification: <b>Standard Walk-In</b>, <b>Senior Citizen (65+)</b>, <b>Specially Abled / Mobility Impaired</b>, or <b>VIP / Emergency</b>.", style_table_cell),
            Paragraph("Applies automatic queue prioritization rank (VIP > Senior > Standard).", style_table_cell)
        ],
        [
            Paragraph("<b>3</b>", style_table_cell_bold),
            Paragraph("<b>Enter Mobile Phone</b> (Optional)", style_table_cell_bold),
            Paragraph("Visitor inputs 10-digit mobile number using numeric on-screen keypad to receive SMS / WhatsApp queue countdown notifications.", style_table_cell),
            Paragraph("Enables automated outbound alerts when 2 customers remain ahead.", style_table_cell)
        ],
        [
            Paragraph("<b>4</b>", style_table_cell_bold),
            Paragraph("<b>Collect Printed Ticket</b>", style_table_cell_bold),
            Paragraph("Thermal printer outputs paper ticket with Token Number (e.g., <b>A-014</b>), Estimated Wait Time (~12 min), and dynamic <b>Mobile QR Code</b>.", style_table_cell),
            Paragraph("Visitor is officially registered; ticket enters <code>Waiting (18001)</code> state.", style_table_cell)
        ],
        [
            Paragraph("<b>5</b>", style_table_cell_bold),
            Paragraph("<b>Mobile Tracking via QR</b>", style_table_cell_bold),
            Paragraph("Visitor scans QR with smartphone camera (iOS/Android). Displays real-time countdown of visitors ahead without downloading an app.", style_table_cell),
            Paragraph("Phone vibrates and turns emerald green when teller calls their ticket.", style_table_cell)
        ],
        [
            Paragraph("<b>6</b>", style_table_cell_bold),
            Paragraph("<b>Appointment Check-In</b>", style_table_cell_bold),
            Paragraph("Pre-booked patients tap <i>'Check-In Appointment'</i> at kiosk bottom and input their 6-digit confirmation code.", style_table_cell),
            Paragraph("Issues an expedited appointment token directly into teller's priority queue.", style_table_cell)
        ],
    ]
    t_visitor = Table(visitor_steps, colWidths=[35, 110, 227, 160])
    t_visitor.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_surface),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_visitor)
    story.append(Spacer(1, 8))

    # 3.2 Staff Counter Station
    story.append(Paragraph("3.2 Staff & Counter Teller Station Console (/staff/counter)", style_h2))
    story.append(Paragraph(
        "The teller console is engineered for maximum throughput, allowing staff to execute all queue actions via physical POS keyboard hotkeys without touching a mouse:",
        style_body
    ))

    hotkey_data = [
        [Paragraph("Physical Key", style_table_header), Paragraph("Command Action", style_table_header), Paragraph("Resulting Token State", style_table_header), Paragraph("Operational Behavior & Impact on Waiting Hall", style_table_header)],
        [Paragraph("<b>`SPACEBAR`</b>", style_table_cell_bold), Paragraph("<b>Call Next</b>", style_table_cell_bold), Paragraph("<font color='#1E40AF'><b>Calling (18003)</b></font>", style_table_cell), Paragraph("Automatically pulls highest-priority waiting customer (VIP > Senior > Special Needs > Standard FIFO). Instantly flashes TV display and sounds audio chime.", style_table_cell)],
        [Paragraph("<b>`F1`</b>", style_table_cell_bold), Paragraph("<b>Call Next (Alt)</b>", style_table_cell_bold), Paragraph("<font color='#1E40AF'><b>Calling (18003)</b></font>", style_table_cell), Paragraph("Secondary POS-keyboard key for Call Next.", style_table_cell)],
        [Paragraph("<b>`F2`</b>", style_table_cell_bold), Paragraph("<b>Recall Customer</b>", style_table_cell_bold), Paragraph("<font color='#D97706'><b>Calling (18003)</b></font>", style_table_cell), Paragraph("Re-triggers the synthesized audio announcement chime and 30-second flashing pulse on the overhead TV display for absent or distracted visitors.", style_table_cell)],
        [Paragraph("<b>`F3`</b>", style_table_cell_bold), Paragraph("<b>Serve Active</b>", style_table_cell_bold), Paragraph("<font color='#059669'><b>Active (18004)</b></font>", style_table_cell), Paragraph("Customer arrives at counter window. Starts the active service SLA stopwatch (turns amber if duration exceeds process SLA target).", style_table_cell)],
        [Paragraph("<b>`F4`</b>", style_table_cell_bold), Paragraph("<b>Put on Hold</b>", style_table_cell_bold), Paragraph("<font color='#7C3AED'><b>Hold (18005)</b></font>", style_table_cell), Paragraph("Places ticket on temporary hold (e.g., waiting for lab test, payment authorization, or documents). Prompts teller for optional hold notes.", style_table_cell)],
        [Paragraph("<b>`F5`</b>", style_table_cell_bold), Paragraph("<b>Complete & Next</b>", style_table_cell_bold), Paragraph("<font color='#059669'><b>Completed (18007)</b></font>", style_table_cell), Paragraph("<b>Rapid Dispatch Key:</b> Finalizes current ticket, logs exact service duration, and automatically calls next customer in 1 stroke.", style_table_cell)],
        [Paragraph("<b>`F7`</b>", style_table_cell_bold), Paragraph("<b>Cancel / No-Show</b>", style_table_cell_bold), Paragraph("<font color='#DC2626'><b>Canceled (18006)</b></font>", style_table_cell), Paragraph("Cancels ticket after 3 unanswered calls. Flags record as customer no-show for supervisor audit.", style_table_cell)],
    ]
    t_hotkeys = Table(hotkey_data, colWidths=[70, 95, 105, 262])
    t_hotkeys.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_primary),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_hotkeys)

    # 3.3 N-Level Multi-Department Workflow Forwarding
    story.append(PageBreak())
    story.append(Paragraph("3.3 N-Level Multi-Department Workflow Forwarding", style_h1))
    story.append(Paragraph(
        "In healthcare, banking, and public administration, a single customer journey frequently requires sequential routing through multiple service departments (e.g., <b>Registration → Vitals/Triage → Doctor Consultation → Blood Lab → Billing & Pharmacy</b>).",
        style_body
    ))
    story.append(Paragraph(
        "DQMS implements automated N-Level pipeline forwarding backed by stored procedure <code>PR_IU_ForwardToken</code>, transferring customers with clinical notes and priority retention without forcing them to re-queue at kiosks.",
        style_body
    ))

    fwd_steps = [
        [Paragraph("Workflow Action", style_table_header), Paragraph("Operator Interaction", style_table_header), Paragraph("Technical Execution & Data Transformation", style_table_header)],
        [
            Paragraph("<b>1. Open Forward Dialog</b>", style_table_cell_bold),
            Paragraph("While serving active token at counter, click <b>'Forward Ticket'</b> button or press <b>`Ctrl + F`</b>.", style_table_cell),
            Paragraph("Pulls active ticket metadata and retrieves list of eligible target processes.", style_table_cell)
        ],
        [
            Paragraph("<b>2. Select Target Pipeline</b>", style_table_cell_bold),
            Paragraph("Select destination department (e.g., <i>Pathology / Blood Lab</i>) from dropdown.", style_table_cell),
            Paragraph("Can route to general department pool or designate a specific target desk.", style_table_cell)
        ],
        [
            Paragraph("<b>3. Priority Management</b>", style_table_cell_bold),
            Paragraph("Choose whether to retain current priority (e.g. <i>Senior Citizen</i>), escalate to <i>VIP</i>, or adopt default.", style_table_cell),
            Paragraph("Ensures transferred patients receive fair queue placement in destination department.", style_table_cell)
        ],
        [
            Paragraph("<b>4. Enter Handoff Notes</b>", style_table_cell_bold),
            Paragraph("Type operational / clinical notes (e.g., <i>'Patient fasted 12 hours; draw lipid panel and blood glucose immediately'</i>).", style_table_cell),
            Paragraph("Saved directly into `TokenWorkflowHistory` and surfaced on receiving teller's console.", style_table_cell)
        ],
        [
            Paragraph("<b>5. Execute Transfer</b>", style_table_cell_bold),
            Paragraph("Click <b>'Execute Forward'</b>. Current window finishes active service; ticket transitions to destination waiting queue.", style_table_cell),
            Paragraph("Executes `PR_IU_ForwardToken`. Patient's mobile QR tracker automatically updates: <i>'Transferred to Pathology Lab. Proceed to 2nd Floor Waiting Hall.'</i>", style_table_cell)
        ]
    ]
    t_fwd = Table(fwd_steps, colWidths=[120, 160, 252])
    t_fwd.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_surface),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_fwd)
    story.append(Spacer(1, 10))

    # 3.4 4K Waiting Room TV & Digital Signage Media Zone
    story.append(Paragraph("3.4 4K Waiting Room TV Display & Digital Signage Media Zone (/tv)", style_h2))
    story.append(Paragraph(
        "Mounted in public waiting halls, the 4K TV display runs in an intelligent split-screen layout. The left zone presents real-time calling queue tokens, while the right zone plays rich promotional campaigns, healthcare education clips, and commercial media.",
        style_body
    ))

    signage_data = [
        [Paragraph("Feature / Component", style_table_header), Paragraph("Behavioral Specification", style_table_header), Paragraph("Visitor Experience & Impact", style_table_header)],
        [
            Paragraph("<b>Smart Audio Ducking Engine</b>", style_table_cell_bold),
            Paragraph("When a teller presses Space/F2 to call a token, the media player automatically dips background video audio down to <b>15%</b> in 200ms, plays the queue chime, then fades back to 75%.", style_table_cell),
            Paragraph("Guarantees crystal-clear auditory token callouts even during noisy, high-energy promotional video playback.", style_table_cell)
        ],
        [
            Paragraph("<b>Calling Token Flashing Pulse</b>", style_table_cell_bold),
            Paragraph("Newly called tokens trigger a high-visibility, 30-second emerald green and amber pulsing border with enlarged text (<b>A-014 → COUNTER 02</b>).", style_table_cell),
            Paragraph("Attracts immediate visual attention of waiting visitors across large 85-foot public lobbies.", style_table_cell)
        ],
        [
            Paragraph("<b>Campaign Scheduler (/admin/signage)</b>", style_table_cell_bold),
            Paragraph("Facility managers upload 1080p MP4 videos or slideshow images, setting start/end dates, playback durations, and zone assignments.", style_table_cell),
            Paragraph("Ensures targeted promotional content is served to specific building wings (e.g. Pediatrics vs Cardiology).", style_table_cell)
        ]
    ]
    t_signage = Table(signage_data, colWidths=[120, 202, 210])
    t_signage.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_primary),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_signage)

    # 3.5 Public Safety & Emergency Broadcast Console
    story.append(Spacer(1, 10))
    story.append(Paragraph("3.5 Safety & Security: Emergency Broadcast Console (/admin/emergency-broadcast)", style_h2))
    story.append(Paragraph(
        "In critical incidents (Fire Alarms, Code Red/Blue medical emergencies, active security threats, or severe weather evacuations), authorized safety officers can instantly hijack all 4K displays facility-wide with a high-priority emergency overlay.",
        style_body
    ))

    emergency_steps = [
        [Paragraph("Emergency Action", style_table_header), Paragraph("Execution Procedure", style_table_header), Paragraph("Security Verification & System Response", style_table_header)],
        [
            Paragraph("<b>1. Access Emergency Hub</b>", style_table_cell_bold),
            Paragraph("Navigate to <code>/admin/emergency-broadcast</code> from the administrator sidebar or mobile incident console.", style_table_cell),
            Paragraph("Requires Safety Officer, Facility Manager, or Super Admin credentials.", style_table_cell)
        ],
        [
            Paragraph("<b>2. Select Alert Severity</b>", style_table_cell_bold),
            Paragraph("Choose severity: <b>Info (Blue)</b>, <b>Warning (Amber)</b>, <b>Critical Hazard (Red)</b>, or <b>Evacuation (Flashing Crimson)</b>.", style_table_cell),
            Paragraph("Applies appropriate color grading, siren acoustic pattern, and border pulsation.", style_table_cell)
        ],
        [
            Paragraph("<b>3. Compose Evacuation Instructions</b>", style_table_cell_bold),
            Paragraph("Enter Headline (e.g., <i>'FIRE ALARM: EVACUATE NORTH PAVILION'</i>) and step-by-step guidance (<i>'Use Fire Stairs B. Assemble at Lawn 2'</i>).", style_table_cell),
            Paragraph("Supports facility-wide broadcast or targeted building/floor scoping.", style_table_cell)
        ],
        [
            Paragraph("<b>4. Mandatory PIN Security Check</b>", style_table_cell_bold),
            Paragraph("Type the 4-digit <b>Supervisor Safety PIN</b> (default: <code>9999</code> or <code>1234</code>) into the security prompt.", style_table_cell),
            Paragraph("<b>Anti-Panic Gate:</b> The trigger button remains cryptographically disabled until the correct PIN is verified.", style_table_cell)
        ],
        [
            Paragraph("<b>5. Instant Screen Hijack</b>", style_table_cell_bold),
            Paragraph("Tap <b>'TRIGGER BROADCAST'</b>. All 4K overhead TVs immediately suppress queue numbers and render the siren alert banner.", style_table_cell),
            Paragraph("Mutes all commercial video audio and displays full-screen emergency guidance within 500 milliseconds.", style_table_cell)
        ],
        [
            Paragraph("<b>6. Issue 'ALL CLEAR' Dismissal</b>", style_table_cell_bold),
            Paragraph("When the incident is resolved, click <b>'Dismiss Broadcast / Issue ALL CLEAR'</b>, re-enter Supervisor PIN, and confirm.", style_table_cell),
            Paragraph("Restores regular queue calling boards and background signage playback instantly.", style_table_cell)
        ]
    ]
    t_emerg = Table(emergency_steps, colWidths=[110, 202, 220])
    t_emerg.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_red),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_emerg)

    # 3.6 Shift Supervisor Analytics & Heatmaps
    story.append(PageBreak())
    story.append(Paragraph("3.6 Shift Supervisor: TAT Variance & Bottleneck Heatmaps (/admin/analytics)", style_h1))
    story.append(Paragraph(
        "Shift supervisors use the Executive Analytics command center to identify operational bottlenecks before SLA breaches occur:",
        style_body
    ))

    sup_data = [
        [Paragraph("Analytics Metric / Tool", style_table_header), Paragraph("Interpretation & Visual Indicator", style_table_header), Paragraph("Supervisor Remediation Workflow", style_table_header)],
        [
            Paragraph("<b>Average Wait Duration</b>", style_table_cell_bold),
            Paragraph("Time elapsed between kiosk ticket printing and teller Call Next.", style_table_cell),
            Paragraph("If wait exceeds department SLA target (e.g., > 15 min), system flags row in amber.", style_table_cell)
        ],
        [
            Paragraph("<b>Average Service Duration</b>", style_table_cell_bold),
            Paragraph("Time elapsed between teller F3 (Active) and F5 (Completed).", style_table_cell),
            Paragraph("Reveals transaction complexity issues or teller retraining requirements.", style_table_cell)
        ],
        [
            Paragraph("<b>2D Bottleneck Heatmap Grid</b>", style_table_cell_bold),
            Paragraph("Matrix mapping <b>Operating Hours (08:00–18:00)</b> against <b>Service Counters</b> with color grading: Green (< 5m), Amber (5–12m), Red (> 15m).", style_table_cell),
            Paragraph("Supervisor spots peak congestion patterns instantly across morning rush hours.", style_table_cell)
        ],
        [
            Paragraph("<b>Dynamic Staff Reallocation</b>", style_table_cell_bold),
            Paragraph("Click <b>'Reallocate Counter'</b> directly from the heatmap view.", style_table_cell),
            Paragraph("Dynamically shifts an idle Billing teller to Laboratory intake for 90 minutes to eliminate waiting room queues.", style_table_cell)
        ]
    ]
    t_sup = Table(sup_data, colWidths=[120, 202, 210])
    t_sup.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_surface),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_sup)
    story.append(Spacer(1, 10))

    # 3.7 Webhook Notification Engine
    story.append(Paragraph("3.7 IT Administrator: Webhook Notification Engine (/admin/webhooks)", style_h2))
    story.append(Paragraph(
        "The Webhook Engine streams real-time queue events to external enterprise platforms (Hospital Information Systems, Salesforce CRM, Core Banking APIs, or Slack channels):",
        style_body
    ))

    webhook_data = [
        [Paragraph("Operational Step", style_table_header), Paragraph("Configuration Action", style_table_header), Paragraph("Security & Delivery Verification Protocol", style_table_header)],
        [
            Paragraph("<b>1. Register Webhook</b>", style_table_cell_bold),
            Paragraph("Click <b>'+ Register Webhook'</b>. Enter Subscriber Name and Destination Target URL (e.g. <code>https://his.hospital.com/api/dqms-listener</code>).", style_table_cell),
            Paragraph("Configure secret token (minimum 32 alphanumeric characters).", style_table_cell)
        ],
        [
            Paragraph("<b>2. Select Event Topics</b>", style_table_cell_bold),
            Paragraph("Subscribe to specific topics: <code>ticket.issued</code>, <code>ticket.called</code>, <code>ticket.completed</code>, <code>ticket.noshow</code>, <code>sla.breached</code>.", style_table_cell),
            Paragraph("Ensures external systems receive only relevant event streams.", style_table_cell)
        ],
        [
            Paragraph("<b>3. Dispatch Test Ping</b>", style_table_cell_bold),
            Paragraph("Click <b>'Send Test Ping'</b> button in the webhook registry table.", style_table_cell),
            Paragraph("Web API dispatches mock JSON payload. Verifies HTTP 200 OK and records round-trip latency.", style_table_cell)
        ],
        [
            Paragraph("<b>4. HMAC-SHA256 Signature</b>", style_table_cell_bold),
            Paragraph("Outgoing HTTP header: <code>X-DQMS-Signature: sha256=&lt;hash&gt;</code>.", style_table_cell),
            Paragraph("Receiving servers verify authenticity by computing HMAC-SHA256 over raw JSON payload with shared secret.", style_table_cell)
        ],
        [
            Paragraph("<b>5. Exponential Backoff</b>", style_table_cell_bold),
            Paragraph("Automated retry engine on failure: +1m, +5m, +15m, +1h.", style_table_cell),
            Paragraph("Prevents event dropouts during transient network or subscriber outages.", style_table_cell)
        ]
    ]
    t_webhooks = Table(webhook_data, colWidths=[110, 202, 220])
    t_webhooks.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_primary),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_webhooks)
    story.append(Spacer(1, 10))

    # 3.8 Offline Edge Resilience
    story.append(Paragraph("3.8 IT Administrator: Offline Edge Resilience & Hybrid Sync (/admin/edge-nodes)", style_h2))
    story.append(Paragraph(
        "Remote clinics, basement labs, and island branches frequently suffer internet WAN outages. DQMS Edge Resilience deploys embedded SQLite replicas (`edge_dqms.db`) to ensure 100% uninterrupted ticketing and counter service during complete network blackouts.",
        style_body
    ))

    edge_states = [
        [Paragraph("Edge Status Banner", style_table_header), Paragraph("Operating Condition", style_table_header), Paragraph("Autonomous Edge Behavior & Self-Healing Protocol", style_table_header)],
        [
            Paragraph("<font color='#059669'><b>ONLINE</b><br/>Central Connected</font>", style_table_cell_bold),
            Paragraph("Normal WAN connectivity to primary MySQL central database.", style_table_cell),
            Paragraph("Transactions commit to central database in real time. Local edge cache receives asynchronous mirror updates.", style_table_cell)
        ],
        [
            Paragraph("<font color='#D97706'><b>OFFLINE DEGRADED</b><br/>Edge Cache Active</font>", style_table_cell_bold),
            Paragraph("WAN internet dropped; central server unreachable.", style_table_cell),
            Paragraph("<b>Zero Interruption:</b> Kiosks print tickets and tellers call/serve tokens seamlessly via local SQLite. Operations append to local <code>ReplayQueue</code> with unique UUIDs.", style_table_cell)
        ],
        [
            Paragraph("<font color='#3B82F6'><b>SYNCING</b><br/>Reconciling Operations</font>", style_table_cell_bold),
            Paragraph("WAN connectivity restored.", style_table_cell),
            Paragraph("Automatic two-way reconciliation drains <code>ReplayQueue</code> chronologically into central MySQL. Resolves conflicts using server timestamps.", style_table_cell)
        ]
    ]
    t_edge = Table(edge_states, colWidths=[110, 160, 262])
    t_edge.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_surface),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_edge)

    # =========================================================================
    # SECTION 4: ADMINISTRATIVE WORKSPACE
    # =========================================================================
    story.append(PageBreak())
    story.append(Paragraph("4. Administrative Facility Workspaces", style_h1))
    story.append(Paragraph(
        "Accessible via <code>/admin/*</code>, these workspaces give facility managers complete control over physical zones, department routing, counters, digital signage campaigns, and security rules:",
        style_body
    ))

    admin_modules = [
        [Paragraph("Admin Module", style_table_header), Paragraph("Route Path", style_table_header), Paragraph("Configuration Guide & Operational Scope", style_table_header)],
        [
            Paragraph("<b>Areas & Zones</b>", style_table_cell_bold),
            Paragraph("<code>/admin/areas</code>", style_code),
            Paragraph("Defines physical facility sections (e.g., <i>Main Triage</i>, <i>Phlebotomy Lab</i>, <i>Cashier Hall</i>). Configure Area Code, Area Name, and link to parent Location ID. Backed by `PR_IU_Area`.", style_table_cell)
        ],
        [
            Paragraph("<b>Processes & SLAs</b>", style_table_cell_bold),
            Paragraph("<code>/admin/processes</code>", style_code),
            Paragraph("Configures service departments and workflows. Set Token Prefix (e.g. 'A', 'B'), SLA Turnaround Time in minutes (e.g. 15m target), communication channels (SMS, WhatsApp), and daily token issuance quotas. Backed by `PR_IU_Process`.", style_table_cell)
        ],
        [
            Paragraph("<b>Counters & Windows</b>", style_table_cell_bold),
            Paragraph("<code>/admin/counters</code>", style_code),
            Paragraph("Maps physical service desks/windows (e.g. <i>Counter 01</i>, <i>Desk C</i>). Assign counter to an Area ID and define initial status (Available 20001, Serving 20002, Break 20003). Backed by `PR_IU_Counter`.", style_table_cell)
        ],
        [
            Paragraph("<b>Signage Campaigns</b>", style_table_cell_bold),
            Paragraph("<code>/admin/signage</code>", style_code),
            Paragraph("Create promotional media campaigns for waiting room TV media zones. Upload MP4 videos or JPG/PNG banners, configure display schedules, and assign to specific screen zones.", style_table_cell)
        ],
        [
            Paragraph("<b>Emergency Broadcast</b>", style_table_cell_bold),
            Paragraph("<code>/admin/emergency-broadcast</code>", style_code),
            Paragraph("Security and evacuation override hub. Configure alert severity, instructional body, and trigger full-screen TV takeover using supervisor PIN verification.", style_table_cell)
        ],
        [
            Paragraph("<b>Webhook Management</b>", style_table_cell_bold),
            Paragraph("<code>/admin/webhooks</code>", style_code),
            Paragraph("Register outgoing event webhook listeners, test HMAC signatures with live test pings, and inspect delivery attempt audit logs.", style_table_cell)
        ],
        [
            Paragraph("<b>Edge Resilience Nodes</b>", style_table_cell_bold),
            Paragraph("<code>/admin/edge-nodes</code>", style_code),
            Paragraph("Monitor remote clinic edge nodes, view offline replay queue depth, and trigger manual synchronization.", style_table_cell)
        ],
        [
            Paragraph("<b>User Accounts & Staff</b>", style_table_cell_bold),
            Paragraph("<code>/admin/user-profiles</code>", style_code),
            Paragraph("Manages user accounts, resets passwords, and assigns staff to specific service counters and allowed process queues using the dual User-Counter assignment table.", style_table_cell)
        ],
        [
            Paragraph("<b>Navigation Menu Setup</b>", style_table_cell_bold),
            Paragraph("<code>/admin/navigation-menu</code>", style_code),
            Paragraph("Dynamically orders sidebar menu items, assigns icons, and maps required permission claims (`navigationmenu` table) with offline fallback safety.", style_table_cell)
        ],
    ]
    t_admin = Table(admin_modules, colWidths=[105, 125, 302])
    t_admin.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_surface),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_admin)

    # =========================================================================
    # SECTION 5: API & STORED PROCEDURES SPECIFICATION
    # =========================================================================
    story.append(Spacer(1, 10))
    story.append(Paragraph("5. Production API Endpoints & Stored Procedures", style_h1))
    api_specs = [
        [Paragraph("HTTP & Endpoint Path", style_table_header), Paragraph("Controller & Purpose", style_table_header), Paragraph("Database Stored Procedure", style_table_header), Paragraph("Auth Requirements", style_table_header)],
        [Paragraph("<code>POST /api/v1/auth/login</code>", style_code_bold), Paragraph("Authenticate User & Issue JWT", style_table_cell), Paragraph("<code>PR_S_User</code>, <code>UserRole</code>", style_code), Paragraph("Anonymous (Public)", style_table_cell)],
        [Paragraph("<code>GET /api/v1/dqms/admin/areas</code>", style_code_bold), Paragraph("Fetch Facility Areas List", style_table_cell), Paragraph("<code>PR_S_Area</code>", style_code), Paragraph("Bearer JWT / API Key", style_table_cell)],
        [Paragraph("<code>GET /api/v1/dqms/admin/processes</code>", style_code_bold), Paragraph("Fetch Service Processes", style_table_cell), Paragraph("<code>PR_S_Process</code>", style_code), Paragraph("Bearer JWT / API Key", style_table_cell)],
        [Paragraph("<code>GET /api/v1/dqms/admin/counters</code>", style_code_bold), Paragraph("Fetch Counter Stations", style_table_cell), Paragraph("<code>PR_S_Counter</code>", style_code), Paragraph("Bearer JWT / API Key", style_table_cell)],
        [Paragraph("<code>POST /api/v1/staff/issue-token</code>", style_code_bold), Paragraph("Issue New Queue Ticket", style_table_cell), Paragraph("<code>PR_IU_IssueToken</code>", style_code), Paragraph("API Key / Bearer JWT", style_table_cell)],
        [Paragraph("<code>POST /api/v1/dqms/tickets</code>", style_code_bold), Paragraph("Kiosk Route Alias for Issue", style_table_cell), Paragraph("<code>PR_IU_IssueToken</code>", style_code), Paragraph("API Key / Bearer JWT", style_table_cell)],
        [Paragraph("<code>POST /api/v1/staff/call-next</code>", style_code_bold), Paragraph("Teller Hotkey: Call Next", style_table_cell), Paragraph("<code>PR_IU_CallNextToken</code>", style_code), Paragraph("Bearer JWT (Staff)", style_table_cell)],
        [Paragraph("<code>POST /api/v1/staff/forward</code>", style_code_bold), Paragraph("Multi-Step Workflow Forward", style_table_cell), Paragraph("<code>PR_IU_ForwardToken</code>", style_code), Paragraph("Bearer JWT (Staff)", style_table_cell)],
        [Paragraph("<code>PUT /api/v1/staff/status</code>", style_code_bold), Paragraph("Update Status (Serve/Hold/Done)", style_table_cell), Paragraph("<code>PR_IU_UpdateTokenStatus</code>", style_code), Paragraph("Bearer JWT (Staff)", style_table_cell)],
        [Paragraph("<code>GET /api/v1/public/display-board</code>", style_code_bold), Paragraph("Overhead TV Stream Feed", style_table_cell), Paragraph("<code>PR_S_PublicDisplayBoard</code>", style_code), Paragraph("Public Anonymous", style_table_cell)],
        [Paragraph("<code>GET /api/v1/public/ticket-status/{id}</code>", style_code_bold), Paragraph("Mobile QR Ticket Tracking", style_table_cell), Paragraph("<code>PR_S_PublicTokenStatus</code>", style_code), Paragraph("Public Anonymous", style_table_cell)],
        [Paragraph("<code>POST /api/v1/emergency/broadcast</code>", style_code_bold), Paragraph("Trigger Emergency Alert Override", style_table_cell), Paragraph("<code>PR_IU_EmergencyBroadcast</code>", style_code), Paragraph("Bearer JWT + PIN", style_table_cell)],
        [Paragraph("<code>POST /api/v1/emergency/dismiss</code>", style_code_bold), Paragraph("Dismiss Emergency Broadcast", style_table_cell), Paragraph("<code>PR_IU_DismissBroadcast</code>", style_code), Paragraph("Bearer JWT + PIN", style_table_cell)],
        [Paragraph("<code>GET /api/v1/signage/campaigns</code>", style_code_bold), Paragraph("Fetch Active Signage Media", style_table_cell), Paragraph("<code>PR_S_SignageCampaigns</code>", style_code), Paragraph("Public Anonymous", style_table_cell)],
        [Paragraph("<code>POST /api/v1/webhooks</code>", style_code_bold), Paragraph("Register Webhook Subscriber", style_table_cell), Paragraph("<code>PR_IU_WebhookSubscription</code>", style_code), Paragraph("Bearer JWT (Admin)", style_table_cell)],
        [Paragraph("<code>POST /api/v1/webhooks/test-ping</code>", style_code_bold), Paragraph("Dispatch HMAC-SHA256 Test Ping", style_table_cell), Paragraph("Direct HttpClient with HMAC", style_code), Paragraph("Bearer JWT (Admin)", style_table_cell)],
        [Paragraph("<code>GET /api/v1/edge/sync-status</code>", style_code_bold), Paragraph("Query Edge Node Health", style_table_cell), Paragraph("SQLite / MySQL Check", style_code), Paragraph("Bearer JWT (Admin)", style_table_cell)],
    ]
    t_api = Table(api_specs, colWidths=[140, 130, 132, 130])
    t_api.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_primary),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 3.5),
    ]))
    story.append(t_api)

    # =========================================================================
    # SECTION 6: TROUBLESHOOTING & SUPPORT
    # =========================================================================
    story.append(PageBreak())
    story.append(Paragraph("6. Production Troubleshooting & Diagnostic Guide", style_h1))
    troubleshoot_data = [
        [Paragraph("Observed Symptom / Error", style_table_header), Paragraph("Root Cause Analysis", style_table_header), Paragraph("Step-by-Step Resolution Protocol", style_table_header)],
        [
            Paragraph("<b>HTTP 401 Unauthorized</b> on Login Screen", style_table_cell_bold),
            Paragraph("Invalid user identifier or incorrect password hash mismatch.", style_table_cell),
            Paragraph("Verify credentials against database. Default admin is <code>admin@dnaqms.com</code> with password <code>Welc0me@555</code>. Ensure Authorization header uses format <code>Bearer &lt;token&gt;</code>.", style_table_cell)
        ],
        [
            Paragraph("<b>Overhead TV Screen Not Refreshing</b>", style_table_cell_bold),
            Paragraph("Network disconnect or browser polling timeout.", style_table_cell),
            Paragraph("1. Check network connectivity to server IP.<br/>2. Open <code>/api/v1/public/display-board</code> in browser to verify JSON stream.<br/>3. Press F5 to refresh browser or restart TV kiosk PC.", style_table_cell)
        ],
        [
            Paragraph("<b>Teller Hotkey Space / F1 Does Nothing</b>", style_table_cell_bold),
            Paragraph("No waiting customers in queue, or browser window lost focus.", style_table_cell),
            Paragraph("1. Click anywhere inside the teller counter screen to restore focus.<br/>2. Verify waiting count in sidebar is greater than 0.<br/>3. Verify teller's counter is active in status <code>Serving (20002)</code>.", style_table_cell)
        ],
        [
            Paragraph("<b>Emergency Broadcast Fails to Trigger</b>", style_table_cell_bold),
            Paragraph("Incorrect or missing Supervisor Security PIN.", style_table_cell),
            Paragraph("Ensure the 4-digit PIN entered matches the supervisor PIN configured in <code>appsettings.json</code> or table <code>SecurityPin</code> (default: <code>9999</code> or <code>1234</code>).", style_table_cell)
        ],
        [
            Paragraph("<b>Edge Banner Displays 'Offline Degraded'</b>", style_table_cell_bold),
            Paragraph("Local edge station lost network connectivity to Central HQ.", style_table_cell),
            Paragraph("Normal resilient behavior. Tellers can continue calling and serving tickets without interruption. System will auto-drain operations upon reconnection.", style_table_cell)
        ],
        [
            Paragraph("<b>Webhook Test Ping Returns HTTP 403 / 401</b>", style_table_cell_bold),
            Paragraph("Subscriber endpoint failed HMAC signature check or requires auth.", style_table_cell),
            Paragraph("Check that subscriber server computes HMAC-SHA256 using the exact same secret key string configured in the DQMS Webhook management screen.", style_table_cell)
        ],
        [
            Paragraph("<b>Mobile QR Scan Returns 'Ticket Not Found'</b>", style_table_cell_bold),
            Paragraph("Token ID or alphanumeric ticket code does not exist in today's queue.", style_table_cell),
            Paragraph("Ensure customer scans the newly printed QR code. Test manually by querying <code>/api/v1/public/ticket-status/A-014</code> in browser.", style_table_cell)
        ],
    ]
    t_trouble = Table(troubleshoot_data, colWidths=[120, 130, 282])
    t_trouble.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_surface),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, c_border),
        ('PADDING', (0,0), (-1,-1), 4.5),
    ]))
    story.append(t_trouble)
    story.append(Spacer(1, 14))

    # Support & Contact Block
    story.append(Paragraph("Enterprise Technical Support Contacts", style_h2))
    support_data = [
        [Paragraph("<b>Support Tier:</b> Tier 3 Mission-Critical Enterprise 24/7", style_body), Paragraph("<b>Email Desk:</b> support@antigravityenterprise.com", style_body)],
        [Paragraph("<b>Customer Portal:</b> https://support.antigravityenterprise.com", style_body), Paragraph("<b>Emergency Hotline:</b> +1 (800) 555-DQMS", style_body)],
    ]
    t_supp = Table(support_data, colWidths=[266, 266])
    t_supp.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F8FAFC")),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_supp)
    story.append(Spacer(1, 20))

    story.append(Paragraph("<b>End of Document • AntiGravity Enterprise Platform Operations Manual</b>", ParagraphStyle('DocEnd', parent=style_body, alignment=TA_CENTER, textColor=c_muted)))

    # Build Document with NumberedCanvas
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"SUCCESS: Professional User Guide PDF generated at: {pdf_filename}")

if __name__ == "__main__":
    build_pdf()
