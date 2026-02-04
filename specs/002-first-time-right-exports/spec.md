# Feature Specification: First Time Right KPI (Exports)

**Feature Branch**: `002-first-time-right-exports`
**Created**: 2026-02-03
**Status**: Complete
**Input**: User description: "Introduce First Time Right KPI to track if flows execute successfully on first try by checking exports and error logs. Start with Post fulfillment (export_fulfillment_create tag)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View First Time Right Rate for Exports (Priority: P1)

As a product operations user, I want to see the "First Time Right" percentage for exports by action type so I can understand how often each export type succeeds without errors on the first attempt.

**Why this priority**: This is the core functionality requested - measuring success rate for exports. Without this, there is no feature.

**Independent Test**: Can be fully tested by running the KPI against the database and verifying it correctly calculates the percentage of exports with no associated error logs for each configured action type.

**Acceptance Scenarios**:

1. **Given** the database contains export records with various action types, **When** the user runs the First Time Right KPI, **Then** the system displays the success percentage for each configured action type.

2. **Given** some exports have error logs and some do not, **When** the KPI is executed, **Then** the result shows total count, successful count, failed count, and success rate for each action type.

3. **Given** no exports exist for a configured action type in the selected date range, **When** the KPI is executed, **Then** the system displays zeros for that action type.

---

### User Story 2 - Filter First Time Right by Date Range (Priority: P2)

As a product operations user, I want to filter the First Time Right KPI by a custom date range so I can analyze trends over specific time periods.

**Why this priority**: Date filtering enables trend analysis and is essential for actionable insights, but the core calculation must work first.

**Independent Test**: Can be tested by running the KPI with different date ranges and verifying results only include exports from the specified period.

**Acceptance Scenarios**:

1. **Given** export records exist across multiple dates, **When** the user specifies a start and end date, **Then** only exports within that range are included in the calculation.

2. **Given** a date range with no export records, **When** the user runs the KPI, **Then** the system indicates zero data for that period.

---

### User Story 3 - Discover Available Action Types (Priority: P3)

As a product operations user, I want to discover what action types exist in the database so I can add them to the configuration file.

**Why this priority**: Discovery mode enables users to find new action types without manual database queries.

**Independent Test**: Can be tested by running the KPI with discover_action_types=true and verifying it lists action types from the database.

**Acceptance Scenarios**:

1. **Given** export records exist with various action types, **When** the user runs the KPI with discover_action_types=true, **Then** the system lists all unique action types with their record counts.

---

### Edge Cases

- What happens when an export has multiple error logs attached? The export should still count as "not first time right" (binary: success or failure).
- What happens when the date range parameters are invalid (end date before start date)? The system should display a validation error.
- What happens when a configured action type has no data? Display zeros for that action type.

## Clarifications

### Session 2026-02-03

- Q: How are error logs linked to exports in the database? → A: Foreign key `error_log.export_id` references `everstox_qm__export_http.id`
- Q: How are action types identified in the database? → A: Filter by `tags -> 'action_type'` (hstore) on `everstox_qm__export_http` table - this column is indexed
- Q: Which error source determines "not first time right"? → A: Only `error_log` table via `export_id` FK

### Session 2026-02-04

- Q: What table should be queried for exports? → A: `everstox_qm__export_http` (not `everstox_qm__import`)
- Q: How to handle multiple action types? → A: Configure in `config.json`, query each in sequence
- Q: How to discover available action types? → A: Add `discover_action_types` parameter to list all action types from DB

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST calculate the "First Time Right" percentage as: (exports with zero error logs / total exports) * 100
- **FR-002**: System MUST query `everstox_qm__export_http` filtering by `tags -> 'action_type'` (indexed column)
- **FR-003**: System MUST check `error_log` table (via `export_id` FK) to determine if an export succeeded on first try
- **FR-004**: System MUST display results for each configured action type showing: action_type, total exports, successful exports, failed exports, and success rate percentage
- **FR-005**: System MUST allow filtering by date range (start date and end date parameters)
- **FR-006**: System MUST load action types from `config.json` file in the KPI directory
- **FR-007**: System MUST provide a discovery mode (`discover_action_types=true`) to list all available action types from the database
- **FR-008**: System MUST handle the case where no matching exports exist gracefully with zero values
- **FR-009**: System MUST follow the existing KPI pattern by extending the BaseKPI class

### Key Entities

- **Export (everstox_qm__export_http table)**: Represents an export operation; filtered by `tags -> 'action_type'` (hstore, indexed), `creation_date` timestamp, and `shop_id` association
- **Error Log (error_log table)**: Log entries linked to exports via `error_log.export_id` foreign key referencing `everstox_qm__export_http.id`; presence of at least one error_log record means the export was not "first time right"
- **Config (config.json)**: JSON file containing `action_types` array listing which action types to query

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can retrieve the First Time Right percentage for all configured action types
- **SC-002**: The KPI results accurately reflect the database state - 100% of exports with zero error logs are counted as successful
- **SC-003**: Users can filter results by date range and receive results that include only exports from the specified period
- **SC-004**: Users can discover available action types using the discover_action_types parameter
- **SC-005**: The KPI is discoverable in the menu as "First Time Right (Exports)" without manual registration
- **SC-006**: New action types can be added by editing config.json without code changes

## Assumptions

- The `everstox_qm__export_http` table contains `tags` hstore with `action_type` key to identify specific export types
- The `tags -> 'action_type'` column has an index for performance
- Error logs are linked via `error_log.export_id` foreign key to `everstox_qm__export_http.id`
- The existing date range default (14 days) is appropriate if no date range is specified

## Implementation Notes

**Final Structure**:
```
src/kpis/first_time_right_exports/
├── __init__.py
├── first_time_right_exports.py   # FirstTimeRightExportsKPI class
└── config.json                   # Action types configuration

tests/unit/
└── test_first_time_right_exports.py
```

**Key Implementation Details**:
- Uses CTE-based SQL query for clarity and performance
- Queries each action type sequentially within a single DB connection
- Console logging shows progress for each action type
- Discovery mode lists top 50 action types by count
