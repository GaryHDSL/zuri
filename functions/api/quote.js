import { withDb, json } from "../_lib/db.js";

function clean(value, max = 5000) {
  return String(value ?? "").trim().slice(0, max);
}

async function readPayload(request) {
  const type = request.headers.get("content-type") || "";
  if (type.includes("application/json")) return await request.json();
  const form = await request.formData();
  return Object.fromEntries(form.entries());
}

export async function onRequestPost(context) {
  try {
    const body = await readPayload(context.request);
    const name = clean(body["Client Name"] || body.name, 150);
    const email = clean(body.Email || body.email, 255);
    const phone = clean(body["Mobile Number"] || body.phone, 40);
    const company = clean(body.Company || body.company, 180);
    const location = clean(body.Location || body.location, 255);
    const service = clean(body["Service Looking"] || body.service, 120);
    const message = clean(body[" Special Message"] || body["Special Message"] || body.message, 5000);

    if (!name || !email || !phone) {
      return json({ ok: false, error: "Name, email and mobile number are required" }, 400);
    }

    const quoteId = await withDb(context.env, async (db) => {
      let customerId = null;
      const [existing] = await db.execute(
        "SELECT id FROM customers WHERE email = ? OR phone = ? LIMIT 1",
        [email, phone]
      );
      customerId = existing[0]?.id ?? null;

      if (customerId) {
        await db.execute(
          "UPDATE customers SET name = ?, company = ?, address = ? WHERE id = ?",
          [name, company || null, location || null, customerId]
        );
      } else {
        const [customer] = await db.execute(
          "INSERT INTO customers (name, email, phone, company, address) VALUES (?, ?, ?, ?, ?)",
          [name, email, phone, company || null, location || null]
        );
        customerId = customer.insertId;
      }

      const [quote] = await db.execute(
        "INSERT INTO quotes (customer_id, service, pickup_location, company, message) VALUES (?, ?, ?, ?, ?)",
        [customerId, service || null, location || null, company || null, message || null]
      );

      return quote.insertId;
    });

    return json({ ok: true, quoteId, message: "Your quote request has been received." }, 201);
  } catch (error) {
    console.error("Quote submission failed", error);
    return json({ ok: false, error: "Unable to save your quote request right now" }, 500);
  }
}
