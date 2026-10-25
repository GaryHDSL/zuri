import { createConnection } from "mysql2/promise";

export async function withDb(env, work) {
  if (!env.HYPERDRIVE) {
    throw new Error("HYPERDRIVE binding is not configured");
  }

  const connection = await createConnection({
    host: env.HYPERDRIVE.host,
    user: env.HYPERDRIVE.user,
    password: env.HYPERDRIVE.password,
    database: env.HYPERDRIVE.database,
    port: env.HYPERDRIVE.port,
    disableEval: true,
  });

  try {
    return await work(connection);
  } finally {
    await connection.end();
  }
}

export function json(data, status = 200) {
  return Response.json(data, {
    status,
    headers: {
      "Cache-Control": "no-store",
    },
  });
}
