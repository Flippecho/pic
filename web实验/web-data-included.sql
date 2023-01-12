-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: web
-- ------------------------------------------------------
-- Server version	8.0.31

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `pv`
--

DROP TABLE IF EXISTS `pv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pv` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `figure` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pv`
--

LOCK TABLES `pv` WRITE;
/*!40000 ALTER TABLE `pv` DISABLE KEYS */;
INSERT INTO `pv` VALUES (1,1251);
/*!40000 ALTER TABLE `pv` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resume`
--

DROP TABLE IF EXISTS `resume`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resume` (
  `id` int NOT NULL,
  `content` text NOT NULL,
  UNIQUE KEY `id` (`id`),
  CONSTRAINT `resume_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resume`
--

LOCK TABLES `resume` WRITE;
/*!40000 ALTER TABLE `resume` DISABLE KEYS */;
INSERT INTO `resume` VALUES (3,'{\"basicInfo\":{\"name\":\"Steven\",\"position\":\"全栈工程师\",\"contacts\":{\"telephone\":\"1-(707)-733-6644\",\"email\":\"baluth@outlook.com\",\"github\":\"github.com/Flippecho\",\"wechat\":\"zyf929233\"}},\"education\":[{\"start\":\"2020.07\",\"end\":\"2024.06\",\"school\":\"中南大学\",\"major\":\"计算机科学与技术\",\"courses\":\"数据结构、算法分析与设计、计算机组成原理与汇编、操作系统、数据库原理、计算机网络、软件工程。\"}],\"work\":[{\"start\":\"2027.04\",\"end\":\"至今\",\"company\":\"广州日顺信息科技有限公司\",\"position\":\"产品经理\",\"content\":[\"团队管理，电商产品管理，电子商务策划项目管理。\",\"网站需求分析，产品设计，产品跟踪，及后续产品优化工作。\",\"与研发、营销、客服配合，展开产品开发、销售、售后工作。\",\"产品应用市场调研和分析。\"]},{\"start\":\"2025.03\",\"end\":\"2027.03\",\"company\":\"广州三合信息科技有限公司\",\"position\":\"软件工程师\",\"content\":[\"负责公司内部业务系统的设计及改进，参与网上商城产品功能设计实施。\",\"负责客户调研、客户需求分析、方案写作等工作，参与公司多个大型电子商务项目的策划工作，担任大商集团网上商城一期建设项目经理。\"]}],\"project\":[{\"start\":\"2028.05\",\"end\":\"2028.11\",\"project\":\"石市通客户端开发\",\"content\":[\"石市通为广东某公司委托开发一款类似 58同城 APP，主要运用于 IOS 和 Android 平台，功能涉及跳蚤市场，在线促销，团购，会员积分，在线求职，同城活动，等十二大模块。\"]},{\"start\":\"2027.06\",\"end\":\"2027.12\",\"project\":\"宝康人力资源管理系统\",\"content\":[\"《宝康人力资源管理系统》为一款应用于PC下的人力资源管理系统，运行环境为Windows all，其主要功能有员工信息、系统留言、员工联系方式、员工风采、区域管理、部门管理、客户资料、工作调度、系统管理等功能。\"]}],\"assessment\":[\"深度互联网从业人员，对互联网保持高度的敏感性和关注度，熟悉产品开发流程，有很强的产品规划、需求分析、交互设计能力，能独立承担 APP 和 Web 项目的管控工作，善于沟通，贴近用户。\",\"钟情于互联网技术应用，在五年的工作经验当中，通过自身努力从软件开发工程师转型到产品经理，获得了不错的成绩。\"]}');
/*!40000 ALTER TABLE `resume` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(32) NOT NULL,
  `password` varchar(32) NOT NULL,
  `suffix` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'default','qakhBtKhL7CKZrw3egzY',NULL),(2,'baluth','3721','jpg'),(3,'steven','3721','jpg');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-01-12  1:44:49
