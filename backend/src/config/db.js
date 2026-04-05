const { Pool } = require("pg");

function getDatabaseConfig() {
  const dockerStyleConfig = {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  };

  if (dockerStyleConfig.host && dockerStyleConfig.user && dockerStyleConfig.database) {
    return dockerStyleConfig;
  }

  if (process.env.DATABASE_URL) {
    return { connectionString: process.env.DATABASE_URL };
  }

  const fallbackConfig = {
    host: process.env.DATABASE_HOST,
    port: process.env.DATABASE_PORT,
    user: process.env.DATABASE_USER || process.env.POSTGRES_USER,
    password: process.env.DATABASE_PASSWORD || process.env.POSTGRES_PASSWORD,
    database: process.env.DATABASE_NAME || process.env.POSTGRES_DB,
  };

  return fallbackConfig;
}

const pool = new Pool(getDatabaseConfig());

pool.ensureRequiredTables = async () => {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS attempts (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL REFERENCES users (id) ON DELETE CASCADE,
      variant_id BIGINT NOT NULL,
      total_questions INTEGER NOT NULL,
      correct_questions INTEGER NOT NULL,
      successful BOOLEAN NOT NULL,
      created_at TIMESTAMP DEFAULT NOW()
    )
  `);
};

module.exports = pool;
