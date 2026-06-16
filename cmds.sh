#!/bin/bash

DB_FILENAME=relojes.sqlite

# sqlite3 $DB_FILENAME 'select * from SETTINGS'
sqlite3 $DB_FILENAME "INSERT INTO settings (log_file, push_ip, push_port, push_freq_s, timeout_s) VALUES ('logs.txt', '192.168.1.107', 4720, 60, 30)"
