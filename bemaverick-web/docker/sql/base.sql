# ************************************************************
# Sequel Pro SQL dump
# Version 4541
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 127.0.0.1 (MySQL 5.5.5-10.1.26-MariaDB-0+deb9u1)
# Database: bemaverick
# Generation Time: 2017-12-13 04:46:51 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE DATABASE IF NOT EXISTS bemaverick;
-- CREATE USER IF NOT EXISTS 'apache'@'localhost' IDENTIFIED BY 'mysql';

USE bemaverick;

# Dump of table app
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app`;

CREATE TABLE `app` (
  `app_key` varchar(16) NOT NULL,
  `secret` varchar(16) NOT NULL,
  `name` varchar(255) NOT NULL,
  `platform` enum('web','iOS','android') DEFAULT NULL,
  `read_access` tinyint(1) NOT NULL DEFAULT '1',
  `write_access` tinyint(1) NOT NULL DEFAULT '1',
  `auth_token_ttl` int(11) DEFAULT '86400',
  `current_app_version` varchar(10) DEFAULT NULL,
  `min_app_version` varchar(10) DEFAULT NULL,
  `grant_types` varchar(255) DEFAULT NULL,
  `updated_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`app_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `app` WRITE;
/*!40000 ALTER TABLE `app` DISABLE KEYS */;

INSERT INTO `app` (`app_key`, `secret`, `name`, `platform`, `read_access`, `write_access`, `auth_token_ttl`, `current_app_version`, `min_app_version`, `grant_types`, `updated_ts`)
VALUES
	('test_key','test_secret','TestApp',NULL,1,1,604800,NULL,NULL,NULL,'2017-09-22 07:45:44');

/*!40000 ALTER TABLE `app` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table badge
# ------------------------------------------------------------

DROP TABLE IF EXISTS `badge`;

CREATE TABLE `badge` (
  `badge_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`badge_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `badge` WRITE;
/*!40000 ALTER TABLE `badge` DISABLE KEYS */;

INSERT INTO `badge` (`badge_id`, `name`, `updated_ts`)
VALUES
	(1,'Original','2017-09-22 12:40:21'),
	(2,'Explorer','2017-09-22 12:40:28'),
	(3,'Rebel','2017-09-22 12:40:33');

/*!40000 ALTER TABLE `badge` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table challenge
# ------------------------------------------------------------

DROP TABLE IF EXISTS `challenge`;

CREATE TABLE `challenge` (
  `challenge_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `mentor_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(1028) DEFAULT NULL,
  `video_id` int(11) DEFAULT NULL,
  `video_thumbnail_image_id` int(11) DEFAULT NULL,
  `card_image_id` int(11) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `winner_response_id` int(11) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT '1',
  `status` enum('published','draft','hidden') NOT NULL DEFAULT 'draft',
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`challenge_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `challenge` WRITE;
/*!40000 ALTER TABLE `challenge` DISABLE KEYS */;

INSERT INTO `challenge` (`challenge_id`, `mentor_id`, `user_id`, `title`, `description`, `video_id`, `video_thumbnail_image_id`, `card_image_id`, `start_time`, `end_time`, `winner_response_id`, `sort_order`, `status`, `updated_ts`)
VALUES
	(1,2,54,'Create A Maverick Toy',NULL,15,NULL,NULL,'2017-10-06 12:00:00','2017-10-31 12:00:00',NULL,2,'published','2017-12-13 04:41:56'),
	(2,4,56,'Who\'s Your Character','description goes here',4,NULL,NULL,'2017-10-04 12:00:00','2017-11-05 12:00:00',NULL,1,'published','2017-12-13 04:41:56'),
	(3,5,57,'Design My Cover Art with Jill Sobule',NULL,5,NULL,NULL,NULL,NULL,NULL,3,'published','2017-12-13 04:41:56');

/*!40000 ALTER TABLE `challenge` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table challenge_tags
# ------------------------------------------------------------

DROP TABLE IF EXISTS `challenge_tags`;

CREATE TABLE `challenge_tags` (
  `challenge_id` int(11) unsigned NOT NULL,
  `tag_id` int(11) NOT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`challenge_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `challenge_tags` WRITE;
/*!40000 ALTER TABLE `challenge_tags` DISABLE KEYS */;

INSERT INTO `challenge_tags` (`challenge_id`, `tag_id`, `updated_ts`)
VALUES
	(2,1,'2017-10-12 20:15:33'),
	(2,2,'2017-10-12 20:15:33'),
	(2,5,'2017-10-12 20:15:33');

/*!40000 ALTER TABLE `challenge_tags` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table image
# ------------------------------------------------------------

DROP TABLE IF EXISTS `image`;

CREATE TABLE `image` (
  `image_id` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) NOT NULL,
  `content_type` varchar(255) NOT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `crop_x` int(11) DEFAULT NULL,
  `crop_y` int(11) DEFAULT NULL,
  `crop_width` int(11) DEFAULT NULL,
  `crop_height` int(11) DEFAULT NULL,
  `updated_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `image` WRITE;
/*!40000 ALTER TABLE `image` DISABLE KEYS */;

INSERT INTO `image` (`image_id`, `filename`, `content_type`, `width`, `height`, `crop_x`, `crop_y`, `crop_width`, `crop_height`, `updated_ts`)
VALUES
	(1,'70d8df74b4f349b4bb326cfa6d1f6ce3.png','image/png',230,280,NULL,NULL,NULL,NULL,'2017-10-12 18:40:47'),
	(2,'3b798b4b0b44736dafb6e65ec17bfdb0.png','image/png',230,280,NULL,NULL,NULL,NULL,'2017-10-12 19:03:06'),
	(3,'8e6740a52914ef1a1bec5730b3d76127.png','image/png',230,280,NULL,NULL,NULL,NULL,'2017-10-12 20:32:34'),
	(4,'e70308cbf458f478150fa1e26d9cfde5.jpg','image/jpeg',4032,3024,NULL,NULL,NULL,NULL,'2017-10-12 20:45:17'),
	(5,'5dadbae8ec82187fa19e2a43064f91ed.png','image/png',230,280,NULL,NULL,NULL,NULL,'2017-10-12 20:45:33'),
	(6,'57810e668f27d7abe2b5d0bc0b606c1d.jpg','image/jpeg',4032,3024,NULL,NULL,NULL,NULL,'2017-10-13 07:01:03'),
	(7,'c3693a3b0540ffabf9e059781e2cc5ed.png','image/png',230,280,NULL,NULL,NULL,NULL,'2017-10-13 07:01:18');

/*!40000 ALTER TABLE `image` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table mentor
# ------------------------------------------------------------

DROP TABLE IF EXISTS `mentor`;

CREATE TABLE `mentor` (
  `mentor_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `short_description` varchar(255) DEFAULT NULL,
  `bio` varchar(1028) DEFAULT NULL,
  `profile_image_id` int(11) DEFAULT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`mentor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `mentor` WRITE;
/*!40000 ALTER TABLE `mentor` DISABLE KEYS */;

INSERT INTO `mentor` (`mentor_id`, `first_name`, `last_name`, `short_description`, `bio`, `profile_image_id`, `updated_ts`)
VALUES
	(1,'Ada','Lovelace','Short Description Here','Bio Here',NULL,'2017-09-11 20:06:00'),
	(2,'Tanya','Mann',NULL,NULL,NULL,'2017-09-22 11:22:37'),
	(3,'Shawn','Robinson',NULL,NULL,7,'2017-09-27 10:00:40'),
	(4,'Adam','Savage',NULL,NULL,NULL,'2017-09-29 16:02:58'),
	(5,'Jill','Sobule',NULL,NULL,NULL,'2017-10-09 22:26:20'),
	(6,'Derreck','Kayongo',NULL,NULL,NULL,'2017-10-12 22:43:57');

/*!40000 ALTER TABLE `mentor` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table oauth_refresh_tokens
# ------------------------------------------------------------

DROP TABLE IF EXISTS `oauth_refresh_tokens`;

CREATE TABLE `oauth_refresh_tokens` (
  `refresh_token` varchar(40) NOT NULL,
  `client_id` varchar(80) NOT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `expires` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `scope` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`refresh_token`),
  KEY `expires_index` (`expires`),
  KEY `user_client_index` (`user_id`(191),`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `oauth_refresh_tokens` WRITE;
/*!40000 ALTER TABLE `oauth_refresh_tokens` DISABLE KEYS */;

INSERT INTO `oauth_refresh_tokens` (`refresh_token`, `client_id`, `user_id`, `expires`, `scope`)
VALUES
	('08c241ce8eb8d50360aaf9f697047dd1a119208b','test_key','24','2017-11-30 20:32:25',NULL),
	('09ff96d1f5af80ca5f40bc0b39ce4ff0335bbf71','test_key','39','2017-10-24 19:40:46',NULL),
	('1a3d23509901b2283f03c525befece7c1adf7b26','test_key','1','2017-10-28 14:22:57',NULL),
	('1fde07fc120ee95e6e9075d3368703e76c310cdd','test_key','2','2017-10-11 14:55:41',NULL),
	('24dc6e1a930faa3c2f743eb7625929644c45d96a','test_key','28','2017-10-21 09:27:57',NULL),
	('2af881117c06f7c361f8bfa51704f4b9b8266e2a','test_key','27','2017-12-02 06:20:18',NULL),
	('505ec50d742041c2ae38ed35faa3206079817cb5','test_key','2','2017-10-11 14:39:15',NULL),
	('5240c1248de614bae17bf4471aabe3d88c635b98','test_key','50','2017-10-27 10:20:03',NULL),
	('590071d67d920244ede829d48dcce5bf34d9650f','test_key','30','2017-12-04 08:54:41',NULL),
	('5c6f341960de8d75cfa705ec36f6c2bb544271d3','test_key','25','2017-11-30 20:33:25',NULL),
	('5f2fc8af8a19be8ba87af12668fb5dac5c44667b','test_key','33','2017-10-23 08:33:33',NULL),
	('6553dd407ae6996d1b382b716c826aa3dc632349','test_key','26','2017-10-15 21:37:27',NULL),
	('665422291a0d8e013cec58bd0f0488dea5eb2b20','test_key','2','2017-10-11 12:31:56',NULL),
	('66634ed95af6282648c657a0570afe61b9b26dc4','test_key','2','2017-10-06 07:53:29',NULL),
	('677d1866543f624eadc349f293b0205ccf258bc0','test_key','31','2017-12-04 08:55:54',NULL),
	('857208a782e806ad834bc18d84152f054e105fb7','test_key','2','2017-10-11 15:29:27',NULL),
	('86c2696628550f377b1229fbaeec691c630dfaec','test_key','2','2017-10-06 07:59:52',NULL),
	('87725f5bb69dcd90d25f22c428b193ac359d0ee3','test_key','2','2017-10-11 14:34:30',NULL),
	('88055a78e380a48ca237d4b15e73ecf21dbf2d24','test_key','51','2017-10-28 18:02:33',NULL),
	('90a48a7fae8b5905ca543bd2429ad797206f3c42','test_key','34','2017-12-08 08:23:21',NULL),
	('cb95b276e43e88b620242ee0a35ab0ac39b90d19','test_key','21','2017-10-18 10:08:28',NULL),
	('ce02ee867eb4ed83e4fa7fc0ea5bea9ba549665a','test_key','2','2017-10-12 10:22:25',NULL),
	('d5abd517582a2cc860bdcf5c96759b9d1a17c3fa','test_key','2','2017-10-11 15:21:54',NULL),
	('d62f28795fd72d94d4170c0b7eca45e93d3154b2','test_key','2','2017-10-11 14:30:31',NULL),
	('da2ba3ea15d2152a2f0094b06d82468d7fd4a56f','test_key','32','2017-12-04 16:51:39',NULL),
	('dbec61ba2b26661017b1545fafc4c89c2b82396a','test_key','2','2017-10-11 12:28:50',NULL),
	('e2b02007b0825fda78111f10465fd083ca9911da','test_key','2','2017-10-30 08:51:36',NULL),
	('e8f66fad81881d3192732755dca43da811a37a21','test_key','2','2017-10-11 14:57:19',NULL),
	('ef0a0449dc7f15074852707f6be2936dd4c03dae','test_key','2','2017-10-11 14:44:26',NULL),
	('f40adf64d01701ba8e56b261ff66e98dc92c8209','test_key','35','2017-10-26 15:55:47',NULL),
	('f593965d45a0a182ee2a28e9bdfd73322e1cb420','test_key','2','2017-10-11 15:16:48',NULL),
	('f675bec4fbca468e3aef30c83ae4ce0a3019cfa4','test_key','29','2017-12-04 08:50:34',NULL),
	('fda7956ab163435dcae4393574fbb25dc6ea066f','test_key','2','2017-10-11 15:25:04',NULL);

/*!40000 ALTER TABLE `oauth_refresh_tokens` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table phinxlog
# ------------------------------------------------------------

DROP TABLE IF EXISTS `phinxlog`;

CREATE TABLE `phinxlog` (
  `version` bigint(20) NOT NULL,
  `migration_name` varchar(100) DEFAULT NULL,
  `start_time` timestamp NULL DEFAULT NULL,
  `end_time` timestamp NULL DEFAULT NULL,
  `breakpoint` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `phinxlog` WRITE;
/*!40000 ALTER TABLE `phinxlog` DISABLE KEYS */;

INSERT INTO `phinxlog` (`version`, `migration_name`, `start_time`, `end_time`, `breakpoint`)
VALUES
	(20171019033919,'ChallengeCardImage','2017-12-12 20:37:21','2017-12-12 20:37:21',0),
	(20171127173212,'UserKidProfileImage','2017-12-12 20:37:21','2017-12-12 20:37:21',0),
	(20171127182919,'UserFollowers','2017-12-12 20:37:21','2017-12-12 20:37:21',0),
	(20171129000851,'UserFavoriteChallenges','2017-12-12 20:37:21','2017-12-12 20:37:21',0),
	(20171130161923,'UserProfileCoverImage','2017-12-12 20:37:21','2017-12-12 20:37:21',0),
	(20171203174019,'ResponseCreatedTimestamp','2017-12-12 20:37:21','2017-12-12 20:37:21',0),
	(20171206035836,'ResponseDescription','2017-12-12 20:37:21','2017-12-12 20:37:21',0),
	(20171211162030,'MentorAsUser','2017-12-12 20:37:21','2017-12-12 20:37:21',0);

/*!40000 ALTER TABLE `phinxlog` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table response
# ------------------------------------------------------------

DROP TABLE IF EXISTS `response`;

CREATE TABLE `response` (
  `response_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `challenge_id` int(11) NOT NULL,
  `video_id` int(11) NOT NULL,
  `description` varchar(1028) DEFAULT NULL,
  `status` enum('active','hidden') NOT NULL DEFAULT 'active',
  `created_ts` datetime NOT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`response_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `response` WRITE;
/*!40000 ALTER TABLE `response` DISABLE KEYS */;

INSERT INTO `response` (`response_id`, `user_id`, `challenge_id`, `video_id`, `description`, `status`, `created_ts`, `updated_ts`)
VALUES
	(1,2,1,3,NULL,'active','0000-00-00 00:00:00','2017-10-07 11:02:20'),
	(2,40,3,6,NULL,'active','0000-00-00 00:00:00','2017-10-10 10:11:58'),
	(3,42,3,7,NULL,'active','0000-00-00 00:00:00','2017-10-10 10:12:53'),
	(4,43,3,8,NULL,'active','0000-00-00 00:00:00','2017-10-10 10:13:02'),
	(5,44,3,9,NULL,'active','0000-00-00 00:00:00','2017-10-10 10:13:31'),
	(6,45,3,10,NULL,'active','0000-00-00 00:00:00','2017-10-10 10:13:41'),
	(7,46,3,11,NULL,'active','0000-00-00 00:00:00','2017-10-10 10:13:51'),
	(8,47,3,12,NULL,'active','0000-00-00 00:00:00','2017-10-10 10:14:00'),
	(9,48,3,13,NULL,'active','0000-00-00 00:00:00','2017-10-10 10:14:10'),
	(10,49,3,14,NULL,'active','0000-00-00 00:00:00','2017-10-10 10:14:19'),
	(11,50,2,16,NULL,'active','0000-00-00 00:00:00','2017-10-13 00:33:21');

/*!40000 ALTER TABLE `response` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table response_badge
# ------------------------------------------------------------

DROP TABLE IF EXISTS `response_badge`;

CREATE TABLE `response_badge` (
  `response_id` int(11) unsigned NOT NULL,
  `badge_id` int(11) unsigned NOT NULL,
  `user_id` int(11) unsigned NOT NULL,
  `created_ts` datetime NOT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`response_id`,`badge_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `response_badge` WRITE;
/*!40000 ALTER TABLE `response_badge` DISABLE KEYS */;

INSERT INTO `response_badge` (`response_id`, `badge_id`, `user_id`, `created_ts`, `updated_ts`)
VALUES
	(1,2,1,'2017-10-13 00:32:12','2017-10-13 00:32:12'),
	(1,3,1,'2017-10-13 00:32:10','2017-10-13 00:32:10'),
	(3,1,1,'2017-10-13 00:23:10','2017-10-13 00:23:10'),
	(3,2,1,'2017-10-13 00:23:13','2017-10-13 00:23:13'),
	(3,3,1,'2017-10-13 00:23:12','2017-10-13 00:23:12');

/*!40000 ALTER TABLE `response_badge` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table response_tags
# ------------------------------------------------------------

DROP TABLE IF EXISTS `response_tags`;

CREATE TABLE `response_tags` (
  `response_id` int(11) unsigned NOT NULL,
  `tag_id` int(11) NOT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`response_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `response_tags` WRITE;
/*!40000 ALTER TABLE `response_tags` DISABLE KEYS */;

INSERT INTO `response_tags` (`response_id`, `tag_id`, `updated_ts`)
VALUES
	(1,4,'2017-10-07 11:02:20'),
	(11,6,'2017-10-13 00:33:21');

/*!40000 ALTER TABLE `response_tags` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table tag
# ------------------------------------------------------------

DROP TABLE IF EXISTS `tag`;

CREATE TABLE `tag` (
  `tag_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `type` enum('predefined','user') NOT NULL DEFAULT 'user',
  `name` varchar(255) NOT NULL DEFAULT '',
  `created_ts` datetime NOT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `tag` WRITE;
/*!40000 ALTER TABLE `tag` DISABLE KEYS */;

INSERT INTO `tag` (`tag_id`, `type`, `name`, `created_ts`, `updated_ts`)
VALUES
	(1,'user','art','2017-09-25 09:35:48','2017-09-25 09:35:48'),
	(2,'user','cool','2017-09-25 09:41:55','2017-09-25 09:41:55'),
	(3,'user','thisisdope','2017-09-25 09:41:55','2017-09-25 09:41:55'),
	(4,'user','test','2017-10-07 11:02:20','2017-10-07 11:02:20'),
	(5,'predefined','costume','2017-10-10 15:57:00','2017-10-10 15:57:00'),
	(6,'user','#video','2017-10-13 00:33:21','2017-10-13 00:33:21');

/*!40000 ALTER TABLE `tag` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_type` enum('kid','parent','mentor') NOT NULL DEFAULT 'kid',
  `username` varchar(20) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  `status` enum('active','deleted') NOT NULL DEFAULT 'active',
  `registered_ts` datetime NOT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;

INSERT INTO `user` (`user_id`, `user_type`, `username`, `password`, `status`, `registered_ts`, `updated_ts`)
VALUES
	(1,'kid','shawn_kid','098f6bcd4621d373cade4e832627b4f6','active','2017-09-12 13:45:09','2017-09-25 09:30:07'),
	(2,'kid','mcgraw','81dc9bdb52d04dc20036dbd8313ed055','active','2017-09-20 13:41:45','2017-10-03 13:48:39'),
	(3,'kid','mcgrawparent','81dc9bdb52d04dc20036dbd8313ed055','active','2017-09-20 14:04:04','2017-09-20 14:04:04'),
	(4,'kid','testuser','e034fb6b66aacc1d48f445ddfb08da98','active','2017-09-27 13:21:41','2017-09-27 13:21:41'),
	(5,'kid','testuser357843','81dc9bdb52d04dc20036dbd8313ed055','active','2017-09-27 13:25:50','2017-09-27 13:25:50'),
	(7,'kid','testmav','81dc9bdb52d04dc20036dbd8313ed055','active','2017-09-28 08:35:57','2017-09-28 08:35:57'),
	(8,'kid','testmav12354','81dc9bdb52d04dc20036dbd8313ed055','active','2017-09-28 08:38:47','2017-09-28 08:38:47'),
	(9,'kid','testparentmav','81dc9bdb52d04dc20036dbd8313ed055','active','2017-09-28 08:55:34','2017-09-28 08:55:34'),
	(11,'kid','dmcgraw','81dc9bdb52d04dc20036dbd8313ed055','active','2017-09-28 11:35:38','2017-09-28 11:35:38'),
	(12,'kid','Cory','ac1c8d64fd23ae5a7eac5b7f7ffee1fa','active','2017-09-28 15:28:57','2017-09-28 15:28:57'),
	(13,'kid','nsantoyo','da1516eae52f1ba5c8cd65fa1bf8dc9a','deleted','2017-09-28 22:30:48','2017-09-28 22:30:48'),
	(14,'kid','kasey','04282d9922258bf1b152e6f8e1f281e8','active','2017-09-29 16:16:43','2017-09-29 16:16:43'),
	(21,'parent','shah-test-parent','80338e79d2ca9b9c090ebaaa2ef293c7','active','2017-10-01 21:07:34','2017-10-01 21:26:23'),
	(22,'parent','shah-test-parent-2','80338e79d2ca9b9c090ebaaa2ef293c7','active','2017-10-01 21:30:50','2017-10-01 21:34:00'),
	(24,'parent','shah-test-parent-3','80338e79d2ca9b9c090ebaaa2ef293c7','active','2017-10-01 21:32:25','2017-10-01 21:34:03'),
	(25,'parent','shah-test-parent-4','80338e79d2ca9b9c090ebaaa2ef293c7','active','2017-10-01 21:33:25','2017-10-01 21:34:08'),
	(26,'parent','shah-test-parent-5','80338e79d2ca9b9c090ebaaa2ef293c7','deleted','2017-10-01 21:34:22','2017-10-01 21:34:22'),
	(27,'kid','mcgrawtesttest','81dc9bdb52d04dc20036dbd8313ed055','active','2017-10-03 07:20:18','2017-10-03 07:20:18'),
	(28,'kid','normatest1','da1516eae52f1ba5c8cd65fa1bf8dc9a','deleted','2017-10-03 20:29:02','2017-10-03 20:29:02'),
	(29,'kid','shawn_parent3','e16b2ab8d12314bf4efbd6203906ea6c','active','2017-10-05 09:50:33','2017-10-05 09:54:27'),
	(30,'kid','shawn_parent4','e16b2ab8d12314bf4efbd6203906ea6c','active','2017-10-05 09:54:41','2017-10-05 09:55:49'),
	(31,'kid','shawn_parent2','e16b2ab8d12314bf4efbd6203906ea6c','active','2017-10-05 09:55:54','2017-10-05 09:55:54'),
	(32,'kid','eldub2001','4cb9c8a8048fd02294477fcb1a41191a','active','2017-10-05 17:51:39','2017-10-05 17:51:39'),
	(33,'kid','ntest1','e32f9e9ee14b2faa16986c56b5bbc46c','active','2017-10-07 17:11:35','2017-10-07 17:11:35'),
	(34,'kid','mcgrawtesttest4','81dc9bdb52d04dc20036dbd8313ed055','active','2017-10-09 09:23:21','2017-10-09 09:23:21'),
	(35,'kid','kasey_m','70c39409de7426359f15a12c011b359b','active','2017-10-09 09:23:59','2017-10-09 09:23:59'),
	(39,'kid','norma','da1516eae52f1ba5c8cd65fa1bf8dc9a','active','2017-10-09 22:43:52','2017-10-09 22:43:52'),
	(40,'kid','samplekid1','098f6bcd4621d373cade4e832627b4f6','active','2017-10-10 10:04:24','2017-10-10 10:04:24'),
	(42,'kid','samplekid2','098f6bcd4621d373cade4e832627b4f6','active','2017-10-10 10:05:51','2017-10-10 10:05:51'),
	(43,'kid','samplekid3','098f6bcd4621d373cade4e832627b4f6','active','2017-10-10 10:07:39','2017-10-10 10:07:39'),
	(44,'kid','samplekid4','098f6bcd4621d373cade4e832627b4f6','active','2017-10-10 10:08:27','2017-10-10 10:08:27'),
	(45,'kid','samplekid5','098f6bcd4621d373cade4e832627b4f6','active','2017-10-10 10:08:40','2017-10-10 10:08:40'),
	(46,'kid','samplekid6','098f6bcd4621d373cade4e832627b4f6','active','2017-10-10 10:08:46','2017-10-10 10:08:46'),
	(47,'kid','samplekid7','098f6bcd4621d373cade4e832627b4f6','active','2017-10-10 10:08:51','2017-10-10 10:08:51'),
	(48,'kid','samplekid8','098f6bcd4621d373cade4e832627b4f6','active','2017-10-10 10:08:57','2017-10-10 10:08:57'),
	(49,'kid','samplekid9','098f6bcd4621d373cade4e832627b4f6','active','2017-10-10 10:09:02','2017-10-10 10:09:02'),
	(50,'kid','nstest','e32f9e9ee14b2faa16986c56b5bbc46c','active','2017-10-13 00:22:10','2017-10-13 00:22:10'),
	(51,'kid','ssddd','8896975a3700267dad5ed6de568bcc42','active','2017-10-14 02:58:41','2017-10-14 02:58:41'),
	(52,'parent','shawn_parent','098f6bcd4621d373cade4e832627b4f6','active','2017-10-14 16:26:53','2017-10-14 16:26:53'),
	(53,'mentor','ada_lovelace','cc03e747a6afbbcbf8be7668acfebee5','active','2017-12-12 20:41:56','2017-12-13 04:41:56'),
	(54,'mentor','tanya_mann','cc03e747a6afbbcbf8be7668acfebee5','active','2017-12-12 20:41:56','2017-12-13 04:41:56'),
	(55,'mentor','shawn_robinson','cc03e747a6afbbcbf8be7668acfebee5','active','2017-12-12 20:41:56','2017-12-13 04:41:56'),
	(56,'mentor','adam_savage','cc03e747a6afbbcbf8be7668acfebee5','active','2017-12-12 20:41:56','2017-12-13 04:41:56'),
	(57,'mentor','jill_sobule','cc03e747a6afbbcbf8be7668acfebee5','active','2017-12-12 20:41:56','2017-12-13 04:41:56'),
	(58,'mentor','derreck_kayongo','cc03e747a6afbbcbf8be7668acfebee5','active','2017-12-12 20:41:56','2017-12-13 04:41:56');

/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table user_favorite_challenges
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_favorite_challenges`;

CREATE TABLE `user_favorite_challenges` (
  `user_id` int(11) unsigned NOT NULL,
  `challenge_id` int(11) unsigned NOT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`challenge_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



# Dump of table user_following_users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_following_users`;

CREATE TABLE `user_following_users` (
  `user_id` int(11) unsigned NOT NULL,
  `following_user_id` int(11) unsigned NOT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`following_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



# Dump of table user_kid
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_kid`;

CREATE TABLE `user_kid` (
  `user_id` int(11) unsigned NOT NULL,
  `parent_email_address` varchar(255) NOT NULL DEFAULT '',
  `profile_image_id` int(11) DEFAULT NULL,
  `profile_cover_image_id` int(11) DEFAULT NULL,
  `bio` varchar(1028) DEFAULT NULL,
  `num_badges_received` int(11) DEFAULT NULL,
  `num_badges_given` int(11) DEFAULT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `user_kid` WRITE;
/*!40000 ALTER TABLE `user_kid` DISABLE KEYS */;

INSERT INTO `user_kid` (`user_id`, `parent_email_address`, `profile_image_id`, `profile_cover_image_id`, `bio`, `num_badges_received`, `num_badges_given`, `updated_ts`)
VALUES
	(1,'shawn+parent@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-09-20 12:05:48'),
	(2,'mom@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-09-20 13:41:45'),
	(7,'deleteme@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-09-28 08:35:57'),
	(8,'deletemetoo@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-09-28 08:38:47'),
	(12,'cory@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-09-28 15:28:57'),
	(13,'norma.a.garcia@gmail.com',NULL,NULL,NULL,NULL,NULL,'2017-09-28 22:30:48'),
	(14,'kasey@atypicalart.com',NULL,NULL,NULL,NULL,NULL,'2017-09-29 16:16:43'),
	(27,'dmcgraw@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-03 07:20:18'),
	(28,'norma.a.garcia@gmail.com',NULL,NULL,NULL,NULL,NULL,'2017-10-03 20:29:02'),
	(29,'shawnparent2@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-05 09:50:33'),
	(30,'shawnparent2@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-05 09:54:41'),
	(31,'shawnparent2@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-05 09:55:54'),
	(32,'luke@eldub.com',NULL,NULL,NULL,NULL,NULL,'2017-10-05 17:51:39'),
	(33,'norma.a.garcia@gmail.com',NULL,NULL,NULL,NULL,NULL,'2017-10-07 17:11:35'),
	(34,'dmcgraw@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-09 09:23:21'),
	(35,'kasey@atypicalart.com',NULL,NULL,NULL,NULL,NULL,'2017-10-09 09:23:59'),
	(39,'norma.a.garcia@gmail.com',NULL,NULL,NULL,NULL,NULL,'2017-10-09 22:43:52'),
	(40,'shawn+samplekid1@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-10 10:05:32'),
	(42,'shawn+samplekid2@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-10 10:06:18'),
	(43,'shawn+samplekid3@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-10 10:07:55'),
	(44,'shawn+samplekid4@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-10 10:08:27'),
	(45,'shawn+samplekid5@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-10 10:08:40'),
	(46,'shawn+samplekid6@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-10 10:08:46'),
	(47,'shawn+samplekid7@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-10 10:08:51'),
	(48,'shawn+samplekid8@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-10 10:08:57'),
	(49,'shawn+samplekid9@slytrunk.com',NULL,NULL,NULL,NULL,NULL,'2017-10-10 10:09:02'),
	(50,'norma.a.garcia@gmail.com',NULL,NULL,NULL,NULL,NULL,'2017-10-13 00:22:10'),
	(51,'ffff@gg.com',NULL,NULL,NULL,NULL,NULL,'2017-10-14 02:58:41');

/*!40000 ALTER TABLE `user_kid` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table user_mentor
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_mentor`;

CREATE TABLE `user_mentor` (
  `user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `short_description` varchar(255) DEFAULT NULL,
  `bio` varchar(1028) DEFAULT NULL,
  `profile_image_id` int(11) DEFAULT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `user_mentor` WRITE;
/*!40000 ALTER TABLE `user_mentor` DISABLE KEYS */;

INSERT INTO `user_mentor` (`user_id`, `first_name`, `last_name`, `short_description`, `bio`, `profile_image_id`, `updated_ts`)
VALUES
	(53,'Ada','Lovelace','Short Description Here',NULL,NULL,'2017-12-13 04:41:56'),
	(54,'Tanya','Mann',NULL,NULL,NULL,'2017-12-13 04:41:56'),
	(55,'Shawn','Robinson',NULL,NULL,7,'2017-12-13 04:41:56'),
	(56,'Adam','Savage',NULL,NULL,NULL,'2017-12-13 04:41:56'),
	(57,'Jill','Sobule',NULL,NULL,NULL,'2017-12-13 04:41:56'),
	(58,'Derreck','Kayongo',NULL,NULL,NULL,'2017-12-13 04:41:56');

/*!40000 ALTER TABLE `user_mentor` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table user_parent
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_parent`;

CREATE TABLE `user_parent` (
  `user_id` int(11) unsigned NOT NULL,
  `email_address` varchar(255) DEFAULT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `user_parent` WRITE;
/*!40000 ALTER TABLE `user_parent` DISABLE KEYS */;

INSERT INTO `user_parent` (`user_id`, `email_address`, `updated_ts`)
VALUES
	(3,'mom@slytrunk.com','2017-09-20 14:04:04'),
	(4,'test@slytrunk.com','2017-09-27 13:21:41'),
	(5,'test14678@slytrunk.com','2017-09-27 13:25:50'),
	(9,'deleteme234234@slytrunk.com','2017-09-28 08:55:34'),
	(11,'dmcgraw@slytrunk.com','2017-09-28 11:35:38'),
	(21,'shah@slytrunk.com','2017-10-01 21:07:34'),
	(22,'shah+parent2@slytrunk.com','2017-10-01 21:30:50'),
	(24,'shah+parent3@slytrunk.com','2017-10-01 21:32:25'),
	(25,'shah+parent4@slytrunk.com','2017-10-01 21:33:26'),
	(26,'shah+parent5@slytrunk.com','2017-10-01 21:34:22'),
	(52,'shawn+parent@slytrunk.com','2017-10-14 16:37:35');

/*!40000 ALTER TABLE `user_parent` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table video
# ------------------------------------------------------------

DROP TABLE IF EXISTS `video`;

CREATE TABLE `video` (
  `video_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) NOT NULL DEFAULT '',
  `thumbnail_url` varchar(255) DEFAULT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`video_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOCK TABLES `video` WRITE;
/*!40000 ALTER TABLE `video` DISABLE KEYS */;

INSERT INTO `video` (`video_id`, `filename`, `thumbnail_url`, `updated_ts`)
VALUES
	(1,'challenge-1-4856e11e2c6e4e5997c8e323c7a84c92.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/challenge-1-4856e11e2c6e4e5997c8e323c7a84c92-thumbnail-00001.jpg','2017-10-05 14:44:29'),
	(2,'challenge-2-ae0872917c79897811a62f998f9f0504.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/challenge-2-ae0872917c79897811a62f998f9f0504-thumbnail-00001.jpg','2017-10-05 14:44:32'),
	(3,'iOS_video_908DD87A-1377-44A0-B57C-DB72C5672ECE_1507399335.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/iOS_video_908DD87A-1377-44A0-B57C-DB72C5672ECE_1507399335-thumbnail-00001.jpg','2017-10-07 11:02:20'),
	(4,'challenge-2-7d255d9831d98738780fddae600c2de5.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/challenge-2-7d255d9831d98738780fddae600c2de5-thumbnail-00001.jpg','2017-10-08 08:28:23'),
	(5,'challenge-3-eab3e4da060d7f8b5ebbce485018854a.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/challenge-3-eab3e4da060d7f8b5ebbce485018854a-thumbnail-00001.jpg','2017-10-09 22:30:26'),
	(6,'response-sample1-480.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/response-sample1-480-thumbnail-00001.jpg','2017-10-10 10:11:58'),
	(7,'response-sample2-480.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/response-sample2-480-thumbnail-00001.jpg','2017-10-10 10:12:53'),
	(8,'response-sample3-480.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/response-sample3-480-thumbnail-00001.jpg','2017-10-10 10:13:02'),
	(9,'response-sample4-480.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/response-sample4-480-thumbnail-00001.jpg','2017-10-10 10:13:31'),
	(10,'response-sample5-480.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/response-sample5-480-thumbnail-00001.jpg','2017-10-10 10:13:41'),
	(11,'response-sample6-480.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/response-sample6-480-thumbnail-00001.jpg','2017-10-10 10:13:51'),
	(12,'response-sample7-480.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/response-sample7-480-thumbnail-00001.jpg','2017-10-10 10:14:00'),
	(13,'response-sample8-480.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/response-sample8-480-thumbnail-00001.jpg','2017-10-10 10:14:10'),
	(14,'response-sample9-480.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/response-sample9-480-thumbnail-00001.jpg','2017-10-10 10:14:19'),
	(15,'challenge-1-2c74df48e1ba27e1a50f2c7430e47973.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/challenge-1-2c74df48e1ba27e1a50f2c7430e47973-thumbnail-00001.jpg','2017-10-11 21:38:57'),
	(16,'iOS_video_A5F7A693-9845-4644-B787-802FBF618E92_1507879999.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/iOS_video_A5F7A693-9845-4644-B787-802FBF618E92_1507879999-thumbnail-00001.jpg','2017-10-13 00:33:21'),
	(17,'iOS_video_D0F0EDB1-B26C-49BE-86ED-A4B3550B044D_1508009529.mp4','https://s3.amazonaws.com/bemaverick-output-videos-thumbnails/iOS_video_D0F0EDB1-B26C-49BE-86ED-A4B3550B044D_1508009529-thumbnail-00001.jpg','2017-10-14 12:32:10');

/*!40000 ALTER TABLE `video` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
