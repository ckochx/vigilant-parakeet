# Gearflow

This is a Fleet maintenance reporting tool.

It uses LiveView and some vanilla JS to present a form for a ticketing system. It leverages tailwind styling.

The form submits to an intake screen (the Index).

Attachments (images, videos, voice notes) are stored locally to disc.

Supports text, voice memos, and speech-to-text.
Uses native browser API to access device capabilities

Speech to text is hidden for unsupported browsers.
  Ex: http://localhost:4000/ on firefox (hidden)
  On safari or chrome (button present and works)

We may also need to add some additional fields:
  - to capture subsequent actions (i.e. the part was ordered and will arrive by 5:00pm)
  - comments
  - add enum to status and priority

Links:
Make a new request: http://localhost:4000/

The requests space is the user facing aspect. All of one users requests will be here.
View all requests: http://localhost:4000/requests

The triage space is on the shop-side. An "admin" will see all requests from all users and can perform subsequent actions on the issue.
Triage requests: http://localhost:4000/triage

Sorting:
Issues are sorted by urgency and date. All the urgent issues appear first with the newest issue on top.

TODO:

1. Implement authentication and authorization for users. limit available actions and data (requests) appropriately
  Most submitters should only see their issues.

  The triage desk users would need to see all the be able to update statuses on the tickets.

  Auth is important to do early and not delay too long. This would be first up.

1. Implement local (indexedDB) storage to store pending messages for sending. (Handle poor connectivity)

  This is a valuable improvement to functionality and resilience. This would be next.

1. Implement server-side storage of attachments in S3 or some other disk store. We can also upload the attachments directly to an S3 with the use of one-time tokens and we should investigate that.

  This should be a relatively light lift and attachment storage is critical to make this actually work.

1. Implement Optical Character Recognition (OCR) on the server (or possibly on the device directly) to process image attachemnts and extract (relevant) details.

  This is nice to have. But it would help to improve the value and usefulness of the app overall.

1. Priority assignment based on keywords ("urgent", "broken", etc.)

  sentiment analysis: would be best with a server side LLM to handle the analysis.

  Potentially the first step in an agent workflow:

    a. sentiment analysis
    b. OCR
    c. image categorization
    d. prioritization
    e. next steps / recommended actions

1. When a voice memo is sent, use AI/LLM to process the record and perform speech to text on the server and add this to the description.

1. Use geofencing to associate a job site with an equipement list.
  a. Populate the "Equipment/Unit Number (if applicable)" field with a list of machines on site.
  b. use typeahead on the server or locally to match against a list of possible machines

1. Implement a player for voice memos.

1. add some user sorting options. Due first, oldest, etc.


## Runing the app locally:

```shell
mix ecto.create
mix ecto.migrate
mix phx.server
open http://localhost:4000/
```