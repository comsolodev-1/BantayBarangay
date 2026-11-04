# Bantay Barangay

A Web-Based Report Monitoring and Compliance System for the DILG Municipal Office of Talisay, Camarines Norte.

Barangays submit their required reports online. The DILG office confirms or denies each report, scores compliance, ranks the 15 barangays, and generates official reports. Team: CTRL ALT WIN.

## Table of Contents
1. [Features](#features)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Database](#database)
5. [Getting Started (Local Setup)](#getting-started-local-setup)
6. [Default Accounts](#default-accounts)
7. [How It Works](#how-it-works)
8. [Security](#security)
9. [Testing](#testing)
10. [Deployment](#deployment)
11. [Troubleshooting](#troubleshooting)
12. [Known Limitations and Assumptions](#known-limitations-and-assumptions)

## Features

| Role | Login | What they can do |
|---|---|---|
| Viewer | No | See public dashboard, rankings, announcements, officials roster and calendar |
| Barangay Admin | Yes | See assigned activities, submit / resubmit / remove reports, view history and report card (PDF), manage own roster, see rankings and announcements |
| Super Admin | Yes | Create and manage activities and periods, review submissions, generate 10 PDF reports, manage announcements, important dates and barangay accounts |

The 10 reports: Weekly / Monthly / Quarterly Activity Submission Summary, Barangay Ranking, Barangay Roster, Monthly Calendar Activity, Announcement, Late Submission, Non-Submission, and Individual Barangay Report Card.

## Tech Stack

Taken from the project proposal.

| Layer | Technology |
|---|---|
| Framework | ASP.NET Web Forms (.NET Framework 4.8), Web Site project |
| Language | VB.NET |
| Database | MySQL 8 |
| Data access | MySQL Connector/NET (`MySql.Data` 8.0.33) with ADO.NET, parameterized queries only |
| Authentication | Forms Authentication + Session State |
| Password hashing | BCrypt (`BCrypt.Net-Next` 4.0.3) |
| PDF reports | iTextSharp 5.5.13.3 |
| UI | Server controls (GridView, FileUpload, Calendar), plain CSS (`Content/site.css`) |
| Tools | Visual Studio 2022, IIS Express, MySQL Workbench |

## Project Structure

```
BantayBarangay/
|-- web.config                 Connection string, auth, session, security headers
|-- packages.config            NuGet packages used
|-- Site.master                Layout for logged-in users (sidebar by role)
|-- Public.master              Layout for the public viewer pages
|-- Default.aspx               Public dashboard (viewer home)
|-- Login.aspx / Logout.aspx   Sign in and sign out
|-- Download.aspx              Permission-checked file download (the only way to get uploads)
|-- Error.aspx                 Friendly error page
|-- App_Code/                  Shared VB.NET classes
|   |-- Db.vb                  MySQL helper (Query, Execute, transactions, housekeeping)
|   |-- Auth.vb                Login, lockout, session values, role base pages
|   |-- Uploads.vb             Upload validation and storage
|   |-- Scoring.vb             Score rules and ranking calculation
|   |-- Assignments.vb         Activities assigned to a barangay + submission status
|   |-- PeriodHelper.vb        Period names, date ranges, period creation
|   |-- CalendarData.vb        Calendar events (important dates + deadlines)
|   |-- ReportBuilder.vb       Builds the 10 reports
|   |-- PdfExport.vb           Writes a report to PDF
|   `-- Ui.vb                  HTML encoding, badges, date text, dropdown helpers
|-- Controls/                  Reusable user controls
|   |-- RankingsView.ascx      Rankings table with year / month filter
|   |-- AnnouncementsView.ascx Announcement list with visibility rules
|   `-- PasswordForm.ascx      Change-password form
|-- Viewer/                    Public pages (Rankings, Announcements, Roster, Calendar)
|-- Barangay/                  Barangay Admin pages
|-- Super/                     Super Admin pages
|-- Content/                   CSS and logos
|-- App_Data/uploads/          Uploaded files (blocked from direct URL access)
|   `-- submissions, templates, announcements, denials
`-- database/
    |-- schema.sql             Tables and keys
    `-- seed.sql               15 Talisay barangays, accounts
```

Every protected page inherits `SuperPage` or `BarangayPage` (in `Auth.vb`), which signs the user out and redirects to login if the session is missing or the role does not match.

## Database

Nine tables: `users`, `barangays`, `barangay_roster`, `announcements`, `important_dates`, `activities`, `reporting_period`, `submissions`, `activity_barangays`.

Changes made to the proposal's ERD (agreed by the group):
- New table `activity_barangays` (which barangays an activity is assigned to)
- New column `activities.is_public` (Public / Private toggle)
- Unique key on `submissions (period_id, barangay_id)` (one submission per barangay per period)
- Requirements list is stored in `activities.instructions`
- The Good / Needs Improvement / Bad remark is stored in `submissions.remarks`

Uploaded files live on the server in `App_Data/uploads`. Only their relative paths are stored in MySQL.

## Getting Started (Local Setup)

Requirements: Windows, Visual Studio 2022 (ASP.NET and web development workload), .NET Framework 4.8, MySQL 8, MySQL Workbench.

1. Open MySQL Workbench and run `database/schema.sql`, then `database/seed.sql`.
2. In Visual Studio choose File > Open > Web Site and select this folder. It is a Web Site project, not a Web Application.
3. Open the Package Manager Console and run:
   ```
   Install-Package MySql.Data -Version 8.0.33
   Install-Package BCrypt.Net-Next -Version 4.0.3
   Install-Package iTextSharp -Version 5.5.13.3
   ```
4. In `web.config`, edit the `BantayDb` connection string (server, user, password).
5. Press F5. The public viewer home opens. Staff sign in through `Login.aspx` (the "Admin Login" button).

## Default Accounts

Change these passwords right after the first login (Settings page).

| Role | Username | Password |
|---|---|---|
| Super Admin | `superadmin` | `Admin@12345` |
| Barangay Admin | `brgy_poblacion`, `brgy_gabon`, ... (one per barangay) | `Barangay@123` |

## How It Works

1. The Super Admin creates an activity: title, frequency, deadline, requirements, optional template file, Public / Private, and the barangays it is assigned to. A reporting period (for example "October 2026") is created automatically. Recurring activities get new periods with "Add Period".
2. Each assigned Barangay Admin sees it under My Activities and uploads a report file.
3. The submission is marked late automatically if it is uploaded after the deadline.
4. The Super Admin reviews it under Submissions:
   - Confirm: on-time report = 1.0 point, late report = 0.5 point, with a Good / Needs Improvement / Bad remark.
   - Deny: needs a reason and may include an attachment. The barangay can then resubmit.
5. Rankings add up confirmed scores per barangay (ties share a rank). Reports and the PDF report card use the same data.
6. Activity status is automatic: Active until the deadline passes, then Closed. Late submissions are still accepted until the Super Admin archives the activity.

## Security

| Risk | How it is handled |
|---|---|
| SQL injection | Every query uses parameters (`Db.vb`) |
| Weak passwords | BCrypt hashing, minimum 8 characters with letters and numbers |
| Brute force login | 5 failed attempts locks that username and IP for 15 minutes; honeypot field on login |
| Session theft / idle sessions | HttpOnly cookies, 20 minute sliding timeout, no-cache on protected pages |
| CSRF | `ViewStateUserKey` tied to the session on every page |
| Accessing another barangay's data | Role check on every protected page; queries and downloads also filter by the user's barangay |
| Malicious uploads | Extension whitelist, 10 MB limit, file signature check, random stored names, saved in `App_Data` and served only through `Download.aspx` |
| XSS | All output is HTML-encoded with `Ui.H` |
| Clickjacking / sniffing | `X-Frame-Options`, `X-Content-Type-Options` headers in `web.config` |

## Testing

Automated checks done during development:
- All VB.NET code compiles without errors.
- `schema.sql` and `seed.sql` load on MariaDB 10.11 with no errors, and all 92 SQL statements in the code run.
- A data test confirmed the ranking math (on time 1.0, late 0.5, pending 0), the "Not Submitted" status, the non-submission report, and that the unique key blocks a duplicate submission.

Manual test checklist (run this on your machine after setup):

| # | Test | Expected result |
|---|---|---|
| 1 | Open `Default.aspx` without logging in | Public dashboard shows, no admin links |
| 2 | Open `/Super/Dashboard.aspx` while logged out | Redirected to Login |
| 3 | Log in as a Barangay Admin, then open `/Super/Dashboard.aspx` | Signed out and sent to Login |
| 4 | Log in with a wrong password 5 times | Account locked message for 15 minutes |
| 5 | Super Admin creates an activity assigned to 3 barangays | Only those 3 barangays see it |
| 6 | Barangay uploads a PDF before the deadline | Status Pending, not late |
| 7 | Barangay uploads a `.exe` renamed to `.pdf` | Rejected (content does not match type) |
| 8 | Barangay uploads a file over 10 MB | Rejected |
| 9 | Super Admin confirms the report | Status Confirmed, 1.0 point, ranking updates |
| 10 | Create an activity with a past deadline and submit | Marked Late, 0.5 point when confirmed |
| 11 | Super Admin denies with a reason | Barangay sees the reason and can Resubmit |
| 12 | Barangay removes a Pending submission | Row deleted, file removed, can submit again |
| 13 | Barangay A opens `Download.aspx?t=submission&id=` of Barangay B | File not found |
| 14 | Open a private activity template link while logged out | File not found |
| 15 | Generate each of the 10 reports and download the PDF | PDF opens with the title, filters and table |
| 16 | Post an announcement for one barangay | Only that barangay (and the Super Admin) sees it |
| 17 | Calendar page, change month | Important dates and public deadlines show on the right days |
| 18 | Change password in Settings, then log in again | New password works, old one fails |

## Deployment

ASP.NET Web Forms needs **Windows with IIS** and .NET Framework 4.8. It does not run on Vercel, Netlify, or Linux-only hosting.

1. Get a Windows / ASP.NET host that also offers MySQL (for example a paid SmarterASP.NET or similar plan; check MySQL support before you buy). The proposal budget is ₱3,500 for hosting.
2. Create the MySQL database on the host and run `database/schema.sql` and `database/seed.sql` (remove the `CREATE DATABASE` and `USE` lines if the host gives you a ready-made database name).
3. In Visual Studio: right-click the web site, Publish Web Site, pick Web Deploy or FTP, and publish. Make sure the NuGet DLLs in `Bin/` are included.
4. Edit `web.config` on the server:
   - Set the `BantayDb` connection string to the host's MySQL details.
   - Turn on HTTPS and set `requireSSL="true"` on the `forms` and `httpCookies` entries.
   - Set `<customErrors mode="On" />` and `<compilation debug="false" />`.
5. Give the IIS application pool identity write permission on `App_Data/uploads` (or set it in the host control panel).
6. Sign in as `superadmin`, change the default passwords, then create or reset the barangay accounts under Accounts.
7. Back up the database and the `App_Data/uploads` folder regularly.

## Troubleshooting

| Problem | Fix |
|---|---|
| "Could not load file or assembly MySql.Data" | Run the three `Install-Package` commands again and check `Bin/` has the DLLs |
| "Unable to connect to any of the specified MySQL hosts" | Check the connection string, that MySQL is running, and the user's permissions |
| Upload fails on the server | Give the app pool write access to `App_Data/uploads` |
| Everyone is signed out quickly | Session timeout is 20 minutes; change `timeout` in `web.config` if needed |
| PDF button shows an error | Confirm `iTextSharp` is installed and the report has valid filters |
| Dates look wrong | Check the server time zone; deadlines use the server clock |

## Known Limitations and Assumptions

- The Super Admin cannot yet edit barangay profile details (captain, secretary, office address).
- Frequencies are Weekly, Monthly, Quarterly, Annual and General.
- Passwords reset by the Super Admin are set directly (no email reset, since the proposal does not include email).
- The project was compiled and its SQL tested outside Visual Studio. Run the manual test checklist above on the real setup before the defense or go-live.
