import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, HRFlowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY

def build_pdf():
    pdf_filename = "DQMS_Enterprise_User_Guide.pdf"
    doc = SimpleDocTemplate(
        pdf_filename,
        pagesize=letter,
        rightMargin=40,
        leftMargin=40,
        topMargin=40,
        bottomMargin=40
    )

    styles = getSampleStyleSheet()

    # Custom Color Palette per UI_UX_DESIGN_SPEC.md
    c_primary = colors.HexColor("#2F81F7")
    c_dark = colors.HexColor("#090D11")
    c_surface = colors.HexColor("#12171F")
    c_text = colors.HexColor("#1F2937")
    c_muted = colors.HexColor("#4B5563")
    c_green = colors.HexColor("#238636")
    c_purple = colors.HexColor("#8957E5")
    c_warning = colors.HexColor("#D29922")

    # Typography Styles
    style_cover_title = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=26,
        leading=32,
        textColor=c_primary,
        alignment=TA_CENTER
    )

    style_cover_sub = ParagraphStyle(
        'CoverSub',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=14,
        leading=18,
        textColor=c_muted,
        alignment=TA_CENTER
    )

    style_h1 = ParagraphStyle(
        'H1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=c_primary,
        spaceBefore=14,
        spaceAfter=8
    )

    style_h2 = ParagraphStyle(
        'H2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=16,
        textColor=c_surface,
        spaceBefore=10,
        spaceAfter=6
    )

    style_body = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=10,
        leading=14,
        textColor=c_text,
        spaceBefore=4,
        spaceAfter=6
    )

    style_code = ParagraphStyle(
        'CodeStyle',
        parent=styles['Normal'],
        fontName='Courier-Bold',
        fontSize=9,
        leading=12,
        textColor=c_purple,
        backColor=colors.HexColor("#F3F4F6"),
        borderColor=colors.HexColor("#E5E7EB"),
        borderWidth=1,
        borderPadding=4,
        spaceBefore=4,
        spaceAfter=6
    )

    story = []

    # =========================================================================
    # COVER / HEADER TITLE BLOCK
    # =========================================================================
    story.append(Spacer(1, 20))
    story.append(Paragraph("DIGITAL QUEUE MANAGEMENT SYSTEM (DQMS)", style_cover_title))
    story.append(Spacer(1, 8))
    story.append(Paragraph("Enterprise Platform User Guide & Operations Manual (Stages 1 - 3)", style_cover_sub))
    story.append(Spacer(1, 15))
    story.append(HRFlowable(width="100%", thickness=2, color=c_primary, spaceBefore=5, spaceAfter=15))

    # Meta Summary Table
    meta_data = [
        [Paragraph("<b>Product Version:</b> v1.0.0 Enterprise", style_body), Paragraph("<b>Technology Stack:</b> .NET 8 Web API + Dapper ORM", style_body)],
        [Paragraph("<b>Frontend Framework:</b> Flutter (Riverpod/Dio)", style_body), Paragraph("<b>Databases:</b> MySQL 8.0 & MS SQL Server 2022", style_body)],
        [Paragraph("<b>Design Standard:</b> Command Center Spec", style_body), Paragraph("<b>Architecture:</b> Service Pattern (No Repositories)", style_body)],
    ]
    t_meta = Table(meta_data, colWidths=[260, 260])
    t_meta.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F9FAFB")),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#E5E7EB")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E5E7EB")),
        ('PADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_meta)
    story.append(Spacer(1, 15))

    # =========================================================================
    # SECTION 1: SYSTEM OVERVIEW
    # =========================================================================
    story.append(Paragraph("1. Executive System Overview", style_h1))
    story.append(Paragraph(
        "The <b>AntiGravity Enterprise DQMS</b> is a multi-tenant, high-performance Queue Management System engineered for operational efficiency, zero-friction operator workflows, and real-time waiting room displays. Built using a <b>C# .NET Core Web API backend</b> with <b>Dapper ORM stored procedures</b> and a cross-platform <b>Flutter frontend</b>, the system operates across 3 distinct perspectives:",
        style_body
    ))

    overview_table_data = [
        [Paragraph("<b>Stage / Perspective</b>", style_body), Paragraph("<b>Target User Group</b>", style_body), Paragraph("<b>Core Capability & Features</b>", style_body)],
        [
            Paragraph("<b>Stage 1: Admin Setup</b>", style_body),
            Paragraph("Application Administrators", style_body),
            Paragraph("Master configuration for Areas/Zones, Process Pipelines with SLA TAT, Counter Windows, and TV Display Templates.", style_body)
        ],
        [
            Paragraph("<b>Stage 2: Staff Console</b>", style_body),
            Paragraph("Counter Operators / Staff", style_body),
            Paragraph("High-speed, low-click operator station powered by direct keyboard hotkeys (<b>Space / F1 to F7</b>) and priority queueing.", style_body)
        ],
        [
            Paragraph("<b>Stage 3: Customer Module</b>", style_body),
            Paragraph("Patients & Customers", style_body),
            Paragraph("4K Overhead TV Display Boards, Touchscreen Ticket Kiosk, Mobile Web QR Ticket Tracking, and WhatsApp alerts.", style_body)
        ]
    ]
    t_overview = Table(overview_table_data, colWidths=[130, 130, 260])
    t_overview.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#EFF6FF")),
        ('TEXTCOLOR', (0,0), (-1,0), c_primary),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#BFDBFE")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E5E7EB")),
        ('PADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_overview)
    story.append(Spacer(1, 15))

    # =========================================================================
    # SECTION 2: STAGE 1 ADMIN MASTERS
    # =========================================================================
    story.append(Paragraph("2. Stage 1: Application Admin Masters", style_h1))
    story.append(Paragraph(
        "Stage 1 provides administrators with structured data tables and real-time KPI metrics for configuring organizational queue infrastructure. Access the panel by selecting <b>Admin Master Configuration</b>.",
        style_body
    ))
    story.append(Paragraph("Key Admin Master Views:", style_h2))

    admin_views = [
        [Paragraph("<b>Master Entity</b>", style_body), Paragraph("<b>Configured Parameters</b>", style_body), Paragraph("<b>Database Stored Procedures</b>", style_body)],
        [Paragraph("<b>Areas & Zones</b>", style_body), Paragraph("Area Code, Area Name, Location ID, Active Status", style_body), Paragraph("<code>PR_S_Area</code>, <code>PR_IU_Area</code>", style_code)],
        [Paragraph("<b>Process Pipelines</b>", style_body), Paragraph("Token Prefix (A-Z), Target SLA TAT (mins), Sub-Tokens", style_body), Paragraph("<code>PR_S_Process</code>, <code>PR_IU_Process</code>", style_code)],
        [Paragraph("<b>Counter Stations</b>", style_body), Paragraph("Counter Number, Window Name, Status Code (20001)", style_body), Paragraph("<code>PR_S_Counter</code>, <code>PR_IU_Counter</code>", style_code)],
        [Paragraph("<b>Display Templates</b>", style_body), Paragraph("Layout Type (GridView 21001, Split 21002, List 21003)", style_body), Paragraph("<code>PR_S_DisplayTemplate</code>, <code>PR_IU_DisplayTemplate</code>", style_code)],
    ]
    t_admin = Table(admin_views, colWidths=[120, 220, 180])
    t_admin.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#F3F4F6")),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#D1D5DB")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E5E7EB")),
        ('PADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_admin)
    story.append(Spacer(1, 15))

    # =========================================================================
    # SECTION 3: STAGE 2 OPERATOR CONSOLE & HOTKEYS
    # =========================================================================
    story.append(PageBreak())
    story.append(Paragraph("3. Stage 2: Staff Counter Station & Keyboard Hotkeys", style_h1))
    story.append(Paragraph(
        "The <b>Counter Operator Console</b> is engineered for high-speed operation. Staff members can call, recall, serve, hold, complete, and cancel queue tickets without using the mouse by leveraging physical keyboard hotkeys.",
        style_body
    ))
    story.append(Paragraph("Operator Keyboard Hotkey Quick Reference:", style_h2))

    hotkey_data = [
        [Paragraph("<b>Hotkey</b>", style_body), Paragraph("<b>Action Name</b>", style_body), Paragraph("<b>Target Token Status</b>", style_body), Paragraph("<b>Description & Behavior</b>", style_body)],
        [Paragraph("<b>SPACE / F1</b>", style_body), Paragraph("Call Next", style_body), Paragraph("<font color='#238636'>Calling (18003)</font>", style_body), Paragraph("Automatically pulls highest priority waiting token (VIP, Senior, Standard).", style_body)],
        [Paragraph("<b>F2</b>", style_body), Paragraph("Recall", style_body), Paragraph("<font color='#D29922'>Calling (18003)</font>", style_body), Paragraph("Triggers audio announcement & TV visual flash pulse again.", style_body)],
        [Paragraph("<b>F3</b>", style_body), Paragraph("Serve Active", style_body), Paragraph("<font color='#2F81F7'>Active (18004)</font>", style_body), Paragraph("Marks customer active at counter and starts SLA service timer.", style_body)],
        [Paragraph("<b>F4</b>", style_body), Paragraph("Hold", style_body), Paragraph("<font color='#8957E5'>Hold (18005)</font>", style_body), Paragraph("Places ticket on hold with optional operator reason notes.", style_body)],
        [Paragraph("<b>F5</b>", style_body), Paragraph("Complete & Call Next", style_body), Paragraph("<font color='#238636'>Completed (18007)</font>", style_body), Paragraph("Completes active ticket and immediately calls next waiting customer.", style_body)],
        [Paragraph("<b>F7</b>", style_body), Paragraph("Cancel", style_body), Paragraph("<font color='#DA3633'>Canceled (18006)</font>", style_body), Paragraph("Cancels ticket for no-show or customer departure.", style_body)],
    ]
    t_hotkeys = Table(hotkey_data, colWidths=[90, 110, 110, 210])
    t_hotkeys.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#FEF3C7")),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#FDE68A")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E5E7EB")),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_hotkeys)
    story.append(Spacer(1, 15))

    # =========================================================================
    # SECTION 4: STAGE 3 CUSTOMER & PUBLIC DISPLAY MODULE
    # =========================================================================
    story.append(Paragraph("4. Stage 3: Customer Displays, Kiosk & Mobile Tracking", style_h1))
    story.append(Paragraph(
        "Stage 3 includes 3 dedicated public interfaces designed for customer engagement and waiting room communication:",
        style_body
    ))

    stage3_features = [
        [Paragraph("<b>Interface View</b>", style_body), Paragraph("<b>Access Point</b>", style_body), Paragraph("<b>Key Features</b>", style_body)],
        [
            Paragraph("<b>4K Overhead TV Display Board</b>", style_body),
            Paragraph("Overhead TV Monitors (Web Browser)", style_body),
            Paragraph("GridView layout (Template 21001) displaying NOW CALLING tokens (e.g. <b>A-001 -> COUNTER 03</b>) with 30-second green/red visual pulse alerts and audio announcements.", style_body)
        ],
        [
            Paragraph("<b>Self-Service Ticket Kiosk</b>", style_body),
            Paragraph("Touchscreen Kiosk Terminal", style_body),
            Paragraph("Large touch buttons for service selection, category filter (Standard, Senior Citizen, Disabled, VIP), and thermal ticket printer integration.", style_body)
        ],
        [
            Paragraph("<b>Mobile Web Ticket Tracker</b>", style_body),
            Paragraph("Customer Smartphone (QR Code Scan)", style_body),
            Paragraph("Live position in queue tracker showing exact <b>Customers Ahead</b> (e.g. 2 ahead) and <b>Estimated Wait Time</b> (~15 mins) with auto-refresh.", style_body)
        ],
    ]
    t_stage3 = Table(stage3_features, colWidths=[140, 130, 250])
    t_stage3.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#F3E8FF")),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#E9D5FF")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E5E7EB")),
        ('PADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_stage3)
    story.append(Spacer(1, 15))

    # =========================================================================
    # SECTION 5: API ENDPOINTS & DATABASE MIGRATIONS
    # =========================================================================
    story.append(Paragraph("5. API Endpoints & SQL Stored Procedures Reference", style_h1))
    
    api_data = [
        [Paragraph("<b>HTTP Method & Endpoint</b>", style_body), Paragraph("<b>Controller Action</b>", style_body), Paragraph("<b>Stored Procedure</b>", style_body)],
        [Paragraph("<code>GET /api/v1/admin/areas</code>", style_code), Paragraph("Get Areas by Org & Loc", style_body), Paragraph("<code>PR_S_Area</code>", style_code)],
        [Paragraph("<code>POST /api/v1/admin/area</code>", style_code), Paragraph("Create / Update Area", style_body), Paragraph("<code>PR_IU_Area</code>", style_code)],
        [Paragraph("<code>POST /api/v1/staff/issue-token</code>", style_code), Paragraph("Issue Queue Ticket", style_body), Paragraph("<code>PR_IU_IssueToken</code>", style_code)],
        [Paragraph("<code>POST /api/v1/staff/call-next</code>", style_code), Paragraph("Operator Call Next Token", style_body), Paragraph("<code>PR_IU_CallNextToken</code>", style_code)],
        [Paragraph("<code>POST /api/v1/staff/update-status</code>", style_code), Paragraph("Update Token Status", style_body), Paragraph("<code>PR_IU_UpdateTokenStatus</code>", style_code)],
        [Paragraph("<code>GET /api/v1/public/display-board</code>", style_code), Paragraph("Overhead TV Board Stream", style_body), Paragraph("<code>PR_S_PublicDisplayBoard</code>", style_code)],
        [Paragraph("<code>GET /api/v1/public/ticket-status/{id}</code>", style_code), Paragraph("Mobile QR Ticket Status", style_body), Paragraph("<code>PR_S_PublicTokenStatus</code>", style_code)],
    ]
    t_api = Table(api_data, colWidths=[200, 160, 160])
    t_api.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#F9FAFB")),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#E5E7EB")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E5E7EB")),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_api)
    story.append(Spacer(1, 20))

    story.append(Paragraph("<b>End of Document • AntiGravity Enterprise Platform Documentation</b>", ParagraphStyle('Footer', parent=style_body, alignment=TA_CENTER, textColor=c_muted)))

    doc.build(story)
    print("PDF build successful: DQMS_Enterprise_User_Guide.pdf")

if __name__ == "__main__":
    build_pdf()
