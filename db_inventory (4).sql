-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 28, 2024 at 07:11 PM
-- Server version: 10.4.22-MariaDB
-- PHP Version: 8.1.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_inventory`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `active_inactive_cat_brand_product` (IN `vbl` VARCHAR(255), IN `cat_id` INT, IN `status_ch` VARCHAR(255))  BEGIN
    IF vbl = 'change_status' THEN
    UPDATE category cat left join brand bd on cat.category_id=bd.category_id LEFT JOIN product pd ON pd.category_id=cat.category_id
set cat.category_status=status_ch, bd.brand_status=status_ch, pd.product_status=status_ch WHERE cat.category_id=cat_id;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cat_pro` (IN `vbl` VARCHAR(255), IN `cat_id` INT, IN `cat_name` VARCHAR(250), IN `cat_status` VARCHAR(255))  BEGIN
    IF vbl = 'insrt' THEN
    INSERT INTO category(category_name)
    VALUES(cat_name);
    
    ELSEIF vbl = 'upd' THEN
    UPDATE category SET category_name=cat_name,category_status=cat_status WHERE category_id = cat_id;
    END IF;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_total` (`vbl` VARCHAR(255))  BEGIN
IF vbl = 'total_credit' THEN
SELECT sum(inventory_order_total) as total_order_value FROM inventory_order WHERE payment_status = 'credit' AND inventory_order_status='active';

ELSEIF vbl = 'total_cash_order' THEN
SELECT sum(inventory_order_total) as total_order_value FROM inventory_order 
	WHERE payment_status = 'cash' 
	AND inventory_order_status='active';

ELSEIF vbl ='total_order_value' THEN
SELECT sum(inventory_order_total) as total_order_value FROM inventory_order 
	WHERE inventory_order_status='active';    
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `fetch_order_list` (IN `vbl` VARCHAR(255))  BEGIN
IF vbl = 'user_wise_total_order' THEN
SELECT sum(inventory_order.inventory_order_total) as order_total, 
	SUM(CASE WHEN inventory_order.payment_status = "cash" THEN inventory_order.inventory_order_total ELSE 0 END) AS cash_order_total, 
	SUM(CASE WHEN inventory_order.payment_status = "credit" THEN inventory_order.inventory_order_total ELSE 0 END) AS credit_order_total, 
	user_details.user_name 
	FROM inventory_order 
	INNER JOIN user_details ON user_details.user_id = inventory_order.user_id 
	WHERE inventory_order.inventory_order_status = "active" GROUP BY inventory_order.user_id;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `inventory_order_proc` (IN `vbl` VARCHAR(255), IN `inventoryOrderId` INT, IN `userid` INT, IN `inventory_total` DOUBLE(10,2), IN `inventory_tax` DOUBLE(10,2), IN `inventoryOrderTotal` DOUBLE(10,2), IN `date1` DATE, IN `in_order_name` VARCHAR(255), IN `inventory_order_mobile` VARCHAR(255), IN `in_order_address` TEXT, IN `pay_status` VARCHAR(255), IN `in_order_status` VARCHAR(255), IN `date2` DATE)  BEGIN
   IF vbl = 'insrt' THEN
   INSERT INTO inventory_order(user_id,inventory_total,inventory_tax, inventory_order_total, inventory_order_date, inventory_order_name,inventory_order_mobile, inventory_order_address, payment_status, inventory_order_status, inventory_order_created_date)VALUES(userid,inventory_total,inventory_tax,inventoryOrderTotal, date1, in_order_name,inventory_order_mobile,in_order_address, pay_status, in_order_status, date2);
   
   ELSEIF vbl = 'upd' THEN
   UPDATE inventory_order SET user_id=userid,inventory_total=inventory_total,inventory_tax=inventory_tax, inventory_order_total=inventoryOrderTotal,
   inventory_order_date=date1, inventory_order_name=in_order_name,inventory_order_mobile=inventory_order_mobile, inventory_order_address=in_order_address, payment_status=pay_status, inventory_order_status=in_order_status, inventory_order_created_date=date2;
   END IF;
   END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `join_product_orderproduct_order` (`vbl` VARCHAR(255), `order_id` INT)  BEGIN
    IF vbl = 'fetch_all_data' THEN
    SELECT * from inventory_order_product op INNER JOIN product pd ON op.product_id=pd.product_id INNER JOIN inventory_order i_o ON op.inventory_order_id=i_o.inventory_order_id INNER JOIN brand bd on bd.brand_id=pd.brand_id WHERE i_o.inventory_order_id=order_id;
    
    END IF;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pro_brand` (`vbl` VARCHAR(255), `b_id` INT, `cat_id` INT, `b_name` VARCHAR(255))  BEGIN 
    IF vbl = 'insrt' THEN
    insert into brand(category_id,brand_name)VALUES(cat_id,b_name);
    ELSEIF vbl = 'upd' THEN
    UPDATE brand SET category_id=cat_id,brand_name=b_name WHERE brand_id=b_id;
    END IF;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pro_product` (`vbl` VARCHAR(255), `p_id` INT, `c_id` INT, `b_id` INT, `p_name` VARCHAR(255), `p_desc` TEXT, `p_qty` INT, `p_unit` VARCHAR(255), `p_base_price` DOUBLE(10,2), `p_tax` DECIMAL(4,2), `p_min_order` DOUBLE(10,2), `p_entry_by` INT, `p_status` VARCHAR(255), `p_date` DATE)  BEGIN
 IF vbl = 'insrt' THEN
 INSERT INTO product (category_id, brand_id, product_name, product_description, product_quantity, product_unit, product_base_price, product_tax, product_enter_by, product_status, product_date)VALUES(c_id,b_id,p_name,p_desc,p_qty,p_unit,p_base_price,p_tax,p_entry_by,p_status,p_date);
 ELSEIF vbl = 'upd' THEN
 UPDATE product SET category_id=c_id,brand_id=b_id,product_name=p_name,product_description=p_desc,product_quantity=p_qty,product_unit=p_unit,product_base_price=p_base_price,product_tax=p_tax,product_enter_by=p_entry_by,product_status=p_status,product_date=p_date WHERE product_id=p_id;
 END IF;
 END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_pro_detail` (IN `vbl` VARCHAR(255), IN `pro_id` INT)  BEGIN
    IF vbl = 'product_details' THEN
    SELECT * FROM product 
		INNER JOIN category ON category.category_id = product.category_id 
		INNER JOIN brand ON brand.brand_id = product.brand_id 
		INNER JOIN user_details ON user_details.user_id = product.product_enter_by 
		WHERE product.product_id in (pro_id);
        ELSEIF vbl='qty' THEN
    SELECT 	inventory_order_product.quantity FROM inventory_order_product 
	INNER JOIN inventory_order ON inventory_order.inventory_order_id = inventory_order_product.inventory_order_id
	WHERE inventory_order_product.product_id = pro_id AND
	inventory_order.inventory_order_status = 'active';
        END IF;
    END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `brand`
--

CREATE TABLE `brand` (
  `brand_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `brand_name` varchar(250) NOT NULL,
  `brand_status` enum('active','inactive') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `brand`
--

INSERT INTO `brand` (`brand_id`, `category_id`, `brand_name`, `brand_status`) VALUES
(1, 4, 'Canon', 'active'),
(2, 4, 'Nikon', 'active'),
(3, 4, 'Sony', 'active'),
(4, 1, 'Samsung', 'active'),
(5, 1, 'Apple', 'active'),
(6, 1, 'One Plus', 'active'),
(7, 1, 'Oppo', 'active'),
(8, 1, 'Vivo', 'active'),
(9, 1, 'Asus', 'active'),
(10, 1, 'Real Me', 'active'),
(11, 1, 'MI', 'active'),
(12, 2, 'HP', 'active'),
(13, 2, 'Lenovo', 'active'),
(14, 2, 'Apple', 'active'),
(15, 2, 'Asus', 'active'),
(16, 2, 'Acer', 'active'),
(17, 2, 'Toshiba', 'active'),
(18, 7, 'Lenovo', 'active'),
(19, 7, 'HP', 'active'),
(20, 7, 'Apple', 'active'),
(21, 7, 'Asus', 'active'),
(22, 7, 'Acer', 'active'),
(23, 6, 'BT1001', 'active'),
(24, 6, 'BT1002', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(250) NOT NULL,
  `category_status` enum('active','inactive') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`category_id`, `category_name`, `category_status`) VALUES
(1, 'Mobile', 'active'),
(2, 'Mobile', 'active'),
(3, 'Desktop', 'active'),
(4, 'Camera', 'active'),
(5, 'Printer', 'active'),
(6, 'BT printer', 'active'),
(7, 'Laptop', 'active'),
(8, 'TEST', 'active'),
(9, 'TEST1', 'active'),
(10, 'TEST3', 'active'),
(11, 'TEST4', 'active'),
(12, 'test5', 'active'),
(13, 'test6', 'active'),
(14, 'test7', 'inactive'),
(15, 'test8', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_order`
--

CREATE TABLE `inventory_order` (
  `inventory_order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `inventory_total` double(10,2) NOT NULL,
  `inventory_tax` double(10,2) NOT NULL,
  `inventory_order_total` double(10,2) NOT NULL,
  `inventory_order_date` date NOT NULL,
  `inventory_order_name` varchar(255) NOT NULL,
  `inventory_order_mobile` varchar(255) NOT NULL,
  `inventory_order_address` text NOT NULL,
  `payment_status` enum('cash','credit') NOT NULL,
  `inventory_order_status` varchar(100) NOT NULL,
  `inventory_order_created_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `inventory_order`
--

INSERT INTO `inventory_order` (`inventory_order_id`, `user_id`, `inventory_total`, `inventory_tax`, `inventory_order_total`, `inventory_order_date`, `inventory_order_name`, `inventory_order_mobile`, `inventory_order_address`, `payment_status`, `inventory_order_status`, `inventory_order_created_date`) VALUES
(1, 1, 54500.00, 9810.00, 64310.00, '2020-07-01', 'Ayan Ali', '06512215786', 'Bariyatu Ranchi', 'cash', 'active', '2020-07-01'),
(2, 1, 35500.00, 6390.00, 41890.00, '2020-07-02', 'Krishna Sir', '8457884875', 'Ranchi', 'cash', 'active', '2020-07-02'),
(3, 2, 15500.00, 2790.00, 18290.00, '2020-07-03', 'Manisha Kumari', '8083583008', 'Kanta Toli Ranchi', 'credit', 'active', '2020-07-03'),
(4, 2, 50000.00, 9000.00, 59000.00, '2020-07-04', 'Naved Anjum', '8345875485', 'NA', 'cash', 'active', '2020-07-04'),
(5, 1, 45500.00, 8190.00, 53690.00, '2020-07-05', 'Amit Kumar', '8754854854', 'NA', 'cash', 'active', '2020-07-05'),
(6, 2, 95500.00, 17190.00, 112690.00, '2020-07-06', 'Sarfraz Alam', '8548788875', 'Bariatu Ranchi', 'cash', 'active', '2020-07-06'),
(7, 1, 54500.00, 9810.00, 64310.00, '2020-07-09', 'Shadab', '8487887845', 'Main road ranchi', 'cash', 'active', '2020-07-09'),
(8, 1, 54500.00, 9810.00, 64310.00, '2020-07-10', 'Alina', '7979996775', 'Ranchi', 'cash', 'active', '2020-07-10'),
(9, 1, 147000.00, 26460.00, 173460.00, '2020-07-11', 'Manish Sir', '80878978984', 'Ranchi', 'cash', 'active', '2020-07-11'),
(10, 1, 64000.00, 11520.00, 75520.00, '2020-07-07', 'Sushma', '8799848787', 'Hatia Ranchi', 'cash', 'active', '2020-07-07'),
(11, 1, 94000.00, 16920.00, 110920.00, '2020-07-16', 'Naved Anjum', '8083583008', 'Hindpiri Ranchi', 'cash', 'active', '2020-07-16'),
(12, 1, 74000.00, 13320.00, 87320.00, '2020-07-30', 'Adil Kaif', '8083583008', 'Simdega Jharkhand', 'cash', 'active', '2020-07-30'),
(13, 1, 50000.00, 9000.00, 59000.00, '2020-08-04', 'imran', '9123121636', 'Bariyatu Ranchi', 'cash', 'active', '2020-08-04'),
(14, 1, 109000.00, 19620.00, 128620.00, '2020-09-03', 'IMRAN', '9123121636', 'BARIYATU RANCHI', 'credit', 'active', '2020-09-03'),
(15, 1, 128000.00, 23040.00, 151040.00, '2023-03-25', 'Shahid', '9709227856', 'Ranchi', 'cash', 'active', '2023-03-25'),
(16, 1, 100000.00, 18000.00, 118000.00, '2023-03-25', 'Rashid', '8083583008', 'Ranchi', 'cash', 'active', '2023-03-25'),
(17, 1, 7000.00, 1260.00, 8260.00, '2023-03-26', 'Test', '808658655', 'Ranchi', 'cash', 'active', '2023-03-26'),
(18, 1, 79500.00, 14310.00, 93810.00, '2023-03-26', 'sdfas', '123123123123', 'erwerewrqrqe', 'cash', 'active', '2023-03-26'),
(19, 1, 64500.00, 11610.00, 76110.00, '2023-07-22', 'Shahid', '9709221786', 'Ranchi', 'cash', 'active', '2023-07-22');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_order_product`
--

CREATE TABLE `inventory_order_product` (
  `inventory_order_product_id` int(11) NOT NULL,
  `inventory_order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` double(10,2) NOT NULL,
  `tax` double(10,2) NOT NULL,
  `status` enum('active','inactive') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `inventory_order_product`
--

INSERT INTO `inventory_order_product` (`inventory_order_product_id`, `inventory_order_id`, `product_id`, `quantity`, `price`, `tax`, `status`) VALUES
(1, 1, 6, 8, 54500.00, 18.00, 'active'),
(2, 2, 5, 1, 35500.00, 18.00, 'active'),
(3, 3, 3, 1, 15500.00, 18.00, 'active'),
(4, 4, 10, 1, 34500.00, 18.00, 'active'),
(5, 4, 3, 1, 15500.00, 18.00, 'active'),
(6, 5, 13, 1, 45500.00, 18.00, 'active'),
(7, 6, 2, 1, 95500.00, 18.00, 'active'),
(8, 7, 6, 1, 54500.00, 18.00, 'active'),
(9, 8, 11, 1, 54500.00, 18.00, 'active'),
(10, 9, 12, 1, 95500.00, 18.00, 'active'),
(11, 9, 14, 1, 51500.00, 18.00, 'active'),
(12, 10, 1, 1, 64000.00, 18.00, 'active'),
(13, 11, 16, 1, 30000.00, 18.00, 'active'),
(14, 11, 1, 1, 64000.00, 18.00, 'active'),
(15, 12, 4, 1, 19500.00, 18.00, 'active'),
(16, 12, 11, 1, 54500.00, 18.00, 'active'),
(17, 13, 15, 2, 50000.00, 18.00, 'active'),
(18, 14, 11, 2, 109000.00, 18.00, 'active'),
(19, 15, 1, 2, 128000.00, 18.00, 'active'),
(20, 16, 18, 2, 100000.00, 18.00, 'active'),
(21, 17, 17, 2, 7000.00, 18.00, 'active'),
(22, 18, 15, 1, 25000.00, 18.00, 'active'),
(23, 18, 11, 1, 54500.00, 18.00, 'active'),
(24, 19, 19, 1, 10000.00, 18.00, 'active'),
(25, 19, 11, 1, 54500.00, 18.00, 'active');

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `product_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `brand_id` int(11) NOT NULL,
  `product_name` varchar(300) NOT NULL,
  `product_description` text NOT NULL,
  `product_quantity` int(11) NOT NULL,
  `product_unit` varchar(150) NOT NULL,
  `product_base_price` double(10,2) NOT NULL,
  `product_tax` decimal(4,2) NOT NULL,
  `product_minimum_order` double(10,2) NOT NULL,
  `product_enter_by` int(11) NOT NULL,
  `product_status` enum('active','inactive') NOT NULL,
  `product_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`product_id`, `category_id`, `brand_id`, `product_name`, `product_description`, `product_quantity`, `product_unit`, `product_base_price`, `product_tax`, `product_minimum_order`, `product_enter_by`, `product_status`, `product_date`) VALUES
(1, 1, 5, 'IPhone-11', 'NA', 5, 'Box', 64000.00, '12.00', 0.00, 1, 'active', '2023-03-25'),
(2, 1, 5, 'Iphone-11 Pro', 'NA', 7, 'Box', 95500.00, '5.00', 0.00, 1, 'active', '2020-07-10'),
(3, 1, 4, 'Glaxy A30', 'NA', 4, 'Box', 15500.00, '5.00', 0.00, 1, 'active', '2020-08-29'),
(4, 1, 4, 'Glaxy A50', 'NA', 10, 'Box', 19500.00, '5.00', 0.00, 1, 'active', '2020-07-09'),
(5, 1, 4, 'Glaxy Note8', 'NA', 7, 'Box', 35500.00, '5.00', 0.00, 1, 'active', '2020-07-09'),
(6, 1, 4, 'Glaxy Note-10', 'NA', 10, 'Box', 54500.00, '5.00', 0.00, 1, 'active', '2020-07-30'),
(7, 2, 16, 'A-One', 'NA', 10, 'Box', 18500.00, '5.00', 0.00, 1, 'active', '2020-07-09'),
(8, 2, 16, 'A-31', 'NA', 10, 'Box', 24500.00, '5.00', 0.00, 1, 'active', '2020-07-09'),
(9, 2, 12, 'Pavilion-305', 'NA', 10, 'Box', 29500.00, '5.00', 0.00, 1, 'active', '2020-07-09'),
(10, 2, 12, 'Pavilion-5A', 'NA', 7, 'Box', 34500.00, '5.00', 0.00, 1, 'active', '2020-07-09'),
(11, 4, 1, 'DSLR-C10', 'NA', 7, 'Box', 54500.00, '5.00', 0.00, 1, 'active', '2020-07-09'),
(12, 4, 1, 'DSLR-C30', 'NA', 7, 'Box', 95500.00, '5.00', 0.00, 1, 'active', '2020-07-09'),
(13, 4, 2, 'DSLR-N20', 'NA', 7, 'Box', 45500.00, '5.00', 0.00, 1, 'active', '2020-07-09'),
(14, 4, 2, 'DSLR-N40', 'NA', 7, 'Box', 51500.00, '5.00', 0.00, 1, 'active', '2020-07-09'),
(15, 7, 22, 'A-ONE-45', 'NA', 5, 'Box', 25000.00, '5.00', 0.00, 1, 'active', '2020-07-16'),
(16, 7, 22, 'A-ONE-50', 'NA', 10, 'Box', 30000.00, '5.00', 0.00, 1, 'active', '2020-07-16'),
(17, 6, 23, 'EVOLUATE', 'NA', 10, 'Box', 3500.00, '5.00', 0.00, 1, 'active', '2020-08-23'),
(18, 7, 21, 'ASUS TUF', 'Description', 10, 'Box', 50000.00, '18.00', 0.00, 1, 'active', '2023-03-25'),
(19, 1, 7, 'Oppo Nco', 'description', 10, 'Box', 10000.00, '18.00', 0.00, 1, 'active', '2023-07-22');

-- --------------------------------------------------------

--
-- Table structure for table `user_details`
--

CREATE TABLE `user_details` (
  `user_id` int(11) NOT NULL,
  `user_email` varchar(200) NOT NULL,
  `user_password` varchar(200) NOT NULL,
  `user_name` varchar(200) NOT NULL,
  `user_type` enum('master','user') NOT NULL,
  `user_status` enum('Active','Inactive') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user_details`
--

INSERT INTO `user_details` (`user_id`, `user_email`, `user_password`, `user_name`, `user_type`, `user_status`) VALUES
(1, 'imran@gmail.com', '$2y$10$THHkH57XoHzBa2XdZMhhuOG5gH9eKMGhrMzWpFTwMXoTRzo2SVU0G', 'Imran', 'master', 'Active'),
(2, 'adil@gmail.com', '$2y$10$42N/XOkVvh2YMyUQdN5lme.AdZtmSPfQpDJc51nirfjpffY/tsmGm', 'Adil', 'user', 'Active'),
(3, 'ayan@gmail.com', '$2y$10$H/kdIuoukRYv.wLeKxm1l.Ekz.HKbQbGFOFLFkwqU9lcSXV.kONDi', 'Ayan', 'user', 'Active'),
(4, 'amit@gmail.com', '$2y$10$eDUTFgNrf66m3Nt5/u2AyeTJN1pzIzzIpS19B8F6CoEwuI3U3a8TS', 'Amit Kumar', 'user', 'Active'),
(5, 'navedanjum@gmail.com', '$2y$10$QMdpjN1IJWI5NGCe1LZ9ze8S2F5FwnmWw0sj7p5IZKgL/0WkfIRNq', 'Naved Anjum', 'master', 'Active');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `brand`
--
ALTER TABLE `brand`
  ADD PRIMARY KEY (`brand_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `inventory_order`
--
ALTER TABLE `inventory_order`
  ADD PRIMARY KEY (`inventory_order_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `inventory_order_product`
--
ALTER TABLE `inventory_order_product`
  ADD PRIMARY KEY (`inventory_order_product_id`),
  ADD KEY `inventory_order_id` (`inventory_order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `brand_id` (`brand_id`),
  ADD KEY `product_enter_by` (`product_enter_by`);

--
-- Indexes for table `user_details`
--
ALTER TABLE `user_details`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `brand`
--
ALTER TABLE `brand`
  MODIFY `brand_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `inventory_order`
--
ALTER TABLE `inventory_order`
  MODIFY `inventory_order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `inventory_order_product`
--
ALTER TABLE `inventory_order_product`
  MODIFY `inventory_order_product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `user_details`
--
ALTER TABLE `user_details`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `brand`
--
ALTER TABLE `brand`
  ADD CONSTRAINT `brand_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`);

--
-- Constraints for table `inventory_order`
--
ALTER TABLE `inventory_order`
  ADD CONSTRAINT `inventory_order_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user_details` (`user_id`);

--
-- Constraints for table `inventory_order_product`
--
ALTER TABLE `inventory_order_product`
  ADD CONSTRAINT `inventory_order_product_ibfk_1` FOREIGN KEY (`inventory_order_id`) REFERENCES `inventory_order` (`inventory_order_id`),
  ADD CONSTRAINT `inventory_order_product_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`);

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`),
  ADD CONSTRAINT `product_ibfk_2` FOREIGN KEY (`brand_id`) REFERENCES `brand` (`brand_id`),
  ADD CONSTRAINT `product_ibfk_3` FOREIGN KEY (`product_enter_by`) REFERENCES `user_details` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
