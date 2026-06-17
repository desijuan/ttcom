PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS settings (
    id          INTEGER PRIMARY KEY CHECK (id = 1) DEFAULT 1,
    log_file    TEXT    NOT NULL,
    push_ip     TEXT    NOT NULL,
    push_port   INTEGER NOT NULL,
    push_freq_s INTEGER NOT NULL,
    timeout_s   INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS orgs (
    id         INTEGER PRIMARY KEY,
    name       TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS buildings (
    id     INTEGER PRIMARY KEY,
    name   TEXT    NOT NULL,
    org_id INTEGER,
    FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS clocks (
    id          INTEGER PRIMARY KEY,
    name        TEXT    NOT NULL,
    ip          TEXT    NOT NULL,
    port        INTEGER NOT NULL,
    building_id INTEGER NOT NULL,
    FOREIGN KEY (building_id) REFERENCES buildings(id) ON DELETE CASCADE
);
