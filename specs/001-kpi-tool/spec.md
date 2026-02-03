# Feature Specification: Product KPIs Tool

**Feature Branch**: `001-kpi-tool`
**Created**: 2026-02-03
**Status**: Draft
**Input**: User description: "Local tool for generating product KPIs with console menu navigation, development mode with data caching, secure credential storage, and modular KPI architecture for long-term maintainability"

## User Scenarios & Testing

### User Story 1 - Quick KPI Report (Priority: P1)

A user wants to quickly generate all standard KPI reports without configuration. They launch the tool, select "Run All KPIs" from the menu, and receive a complete report with all configured metrics.

**Why this priority**: This is the primary use case - most users want quick results without deep-diving into individual KPIs. The "hit and run" functionality delivers immediate value.

**Independent Test**: Can be fully tested by launching the tool and selecting the quick-run option. Delivers a complete KPI report showing all configured metrics.

**Acceptance Scenarios**:

1. **Given** the user has VPN connected and database credentials stored, **When** they select "Run All KPIs", **Then** they see progress for each KPI being generated and receive a complete report
2. **Given** the user has not stored database credentials, **When** they select "Run All KPIs", **Then** they are prompted to configure credentials first
3. **Given** a KPI query fails, **When** running all KPIs, **Then** the tool continues with remaining KPIs and reports the failure clearly

---

### User Story 2 - Database Credential Management (Priority: P1)

A user needs to securely store their database connection URL so they can use the tool without entering credentials each time. They configure credentials once, and the tool retrieves them securely for all subsequent sessions.

**Why this priority**: Without credential storage, no KPI functionality works. This is a foundational requirement.

**Independent Test**: Can be tested by storing credentials, closing the tool, reopening, and verifying the tool can connect without re-entering credentials.

**Acceptance Scenarios**:

1. **Given** the user has no stored credentials, **When** they navigate to credential setup, **Then** they can enter and securely store their database URL
2. **Given** the user has stored credentials, **When** they want to verify the connection, **Then** they can view a masked version of the stored URL
3. **Given** the user wants to change credentials, **When** they update the stored URL, **Then** the new credentials replace the old ones
4. **Given** the user wants to remove credentials, **When** they clear stored credentials, **Then** no credentials remain in storage

---

### User Story 3 - Individual KPI Deep Dive (Priority: P2)

A user wants to examine a specific KPI in detail, possibly with custom parameters (like filtering by shop or date range). They navigate to a specific KPI, configure options, and run it individually.

**Why this priority**: Supports power users who need detailed analysis, but most users will use the quick-run option.

**Independent Test**: Can be tested by selecting a specific KPI from the menu, adjusting parameters, and verifying the filtered results.

**Acceptance Scenarios**:

1. **Given** a user selects a specific KPI, **When** they view its options, **Then** they see available parameters they can configure
2. **Given** a user configures custom parameters, **When** they run the KPI, **Then** results reflect those parameters
3. **Given** a user runs an individual KPI, **When** viewing results, **Then** they see more detailed output than the summary report

---

### User Story 4 - Development Mode with Caching (Priority: P2)

A developer iterating on a new KPI needs to work with data without repeatedly querying the database. They enable development mode, which caches query results locally for faster iteration.

**Why this priority**: Essential for KPI development workflow but not needed for regular users.

**Independent Test**: Can be tested by enabling dev mode, running a query, modifying display logic, and re-running without database access.

**Acceptance Scenarios**:

1. **Given** development mode is enabled, **When** a query is executed, **Then** results are cached locally
2. **Given** cached data exists for a query, **When** running in dev mode, **Then** cached data is used instead of querying the database
3. **Given** development mode is disabled (production mode), **When** any query is executed, **Then** live data is always fetched from the database
4. **Given** cached data exists, **When** the user wants fresh data, **Then** they can clear the cache and fetch live data

---

### User Story 5 - Add New KPI (Priority: P3)

A developer needs to add a new KPI to the system. They create a new KPI following the established structure, and it automatically appears in the menu and is included in the "Run All" report.

**Why this priority**: Important for long-term maintainability but not needed for initial tool usage.

**Independent Test**: Can be tested by adding a new KPI following the structure and verifying it appears in menus and reports.

**Acceptance Scenarios**:

1. **Given** a new KPI is created following the standard structure, **When** the tool loads, **Then** the new KPI appears in the menu automatically
2. **Given** a new KPI exists, **When** "Run All KPIs" is selected, **Then** the new KPI is included in the report
3. **Given** a KPI has required configuration (parameters), **When** viewed in the menu, **Then** its configurable options are discoverable

---

### Edge Cases

- What happens when VPN is not connected? The tool should detect connection failure and provide a clear message about VPN requirement
- What happens when database schema changes? KPIs should handle missing columns gracefully with clear error messages
- What happens when a query takes too long? Users should see progress indication and be able to cancel
- What happens when cache becomes stale in dev mode? Users can manually clear cache; cache does not auto-expire
- What happens when keychain access is denied? Tool should prompt user to grant keychain access permissions

## Requirements

### Functional Requirements

- **FR-001**: System MUST provide a single entry point that launches an interactive console menu
- **FR-002**: System MUST store database credentials exclusively in the macOS keychain (no credentials in repository)
- **FR-003**: System MUST provide a "Run All KPIs" option that executes all configured KPIs with a single action
- **FR-004**: System MUST display progress to the user during KPI generation (which KPI is running, completion status)
- **FR-005**: System MUST support a development mode that caches database query results locally, activated via a menu toggle option
- **FR-006**: System MUST always fetch live data when not in development mode (production mode is the default on each launch)
- **FR-007**: System MUST allow users to run individual KPIs with configurable parameters
- **FR-008**: System MUST organize KPIs as separate, clearly structured modules for maintainability
- **FR-009**: System MUST automatically discover and include new KPIs added following the standard structure
- **FR-010**: System MUST allow users to view, update, and clear stored database credentials
- **FR-011**: System MUST mask sensitive credential information when displayed to users
- **FR-012**: System MUST provide clear error messages when database connection fails
- **FR-013**: System MUST export KPI report results to file, supporting both CSV and JSON formats with user selection at runtime

### Key Entities

- **KPI**: A single business metric with a name, description, query logic, and optional configurable parameters
- **KPI Report**: A collection of KPI results from a single run, with timestamp and summary
- **Configuration**: User settings including database credentials and development mode state
- **Cache Entry**: Stored query results in dev mode, associated with the query parameters used

## Success Criteria

### Measurable Outcomes

- **SC-001**: Users can generate a complete KPI report in under 3 interactions from launch (launch → menu → run all → results)
- **SC-002**: New KPIs can be added without modifying any existing code files (purely additive changes)
- **SC-003**: Development mode reduces iteration time by eliminating database round-trips for cached queries
- **SC-004**: Zero credentials appear in any repository files (verified by scanning all committed files)
- **SC-005**: Users can identify which KPI is currently running and overall progress at any time during execution
- **SC-006**: 100% of KPI execution errors are reported with actionable error messages (not generic failures)

## Clarifications

### Session 2026-02-03

- Q: How should KPI report results be presented to users? → A: Export to file (CSV, JSON, or similar)
- Q: How do users enable/disable development mode? → A: Menu toggle (option in console menu to switch modes)
- Q: Which export file format(s) should be supported? → A: Both JSON and CSV, user chooses at runtime
- Q: Should development mode persist between sessions? → A: No, reset to production mode on each launch

## Assumptions

- Users are on macOS with access to the system keychain
- Users manually establish VPN connection before using the tool (VPN management is out of scope)
- The database schema for orders and related tables is stable
- Users have appropriate database read permissions
- The tool is used locally by individual users (not deployed as a service)
- KPIs are read-only operations (no data modification)
