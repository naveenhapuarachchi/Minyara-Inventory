-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 20, 2026 at 08:23 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `minyara_inventory`
--

-- --------------------------------------------------------

--
-- Table structure for table `bills`
--

CREATE TABLE `bills` (
  `id` int(10) UNSIGNED NOT NULL,
  `bill_no` varchar(30) NOT NULL,
  `customer_name` varchar(150) DEFAULT NULL,
  `customer_phone` varchar(20) DEFAULT NULL,
  `subtotal` decimal(10,2) DEFAULT 0.00,
  `discount` decimal(10,2) DEFAULT 0.00,
  `tax` decimal(10,2) DEFAULT 0.00,
  `total` decimal(10,2) DEFAULT 0.00,
  `paid_amount` decimal(10,2) DEFAULT 0.00,
  `change_amount` decimal(10,2) DEFAULT 0.00,
  `payment_method` enum('cash','card','other') DEFAULT 'cash',
  `status` enum('paid','unpaid','cancelled') DEFAULT 'paid',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bills`
--

INSERT INTO `bills` (`id`, `bill_no`, `customer_name`, `customer_phone`, `subtotal`, `discount`, `tax`, `total`, `paid_amount`, `change_amount`, `payment_method`, `status`, `notes`, `created_at`) VALUES
(11, 'MIN-20260328-9317', '', '', 30.00, 0.00, 0.00, 30.00, 30.00, 0.00, 'cash', 'paid', '', '2026-03-28 09:44:33'),
(13, 'MIN-20260328-2596', '', '', 84.00, 0.00, 0.00, 84.00, 84.00, 0.00, 'cash', 'paid', '', '2026-03-28 09:48:37'),
(14, 'MIN-20260328-9172', '', '', 695.00, 0.00, 0.00, 695.00, 695.00, 0.00, 'cash', 'paid', '', '2026-03-28 09:50:07'),
(15, 'MIN-20260328-0233', '', '', 16.00, 0.00, 0.00, 16.00, 16.00, 0.00, 'cash', 'paid', '', '2026-03-28 09:52:31'),
(16, 'MIN-20260328-9171', '', '', 940.00, 0.00, 0.00, 940.00, 940.00, 0.00, 'cash', 'paid', '', '2026-03-28 12:17:29'),
(19, 'MIN-20260329-3218', '', '', 98.00, 0.00, 0.00, 98.00, 98.00, 0.00, 'cash', 'paid', '', '2026-03-29 04:01:51'),
(21, 'MIN-20260329-6926', '', '', 46.00, 0.00, 0.00, 46.00, 46.00, 0.00, 'cash', 'paid', '', '2026-03-29 05:03:29'),
(23, 'MIN-20260329-6592', '', '', 530.00, 0.00, 0.00, 530.00, 530.00, 0.00, 'cash', 'paid', '', '2026-03-29 08:23:59'),
(24, 'MIN-20260329-8365', '', '', 150.00, 0.00, 0.00, 150.00, 150.00, 0.00, 'cash', 'paid', '', '2026-03-29 13:31:36'),
(25, 'MIN-20260329-2701', '', '', 54.00, 0.00, 0.00, 54.00, 54.00, 0.00, 'cash', 'paid', '', '2026-03-29 14:00:39'),
(27, 'MIN-20260329-2866', 'Danulya', '', 140.00, 0.00, 0.00, 140.00, 140.00, 0.00, 'cash', 'paid', '', '2026-03-29 15:16:18'),
(28, 'MIN-20260330-4664', 'Nethmi', '', 110.00, 0.00, 0.00, 110.00, 110.00, 0.00, 'cash', 'paid', '', '2026-03-30 10:26:32'),
(29, 'MIN-20260330-2398', '', '', 256.00, 0.00, 0.00, 256.00, 256.00, 0.00, 'cash', 'paid', '', '2026-03-30 11:07:30'),
(30, 'MIN-20260330-8203', '', '', 60.00, 0.00, 0.00, 60.00, 60.00, 0.00, 'cash', 'paid', '', '2026-03-30 15:34:36'),
(31, 'MIN-20260330-2218', '', '', 120.00, 0.00, 0.00, 120.00, 120.00, 0.00, 'cash', 'paid', '', '2026-03-30 16:39:52'),
(32, 'MIN-20260331-3631', '', '', 350.00, 0.00, 0.00, 350.00, 350.00, 0.00, 'cash', 'paid', '', '2026-03-31 13:15:21'),
(33, 'MIN-20260331-6238', '', '', 540.00, 0.00, 0.00, 540.00, 540.00, 0.00, 'cash', 'paid', '', '2026-03-31 13:37:00'),
(34, 'MIN-20260331-7759', '', '', 38.00, 0.00, 0.00, 38.00, 38.00, 0.00, 'cash', 'paid', '', '2026-03-31 14:04:12'),
(35, 'MIN-20260331-4590', '', '', 60.00, 0.00, 0.00, 60.00, 60.00, 0.00, 'cash', 'paid', '', '2026-03-31 14:05:11'),
(36, 'MIN-20260401-7766', '', '', 250.00, 0.00, 0.00, 250.00, 250.00, 0.00, 'cash', 'paid', '', '2026-04-01 02:52:17'),
(38, 'MIN-20260401-3604', '', '', 150.00, 0.00, 0.00, 150.00, 150.00, 0.00, 'cash', 'paid', '', '2026-04-01 05:19:10'),
(41, 'MIN-20260401-3704', '', '', 150.00, 0.00, 0.00, 150.00, 150.00, 0.00, 'cash', 'paid', '', '2026-04-01 05:37:26'),
(43, 'MIN-20260401-6839', '', '', 400.00, 0.00, 0.00, 400.00, 400.00, 0.00, 'cash', 'paid', '', '2026-04-01 05:44:05'),
(44, 'MIN-20260401-6404', '', '', 40.00, 0.00, 0.00, 40.00, 40.00, 0.00, 'cash', 'paid', '', '2026-04-01 08:59:26'),
(45, 'MIN-20260401-6118', '', '', 114.00, 0.00, 0.00, 114.00, 114.00, 0.00, 'cash', 'paid', '', '2026-04-01 10:48:05'),
(46, 'MIN-20260401-1043', '', '', 200.00, 0.00, 0.00, 200.00, 200.00, 0.00, 'cash', 'paid', '', '2026-04-01 12:11:01'),
(47, 'MIN-20260401-2198', '', '', 630.00, 0.00, 0.00, 630.00, 630.00, 0.00, 'cash', 'paid', '', '2026-04-01 13:02:06'),
(49, 'MIN-20260401-8821', '', '', 200.00, 0.00, 0.00, 200.00, 200.00, 0.00, 'cash', 'paid', '', '2026-04-01 15:27:01'),
(52, 'MIN-20260404-3453', '', '', 170.00, 0.00, 0.00, 170.00, 170.00, 0.00, 'cash', 'paid', '', '2026-04-04 09:28:14'),
(53, 'MIN-20260405-6124', '', '', 36.00, 0.00, 0.00, 36.00, 36.00, 0.00, 'cash', 'paid', '', '2026-04-05 07:18:56'),
(54, 'MIN-20260405-4639', '', '', 255.00, 5.00, 0.00, 250.00, 250.00, 0.00, 'cash', 'paid', '', '2026-04-05 07:50:02'),
(55, 'MIN-20260405-9051', '', '', 309.00, 0.00, 0.00, 309.00, 309.00, 0.00, 'cash', 'paid', '', '2026-04-05 09:53:33'),
(56, 'MIN-20260405-7879', '', '', 208.00, 0.00, 0.00, 208.00, 208.00, 0.00, 'cash', 'paid', '', '2026-04-05 14:39:00'),
(57, 'MIN-20260405-2833', '', '', 160.00, 0.00, 0.00, 160.00, 160.00, 0.00, 'cash', 'paid', '', '2026-04-05 14:45:00'),
(60, 'MIN-20260406-8452', '', '', 340.00, 0.00, 0.00, 340.00, 340.00, 0.00, 'cash', 'paid', '', '2026-04-06 13:12:49'),
(61, 'MIN-20260406-9491', '', '', 420.00, 0.00, 0.00, 420.00, 420.00, 0.00, 'cash', 'paid', '', '2026-04-06 13:23:36'),
(62, 'MIN-20260406-6555', '', '', 60.00, 0.00, 0.00, 60.00, 60.00, 0.00, 'cash', 'paid', '', '2026-04-06 13:28:38'),
(63, 'MIN-20260406-0792', '', '', 108.00, 0.00, 0.00, 108.00, 108.00, 0.00, 'cash', 'paid', '', '2026-04-06 13:34:44'),
(65, 'MIN-20260406-0768', '', '', 15.00, 0.00, 0.00, 15.00, 15.00, 0.00, 'cash', 'paid', '', '2026-04-06 13:48:16'),
(66, 'MIN-20260406-2701', 'Danulya', '', 160.00, 0.00, 0.00, 160.00, 160.00, 0.00, 'cash', 'unpaid', '', '2026-04-06 15:04:10'),
(67, 'MIN-20260406-0786', '', '', 794.00, 0.00, 0.00, 794.00, 794.00, 0.00, 'cash', 'paid', '', '2026-04-06 16:09:35'),
(68, 'MIN-20260407-2286', '', '', 300.00, 0.00, 0.00, 300.00, 300.00, 0.00, 'cash', 'paid', '', '2026-04-07 13:15:03'),
(69, 'MIN-20260408-2735', '', '', 836.00, 0.00, 0.00, 836.00, 836.00, 0.00, 'cash', 'paid', '', '2026-04-07 18:34:03'),
(70, 'MIN-20260408-4975', 'Thinula', '', 200.00, 0.00, 0.00, 200.00, 200.00, 0.00, 'cash', 'paid', '', '2026-04-08 11:22:53'),
(71, 'MIN-20260408-2074', '', '+94 72 961 2303', 290.00, 0.00, 0.00, 290.00, 290.00, 0.00, 'cash', 'paid', '', '2026-04-08 12:07:13'),
(72, 'MIN-20260408-2564', '', '+94 77 652 6523', 40.00, 0.00, 0.00, 40.00, 40.00, 0.00, 'cash', 'paid', '', '2026-04-08 12:08:43'),
(73, 'MIN-20260408-0472', '', '', 55.00, 0.00, 0.00, 55.00, 55.00, 0.00, 'cash', 'paid', '', '2026-04-08 12:28:57'),
(74, 'MIN-20260408-4733', 'Danulya', '', 30.00, 0.00, 0.00, 30.00, 30.00, 0.00, 'cash', 'unpaid', '', '2026-04-08 12:52:50'),
(75, 'MIN-20260408-8870', '', '94 75 236 2359', 40.00, 0.00, 0.00, 40.00, 40.00, 0.00, 'cash', 'paid', '', '2026-04-08 12:53:29'),
(76, 'MIN-20260408-7581', 'Thinula', '', 140.00, 0.00, 0.00, 140.00, 140.00, 0.00, 'cash', 'paid', '', '2026-04-08 13:02:37'),
(77, 'MIN-20260408-4242', '', '', 20.00, 0.00, 0.00, 20.00, 20.00, 0.00, 'cash', 'paid', '', '2026-04-08 13:54:41'),
(78, 'MIN-20260408-2600', 'Ishara', '', 500.00, 0.00, 0.00, 500.00, 500.00, 0.00, 'cash', 'paid', '', '2026-04-08 13:57:44'),
(80, 'MIN-20260408-5237', 'Danulya', '', 60.00, 0.00, 0.00, 60.00, 60.00, 0.00, 'cash', 'unpaid', '', '2026-04-08 15:11:29'),
(81, 'MIN-20260408-1116', '', '', 240.00, 0.00, 0.00, 240.00, 240.00, 0.00, 'cash', 'paid', '', '2026-04-08 15:14:17'),
(82, 'MIN-20260409-6517', '', '', 430.00, 0.00, 0.00, 430.00, 430.00, 0.00, 'cash', 'paid', '', '2026-04-08 19:18:00'),
(83, 'MIN-20260409-0075', '', '', 360.00, 0.00, 0.00, 360.00, 360.00, 0.00, 'cash', 'paid', '', '2026-04-09 12:59:00'),
(84, 'MIN-20260409-2606', '', '', 340.00, 0.00, 0.00, 340.00, 340.00, 0.00, 'cash', 'paid', '', '2026-04-09 12:59:28'),
(85, 'MIN-20260409-0169', 'Danulya', '', 40.00, 0.00, 0.00, 40.00, 40.00, 0.00, 'cash', 'unpaid', '', '2026-04-09 14:31:46'),
(86, 'MIN-20260410-1703', '', '', 16.00, 0.00, 0.00, 16.00, 16.00, 0.00, 'cash', 'paid', '', '2026-04-10 14:12:36'),
(87, 'MIN-20260411-0463', '', '', 80.00, 0.00, 0.00, 80.00, 80.00, 0.00, 'cash', 'paid', '', '2026-04-11 05:08:02'),
(88, 'MIN-20260411-5467', '', '', 70.00, 0.00, 0.00, 70.00, 70.00, 0.00, 'cash', 'paid', '', '2026-04-11 05:09:33'),
(91, 'MIN-20260418-0678', '', '', 200.00, 0.00, 0.00, 200.00, 200.00, 0.00, 'cash', 'paid', '', '2026-04-18 06:58:50'),
(92, 'MIN-20260418-0619', 'Danulya', '', 610.00, 0.00, 0.00, 610.00, 610.00, 0.00, 'cash', 'unpaid', '', '2026-04-18 07:56:21'),
(93, 'MIN-20260418-9381', '', '', 228.00, 0.00, 0.00, 228.00, 228.00, 0.00, 'cash', 'paid', '', '2026-04-18 13:32:13'),
(94, 'MIN-20260419-9909', '', '', 15.00, 0.00, 0.00, 15.00, 100.00, 85.00, 'cash', 'paid', '', '2026-04-19 04:58:38'),
(95, 'MIN-20260419-4351', '', '', 16.00, 0.00, 0.00, 16.00, 16.00, 0.00, 'cash', 'paid', '', '2026-04-19 05:22:19'),
(96, 'MIN-20260419-4036', 'Ms.Jiana Jayawardhana', '', 72.00, 0.00, 0.00, 72.00, 72.00, 0.00, 'cash', 'paid', '', '2026-04-19 05:40:19'),
(97, 'MIN-20260419-3152', 'Danulya', '', 40.00, 0.00, 0.00, 40.00, 40.00, 0.00, 'cash', 'unpaid', '', '2026-04-19 05:41:53'),
(98, 'MIN-20260419-9611', 'Ms.Jiana Jayawardhana', '', 80.00, 0.00, 0.00, 80.00, 80.00, 0.00, 'cash', 'paid', '', '2026-04-19 09:03:38'),
(99, 'MIN-20260419-2219', 'danulya', '', 100.00, 0.00, 0.00, 100.00, 100.00, 0.00, 'cash', 'unpaid', '', '2026-04-19 09:22:59'),
(100, 'MIN-20260419-6943', '', '', 80.00, 0.00, 0.00, 80.00, 100.00, 20.00, 'cash', 'paid', '', '2026-04-19 09:29:21'),
(101, 'MIN-20260419-4315', '', '', 200.00, 0.00, 0.00, 200.00, 500.00, 300.00, 'cash', 'paid', '', '2026-04-19 12:15:59'),
(102, 'MIN-20260419-6549', '', '', 520.00, 0.00, 0.00, 520.00, 520.00, 0.00, 'cash', 'unpaid', '', '2026-04-19 12:17:21'),
(103, 'MIN-20260419-9705', 'Danulya', '', 520.00, 0.00, 0.00, 520.00, 520.00, 0.00, 'cash', 'unpaid', '', '2026-04-19 12:17:34'),
(104, 'MIN-20260419-8533', 'Danulya', '', 82.00, 0.00, 0.00, 82.00, 82.00, 0.00, 'cash', 'unpaid', '', '2026-04-19 14:27:55'),
(105, 'MIN-20260420-5503', '', '', 180.00, 0.00, 0.00, 180.00, 180.00, 0.00, 'cash', 'paid', '', '2026-04-20 12:53:08'),
(107, 'MIN-20260420-0068', '', '', 652.00, 0.00, 0.00, 652.00, 652.00, 0.00, 'cash', 'paid', '', '2026-04-20 13:17:18'),
(108, 'MIN-20260420-7797', '', '', 100.00, 0.00, 0.00, 100.00, 100.00, 0.00, 'cash', 'paid', '', '2026-04-20 13:22:31'),
(109, 'MIN-20260420-9781', '', '', 100.00, 0.00, 0.00, 100.00, 100.00, 0.00, 'cash', 'paid', '', '2026-04-20 13:42:10'),
(110, 'MIN-20260420-4674', '', '', 100.00, 0.00, 0.00, 100.00, 100.00, 0.00, 'cash', 'paid', '', '2026-04-20 13:42:16'),
(111, 'MIN-20260420-7861', 'Danulya', '', 230.00, 0.00, 0.00, 230.00, 230.00, 0.00, 'cash', 'unpaid', '', '2026-04-20 14:28:17'),
(112, 'MIN-20260420-8490', '', '', 40.00, 0.00, 0.00, 40.00, 40.00, 0.00, 'cash', 'paid', '', '2026-04-20 14:52:37'),
(113, 'MIN-20260420-5632', 'Danulya', '', 120.00, 0.00, 0.00, 120.00, 120.00, 0.00, 'cash', 'unpaid', '', '2026-04-20 15:14:04'),
(114, 'MIN-20260420-0958', 'Danulya', '', 70.00, 0.00, 0.00, 70.00, 70.00, 0.00, 'cash', 'unpaid', '', '2026-04-20 16:48:25');

-- --------------------------------------------------------

--
-- Table structure for table `bill_items`
--

CREATE TABLE `bill_items` (
  `id` int(10) UNSIGNED NOT NULL,
  `bill_id` int(10) UNSIGNED NOT NULL,
  `product_id` int(10) UNSIGNED DEFAULT NULL,
  `product_name` varchar(200) NOT NULL,
  `unit` varchar(30) DEFAULT NULL,
  `qty` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bill_items`
--

INSERT INTO `bill_items` (`id`, `bill_id`, `product_id`, `product_name`, `unit`, `qty`, `unit_price`, `total`) VALUES
(36, 11, NULL, 'Printouts', 'pcs', 1, 30.00, 30.00),
(38, 13, NULL, 'Printouts', 'pcs', 1, 84.00, 84.00),
(39, 14, NULL, 'printouts', 'pcs', 1, 330.00, 330.00),
(40, 14, NULL, 'Blacnk Book', 'pcs', 1, 75.00, 75.00),
(41, 14, 43, 'Chemifix Glu', 'pcs', 1, 290.00, 290.00),
(42, 15, NULL, 'Printouts', 'pcs', 1, 16.00, 16.00),
(43, 16, NULL, 'Printouts 76 pages', 'pcs', 1, 380.00, 380.00),
(44, 16, NULL, 'Printouts 48 Pages', 'pcs', 1, 240.00, 240.00),
(45, 16, NULL, 'Printouts 64 Pages', 'pcs', 1, 320.00, 320.00),
(50, 19, NULL, 'B&W Printing', 'pcs', 1, 8.00, 8.00),
(51, 19, NULL, 'Color Printouts', 'pcs', 3, 30.00, 90.00),
(53, 21, NULL, 'Printouts', 'pcs', 1, 30.00, 30.00),
(54, 21, NULL, 'printouts', 'pcs', 2, 8.00, 16.00),
(57, 23, NULL, 'Color Printouts with Stciker Paper', 'pcs', 4, 80.00, 320.00),
(58, 23, NULL, 'Color Printouts with Ice Board', 'pcs', 2, 100.00, 200.00),
(59, 23, NULL, 'Printouts B&W', 'pcs', 1, 10.00, 10.00),
(60, 24, NULL, 'Color Printouts', 'pcs', 2, 40.00, 80.00),
(61, 24, NULL, 'B&W Printouts', 'pcs', 7, 10.00, 70.00),
(62, 25, NULL, 'Printouts', 'pcs', 1, 16.00, 16.00),
(63, 25, NULL, 'Color Printouts', 'pcs', 1, 30.00, 30.00),
(64, 25, NULL, 'Printouts', 'pcs', 1, 8.00, 8.00),
(67, 27, NULL, 'Color Printouts', 'pcs', 2, 40.00, 80.00),
(68, 27, NULL, 'Color Printouts', 'pcs', 2, 30.00, 60.00),
(69, 28, NULL, 'Printouts', 'pcs', 1, 102.00, 102.00),
(70, 28, NULL, 'Printouts', 'pcs', 1, 8.00, 8.00),
(71, 29, NULL, 'Printouts B&W', 'pcs', 24, 10.00, 240.00),
(72, 29, NULL, 'Printouts B&W', 'pcs', 2, 8.00, 16.00),
(73, 30, 15, 'Key Tag Note Book', 'pcs', 1, 60.00, 60.00),
(74, 31, NULL, 'Printouts B&W', 'pcs', 15, 8.00, 120.00),
(75, 32, NULL, 'Printouts B&W', 'pcs', 10, 8.00, 80.00),
(76, 32, NULL, 'Type setting', 'pcs', 3, 90.00, 270.00),
(77, 33, NULL, 'Ten Blue', 'pcs', 5, 18.00, 90.00),
(78, 33, NULL, 'Nataraj Pencil', 'pcs', 1, 250.00, 250.00),
(79, 33, NULL, 'QR Fuel Pass with Laminate', 'pcs', 2, 100.00, 200.00),
(80, 34, NULL, 'Printouts Color', 'pcs', 1, 30.00, 30.00),
(81, 34, NULL, 'Printouts B&W', 'pcs', 1, 8.00, 8.00),
(82, 35, 15, 'Key Tag Note Book', 'pcs', 1, 60.00, 60.00),
(83, 36, NULL, 'Printouts B&W 21 Pages (double)', 'pcs', 21, 10.00, 210.00),
(84, 36, NULL, 'Printouts B&W 4 Pages (double', 'pcs', 4, 10.00, 40.00),
(85, 38, NULL, 'Photocopy', 'pcs', 10, 15.00, 150.00),
(88, 41, NULL, 'Photocopy', 'pcs', 10, 15.00, 150.00),
(90, 43, NULL, 'Graphic design Rs.1000 (Purna)', 'pcs', 1, 200.00, 200.00),
(91, 43, NULL, 'Printouts Color', 'pcs', 5, 40.00, 200.00),
(92, 44, NULL, 'Printouts Legal', 'pcs', 2, 20.00, 40.00),
(93, 45, NULL, 'Printouts', 'pcs', 6, 10.00, 60.00),
(94, 45, NULL, 'ten Pen Blue', 'pcs', 2, 18.00, 36.00),
(95, 45, NULL, 'Atlas Earaser', 'pcs', 1, 18.00, 18.00),
(96, 46, NULL, 'Printouts B&W', 'pcs', 20, 10.00, 200.00),
(97, 47, NULL, 'Photocopy', 'pcs', 16, 15.00, 240.00),
(98, 47, NULL, 'type settings', 'pcs', 3, 100.00, 300.00),
(99, 47, NULL, 'Printouts B&W', 'pcs', 9, 10.00, 90.00),
(101, 49, NULL, 'Printouts Color', 'pcs', 5, 40.00, 200.00),
(107, 52, NULL, 'Printouts Color', 'pcs', 1, 30.00, 30.00),
(108, 52, NULL, 'Printouts B&W', 'pcs', 14, 10.00, 140.00),
(109, 53, 38, 'Atlas Pencil Single', 'pcs', 1, 36.00, 36.00),
(110, 54, NULL, 'Scan 5page', 'pcs', 5, 15.00, 75.00),
(111, 54, NULL, 'Scan 3 pages', 'pcs', 3, 15.00, 45.00),
(112, 54, NULL, 'Scan color', 'pcs', 1, 25.00, 25.00),
(113, 54, NULL, 'Scan 4 Pages', 'pcs', 4, 15.00, 60.00),
(114, 54, NULL, 'Scan Color 2 pages', 'pcs', 2, 25.00, 50.00),
(115, 55, NULL, 'Photocopy', 'pcs', 1, 15.00, 15.00),
(116, 55, NULL, 'Printouts Paper', 'pcs', 8, 10.00, 80.00),
(117, 55, NULL, 'Printouts Application', 'pcs', 15, 10.00, 150.00),
(118, 55, 14, 'Atlas Chooty Blue Color pen', 'pcs', 2, 32.00, 64.00),
(119, 56, NULL, 'Prntouts B&W', 'pcs', 1, 208.00, 208.00),
(120, 57, NULL, 'Printouts Color', 'pcs', 4, 40.00, 160.00),
(124, 60, NULL, 'Comb Binding 32Pages', 'pcs', 1, 340.00, 340.00),
(125, 61, NULL, 'Printouts', 'pcs', 1, 180.00, 180.00),
(126, 61, 28, 'Atlas Glu Binder Small', 'pcs', 1, 100.00, 100.00),
(127, 61, NULL, 'Glu Pen Atlas', 'pcs', 1, 140.00, 140.00),
(128, 62, NULL, 'Marshmallow', 'pcs', 6, 10.00, 60.00),
(129, 63, 38, 'Atlas Pencil Single', 'pcs', 3, 36.00, 108.00),
(131, 65, NULL, 'photocopy', 'pcs', 1, 15.00, 15.00),
(132, 66, NULL, 'Black and White Print', 'pcs', 3, 10.00, 30.00),
(133, 66, NULL, 'color print', 'pcs', 2, 30.00, 60.00),
(134, 66, NULL, 'Type setting', 'pcs', 1, 70.00, 70.00),
(135, 67, NULL, 'Printouts B&W', 'pcs', 33, 8.00, 264.00),
(136, 67, NULL, 'Word Editing', 'pcs', 1, 150.00, 150.00),
(137, 67, NULL, 'Comb Binding', 'pcs', 1, 340.00, 340.00),
(138, 67, NULL, 'Photocopy', 'pcs', 4, 10.00, 40.00),
(139, 68, 95, 'Birds Feathers', 'pcs', 2, 150.00, 300.00),
(140, 69, NULL, 'Printouts Color', 'pcs', 3, 40.00, 120.00),
(141, 69, NULL, 'Type Setting', 'pcs', 2, 100.00, 200.00),
(142, 69, NULL, 'Printouts B&W', 'pcs', 2, 8.00, 16.00),
(143, 69, NULL, 'Printouts Color', 'pcs', 1, 200.00, 200.00),
(144, 69, NULL, 'Type setting', 'pcs', 3, 100.00, 300.00),
(145, 70, NULL, 'Color Printing', 'pcs', 5, 40.00, 200.00),
(146, 71, NULL, 'Black and White', 'pcs', 29, 10.00, 290.00),
(147, 72, NULL, 'colour print', 'pcs', 1, 40.00, 40.00),
(148, 73, 86, 'SchoolMate 40 =', 'pcs', 1, 55.00, 55.00),
(149, 74, NULL, 'Black and White Print', 'pcs', 3, 10.00, 30.00),
(150, 75, NULL, 'Black and White Print', 'pcs', 4, 10.00, 40.00),
(151, 76, NULL, 'Atlas Binder Glue Pen', 'pcs', 1, 140.00, 140.00),
(152, 77, NULL, 'Choco Express', 'pcs', 1, 20.00, 20.00),
(153, 78, NULL, 'Type Setting', 'pcs', 4, 100.00, 400.00),
(154, 78, NULL, 'Mash mellow', 'pcs', 7, 10.00, 70.00),
(155, 78, NULL, 'small envelopes', 'pcs', 6, 5.00, 30.00),
(157, 80, NULL, 'color print', 'pcs', 1, 40.00, 40.00),
(158, 80, NULL, 'Black and White', 'pcs', 2, 10.00, 20.00),
(159, 81, NULL, 'Printouts Color', 'pcs', 6, 40.00, 240.00),
(160, 82, NULL, 'Photocopy B&W', 'pcs', 43, 10.00, 430.00),
(161, 83, NULL, 'Type settings', 'pcs', 3, 100.00, 300.00),
(162, 83, NULL, 'Printouts B&W', 'pcs', 6, 10.00, 60.00),
(163, 84, NULL, 'Type settings', 'pcs', 3, 100.00, 300.00),
(164, 84, NULL, 'Printouts B&W', 'pcs', 4, 10.00, 40.00),
(165, 85, NULL, 'black and White Print', 'pcs', 4, 10.00, 40.00),
(166, 86, NULL, 'Printouts B&W', 'pcs', 2, 8.00, 16.00),
(167, 87, NULL, 'Printouts B&W', 'pcs', 8, 10.00, 80.00),
(168, 88, NULL, 'Printouts Color', 'pcs', 1, 40.00, 40.00),
(169, 88, NULL, 'Image Download', 'pcs', 1, 30.00, 30.00),
(178, 91, NULL, 'Printouts & Type Settings', 'pcs', 1, 200.00, 200.00),
(179, 92, NULL, 'Colour Printout', 'pcs', 15, 40.00, 600.00),
(180, 92, NULL, 'Black and White Print', 'pcs', 1, 10.00, 10.00),
(181, 93, NULL, 'Invitation Card A5', 'pcs', 2, 45.00, 90.00),
(182, 93, NULL, 'Printouts Color & B&W', 'pcs', 1, 88.00, 88.00),
(183, 93, NULL, 'Note Book A6', 'pcs', 1, 50.00, 50.00),
(184, 94, NULL, 'Photocopy', 'pcs', 1, 15.00, 15.00),
(185, 95, NULL, 'Printouts', 'pcs', 1, 16.00, 16.00),
(186, 96, NULL, 'B & K Print', 'pcs', 9, 8.00, 72.00),
(187, 97, NULL, 'B & K', 'pcs', 4, 10.00, 40.00),
(188, 98, NULL, 'B & K Printouts', 'pcs', 10, 8.00, 80.00),
(189, 99, NULL, 'B&K printout', 'pcs', 10, 10.00, 100.00),
(190, 100, NULL, 'Jelly', 'pcs', 2, 20.00, 40.00),
(191, 100, NULL, 'Colour Print', 'pcs', 1, 40.00, 40.00),
(192, 101, NULL, 'Photocopy', 'pcs', 4, 15.00, 60.00),
(193, 101, NULL, 'Printouts B&W', 'pcs', 2, 10.00, 20.00),
(194, 101, NULL, 'Printouts Color', 'pcs', 3, 40.00, 120.00),
(195, 102, 41, 'Glu Stick', 'pcs', 2, 120.00, 240.00),
(196, 102, 80, 'Clear Bag', 'pcs', 2, 120.00, 240.00),
(197, 102, NULL, 'Color A4', 'pcs', 4, 10.00, 40.00),
(198, 103, 41, 'Glu Stick', 'pcs', 2, 120.00, 240.00),
(199, 103, 80, 'Clear Bag', 'pcs', 2, 120.00, 240.00),
(200, 103, NULL, 'Color A4', 'pcs', 4, 10.00, 40.00),
(201, 104, 38, 'Atlas Pencil Single', 'pcs', 2, 36.00, 72.00),
(202, 104, NULL, 'Printout', 'pcs', 1, 10.00, 10.00),
(203, 105, NULL, 'Printouts Color (Double side)', 'pcs', 3, 60.00, 180.00),
(205, 107, NULL, 'Printouts', 'pcs', 3, 10.00, 30.00),
(206, 107, NULL, 'ten pen black', 'pcs', 1, 18.00, 18.00),
(207, 107, 16, 'Atlas Chooty Black Color pen', 'pcs', 1, 32.00, 32.00),
(208, 107, 14, 'Atlas Chooty Blue Color pen', 'pcs', 1, 32.00, 32.00),
(209, 107, NULL, 'red pen', 'pcs', 1, 20.00, 20.00),
(210, 107, NULL, 'printouts', 'pcs', 16, 10.00, 160.00),
(211, 107, NULL, 'lamintating', 'pcs', 2, 100.00, 200.00),
(212, 107, NULL, 'type settings', 'pcs', 1, 50.00, 50.00),
(213, 107, 19, 'Glitter Pen Yellow', 'pcs', 1, 60.00, 60.00),
(214, 107, 40, 'Numbering Eraser', 'pcs', 1, 50.00, 50.00),
(215, 108, NULL, 'Printouts B&W', 'pcs', 2, 10.00, 20.00),
(216, 108, NULL, 'Printouts Color', 'pcs', 2, 40.00, 80.00),
(217, 109, NULL, 'Laminating', 'pcs', 1, 100.00, 100.00),
(218, 110, NULL, 'Laminating', 'pcs', 1, 100.00, 100.00),
(219, 111, NULL, 'Printouts B&W', 'pcs', 3, 10.00, 30.00),
(220, 111, NULL, 'Printouts Color', 'pcs', 5, 40.00, 200.00),
(221, 112, NULL, 'Printouts Color', 'pcs', 1, 40.00, 40.00),
(222, 113, NULL, 'Printouts Color', 'pcs', 3, 40.00, 120.00),
(223, 114, NULL, 'Printouts Color', 'pcs', 1, 40.00, 40.00),
(224, 114, NULL, 'Editing', 'pcs', 1, 30.00, 30.00);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`, `created_at`) VALUES
(1, 'Pens & Pencils', 'Ball pens, gel pens, pencils', '2026-03-22 20:45:12'),
(10, 'Note Books', '', '2026-03-22 22:36:45'),
(11, 'Eraser', '', '2026-03-22 22:36:58'),
(12, 'Stapler', '', '2026-03-22 22:46:25'),
(13, 'Stickers', '', '2026-03-26 16:12:41'),
(14, 'Kids', '', '2026-03-26 16:12:52'),
(15, 'Gum', '', '2026-03-26 16:13:13'),
(16, 'Other', '', '2026-03-26 16:13:18'),
(17, 'Sharpener', '', '2026-03-26 16:13:43'),
(18, 'Cello tape', '', '2026-03-26 16:13:58'),
(19, 'Highlighters', '', '2026-03-26 16:14:21'),
(20, 'Pastel', '', '2026-03-26 16:18:16'),
(21, 'Clips', '', '2026-03-26 16:33:06'),
(22, 'Key Tags', '', '2026-03-26 16:50:22'),
(23, 'Books', '', '2026-03-28 06:13:46'),
(24, 'Seeds', '', '2026-03-28 06:31:04'),
(26, 'Markers', '', '2026-03-28 14:49:12'),
(27, 'Bags', '', '2026-03-28 14:54:11'),
(28, 'Ruler', '', '2026-04-03 14:19:24');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(10) UNSIGNED NOT NULL,
  `category_id` int(10) UNSIGNED DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `sku` varchar(80) DEFAULT NULL,
  `unit` varchar(30) DEFAULT 'pcs',
  `cost_price` decimal(10,2) DEFAULT 0.00,
  `sell_price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `stock_qty` int(11) DEFAULT 0,
  `min_stock` int(11) DEFAULT 5,
  `description` text DEFAULT NULL,
  `color` varchar(30) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `category_id`, `name`, `sku`, `unit`, `cost_price`, `sell_price`, `stock_qty`, `min_stock`, `description`, `color`, `image`, `is_active`, `created_at`) VALUES
(1, 1, 'Blue Ball Pen', 'PEN-BLU-001', 'pcs', 8.00, 15.00, 50, 10, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(2, 1, 'Black Ball Pen', 'PEN-BLK-001', 'pcs', 8.00, 15.00, 40, 10, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(3, 1, 'HB Pencil', 'PEN-HB-001', 'pcs', 5.00, 10.00, 80, 15, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(4, 1, 'Gel Pen (Blue)', 'GEL-BLU-001', 'pcs', 12.00, 20.00, 30, 8, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(5, NULL, 'Ruled Notebook 100pg', 'NB-RUL-100', 'pcs', 40.00, 65.00, 60, 10, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(6, NULL, 'A4 Pad 50pg', 'NB-A4-050', 'pcs', 55.00, 90.00, 25, 5, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(7, NULL, 'Colour Pencil Set 12', 'ART-CP-012', 'set', 100.00, 175.00, 20, 5, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(8, NULL, 'Drawing Sheet A4', 'ART-DS-A4', 'pcs', 5.00, 10.00, 100, 20, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(9, NULL, '30cm Ruler', 'GEO-RUL-30', 'pcs', 15.00, 25.00, 55, 8, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(10, NULL, 'Geometry Box', 'GEO-BOX-01', 'pcs', 80.00, 150.00, 15, 4, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(11, NULL, 'Eraser (Large)', 'ERA-LRG-01', 'pcs', 5.00, 10.00, 120, 20, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(12, NULL, 'Pencil Sharpener', 'SHP-001', 'pcs', 8.00, 15.00, 60, 10, NULL, NULL, NULL, 0, '2026-03-22 20:45:12'),
(13, NULL, 'Nike Backpack', 'NIK-69C0556DDEFAC', 'pcs', 0.00, 2500.00, 5, 5, '', NULL, NULL, 0, '2026-03-22 20:47:41'),
(14, 1, 'Atlas Chooty Blue Color pen', 'ATL-69C06FCAAF314', 'pcs', 28.00, 32.00, 41, 5, '', '#3B82F6', 'assets/products/prod_69e63462db263.jpg', 1, '2026-03-22 22:40:10'),
(15, 10, 'Key Tag Note Book', 'KEY-69C0702C73C08', 'pcs', 40.00, 60.00, 12, 5, '', NULL, NULL, 1, '2026-03-22 22:41:48'),
(16, 1, 'Atlas Chooty Black Color pen', 'ATL-69C070E67FB72', 'pcs', 28.00, 32.00, 49, 5, '', '#1E293B', NULL, 1, '2026-03-22 22:44:54'),
(17, 12, 'Atlas Stapler Pins (BIG)', 'STA-69C0718190E8A', 'pcs', 70.00, 80.00, 12, 2, 'No.369', NULL, 'assets/products/prod_69cfce1c82bca.jpeg', 1, '2026-03-22 22:47:29'),
(18, 12, 'Atlas Stapler Pings (small)', 'STA-69C0720B01DF2', 'pcs', 40.00, 50.00, 17, 2, '', NULL, NULL, 1, '2026-03-22 22:49:47'),
(19, 1, 'Glitter Pen Yellow', 'GLI-69C29B997A93E', 'pcs', 50.00, 60.00, 4, 1, '', '#EAB308', NULL, 1, '2026-03-24 14:11:37'),
(20, 1, 'Glitter Pen Purple', 'GLI-69C29C160E1D3', 'pcs', 50.00, 60.00, 3, 1, '', '#A855F7', NULL, 1, '2026-03-24 14:13:42'),
(21, 1, 'Glitter Pen Blue', 'GLI-69C29C4A22B68', 'pcs', 50.00, 60.00, 5, 1, '', '#3B82F6', NULL, 1, '2026-03-24 14:14:34'),
(22, 1, 'Glitter Pen Pink', 'GLI-69C2A0BB11AA3', 'pcs', 50.00, 60.00, 4, 1, '', '#EC4899', NULL, 1, '2026-03-24 14:33:31'),
(23, 20, 'Atlas Pastel 24 Color', 'ATL-69C55C7E623A1', 'pcs', 320.00, 350.00, 4, 1, '', NULL, NULL, 1, '2026-03-26 16:19:10'),
(24, 1, 'Atlas 6 Color Pencil', 'ATL-69C55CCFACAB1', 'pcs', 200.00, 235.00, 4, 1, '', NULL, NULL, 1, '2026-03-26 16:20:31'),
(25, 1, 'Atlas 12 Color Pencil', 'ATL-69C55D15A96E2', 'pcs', 590.00, 630.00, 2, 1, '', NULL, 'assets/products/prod_69e6342e3e2e3.jpg', 1, '2026-03-26 16:21:41'),
(26, 19, 'Atlas 6 Color Felta', 'ATL-69C55DDA8FA6C', 'pcs', 220.00, 260.00, 5, 1, '', NULL, NULL, 1, '2026-03-26 16:24:58'),
(27, 1, 'Atlas HB Pencil 12 Case', 'ATL-69C55E1F9E1C3', 'pcs', 420.00, 440.00, 4, 1, '', NULL, NULL, 1, '2026-03-26 16:26:07'),
(28, 15, 'Atlas Glu Binder Small', 'ATL-69C55E6E66FF7', 'pcs', 85.00, 100.00, 6, 2, '', NULL, NULL, 1, '2026-03-26 16:27:26'),
(29, 12, 'Starler Stapler Machine (small HL-203)', 'STA-69C55F10616D2', 'pcs', 120.00, 145.00, 6, 2, '', NULL, NULL, 1, '2026-03-26 16:30:08'),
(30, 18, 'Cello tape Small', 'CEL-69C55F4E64062', 'pcs', 15.00, 20.00, 8, 2, '', NULL, NULL, 1, '2026-03-26 16:31:10'),
(31, 18, 'Cello tape (BIG)', 'CEL-69C55F72B12C6', 'pcs', 80.00, 100.00, 1, 1, '', NULL, NULL, 1, '2026-03-26 16:31:46'),
(32, 21, 'Round Clips', 'ROU-69C55FF6DACAA', 'pcs', 45.00, 55.00, 5, 2, '', NULL, NULL, 1, '2026-03-26 16:33:58'),
(33, 26, 'Whiteboard Marker RED', 'WHI-69C56029ACD13', 'pcs', 90.00, 120.00, 4, 2, '', '#EF4444', NULL, 1, '2026-03-26 16:34:49'),
(34, 26, 'Whiteboard Marker BLACK', 'WHI-69C5604297EB2', 'pcs', 90.00, 120.00, 0, 2, '', '#1E293B', NULL, 1, '2026-03-26 16:35:14'),
(35, 26, 'Whiteboard Marker BLUE', 'WHI-69C5605DAF0A4', 'pcs', 90.00, 120.00, 0, 2, '', '#3B82F6', NULL, 1, '2026-03-26 16:35:41'),
(36, 10, 'Note Book Big (Upper Open)', 'NOT-69C5609BD1B41', 'pcs', 200.00, 220.00, 4, 2, '', NULL, NULL, 1, '2026-03-26 16:36:43'),
(37, 17, 'Sharper DOMS', 'SHA-69C560FA923B7', 'pcs', 28.00, 35.00, 15, 5, '', NULL, NULL, 1, '2026-03-26 16:38:18'),
(38, 1, 'Atlas Pencil Single', 'ATL-69C56139A327A', 'pcs', 32.00, 36.00, 13, 5, '', NULL, NULL, 1, '2026-03-26 16:39:21'),
(39, 11, 'Labubu Eraser', 'LAB-69C561A33D4CD', 'pcs', 15.00, 20.00, 15, 5, '', NULL, 'assets/products/prod_69cfcd487e498.jpeg', 1, '2026-03-26 16:41:07'),
(40, 11, 'Numbering Eraser', 'NUM-69C5622A3A176', 'pcs', 40.00, 50.00, 23, 5, '', NULL, 'assets/products/prod_69cfcdace68fb.jpeg', 1, '2026-03-26 16:43:22'),
(41, 15, 'Glu Stick', 'GLU-69C562BDB6EA2', 'pcs', 100.00, 120.00, 1, 3, '', NULL, NULL, 1, '2026-03-26 16:45:49'),
(42, 16, 'Atlas Correction Bottle', 'ATL-69C5635CB6979', 'pcs', 110.00, 130.00, 12, 2, '', NULL, NULL, 1, '2026-03-26 16:48:28'),
(43, 15, 'Chemifix Glu', 'CHE-69C5638AACC28', 'pcs', 250.00, 290.00, 3, 1, '', NULL, NULL, 1, '2026-03-26 16:49:14'),
(44, 22, 'Spiderman Key Tag', 'SPI-69C563C8A0C71', 'pcs', 120.00, 150.00, 5, 2, '', NULL, NULL, 1, '2026-03-26 16:50:16'),
(45, 22, 'Dragon Key Tag', 'DRA-69C563FE2B9A4', 'pcs', 120.00, 150.00, 7, 2, '', NULL, NULL, 1, '2026-03-26 16:51:10'),
(46, 21, 'Macaron paper Clip (4 Pice)', 'MAC-69C5645CC9C46', 'pcs', 100.00, 150.00, 3, 1, '', NULL, NULL, 1, '2026-03-26 16:52:44'),
(47, 17, 'Macaron Pencil Sharpener', 'MAC-69C564A774629', 'pcs', 100.00, 150.00, 3, 1, '', NULL, NULL, 1, '2026-03-26 16:53:59'),
(48, 16, 'Macaron Stapler Nail Remover', 'MAC-69C5650E4F6A8', 'pcs', 300.00, 390.00, 3, 1, '', NULL, NULL, 1, '2026-03-26 16:55:42'),
(49, 16, 'Macaron paper Clicp small', 'MAC-69C565E6B7F56', 'pcs', 250.00, 300.00, 1, 1, '', NULL, NULL, 1, '2026-03-26 16:59:18'),
(50, 21, 'Macaron Long Tail Clip', 'MAC-69C5660B3E7E6', 'pcs', 250.00, 300.00, 2, 1, '', NULL, NULL, 1, '2026-03-26 16:59:55'),
(51, 16, 'Macaron Key Plates', 'MAC-69C56647BF64C', 'pcs', 250.00, 300.00, 1, 1, '', NULL, NULL, 1, '2026-03-26 17:00:55'),
(52, 21, 'Macaron Paper Clips Big', 'MAC-69C5669531FA8', 'pcs', 250.00, 300.00, 2, 1, '', NULL, NULL, 1, '2026-03-26 17:02:13'),
(53, 10, 'Cry Baby Note Book', 'CRY-69C566D3C3251', 'pcs', 50.00, 70.00, 23, 5, '', NULL, NULL, 1, '2026-03-26 17:03:15'),
(54, 16, 'A4 Color Clip Paper Board (Exam)', 'ACO-69C5672E2AF0A', 'pcs', 300.00, 320.00, 3, 1, '', NULL, NULL, 1, '2026-03-26 17:04:46'),
(55, 14, 'Toy Clock', 'TOY-69C5679151D33', 'pcs', 130.00, 150.00, 5, 1, '', NULL, 'assets/products/prod_69d550725343e.jpeg', 1, '2026-03-26 17:06:25'),
(56, 16, 'Puncher IDM', 'PUN-69C567B92878C', 'pcs', 400.00, 450.00, 3, 1, '', NULL, NULL, 1, '2026-03-26 17:07:05'),
(57, 19, 'Little Bear Highlighter (small)', 'LIT-69C5684F785A7', 'pcs', 280.00, 300.00, 6, 2, '', NULL, NULL, 1, '2026-03-26 17:09:35'),
(58, 14, 'Abacus 4', 'ABA-69C568A76316C', 'pcs', 330.00, 360.00, 5, 1, '', NULL, 'assets/products/prod_69e6335018553.jpg', 1, '2026-03-26 17:11:03'),
(59, 14, '3D Shapes (Solid Set) 9PCS', 'DSH-69C5690755475', 'pcs', 300.00, 325.00, 3, 1, '', NULL, 'assets/products/prod_69d55066a6838.jpeg', 1, '2026-03-26 17:12:39'),
(60, 14, '2D Shapes 7PCS', 'DSH-69C5696CD2591', 'pcs', 115.00, 135.00, 5, 1, '', NULL, 'assets/products/prod_69cfb24f24435.jpeg', 1, '2026-03-26 17:14:20'),
(61, 14, 'Bars & Cubes 15PCS', 'BAR-69C569CDEDD6E', 'pcs', 270.00, 300.00, 4, 1, '5 Bars, 10 Cubes', NULL, NULL, 1, '2026-03-26 17:15:57'),
(62, 16, 'Sticky Note BAR', 'STI-69C56A6DD6DBA', 'pcs', 150.00, 180.00, 3, 1, '100PCS/ 5 colors', NULL, NULL, 1, '2026-03-26 17:18:37'),
(63, 16, 'Sticky Note Single page', 'STI-69C56A8FED43F', 'pcs', 140.00, 150.00, 4, 1, '', NULL, NULL, 1, '2026-03-26 17:19:11'),
(64, 1, 'Speed 5 Colors Pen', 'SPE-69C56BAA35A2D', 'pcs', 125.00, 125.00, 3, 1, '', NULL, NULL, 1, '2026-03-26 17:23:54'),
(65, 18, 'Normal File Covers', 'NOR-69C56C3648EB2', 'pcs', 40.00, 40.00, 5, 3, '', NULL, NULL, 1, '2026-03-26 17:26:14'),
(66, 23, 'Rangana CR 200#', 'RAN-69C77215C8390', 'pcs', 400.00, 460.00, 9, 2, '', NULL, NULL, 1, '2026-03-28 06:15:49'),
(67, 23, '5 Ruled 80 page (28mm) 2026 NEW', 'RUL-69C7728659DFE', 'pcs', 120.00, 120.00, 6, 2, '', NULL, 'assets/products/prod_69e632dd44f04.png', 1, '2026-03-28 06:17:42'),
(68, 23, 'Rangana CR 200=', 'RAN-69C772E2A0E29', 'pcs', 400.00, 430.00, 6, 2, '', NULL, NULL, 1, '2026-03-28 06:19:14'),
(69, 23, 'Rangana CR 160=', 'RAN-69C7734C6A70B', 'pcs', 320.00, 360.00, 5, 2, '', NULL, NULL, 1, '2026-03-28 06:21:00'),
(70, 23, 'Rangana CR 120#', 'RAN-69C773E26818A', 'pcs', 240.00, 280.00, 12, 2, '', NULL, NULL, 1, '2026-03-28 06:23:30'),
(71, 23, 'Dumnidu CR 120#', 'DUM-69C7741A0826A', 'pcs', 220.00, 230.00, 1, 2, '', NULL, NULL, 1, '2026-03-28 06:24:26'),
(72, 16, 'Exam Papers =', 'EXA-69C7746E69DCD', 'pcs', 260.00, 270.00, 5, 1, '', NULL, NULL, 1, '2026-03-28 06:25:50'),
(73, 14, 'Googley Eyes', 'GOO-69C774FFC4EAF', 'pcs', 60.00, 80.00, 23, 3, '', NULL, NULL, 1, '2026-03-28 06:28:15'),
(74, 24, 'Igini Seeds', 'IGI-69C775CF3C05C', 'pcs', 35.00, 40.00, 7, 1, '', NULL, NULL, 1, '2026-03-28 06:31:43'),
(75, 24, 'Kohomba Seeds', 'KOH-69C775E8B4E20', 'pcs', 35.00, 40.00, 7, 1, '', NULL, NULL, 1, '2026-03-28 06:32:08'),
(76, 24, 'Mi Seeds', 'MIS-69C775FF696D8', 'pcs', 35.00, 40.00, 7, 1, '', NULL, NULL, 1, '2026-03-28 06:32:31'),
(77, 24, 'Madatiya Seeds', 'MAD-69C7761EC976F', 'pcs', 35.00, 40.00, 7, 1, '', NULL, NULL, 1, '2026-03-28 06:33:02'),
(78, 24, 'Edaru Seeds', 'EDA-69C7763943FE9', 'pcs', 35.00, 40.00, 7, 1, '', NULL, NULL, 1, '2026-03-28 06:33:29'),
(79, 23, 'A Printouts One side', 'APR-69C7A37F519F8', 'pcs', 0.00, 8.00, 1000000000, 0, '', NULL, NULL, 0, '2026-03-28 09:46:39'),
(80, 27, 'Clear Bag', 'CLE-69C7EBEB5BEBB', 'pcs', 90.00, 120.00, 9, 5, '', NULL, NULL, 1, '2026-03-28 14:55:39'),
(81, 16, 'Sri Lanka Map', 'SRI-69C7EE9FBDFAD', 'pcs', 5.00, 10.00, 97, 5, '', NULL, NULL, 1, '2026-03-28 15:07:11'),
(82, 16, 'World Map', 'WOR-69C7EEC30855F', 'pcs', 0.00, 10.00, 97, 5, '', NULL, NULL, 1, '2026-03-28 15:07:47'),
(83, 23, 'Richard (1/2)\" Square 80', 'RIC-69C7EF0C481FF', 'pcs', 75.00, 80.00, 18, 5, '', NULL, NULL, 1, '2026-03-28 15:09:00'),
(84, 23, 'Rangana EX 160 =', 'RAN-69C7EF4137883', 'pcs', 150.00, 170.00, 11, 5, '', NULL, NULL, 1, '2026-03-28 15:09:53'),
(85, 23, 'Atlas Botany 80', 'ATL-69C7EF7F97884', 'pcs', 70.00, 75.00, 2, 5, '', NULL, NULL, 1, '2026-03-28 15:10:55'),
(86, 23, 'SchoolMate 40 =', 'SCH-69C7EFE234563', 'pcs', 50.00, 55.00, 4, 4, '', NULL, NULL, 1, '2026-03-28 15:12:34'),
(87, 1, 'Doll Pencil', 'DOL-69CE6F2FDF492', 'pcs', 130.00, 140.00, 3, 2, '', NULL, NULL, 1, '2026-04-02 13:29:19'),
(88, 1, 'Eraser with pencil', 'ERA-69CE7F7EE2943', 'pcs', 40.00, 40.00, 18, 5, '', NULL, NULL, 1, '2026-04-02 14:38:54'),
(89, 19, 'Speed Highlight Green', 'SPE-69CE7FF546134', 'pcs', 90.00, 100.00, 2, 1, '', '#22C55E', NULL, 1, '2026-04-02 14:40:53'),
(90, 19, 'Speed Highlight  Pink', 'SPE-69CE80107339A', 'pcs', 90.00, 100.00, 1, 1, '', '#EC4899', NULL, 1, '2026-04-02 14:41:20'),
(91, 19, 'Speed Highlight Purple', 'SPE-69CE802BE48F7', 'pcs', 90.00, 100.00, 1, 1, '', '#A855F7', NULL, 1, '2026-04-02 14:41:47'),
(92, 1, 'Erasable Pen with Doll', 'ERA-69CE80D647E0B', 'pcs', 190.00, 200.00, 11, 5, '', NULL, NULL, 1, '2026-04-02 14:44:38'),
(93, 1, 'Erasable Pen', 'ERA-69CE81295A98C', 'pcs', 110.00, 120.00, 12, 5, '', NULL, NULL, 1, '2026-04-02 14:46:01'),
(94, 28, 'Hello Kitty Ruler 30CM', 'HEL-69CFCCACEC692', 'pcs', 150.00, 180.00, 11, 3, '', NULL, 'assets/products/prod_69cfcc7f3955b.jpeg', 1, '2026-04-03 14:20:28'),
(95, 16, 'Birds Feathers', 'BIR-69D5034C74C95', 'pcs', 145.00, 150.00, 6, 2, '', NULL, 'assets/products/prod_69d503486dc43.jpeg', 1, '2026-04-07 13:14:52'),
(96, 16, 'Dry Leaves', 'DRY-69D504030823B', 'pcs', 145.00, 150.00, 1, 2, '', NULL, 'assets/products/prod_69d503fd4c072.jpeg', 1, '2026-04-07 13:17:55'),
(97, 16, 'Dry Flowers', 'DRY-69D5045359358', 'pcs', 85.00, 85.00, 1, 2, '', NULL, 'assets/products/prod_69d504512d3e7.jpeg', 1, '2026-04-07 13:19:15'),
(98, 1, 'Ten pen Blue', 'TEN-69E62EAEEEB63', 'pcs', 18.00, 18.00, 13, 5, '', '#3B82F6', 'assets/products/prod_69e62eace0c80.webp', 1, '2026-04-20 13:48:30'),
(99, 1, 'Ten Pen Black', 'TEN-69E62F2460E09', 'pcs', 18.00, 18.00, 25, 5, '', '#1E293B', 'assets/products/prod_69e62f224e359.webp', 1, '2026-04-20 13:50:28'),
(100, 1, 'Rainbow Pencil', 'RAI-69E6326ACB8AF', 'pcs', 45.00, 50.00, 10, 5, '', NULL, 'assets/products/prod_69e63268caf8f.jpeg', 1, '2026-04-20 14:04:26');

-- --------------------------------------------------------

--
-- Table structure for table `stock_adjustments`
--

CREATE TABLE `stock_adjustments` (
  `id` int(10) UNSIGNED NOT NULL,
  `product_id` int(10) UNSIGNED NOT NULL,
  `type` enum('in','out','sale','return') NOT NULL,
  `quantity` int(11) NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stock_adjustments`
--

INSERT INTO `stock_adjustments` (`id`, `product_id`, `type`, `quantity`, `note`, `created_at`) VALUES
(1, 13, 'in', 5, 'Initial stock', '2026-03-22 20:47:41'),
(2, 1, 'sale', 2, 'Bill MIN-20260322-2823', '2026-03-22 20:48:22'),
(3, 13, 'sale', 1, 'Bill MIN-20260322-2823', '2026-03-22 20:48:22'),
(4, 9, 'sale', 2, 'Bill MIN-20260322-1871', '2026-03-22 20:52:59'),
(5, 7, 'sale', 1, 'Bill MIN-20260322-1871', '2026-03-22 20:53:00'),
(6, 1, 'sale', 1, 'Bill MIN-20260322-1871', '2026-03-22 20:53:00'),
(7, 9, 'in', 10, '', '2026-03-22 20:56:10'),
(8, 9, 'out', 10, '', '2026-03-22 20:56:25'),
(9, 9, 'in', 10, '', '2026-03-22 20:56:31'),
(10, 9, 'sale', 1, 'Bill MIN-20260322-6221', '2026-03-22 21:33:00'),
(11, 6, 'sale', 1, 'Bill MIN-20260322-6221', '2026-03-22 21:33:00'),
(12, 2, 'sale', 1, 'Bill MIN-20260322-6221', '2026-03-22 21:33:00'),
(13, 11, 'sale', 1, 'Bill MIN-20260322-6221', '2026-03-22 21:33:00'),
(14, 8, 'sale', 1, 'Bill MIN-20260322-6221', '2026-03-22 21:33:00'),
(15, 12, 'sale', 1, 'Bill MIN-20260322-6221', '2026-03-22 21:33:00'),
(16, 13, 'sale', 4, 'Bill MIN-20260322-6221', '2026-03-22 21:33:00'),
(17, 3, 'sale', 4, 'Bill MIN-20260322-6221', '2026-03-22 21:33:00'),
(18, 10, 'sale', 1, 'Bill MIN-20260322-6221', '2026-03-22 21:33:00'),
(19, 5, 'sale', 1, 'Bill MIN-20260322-6221', '2026-03-22 21:33:00'),
(20, 2, 'sale', 1, 'Bill MIN-20260322-3445', '2026-03-22 21:33:57'),
(21, 11, 'sale', 4, 'Bill MIN-20260322-3445', '2026-03-22 21:33:57'),
(22, 4, 'sale', 2, 'Bill MIN-20260322-3445', '2026-03-22 21:33:57'),
(23, 3, 'sale', 1, 'Bill MIN-20260322-3445', '2026-03-22 21:33:57'),
(24, 8, 'sale', 5, 'Bill MIN-20260322-3445', '2026-03-22 21:33:57'),
(25, 6, 'sale', 5, 'Bill MIN-20260322-3445', '2026-03-22 21:33:57'),
(26, 5, 'sale', 1, 'Bill MIN-20260322-3445', '2026-03-22 21:33:57'),
(27, 10, 'sale', 1, 'Bill MIN-20260322-3445', '2026-03-22 21:33:57'),
(28, 10, 'sale', 11, 'Bill MIN-20260322-2543', '2026-03-22 21:34:17'),
(29, 10, 'return', 11, 'Cancelled Bill MIN-20260322-2543', '2026-03-22 22:36:18'),
(30, 2, 'return', 1, 'Cancelled Bill MIN-20260322-3445', '2026-03-22 22:36:20'),
(31, 11, 'return', 4, 'Cancelled Bill MIN-20260322-3445', '2026-03-22 22:36:20'),
(32, 4, 'return', 2, 'Cancelled Bill MIN-20260322-3445', '2026-03-22 22:36:20'),
(33, 3, 'return', 1, 'Cancelled Bill MIN-20260322-3445', '2026-03-22 22:36:20'),
(34, 8, 'return', 5, 'Cancelled Bill MIN-20260322-3445', '2026-03-22 22:36:20'),
(35, 6, 'return', 5, 'Cancelled Bill MIN-20260322-3445', '2026-03-22 22:36:20'),
(36, 5, 'return', 1, 'Cancelled Bill MIN-20260322-3445', '2026-03-22 22:36:20'),
(37, 10, 'return', 1, 'Cancelled Bill MIN-20260322-3445', '2026-03-22 22:36:20'),
(38, 9, 'return', 1, 'Cancelled Bill MIN-20260322-6221', '2026-03-22 22:36:21'),
(39, 6, 'return', 1, 'Cancelled Bill MIN-20260322-6221', '2026-03-22 22:36:21'),
(40, 2, 'return', 1, 'Cancelled Bill MIN-20260322-6221', '2026-03-22 22:36:21'),
(41, 11, 'return', 1, 'Cancelled Bill MIN-20260322-6221', '2026-03-22 22:36:21'),
(42, 8, 'return', 1, 'Cancelled Bill MIN-20260322-6221', '2026-03-22 22:36:21'),
(43, 12, 'return', 1, 'Cancelled Bill MIN-20260322-6221', '2026-03-22 22:36:21'),
(44, 13, 'return', 4, 'Cancelled Bill MIN-20260322-6221', '2026-03-22 22:36:21'),
(45, 3, 'return', 4, 'Cancelled Bill MIN-20260322-6221', '2026-03-22 22:36:21'),
(46, 10, 'return', 1, 'Cancelled Bill MIN-20260322-6221', '2026-03-22 22:36:21'),
(47, 5, 'return', 1, 'Cancelled Bill MIN-20260322-6221', '2026-03-22 22:36:21'),
(48, 9, 'return', 2, 'Cancelled Bill MIN-20260322-1871', '2026-03-22 22:36:23'),
(49, 7, 'return', 1, 'Cancelled Bill MIN-20260322-1871', '2026-03-22 22:36:23'),
(50, 1, 'return', 1, 'Cancelled Bill MIN-20260322-1871', '2026-03-22 22:36:23'),
(51, 1, 'return', 2, 'Cancelled Bill MIN-20260322-2823', '2026-03-22 22:36:25'),
(52, 13, 'return', 1, 'Cancelled Bill MIN-20260322-2823', '2026-03-22 22:36:25'),
(53, 14, 'in', 42, 'Initial stock', '2026-03-22 22:40:10'),
(54, 15, 'in', 16, 'Initial stock', '2026-03-22 22:41:48'),
(55, 16, 'in', 49, 'Initial stock', '2026-03-22 22:44:54'),
(56, 17, 'in', 5, '', '2026-03-22 22:47:45'),
(57, 17, 'in', 10, '', '2026-03-22 22:48:05'),
(58, 17, 'out', 5, '', '2026-03-22 22:48:14'),
(59, 18, 'in', 16, 'Initial stock', '2026-03-22 22:49:47'),
(60, 14, 'sale', 2, 'Bill MIN-20260324-0313', '2026-03-24 13:03:25'),
(61, 15, 'sale', 2, 'Bill MIN-20260324-0313', '2026-03-24 13:03:25'),
(62, 17, 'sale', 2, 'Bill MIN-20260324-0313', '2026-03-24 13:03:25'),
(63, 18, 'sale', 1, 'Bill MIN-20260324-0313', '2026-03-24 13:03:25'),
(64, 16, 'sale', 1, 'Bill MIN-20260324-0313', '2026-03-24 13:03:25'),
(65, 14, 'in', 2, '', '2026-03-24 13:05:53'),
(66, 15, 'in', 2, '', '2026-03-24 13:06:11'),
(67, 17, 'in', 2, '', '2026-03-24 13:06:31'),
(68, 18, 'in', 1, '', '2026-03-24 13:06:43'),
(69, 16, 'in', 1, '', '2026-03-24 13:07:03'),
(70, 19, 'in', 1, 'Initial stock', '2026-03-24 14:11:37'),
(71, 19, 'in', 4, '', '2026-03-24 14:11:56'),
(72, 20, 'in', 3, 'Initial stock', '2026-03-24 14:13:42'),
(73, 21, 'in', 5, 'Initial stock', '2026-03-24 14:14:34'),
(74, 22, 'in', 4, 'Initial stock', '2026-03-24 14:33:31'),
(75, 23, 'in', 4, 'Initial stock', '2026-03-26 16:19:10'),
(76, 24, 'in', 4, 'Initial stock', '2026-03-26 16:20:31'),
(77, 25, 'in', 2, 'Initial stock', '2026-03-26 16:21:41'),
(78, 26, 'in', 5, 'Initial stock', '2026-03-26 16:24:58'),
(79, 27, 'in', 4, 'Initial stock', '2026-03-26 16:26:07'),
(80, 28, 'in', 7, 'Initial stock', '2026-03-26 16:27:26'),
(81, 29, 'in', 6, 'Initial stock', '2026-03-26 16:30:08'),
(82, 30, 'in', 8, 'Initial stock', '2026-03-26 16:31:10'),
(83, 31, 'in', 1, 'Initial stock', '2026-03-26 16:31:46'),
(84, 32, 'in', 4, 'Initial stock', '2026-03-26 16:33:58'),
(85, 33, 'in', 4, 'Initial stock', '2026-03-26 16:34:49'),
(86, 36, 'in', 4, 'Initial stock', '2026-03-26 16:36:43'),
(87, 37, 'in', 15, 'Initial stock', '2026-03-26 16:38:18'),
(88, 38, 'in', 19, 'Initial stock', '2026-03-26 16:39:21'),
(89, 39, 'in', 15, 'Initial stock', '2026-03-26 16:41:07'),
(90, 40, 'in', 24, 'Initial stock', '2026-03-26 16:43:22'),
(91, 41, 'in', 5, 'Initial stock', '2026-03-26 16:45:49'),
(92, 42, 'in', 12, 'Initial stock', '2026-03-26 16:48:28'),
(93, 43, 'in', 4, 'Initial stock', '2026-03-26 16:49:14'),
(94, 44, 'in', 5, 'Initial stock', '2026-03-26 16:50:16'),
(95, 45, 'in', 7, 'Initial stock', '2026-03-26 16:51:10'),
(96, 46, 'in', 3, 'Initial stock', '2026-03-26 16:52:44'),
(97, 47, 'in', 3, 'Initial stock', '2026-03-26 16:53:59'),
(98, 48, 'in', 3, 'Initial stock', '2026-03-26 16:55:42'),
(99, 49, 'in', 1, 'Initial stock', '2026-03-26 16:59:18'),
(100, 50, 'in', 2, 'Initial stock', '2026-03-26 16:59:55'),
(101, 51, 'in', 1, 'Initial stock', '2026-03-26 17:00:55'),
(102, 52, 'in', 2, 'Initial stock', '2026-03-26 17:02:13'),
(103, 53, 'in', 23, 'Initial stock', '2026-03-26 17:03:15'),
(104, 54, 'in', 3, 'Initial stock', '2026-03-26 17:04:46'),
(105, 55, 'in', 5, 'Initial stock', '2026-03-26 17:06:25'),
(106, 56, 'in', 3, 'Initial stock', '2026-03-26 17:07:05'),
(107, 57, 'in', 6, 'Initial stock', '2026-03-26 17:09:35'),
(108, 58, 'in', 5, 'Initial stock', '2026-03-26 17:11:03'),
(109, 59, 'in', 3, 'Initial stock', '2026-03-26 17:12:39'),
(110, 60, 'in', 5, 'Initial stock', '2026-03-26 17:14:20'),
(111, 61, 'in', 4, 'Initial stock', '2026-03-26 17:15:57'),
(112, 62, 'in', 3, 'Initial stock', '2026-03-26 17:18:37'),
(113, 63, 'in', 4, 'Initial stock', '2026-03-26 17:19:11'),
(114, 64, 'in', 3, 'Initial stock', '2026-03-26 17:23:54'),
(115, 65, 'in', 5, 'Initial stock', '2026-03-26 17:26:14'),
(116, 54, 'sale', 1, 'Bill MIN-20260326-0955', '2026-03-26 17:34:39'),
(117, 54, 'return', 1, 'Cancelled Bill MIN-20260326-0955', '2026-03-26 17:35:11'),
(118, 43, 'sale', 1, 'Bill MIN-20260328-5746', '2026-03-28 06:03:03'),
(119, 14, 'return', 2, 'Cancelled Bill MIN-20260324-0313', '2026-03-28 06:03:13'),
(120, 15, 'return', 2, 'Cancelled Bill MIN-20260324-0313', '2026-03-28 06:03:13'),
(121, 17, 'return', 2, 'Cancelled Bill MIN-20260324-0313', '2026-03-28 06:03:13'),
(122, 18, 'return', 1, 'Cancelled Bill MIN-20260324-0313', '2026-03-28 06:03:13'),
(123, 16, 'return', 1, 'Cancelled Bill MIN-20260324-0313', '2026-03-28 06:03:13'),
(124, 66, 'in', 9, 'Initial stock', '2026-03-28 06:15:49'),
(125, 67, 'in', 6, 'Initial stock', '2026-03-28 06:17:42'),
(126, 68, 'in', 6, 'Initial stock', '2026-03-28 06:19:14'),
(127, 69, 'in', 5, 'Initial stock', '2026-03-28 06:21:00'),
(128, 70, 'in', 12, 'Initial stock', '2026-03-28 06:23:30'),
(129, 71, 'in', 1, 'Initial stock', '2026-03-28 06:24:26'),
(130, 72, 'in', 5, 'Initial stock', '2026-03-28 06:25:50'),
(131, 73, 'in', 23, 'Initial stock', '2026-03-28 06:28:15'),
(132, 74, 'in', 7, 'Initial stock', '2026-03-28 06:31:43'),
(133, 75, 'in', 7, 'Initial stock', '2026-03-28 06:32:08'),
(134, 76, 'in', 7, 'Initial stock', '2026-03-28 06:32:31'),
(135, 77, 'in', 7, 'Initial stock', '2026-03-28 06:33:02'),
(136, 78, 'in', 7, 'Initial stock', '2026-03-28 06:33:29'),
(137, 60, 'sale', 1, 'Bill MIN-20260328-1911', '2026-03-28 06:37:16'),
(138, 60, 'return', 1, 'Cancelled Bill MIN-20260328-1911', '2026-03-28 06:37:32'),
(139, 79, 'in', 1000000000, 'Initial stock', '2026-03-28 09:46:39'),
(140, 43, 'return', 1, 'Cancelled Bill MIN-20260328-5746', '2026-03-28 09:49:06'),
(141, 43, 'sale', 1, 'Bill MIN-20260328-9172', '2026-03-28 09:50:07'),
(142, 80, 'in', 13, 'Initial stock', '2026-03-28 14:55:39'),
(143, 81, 'in', 97, 'Initial stock', '2026-03-28 15:07:11'),
(144, 82, 'in', 97, 'Initial stock', '2026-03-28 15:07:47'),
(145, 83, 'in', 18, 'Initial stock', '2026-03-28 15:09:00'),
(146, 84, 'in', 11, 'Initial stock', '2026-03-28 15:09:53'),
(147, 85, 'in', 2, 'Initial stock', '2026-03-28 15:10:55'),
(148, 86, 'in', 5, 'Initial stock', '2026-03-28 15:12:34'),
(149, 32, 'in', 1, '', '2026-03-29 04:24:10'),
(150, 15, 'sale', 1, 'Bill MIN-20260330-8203', '2026-03-30 15:34:36'),
(151, 15, 'out', 5, '', '2026-03-30 16:41:23'),
(152, 15, 'in', 1, '', '2026-03-30 16:41:27'),
(153, 15, 'sale', 1, 'Bill MIN-20260331-4590', '2026-03-31 14:05:11'),
(154, 59, 'sale', 1, 'Bill MIN-20260401-5441', '2026-04-01 15:18:25'),
(155, 59, 'return', 1, 'Cancelled Bill MIN-20260401-5441', '2026-04-01 15:30:31'),
(156, 60, 'sale', 1, 'Bill MIN-20260402-9855', '2026-04-02 11:40:24'),
(157, 59, 'sale', 1, 'Bill MIN-20260402-9855', '2026-04-02 11:40:24'),
(158, 67, 'sale', 1, 'Bill MIN-20260402-9855', '2026-04-02 11:40:24'),
(159, 26, 'sale', 1, 'Bill MIN-20260402-9855', '2026-04-02 11:40:24'),
(160, 60, 'return', 1, 'Cancelled Bill MIN-20260402-9855', '2026-04-02 11:40:43'),
(161, 59, 'return', 1, 'Cancelled Bill MIN-20260402-9855', '2026-04-02 11:40:43'),
(162, 67, 'return', 1, 'Cancelled Bill MIN-20260402-9855', '2026-04-02 11:40:43'),
(163, 26, 'return', 1, 'Cancelled Bill MIN-20260402-9855', '2026-04-02 11:40:43'),
(164, 87, 'in', 3, 'Initial stock', '2026-04-02 13:29:19'),
(165, 88, 'in', 18, 'Initial stock', '2026-04-02 14:38:54'),
(166, 89, 'in', 2, 'Initial stock', '2026-04-02 14:40:53'),
(167, 90, 'in', 1, 'Initial stock', '2026-04-02 14:41:20'),
(168, 91, 'in', 1, 'Initial stock', '2026-04-02 14:41:47'),
(169, 92, 'in', 11, 'Initial stock', '2026-04-02 14:44:38'),
(170, 93, 'in', 12, 'Initial stock', '2026-04-02 14:46:01'),
(171, 94, 'in', 11, 'Initial stock', '2026-04-03 14:20:28'),
(172, 38, 'sale', 1, 'Bill MIN-20260405-6124', '2026-04-05 07:18:56'),
(173, 14, 'sale', 2, 'Bill MIN-20260405-9051', '2026-04-05 09:53:33'),
(174, 28, 'sale', 1, 'Bill MIN-20260406-9491', '2026-04-06 13:23:36'),
(175, 38, 'sale', 3, 'Bill MIN-20260406-0792', '2026-04-06 13:34:44'),
(176, 38, 'sale', 3, 'Bill MIN-20260406-9477', '2026-04-06 13:35:16'),
(177, 38, 'return', 3, 'Cancelled Bill MIN-20260406-9477', '2026-04-06 13:35:25'),
(178, 95, 'in', 7, 'Initial stock', '2026-04-07 13:14:52'),
(179, 95, 'sale', 2, 'Bill MIN-20260407-2286', '2026-04-07 13:15:03'),
(180, 95, 'in', 1, '', '2026-04-07 13:15:27'),
(181, 96, 'in', 1, 'Initial stock', '2026-04-07 13:17:55'),
(182, 97, 'in', 1, 'Initial stock', '2026-04-07 13:19:15'),
(183, 86, 'sale', 1, 'Bill MIN-20260408-0472', '2026-04-08 12:28:57'),
(184, 24, 'sale', 1, 'Bill MIN-20260418-5612', '2026-04-17 23:12:57'),
(185, 26, 'sale', 1, 'Bill MIN-20260418-5612', '2026-04-17 23:12:57'),
(186, 25, 'sale', 1, 'Bill MIN-20260418-5612', '2026-04-17 23:12:57'),
(187, 14, 'sale', 1, 'Bill MIN-20260418-5612', '2026-04-17 23:12:57'),
(188, 42, 'sale', 12, 'Bill MIN-20260418-5612', '2026-04-17 23:12:57'),
(189, 24, 'return', 1, 'Cancelled Bill MIN-20260418-5612', '2026-04-17 23:13:15'),
(190, 26, 'return', 1, 'Cancelled Bill MIN-20260418-5612', '2026-04-17 23:13:15'),
(191, 25, 'return', 1, 'Cancelled Bill MIN-20260418-5612', '2026-04-17 23:13:15'),
(192, 14, 'return', 1, 'Cancelled Bill MIN-20260418-5612', '2026-04-17 23:13:15'),
(193, 42, 'return', 12, 'Cancelled Bill MIN-20260418-5612', '2026-04-17 23:13:15'),
(194, 59, 'sale', 2, 'Bill MIN-20260418-9717', '2026-04-17 23:35:56'),
(195, 67, 'sale', 1, 'Bill MIN-20260418-9717', '2026-04-17 23:35:56'),
(196, 54, 'sale', 2, 'Bill MIN-20260418-9717', '2026-04-17 23:35:56'),
(197, 59, 'return', 2, 'Cancelled Bill MIN-20260418-9717', '2026-04-17 23:36:25'),
(198, 67, 'return', 1, 'Cancelled Bill MIN-20260418-9717', '2026-04-17 23:36:25'),
(199, 54, 'return', 2, 'Cancelled Bill MIN-20260418-9717', '2026-04-17 23:36:25'),
(200, 41, 'sale', 2, 'Bill MIN-20260419-6549', '2026-04-19 12:17:21'),
(201, 80, 'sale', 2, 'Bill MIN-20260419-6549', '2026-04-19 12:17:21'),
(202, 41, 'sale', 2, 'Bill MIN-20260419-9705', '2026-04-19 12:17:34'),
(203, 80, 'sale', 2, 'Bill MIN-20260419-9705', '2026-04-19 12:17:34'),
(204, 38, 'sale', 2, 'Bill MIN-20260419-8533', '2026-04-19 14:27:55'),
(205, 16, 'sale', 1, 'Bill MIN-20260420-0068', '2026-04-20 13:17:18'),
(206, 14, 'sale', 1, 'Bill MIN-20260420-0068', '2026-04-20 13:17:18'),
(207, 19, 'sale', 1, 'Bill MIN-20260420-0068', '2026-04-20 13:17:18'),
(208, 40, 'sale', 1, 'Bill MIN-20260420-0068', '2026-04-20 13:17:18'),
(209, 98, 'in', 13, 'Initial stock', '2026-04-20 13:48:30'),
(210, 99, 'in', 25, 'Initial stock', '2026-04-20 13:50:28'),
(211, 100, 'in', 10, 'Initial stock', '2026-04-20 14:04:26');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bills`
--
ALTER TABLE `bills`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `bill_no` (`bill_no`);

--
-- Indexes for table `bill_items`
--
ALTER TABLE `bill_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bill_id` (`bill_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `stock_adjustments`
--
ALTER TABLE `stock_adjustments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bills`
--
ALTER TABLE `bills`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=115;

--
-- AUTO_INCREMENT for table `bill_items`
--
ALTER TABLE `bill_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=225;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `stock_adjustments`
--
ALTER TABLE `stock_adjustments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=212;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bill_items`
--
ALTER TABLE `bill_items`
  ADD CONSTRAINT `bill_items_ibfk_1` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bill_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `stock_adjustments`
--
ALTER TABLE `stock_adjustments`
  ADD CONSTRAINT `stock_adjustments_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
