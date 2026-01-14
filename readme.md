# gator

gator is a terminal-based RSS reader and aggregator written in Go.

It lets you:

- register and manage users
- add and follow RSS feeds
- run a background aggregator that fetches posts on a schedule
- browse posts from the feeds you follow, right in your terminal

---

## Prerequisites

To build and run gator, you’ll need:

- Go (version 1.21+ recommended)
  - Install from: https://go.dev/dl/
- PostgreSQL
  - Install from: https://www.postgresql.org/download/
  - Ensure psql and the Postgres server are running and accessible.

You should also have Git installed to clone the repository.

---

## Installation

### 1. Clone the repository

    git clone https://github.com/orby1647/gator.git
    cd gator

### 2. Set up the database

1. Create a Postgres database (for example, gator):

       createdb gator

2. Apply migrations (if you’re using goose or another migration tool, follow those steps here).
   For example, with goose:

       goose postgres "$DB_URL" up

   Where DB_URL looks something like:

       postgres://username:password@localhost:5432/gator?sslmode=disable

   Adjust username, password, host, port, and DB name as needed.

### 3. Install the gator CLI

From the repo root:

    go install ./...

or, if you want to install directly from GitHub:

    go install github.com/orby1647/gator@latest

This builds a static gator binary and places it in your GOBIN (usually $HOME/go/bin).
Make sure GOBIN is on your PATH, for example:

    export PATH="$PATH:$(go env GOPATH)/bin"

After that, you should be able to run:

    gator

from any directory.

Note:
- go run . is for development.
- gator (the installed binary) is what you’ll use “in production”.

---

## Configuration

gator uses a config file to store:

- the database URL
- the current logged-in user

By default, the config is stored in your home directory (for example):

    ~/.gatorconfig.json

A typical config might look like:

    {
      "db_url": "postgres://username:password@localhost:5432/gator?sslmode=disable",
      "current_user_name": ""
    }

You can either:

- create this file manually before first run, or
- let the program create/update it as you register and log in users.

As long as db_url is correct, you can use the CLI commands (register, login, etc.) to manage the rest.

---

## Usage

Once installed and configured, you can use gator from the command line.

### Users

Register a new user:

    gator register lane

Log in as an existing user:

    gator login lane

List all users:

    gator users

The current user will be labeled with (current).

Reset the database (development convenience):

    gator reset

This deletes all users (and cascades dependent records like feeds, follows, and posts).

---

### Feeds and follows

Add a new feed (and auto-follow it):

    gator addfeed "Boot.dev Blog" https://blog.boot.dev/index.xml

List all feeds and who added them:

    gator feeds

Example output:

    * Boot.dev Blog (https://blog.boot.dev/index.xml) — added by lane

Follow an existing feed by URL:

    gator follow https://blog.boot.dev/index.xml

Unfollow a feed by URL:

    gator unfollow https://blog.boot.dev/index.xml

List feeds the current user is following:

    gator following

---

### Aggregation (background fetcher)

The agg command runs a never-ending loop that:

1. selects the next feed to scrape (based on last_fetched_at)
2. marks it as fetched
3. fetches and parses the RSS
4. stores posts in the database

Run the aggregator with a given interval:

    gator agg 1m

Examples of valid intervals:

- 1s — every second
- 30s — every 30 seconds
- 1m — every minute
- 5m — every 5 minutes
- 1h — every hour

When it starts, it prints something like:

    Collecting feeds every 1m0s
    Fetching feed: Boot.dev Blog (https://blog.boot.dev/index.xml)

You can kill the aggregator with Ctrl+C.

Recommended:
Run gator agg in one terminal window and interact with the CLI (add feeds, follow feeds, browse posts) in another.

---

### Browsing posts

gator stores posts from the feeds you follow and lets you browse them.

Browse recent posts:

    gator browse

By default, this shows the 2 most recent posts from feeds you follow.

Browse with a custom limit:

    gator browse 10

This shows the 10 most recent posts.

Output looks something like:

    Title: Understanding Interfaces in Go
    URL:   https://blog.boot.dev/understanding-interfaces-in-go/
    Published: Mon, 06 Sep 2021 12:00:00 GMT

---

## Development

During development, you can run the CLI directly from the project directory:

    go run .

This behaves like gator, but builds and runs the code on the fly.

Typical dev workflow:

    # Run migrations
    goose postgres "$DB_URL" up

    # Run the app
    go run . register lane
    go run . login lane
    go run . addfeed "Boot.dev Blog" https://blog.boot.dev/index.xml
    go run . agg 1m
    go run . browse 5

---

## Production

Once installed with go install, gator is a statically compiled binary that:

- does not require the Go toolchain at runtime
- only needs access to your Postgres database and config file

You can copy the gator binary to another machine (with the same OS/architecture), point it at a Postgres instance, set up the config file, and run it there without needing Go installed.

---

## License

Add your preferred license here (e.g., MIT, Apache 2.0) if you plan to share this publicly.
