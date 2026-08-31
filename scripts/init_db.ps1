$ErrorActionPreference = "Stop"

# Dependency check
if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
  [Console]::Error.WriteLine("Error: psql is not installed")
  exit 1
}

if (-not (Get-Command sqlx -ErrorAction SilentlyContinue)) {
  [Console]::Error.WriteLine("Error: sqlx is not installed")
  [Console]::Error.WriteLine("Use: ")
  [Console]::Error.WriteLine("     cargo install sqlx-cli --no-default-features --features postgres")
  [Console]::Error.WriteLine("to install it.")
  exit 1
}

# Check if custom set - otherwise default
$DB_USER = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "postgres" }
$DB_PASSWORD = if ($env:POSTGRES_PASSWORD) { $env:POSTGRES_PASSWORD } else { "postgres" }
$DB_NAME = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "newsletter" }
$DB_PORT = if ($env:POSTGRES_PORT) { $env:POSTGRES_PORT } else { "5432" }

# Launch postgres using Docker
if (-not $env:SKIP_DOCKER) {
  docker run `
    --name zero2prod-postgres `
    -e POSTGRES_USER=$DB_USER `
    -e POSTGRES_PASSWORD=$DB_PASSWORD `
    -e POSTGRES_DB=$DB_NAME `
    -p "${DB_PORT}:5432" `
    -d postgres `
    postgres -N 1000

  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

# Ping postgres until it's ready
$env:PGPASSWORD = $DB_PASSWORD

do {
  psql -h "localhost" -U $DB_USER -p $DB_PORT -d "postgres" -c "\q" *> $null
  $ready = $LASTEXITCODE -eq 0

  if (-not $ready) {
    [Console]::Error.WriteLine("Postgres still unavailable - sleeping")
    Start-Sleep -Seconds 1
  }
} until ($ready)

[Console]::Error.WriteLine("Postgres is up and running on port $DB_PORT - now running migration...")
$env:DATABASE_URL = "postgres://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}"

sqlx database create
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

sqlx migrate run
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

[Console]::Error.WriteLine("Postgres has been migrated, ready to go!")
