# Rollback procedure

Use this procedure when a release causes session, invite, NUI, reveal, or cleanup failures.

1. Stop the affected resource and record the current tag and console error.
2. Restore the previous known-good resource archive or checkout.
3. Restore the matching configuration and permissions backup.
4. Restart the resource and verify that active table/session cleanup does not leave stale entities or locks.
5. Run the staging smoke test before reopening readings.
6. Record the incident and keep the broken release unavailable until fixed on `dev`.

This resource currently has no database migration. If persistence is added later, the release must include a tested migration and a database backup before deployment.
