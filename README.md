# Bookkit

Production-oriented **Ruby on Rails 8.1** application with **PostgreSQL**, **Hotwire** (Turbo + Stimulus), and **Docker** for local development.

## Stack

| Layer | Choice |
| --- | --- |
| Language | Ruby 3.4.5 |
| Framework | Rails 8.1 |
| Database | PostgreSQL 16 |
| Assets | Propshaft + Importmap + Tailwind CSS v4 |
| Frontend | Turbo, Stimulus |
| Brand | Bookkit (Reddit layout · whiteboard monochrome) |
| Jobs / Cache / Cable (prod) | Solid Queue, Solid Cache, Solid Cable |
| App server | Puma (Thruster in production image) |
| Deploy | Kamal-ready (`config/deploy.yml`, production `Dockerfile`) |

## Quick start (Docker — recommended)

Host ports **5432–5434** are often already taken. This project maps Postgres to **5435**.

```bash
cp .env.example .env
docker compose up --build
```

Open **http://localhost:3000**

Health check: **http://localhost:3000/up**

| Service | Container | Host port |
| --- | --- | --- |
| Rails (`web`) | `bookkit-web` | `3000` |
| Postgres (`db`) | `bookkit-db` | `5435` → container `5432` |

Useful commands:

```bash
docker compose logs -f web
docker compose exec web bin/rails console
docker compose exec web bin/rails db:migrate
docker compose exec web bin/rails tailwindcss:build   # rebuild CSS after design changes
docker compose down          # stop
docker compose down -v       # stop + wipe DB volume
```

### Tailwind CSS

- Source (brand kit + tokens): `app/assets/tailwind/application.css`
- Built output: `app/assets/builds/tailwind.css` (gitignored; built on container start)
- Live rebuild on the **host**: `bin/dev` (Rails + `tailwindcss:watch`)
- One-shot rebuild: `bin/rails tailwindcss:build`

## Run Rails on the host (DB still in Docker)

```bash
docker compose up -d db
cp .env.example .env   # DATABASE_URL points at localhost:5435
bundle install
bin/setup --skip-server
bin/dev
```

## Project layout

```
app/                 # MVC, assets, JS (importmap), views
bin/                 # rails, setup, docker-entrypoint, jobs, ci tooling
config/              # environments, database, cable/cache/queue, deploy
db/                  # seeds + solid_* schemas (cache/queue/cable)
test/                # Minitest + Capybara system tests
Dockerfile           # production image (Kamal / thruster)
Dockerfile.dev       # local development image
docker-compose.yml   # web + postgres for local work
```

## Configuration

- **Secrets:** `config/master.key` (gitignored) + `config/credentials.yml.enc`
- **Env:** copy `.env.example` → `.env` (gitignored)
- **Database:** `config/database.yml` reads `POSTGRES_*` / `DATABASE_URL`
- **Production multi-DB:** primary + cache + queue + cable (Solid stack)

## Tests & quality

```bash
bin/rails test
bin/rails test:system
bin/ci                 # or: bin/rubocop, bin/brakeman, bin/bundler-audit
```

CI runs via GitHub Actions (`.github/workflows/ci.yml`).

## Production

```bash
# Build production image (needs master key at runtime)
docker build -t bookkit .
docker run --rm -p 80:80 \
  -e RAILS_MASTER_KEY="$(cat config/master.key)" \
  -e DATABASE_URL=postgres://... \
  bookkit
```

Kamal config lives in `config/deploy.yml` and `.kamal/`. Wire registry, hosts, and secrets before deploying.

## License

Private / unlicensed unless otherwise specified.
