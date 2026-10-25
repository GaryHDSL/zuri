# Zuri Logistics MySQL database

This directory contains the first database layer for Zuri Logistics Group.

## Schema

`schema.sql` targets MySQL 8.4 and creates the `zuri_logistics` database plus the core tables for:

- customers and CRM contacts
- website contact enquiries
- transport quotes
- vehicles and drivers
- shipments and shipment tracking events
- invoices and payments
- warehouse inventory
- staff/user accounts

The schema uses InnoDB, primary keys, indexes and foreign-key relationships. MySQL documents InnoDB as the default storage engine for `CREATE TABLE` and supports foreign-key definitions in table creation. citeturn0view0

## Installation

Run `schema.sql` on the MySQL server that will host the Zuri backend.

Do **not** commit production database passwords, API keys or connection strings to this repository. The future backend should load those values from environment variables/secrets.

## Next integration step

The static Cloudflare Pages frontend should submit contact/quote forms to a backend API. The API—not browser JavaScript—should hold the MySQL credentials and write records to this database.
