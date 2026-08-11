-- Run against your ESX database. Only needed if Config.Inventory resolves
-- to 'esx' and Config.RequireTableItem = true.

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`)
VALUES ('tarot_table', 'Tarot Masası', 4000, 0, 1)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`);
