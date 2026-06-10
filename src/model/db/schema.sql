CREATE TABLE IF NOT EXISTS config (
    id          INTEGER PRIMARY KEY CHECK (id = 1) DEFAULT 1,
    log_file    TEXT    NOT NULL,
    push_ip     TEXT    NOT NULL,
    push_port   INTEGER NOT NULL,
    push_freq_s INTEGER NOT NULL,
    timeout_s   INTEGER NOT NULL
);
