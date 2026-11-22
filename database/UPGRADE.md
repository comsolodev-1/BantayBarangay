# Database setup and upgrade

The app uses barangay codes for barangay links and looks up role names from the
`roles` table. Use the app version that ships with these SQL files.

For an existing installation that already uses barangay codes, select the
database named in the app's `BantayDb` setting and import
`add_roster_term_years.sql` before using the updated roster. Existing officials
keep their records and show an empty term until both years are entered.

## Fresh setup

1. Start MySQL or MariaDB and open phpMyAdmin.
2. On the server's Import tab, import `schema.sql` first. It creates
   `bantay_barangay`, defines the tables, and inserts the three roles.
3. Import `seed.sql` next. It adds the 15 barangays and starter accounts.
4. Run the app with the `BantayDb` connection string targeting
   `bantay_barangay`. Use the supplied initial login information and set new
   passwords before sharing the installation.

## Upgrade a database that already has records

These steps assume the original database is named `bantay_barangay` and has
the original `barangay_id` and `users.role` columns.

1. Stop the website to freeze changes. Export `bantay_barangay` from
   phpMyAdmin and back up the app's `App_Data/uploads` directory.
2. In phpMyAdmin, check the collation of the original `bantay_barangay`
   database. Create an empty `bantay_barangay_v2` database with the same
   collation. For example, our XAMPP setup used `utf8mb4_general_ci`.

   Make a copy of the new `schema.sql`. In that copy, change the database
   name to `bantay_barangay_v2` in the `CREATE DATABASE` and `USE`
   statements at the top. Select `bantay_barangay_v2` in phpMyAdmin,
   confirm the top bar shows the `_v2` name, then import the copy.
3. Keep `bantay_barangay_v2` selected and import `upgrade_from_legacy.sql`.
   This copies the existing records, including accounts and barangays.
   Skip `seed.sql` for an upgrade. If either import reports an error,
   stop before switching the app's connection.
   because your existing accounts and barangays are copied.
4. After a successful import, change only the database name in the
   `BantayDb` connection string in `web.config` to
   `bantay_barangay_v2`. The app's database account must have access to
   that database. Keep `App_Data/uploads` in place.
5. Start the updated app, sign in again, and check both admin roles,
   submissions, reports, and an existing uploaded file before resuming work.

If the copy fails, the data transaction rolls back and the original database
remains available. Read the import error and keep the app pointed at its
previous database with the previous code. Some old databases might have
submissions without a recorded submitter or values that violate the new
constraints. Resolve those with your backend teammate before retrying. If a
failed import left the temporary migration routine in the destination,
remove that routine in phpMyAdmin before rerunning the import.
