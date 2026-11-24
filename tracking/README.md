# Zuri Logistics Tracking

This folder defines the first implementation stage for a combined customer shipment tracker and internal fleet control tower.

## Included data model

Import `schema.sql` into a **backup-first staging database**. It creates:
- Vehicles, including third-party fleet vehicles
- Drivers with hashed device tokens
- Shipments and customer-facing tracking codes
- Timestamped GPS positions from driver phones, GPS devices or Traccar
- Shipment status events for collection, border, offloading and delivery

## Two GPS sources

1. **Driver phones:** a mobile-friendly driver page will request location permission and send periodic coordinates over HTTPS. Drivers must be informed and must explicitly enable sharing.
2. **GPS hardware / Traccar:** connect compatible trackers to Traccar, then consume its authenticated API or webhook feed. Device identifiers must be mapped to Zuri vehicle records.

The database supports both sources. Live GPS is not active merely by importing the schema; device provisioning and authenticated API endpoints are still required.

## Required deployment work

1. Rotate the database password currently present in the repository and remove credentials from source control. Use hosting environment secrets or a private config file outside the public web root.
2. Create a staging database and import `schema.sql`.
3. Configure HTTPS, restricted admin authentication, CSRF protection, rate limits and hashed driver/device tokens before exposing write endpoints.
4. Configure Traccar URL and API token as server-side secrets. Never place the Traccar token or database password in browser JavaScript.
5. Add the customer tracking page and staff-only control tower only after the authenticated API is deployed and tested.

## Privacy and safety

Collect location only for active work trips, show drivers when sharing is enabled, restrict precise location to authorized staff, and define a retention period. Public tracking lookups should expose shipment milestones and coarse progress—not a truck's live coordinates or driver's personal details.
