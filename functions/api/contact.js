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
    const name = clean(body.Name || body.name, 150);
    const email = clean(body.Email || body.email, 255);
    const phone = clean(body["Phone Number"] || body.phone, 40);
    const subject = clean(body.Subject || body.subject, 255);
    const message = clean(body.Message || body.message, 5000);

    if (!name || !message) {
      return json({ ok: false, error: "Name and message are required" }, 400);
    }

    await withDb(context.env, async (db) => {
      let customerId = null;
      if (email || phone) {
        const [existing] = await db.execute(
          "SELECT id FROM customers WHERE (email IS NOT NULL AND email = ?) OR (phone IS NOT NULL AND phone = ?) LIMIT 1",
          [email || null, phone || null]
        );
        customerId = existing[0]?.id ?? null;
      }

      if (!customerId) {
        const [customer] = await db.execute(
          "INSERT INTO customers (name, email, phone) VALUES (?, ?, ?)",
          [name, email || null, phone || null]
        );
        customerId = customer.insertId;
      }

      await db.execute(
        "INSERT INTO enquiries (customer_id, name, email, phone, subject, message, source) VALUES (?, ?, ?, ?, ?, ?, 'website')",
        [customerId, name, email || null, phone || null, subject || null, message]
      );
    });

    return json({ ok: true, message: "Your enquiry has been received." }, 201);
  } catch (error) {
    console.error("Contact submission failed", error);
    return json({ ok: false, error: "Unable to save your enquiry right now" }, 500);
  }
}
