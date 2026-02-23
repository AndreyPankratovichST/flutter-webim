# Webim Mobile SDK – Server‑side API Reference

Below is a high‑level description of all public server endpoints that the SDK talks to, grouped by functional area.

The table lists:

Endpoint	HTTP method	URL (relative to https://{server}/api/v1/…)	Request payload / query parameters	Response format	Notes
Auth / Session					
POST /session	POST	/api/v1/session/create	{ "visitorId": string, "clientSideId": string, … } – visitor info and optional device data	{ "sessionId": string, "token": string, … } – session token used for subsequent calls	Creates a new visitor session.
POST /session/refresh	POST	/api/v1/session/refresh	{ "token": string }	{ "sessionId": string, "token": string, … }	Refreshes a stale token.
DELETE /session/{id}	DELETE	/api/v1/session/delete	none	{ "status": "ok" }	Ends the session.
Message flow					
POST /message	POST	/api/v1/message/send	{ "sessionId": string, "content": string, "type": string, … } – text, file URL, etc.	{ "messageId": string, "status":"sent" }	Sends a new message.
GET /messages/history	GET	/api/v1/message/history	query: sessionId, before?, since?, limit?	{ "messages": [ … ], "hasMore": bool }	Fetches paginated chat history.
GET /messages/stream	GET	/api/v1/message/stream?sessionId=	none (WebSocket upgrade handled by SDK)	WebSocket stream of MessageItem JSON objects	Real‑time message delivery.
FAQ / Knowledge base					
GET /faq	GET	/api/v1/faq/list	query: departmentId?, categoryId?	{ "categories": [ … ], "items":[…] }	Returns top‑level FAQ categories.
GET /faq/categories/{id}	GET	/api/v1/faq/category	none	{ "category": { … }, "items":[…] }	Returns a single category and its items.
GET /faq/item/{id}	GET	/api/v1/faq/item	none	{ "item": { … } }	Returns a single FAQ item.
Survey					
POST /survey/answer	POST	/api/v1/survey/submit	{ "sessionId": string, "surveyId": string, "answers":[{qId, answer}] }	{ "status":"ok" }	Submits survey answers.
File upload					
POST /file/upload	POST	/api/v1/file/upload	multipart/form‑data: file, optional metadata	{ "url":"https://…/files/12345", "mime":string, … }	Returns signed URL for accessing the file.
Location / Operators					
GET /operators/online	GET	/api/v1/operator/online	query: departmentId?	{ "operators":[{id, name, status,…}] }	List of online operators.
History / Delta sync					
GET /history/delta	GET	/api/v1/history/delta?since=	query: sessionId, since (timestamp)	{ "deltas":[…] }	Incremental sync of new messages.
System / Diagnostics					
GET /status	GET	/api/v1/status	none	{ "ok":true, "version":"…", … }	Health‑check endpoint.
WebimService (internal)					
POST /service/command	POST	/api/v1/service/command	{ "cmd":"…", "payload":{…} }	{ "result":{…} }	Used by SDK for internal actions (e.g., startSession, endChat).
Request / Response payload details
Field	Type	Description
visitorId	string	Unique ID assigned to a visitor (can be generated client‑side).
clientSideId	string	Device fingerprint / identifier.
sessionId	string	Token identifying the active chat session.
content	string	Text of a message. For files, this is the signed URL returned by /file/upload.
type	string	"text", "image", "video", "file" etc.
departmentId	string	Optional filter for department‑specific FAQs/operators.
categoryId	string	FAQ category identifier.
surveyId	string	Identifier of the survey to answer.
answers	array	List of {qId: string, answer: string} objects.
since / before	timestamp (ISO 8601)	Pagination markers for history/delta endpoints.
limit	int	Max number of items to return (default 50).
Typical SDK flow
Create session – POST /session → obtain token.
Send/receive messages – use /message/send, /messages/history, and the WebSocket stream.
FAQ – query /faq or specific items; use locally cached data if available.
Upload file – POST /file/upload → get signed URL, then send that URL in a message.
Survey – submit via /survey/answer.
Sync history – call /history/delta periodically to keep local cache fresh.
End session – DELETE /session/{id} when chat ends.
Note: All endpoints expect the SDK to attach an Authorization: Bearer {token} header unless otherwise specified.

Error handling
All endpoints return a JSON object with at least:


{ "error": { "code": int, "message": string } }
400 – bad request (validation error)
401 – unauthorized (invalid/expired token)
403 – forbidden
404 – resource not found
500 – internal server error
The SDK maps these to local error types (WebimError, FatalErrorHandler) for consistent handling.

End of documentation.