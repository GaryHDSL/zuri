# Zuri customer login and registration

The authentication pages are PHP and require PHP 8+, PDO MySQL, HTTPS and a MySQL database.

## Install

1. Back up the production site and database.
2. Import `auth/schema.sql` into the Zuri MySQL database.
3. Configure the following environment variables in the hosting control panel or PHP-FPM environment:
   - `ZURI_DB_HOST`
   - `ZURI_DB_NAME`
   - `ZURI_DB_USER`
   - `ZURI_DB_PASS`
4. Ensure PHP has PDO MySQL enabled and that HTTPS is active.
5. Deploy the PHP files and test registration, sign-in, sign-out and session expiry over HTTPS.

The authentication code intentionally does not read or reuse the credentials currently stored in the repository's legacy `db.php`. Rotate those exposed database credentials and move all secrets out of source control before production deployment.

## Security notes

- Passwords use PHP `password_hash()` and `password_verify()`.
- Database queries use PDO prepared statements.
- Forms use session-bound CSRF tokens.
- Session cookies are HttpOnly and SameSite=Lax; Secure is enabled when HTTPS is detected.
- Public registration always creates the `customer` role. It does not expose administrator registration.
- This is a customer-account foundation, not yet an email-verified or password-reset system.
- Add host-level request throttling and email verification before opening registration to high-volume public traffic.
- Do not enable the pages until the database schema and private database configuration are installed.
