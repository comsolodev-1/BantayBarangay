-- Seed data: 15 barangays of Talisay, Camarines Norte, Super Admin, and one Barangay Admin per barangay
-- Default passwords (change after first login): superadmin = Admin@12345 ; barangay admins = Barangay@123
USE bantay_barangay;

INSERT INTO users (username,password_hash,first_name,last_name,role,account_status,password_changed) VALUES
('superadmin','$2b$11$7WjR3re9sWDM6zYRKRDOi.T29Kr5rRdoaqaaBUrm29g0tzLJVdJlu','DILG','Super Admin','Super Admin','Active',NOW());

INSERT INTO barangays (barangay_name,barangay_code,municipality,province,status) VALUES
('Binanuaan','TAL-01','Talisay','Camarines Norte','Active'),
('Caawigan','TAL-02','Talisay','Camarines Norte','Active'),
('Cahabaan','TAL-03','Talisay','Camarines Norte','Active'),
('Calintaan','TAL-04','Talisay','Camarines Norte','Active'),
('Del Carmen','TAL-05','Talisay','Camarines Norte','Active'),
('Gabon','TAL-06','Talisay','Camarines Norte','Active'),
('Itomang','TAL-07','Talisay','Camarines Norte','Active'),
('Poblacion','TAL-08','Talisay','Camarines Norte','Active'),
('San Francisco','TAL-09','Talisay','Camarines Norte','Active'),
('San Isidro','TAL-10','Talisay','Camarines Norte','Active'),
('San Jose','TAL-11','Talisay','Camarines Norte','Active'),
('San Nicolas','TAL-12','Talisay','Camarines Norte','Active'),
('Santa Cruz','TAL-13','Talisay','Camarines Norte','Active'),
('Santa Elena','TAL-14','Talisay','Camarines Norte','Active'),
('Santo Niño','TAL-15','Talisay','Camarines Norte','Active');

INSERT INTO users (username,password_hash,first_name,last_name,role,barangay_id,account_status,created_by) VALUES
('brgy_binanuaan','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Binanuaan Admin','Barangay Admin',1,'Active',1),
('brgy_caawigan','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Caawigan Admin','Barangay Admin',2,'Active',1),
('brgy_cahabaan','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Cahabaan Admin','Barangay Admin',3,'Active',1),
('brgy_calintaan','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Calintaan Admin','Barangay Admin',4,'Active',1),
('brgy_del_carmen','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Del Carmen Admin','Barangay Admin',5,'Active',1),
('brgy_gabon','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Gabon Admin','Barangay Admin',6,'Active',1),
('brgy_itomang','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Itomang Admin','Barangay Admin',7,'Active',1),
('brgy_poblacion','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Poblacion Admin','Barangay Admin',8,'Active',1),
('brgy_san_francisco','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','San Francisco Admin','Barangay Admin',9,'Active',1),
('brgy_san_isidro','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','San Isidro Admin','Barangay Admin',10,'Active',1),
('brgy_san_jose','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','San Jose Admin','Barangay Admin',11,'Active',1),
('brgy_san_nicolas','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','San Nicolas Admin','Barangay Admin',12,'Active',1),
('brgy_santa_cruz','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Santa Cruz Admin','Barangay Admin',13,'Active',1),
('brgy_santa_elena','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Santa Elena Admin','Barangay Admin',14,'Active',1),
('brgy_santo_nino','$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu','Barangay','Santo Niño Admin','Barangay Admin',15,'Active',1);

UPDATE barangays b JOIN users u ON u.barangay_id = b.barangay_id AND u.role = 'Barangay Admin' SET b.user_id = u.user_id;
