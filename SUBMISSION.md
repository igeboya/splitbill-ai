# Devpost submission text

## Short description (one sentence)

Snap a receipt, and every person at the table gets their own PayPal link to pay their share.

## Inspiration

Splitting a bill is a two-minute argument and a ten-minute chase. One person pays, then messages
the group, then reminds everyone, then eats the loss when someone "forgets". The math is not the
hard part — collecting is.

## What it does

You send a photo of the receipt plus the list of names. SplitBill AI reads every line item,
totals the bill, divides it, and creates a **separate PayPal order per person** with its own
approval link. Each person taps the link, approves, and pays from their own PayPal account.
Money is captured immediately, and the payer lands on a receipt page showing the captured amount.

## How we built it

- **n8n** as the runtime and the API — two webhooks, no server to host.
- **Gemini 3.5 Flash-Lite** (vision) reads the receipt image and returns structured line items.
- A Code node validates the items, drops zero-value rows, totals, splits per participant and
  converts IDR to USD, emitting one item per person so the HTTP node fans out naturally.
- **PayPal Orders v2**: `create order` per participant, then `capture` from the return webhook.
  The return URL points straight back into the workflow, so PayPal's own checkout *is* the UI.

## Challenges

- Receipt OCR from a photo needs a vision model, not a text model with a URL in the prompt.
- PayPal does not support IDR, so amounts are converted before creating the order.
- Capturing requires PayPal's return redirect to carry the order id — solved by routing
  `return_url` into a GET webhook and reading `?token=`.
- Real-world debugging: deprecated model ids, PayPal rejecting credentials in the body instead
  of HTTP Basic, and Cloudflare's 100-second ceiling in front of the webhook.

## What's next

Live FX rates, per-item assignment (I had the fish, you had the steak), partial payments,
WhatsApp delivery of each link, and a hosted landing page for non-API users.

## Built with

n8n, PayPal Orders API v2, PayPal sandbox, Google Gemini (3.5 Flash-Lite), JavaScript.

## Tools section (what the form asks for)

| Tool | Role |
|------|------|
| PayPal Orders API v2 (sandbox) | creates one capture-intent order per participant and captures the payment |
| PayPal OAuth2 (client credentials) | token acquisition for both PayPal calls |
| Google Gemini 3.5 Flash-Lite | multimodal vision model that turns the receipt photo into structured line items |
| n8n | orchestration, HTTP calls, code steps, webhook endpoints, HTML receipt renderer |
