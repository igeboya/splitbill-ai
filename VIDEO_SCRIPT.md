# Demo video script — 3 minutes max

## 0:00-0:20 — The problem
Screen: split bill chat screenshot / group chat asking for money.
VO: "Splitting a bill is easy. Collecting it is not. One person pays, then chases everyone for a week."

## 0:20-0:45 — What it is
Screen: n8n canvas, the 12 nodes highlighted left to right.
VO: "SplitBill AI: photograph the receipt, and every person at the table gets their own PayPal
payment link. No app, no server — it runs as one n8n workflow."

## 0:45-1:20 — OCR and split
Screen: send the curl request (or a thin form) with the receipt photo and 3 names.
Cut to: `Process & Calculate` output panel showing 4 parsed items and total 103,000.
VO: "A vision model reads every line item — name, quantity, unit price. The workflow drops junk
rows, totals it, splits three ways and converts to USD because PayPal doesn't settle IDR."

## 1:20-2:00 — PayPal order created
Screen: response JSON with 3 `payments[]` entries, highlight one `approval_url`.
VO: "Three separate PayPal orders, one per participant — each with its own approval link.
Orders created with intent CAPTURE."

## 2:00-2:35 — Pay and capture
Screen: open approval URL in sandbox, balance selected, Pay Now → redirect to the receipt page:
"Payment captured / PAID / 2.15 USD".
VO: "The payer approves with a sandbox balance, and PayPal redirects straight back into the
workflow, which captures the order."

## 2:35-2:55 — Proof
Screen: PayPal sandbox transaction, status COMPLETED, balance debited.
VO: "Status COMPLETED, funds captured. This is money moving, not just an order being created."

## 2:55-3:00 — Close
Screen: canvas + repo URL.
VO: "SplitBill AI — snap the receipt, get paid."
