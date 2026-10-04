# Assessment Notes

## Changes Made

### 1. Fixed task status filtering
The status filter was returning tasks with other statuses. I found that the SQL query had an `AND`/`OR` precedence issue. I added parentheses around the title and description search conditions so the status condition applies to the complete search.

I also applied the same correction to the Oracle PL/SQL reference query.

### 2. Fixed pagination after filtering
When I changed the status or search query while on a later page, the application stayed on that page even when the filtered results had fewer pages. I updated `App.jsx` to reset the page to 1 whenever the search query or status changes.

### 3. Fixed API error loading state
When an API request failed, the loading state remained active. I updated `useTasks.js` to clear the error when a new request starts and set `loading` to `false` when the request fails.

## Tools / AI Used

I used VS Code to inspect the code, identify potential bugs, understand their root causes, and guide the fixes. I manually applied the changes and verified the behavior through the application and API.