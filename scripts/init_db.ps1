$ErrorActionPreferance = "Stop"
Set-PSDebug -Trace 1

# Check if a custom user has been set, otherwise default to 'postgres'
$DB_USER = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "postgres" }

# Check if a custom password has been set, otherwise default to 'password'
$DB_PASSWORD = if ($env:POSTGRES_PASSWORD) { $env:POSTGRES_PASSWORD } else { "password" }

# Check if a custom database name has been set, otherwise default to 'newsletter'
$DB_NAME = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "newsletter" }

# Check if a custom port has been set, otherwise default to '5432'
$DB_PORT = if ($env:POSTGRES_PORT) { $env:POSTGRES_PORT } else { "5432" }

# Launch postgres using Docker
docker run `
  -e POSTGRES_USER=$DB_USER `
  -e POSTGRES_PASSWORD=$DB_PASSWORD `
  -e POSTGRES_DB=$DB_NAME `
  -p "${DB_PORT}:5432" `
  -d postgres `
  postgres -N 1000