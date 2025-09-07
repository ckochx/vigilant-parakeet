# Gearflow

This is a Fleet maintenance reporting tool.

It uses LiveView and some vanilla JS to present a form for a ticketing system. It leverages tailwind styling.

The form submits to an intake screen (the Index).

Supports text, voice memos, and speech-to-text.

Speech to text is hidden for unsupported browsers.

Ex: http://localhost:4000/ on firefox (hidden)
On safari or chrome (button present and works)

We will also need to add some additional fields:
  - to capture subsequent actions (i.e. the part was ordered and will arrive by 5:00pm)
  - comments
  - add enum to status and priority

Links:
Make a new request: http://localhost:4000/
View all requests: http://localhost:4000/requests
Triage requests: http://localhost:4000/triage

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


## Runing the app locally:

```shell
mix ecto.create
mix ecto.migrate
mix phx.server
open http://localhost:4000/
```