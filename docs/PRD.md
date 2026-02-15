# 66 Streaks — Product Requirements Document (MVP)

---

## 1. Product Overview

**Product Name:** 66 Streaks  
**Category:** Behavior Change / Streak Builder  
**Positioning:** A streak-first habit builder designed to push users through 66 consecutive days without breaking the chain.

**Core Philosophy:**  
Users are not tracking habits.  
They are protecting streaks.

Primary psychological driver: **Loss aversion**

---

## 2. Product Goals (MVP)

### Primary Goal
Help users complete 66 consecutive days of a habit without breaking the streak.

### Success Metrics
- D1 retention > 60%
- D7 retention > 35%
- 30% of users reach Day 7
- 15% reach Day 14

Revenue is not considered during MVP validation.

---

## 3. Target Audience

### Primary Users
- Gym beginners
- People quitting sugar/smoking/porn
- Students building study streaks
- Creators posting daily content
- Self-improvement audience (18–35)

### Psychological Profile
- Motivated but inconsistent
- Competitive with themselves
- Emotionally attached to streak numbers
- Afraid of losing progress

---

## 4. Core Value Proposition

> “Don’t break the chain for 66 days.”

Simple. Focused. Pressure-driven.

---

## 5. Core Concept Mechanics

### Why 66?
Research suggests habits form around 66 days.  
The UI reinforces:

- Day X / 66
- Percentage to completion
- Visual grid progression

---

## 6. MVP Scope (7–14 Day Build)

### 6.1 Habit Creation

User can:
- Add habit title
- Select emoji
- Select daily reminder time
- Select check-in window (default: 6am–11pm)

Limit:  
Maximum 3 active streaks.

---

### 6.2 Home Screen

Each habit appears as a card.

Each card includes:

- Emoji + habit title
- Large streak counter (Day X)
- Progress: X / 66
- Percentage completion
- 66-day GitHub-style grid
- Check-in button (if incomplete)
- Completed state indicator

No extra stats or dashboards.

---

### 6.3 Streak Logic

- One check-in per calendar day
- If user misses check-in window → streak resets to 0
- Reset must be clearly visible and emotionally impactful
- No streak freeze in MVP

---

### 6.4 Progress Grid

- 66 blocks total
- Filled = completed days
- Empty = remaining days
- Reset clears entire grid

Purpose: Visual pressure.

---

### 6.5 Notifications (Local Only)

Two types:

#### Reminder Notification
Examples:
- “Day 12 is waiting.”
- “Don’t break your streak.”

#### Morning Motivation (Optional Toggle)
Examples:
- “You crushed yesterday. Keep going.”
- “Consistency builds identity.”

Static message pool. No AI.

---

### 6.6 Light / Dark Mode

- System default
- Manual toggle in settings

---

### 6.7 Offline First

- Fully offline
- Local database only
- No authentication
- No cloud sync

---

## 7. Out of Scope (MVP)

- Social features
- Cloud backup
- Widgets
- Notes
- Categories
- Analytics dashboards
- Gamification levels
- Multiple reminders per habit
- Calendar views

---

## 8. UX Principles

### Emotion > Data
No analytics overload.

### Intentional Friction
Reset must feel real.

### Focused Interface
Max 3 streaks. Clean layout.

---

## 9. User Flow

### First Launch

1. One intro slide  
   “Build one habit. Protect the streak. 66 days.”
2. Create first streak
3. Set reminder
4. Land on home screen

---

### Daily Usage

1. Open app
2. View streak
3. Tap check-in
4. Grid updates
5. Close app

Target interaction time: <10 seconds.

---

## 10. UI Design System

### Design Direction
Minimal. Clean. Intense. Modern.

No playful or cartoon style.

---

### 10.1 Color System

#### Primary Accent
Electric Blue — `#2563EB`

#### Success State
Emerald — `#10B981`

#### Danger State
Soft Red — `#EF4444`

---

### Dark Mode

- Background: `#0F172A`
- Card: `#1E293B`
- Text Primary: `#F8FAFC`

---

### Light Mode

- Background: `#F9FAFB`
- Card: `#FFFFFF`
- Text Primary: `#111827`

---

### 10.2 Typography

Primary Font: SF Pro (system)

Hierarchy:
- Streak Number: Large, bold
- Habit Title: Medium semibold
- Secondary Info: Small regular

---

### 10.3 Card Layout Structure

Top:
Emoji + Habit Title

Middle:
DAY 23 (large)
23 / 66 • 34%

Bottom:
66-day grid

CTA:
Check In button

---

## 11. Data Model

Habit:
- id
- title
- emoji
- startDate
- currentStreak
- lastCheckInDate
- reminderTime
- isCompletedToday
- status (active / broken / completed)

---

## 12. Edge Cases

- Only one check-in per calendar day
- If app not opened for multiple days → streak resets on next launch
- Device time manipulation should not allow multiple same-day check-ins

---

## 13. Psychological Hooks

- Large streak number
- Visible reset
- Countdown toward 66
- Daily reminder pressure
- Visual completion grid

---

## 14. Future Monetization (Post-Validation)

Subscription: $7.99/month

Unlock:
- Unlimited streaks
- Streak freeze (1–3/month)
- Custom themes
- Widgets
- Shareable streak cards
- Archive history
- Advanced stats

Primary trigger:
User misses a day → Offer streak protection.

---

## 15. Viral Angles

- “Day 1 of quitting sugar”
- “Day 40 update”
- Screen recording of streak growth
- Before/after transformation
- 66-day challenge trend

The number 66 is inherently content-friendly.

---

## 16. Technical Feasibility

- Local database
- Local notifications
- Frontend-heavy
- No backend
- No infra costs
- No moderation

---

## 17. Build Difficulty

Very Easy

Estimated build time: 7–10 days using AI coding tools.