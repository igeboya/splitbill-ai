# SplitBill AI — split a receipt, charge everyone with PayPal

Turn a photo of a restaurant receipt into per-person PayPal payment links. A vision model reads the line items, the split is computed, and each participant gets their own PayPal order they can approve and pay from a phone.

Built for the **PayPal AI Hackathon**. Runs entirely as an n8n workflow — no server, no frontend to host.

## How it works

```
POST /webhook/split-bill   { image, participants[] }
        |
   Prepare AI Request      build a vision request (image URL, data URL or raw base64)
        |
   AI OCR                  Gemini 3.5 Flash-Lite reads every line item -> JSON
        |
   Process & Calculate     filters junk rows, totals, splits, converts IDR->USD,
        |                  emits one item per participant
   PayPal Create Order     POST /v2/checkout/orders  (one order per person)
        |
   Response                { success, total, per_person, items[], payments[] }
```

Each `payments[].approval_url` is a PayPal checkout link. After the payer approves, PayPal
redirects to:

```
GET /webhook/paypal-capture?token=<order_id>
        |
   PayPal Capture Order    POST /v2/checkout/orders/{id}/capture
        |
   Respond - Receipt Page  HTML receipt: status, payer, amount, order id
```

Money only moves at the capture step, which is what closes the loop.

## Requirements

- n8n (tested on n8n cloud 1.x)
- A Google AI Studio API key (Gemini) — free tier is enough
- PayPal developer account with a **sandbox** REST app (Client ID + Secret)

## Setup

1. **Import** `workflow/splitbill.json` into n8n.
2. **Credential: Header Auth** (for the AI node)
   - Name `Authorization`
   - Value `Bearer <GOOGLE_AI_STUDIO_KEY>`
3. **Credential: OAuth2 API** (for both PayPal nodes)
   - Grant Type `Client Credentials`
   - Access Token URL `https://api-m.sandbox.paypal.com/v1/oauth2/token`
   - Client ID + Client Secret from the sandbox app
   - Authentication **Header** (PayPal requires HTTP Basic — Body will fail with
     `Client authentication failed`)
4. Point both PayPal nodes at that credential, then **Publish** the workflow.
5. Replace `bengss` in `return_url` / `cancel_url` with your own n8n subdomain.

## Usage

```bash
curl -X POST https://<your-subdomain>.app.n8n.cloud/webhook/split-bill \
  -H "Content-Type: application/json" \
  -d '{"image":"https://example.com/receipt.jpg","participants":["Beng","Andi","Rina"]}'
```

`image` accepts a public URL, a data URL (`data:image/jpeg;base64,...`) or bare base64.
Omit `participants` and it defaults to `["Person 1","Person 2"]`.

```json
{
  "success": true,
  "currency": "IDR",
  "total": 103000,
  "per_person": 34333,
  "items": [{"name":"Nasi Goreng Spesial","qty":2,"unit_price":25000,"total":50000}],
  "payments": [{
    "participant": "Beng",
    "amount_idr": 34333,
    "amount_usd": "2.15",
    "order_id": "74K2556111654951E",
    "status": "CREATED",
    "approval_url": "https://www.sandbox.paypal.com/checkoutnow?token=74K2556111654951E"
  }]
}
```

## PayPal integration

- `POST /v2/checkout/orders` — one order per participant, `intent: CAPTURE`, amount in USD,
  `custom_id` carries the participant name so the receipt can attribute the payment.
- `POST /v2/checkout/orders/{id}/capture` — fired from the return webhook, `Prefer: return=representation`.
- `application_context.return_url` points back into the workflow, so PayPal's redirect is the UI.
- Verified end to end in sandbox: order status `COMPLETED`, buyer balance debited.

## AI integration

`gemini-3.5-flash-lite` via the OpenAI-compatible endpoint
(`/v1beta/openai/chat/completions`), temperature 0, message content as
`[{type:"image_url"},{type:"text"}]`. The system prompt forces a JSON array reply, and the
parser tolerates code fences and stray prose.

## Limitations

- IDR is not a PayPal-supported currency, so totals are converted at a fixed
  `IDR_PER_USD` constant in `Process & Calculate`. For a production build this reads a live FX rate.
- The split is even per person; per-item assignment is not implemented.
- OCR latency is 10-50s depending on the model; the webhook is synchronous, so callers wait.
  Cloudflare fronts n8n cloud and kills any request over 100 seconds.
- Sandbox only. Going live needs a live REST app and real currency handling.

## License

MIT — see `LICENSE`.
