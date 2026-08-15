# Staging test matrix

Record the version, date, tester, result, and notes for each row.

| Scenario | Expected result |
|---|---|
| Clean resource start | No startup error; manifest version is visible in logs. |
| Table placement | Server validates coordinates, model, ownership, and item consumption. |
| Invite and accept/reject | Only the intended reader/customer can transition the session. |
| Spread/deal/reveal flow | State and sequence advance server-side and both players synchronize. |
| Invalid session or sequence | Request is rejected without advancing the reading. |
| Duplicate/replay reveal | A slot cannot be revealed twice or out of order. |
| Reader/customer permissions | Customer cannot perform reader-only actions. |
| Player disconnect | Session, invitation, table ownership, and temporary state are cleaned up. |
| Resource restart | No stale table/entity/session state remains. |
| Two-player concurrent actions | State transitions remain consistent under simultaneous requests. |
| Rollback smoke test | Previous tagged release starts and the main flow works. |
