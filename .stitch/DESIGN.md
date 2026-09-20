---
name: DQMS Enterprise Clinical Suite
colors:
  canvas-base: '#090D11'
  surface-layer-1: '#111827'
  surface-layer-2: '#1F2937'
  primary-accent: '#0284C7'
  primary-specular: '#38BDF8'
  secondary-accent: '#6366F1'
  tertiary-emerald: '#10B981'
  warning-amber: '#F59E0B'
  danger-crimson: '#EF4444'
  text-main: '#F0F6FC'
  text-muted: '#8B949E'
  text-subtle: '#6E7681'
  glass-border: 'rgba(255, 255, 255, 0.15)'
typography:
  display-hero:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 48px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

# DQMS Enterprise Design System: Clinical Glassmorphic Architecture

## 1. Overview & North Star
The visual language establishes a high-performance clinical operations command center and patient concierge portal. It merges dark-mode translucent glassmorphism with high-contrast medical data presentation, ambient neon glows, and tactile 3D interactions.

## 2. Color Palette & Functional Tokens
- **Canvas Base**: `#090D11` (Deep Obsidian)
- **Surface Layer 1**: `#111827` / `rgba(17, 24, 39, 0.75)` with 20px blur
- **Surface Layer 2**: `#1F2937` / `rgba(31, 41, 55, 0.85)` with 24px blur
- **Primary Accent**: `#0284C7` (Electric Cyan) with `#38BDF8` specular highlight
- **Secondary Accent**: `#6366F1` (Iris Cobalt) for analytics and clinical workflows
- **Tertiary Accent**: `#10B981` (Vital Emerald) for 'Now Serving' verification and positive metrics
- **Warning / Triage**: `#F59E0B` (Sunset Amber) for queue waiting and pending alerts
- **Critical / Danger**: `#EF4444` (Triage Red) for SLA breaches and urgent interventions
- **Text Main**: `#F0F6FC`
- **Text Muted**: `#8B949E`
- **Text Subtle**: `#6E7681`

## 3. Typography (Plus Jakarta Sans)
- **Display Hero (38-42px)**: Token numbers (e.g. A012, C-01) with tabular lining figures
- **Headlines (20-28px)**: Screen headers, department names
- **Body & Data (13-15px)**: Tabular queue logs, patient profiles
- **Labels (10-12px, Bold)**: Status pills, room badges, hotkey indicators

## 4. Elevation, Depth & Glass Containers
- Multi-layer translucent surfaces with 1px border highlight (`rgba(255, 255, 255, 0.15)`)
- Ambient radial caustics and soft cyan/cobalt drop glows
- Micro-press 3D physics on action cards and buttons

## 5. Signature Components
- **NowServingBannerGlassCard**: High-contrast live consultation announcement
- **NextAppointmentGlassCard**: 3D hero card with token number, date, time, and QR pass
- **GlassPillBadge**: Status indicators (Now Serving, In Service, Checked-In, Completed)
- **Tactical Hotkey Buttons**: F1-F7 operator console controls
