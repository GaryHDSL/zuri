import { withDb, json } from "../_lib/db.js";

export async function onRequestGet(context) {
  try {
    const result = await withDb(context.env, async (db) => {
      const [rows] = await db.query("SELECT 1 AS ok");
      return rows[0];
    });

    return json({ ok: result.ok === 1, database: "mysql" });
  } catch (error) {
    console.error("Database health check failed", error);
    return json({ ok: false, error: "Database connection unavailable" }, 503);
  }
}
