INSERT INTO orgs (id, name)
VALUES (1, 'Cancillería');

INSERT INTO buildings (id, name, org_id)
VALUES (1, 'Edificio 1', 1);

INSERT INTO clocks (id, name, ip, port, building_id)
VALUES (1, 'Entrada Principal', '82.254.138.246', 4277, 1);

INSERT INTO clocks (id, name, ip, port, building_id)
VALUES (2, 'Entrada Lateral', '80.171.133.247', 4270, 1);

INSERT INTO clocks (id, name, ip, port, building_id)
VALUES (3, 'Estacionamiento', '70.95.11.51', 4294, 1);

INSERT INTO buildings (id, name, org_id)
VALUES (2, 'Edificio 2', 1);

INSERT INTO clocks (id, name, ip, port, building_id)
VALUES (4, 'Entrada Única', '80.256.130.47', 4270, 2);
