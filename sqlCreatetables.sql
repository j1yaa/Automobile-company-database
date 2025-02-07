-- Course: CSCE 4350.501 - 11546 Fundamentals of Database Systems
-- Team1:	Diana Pappe Casco
-- 	Jiya Singh
-- 	Colton Pulliam
-- Assignment: Group Project

CREATE TABLE `Assembler` (
  `VIN` varchar(17) NOT NULL,
  `AssemblerID` int NOT NULL AUTO_INCREMENT,
  `PartInventoryID` varchar(15) NOT NULL,
  PRIMARY KEY (`AssemblerID`),
  UNIQUE KEY `AssemblerID_UNIQUE` (`AssemblerID`)
) ENGINE=InnoDB AUTO_INCREMENT=5074 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Brand` (
  `BrandId` varchar(5) NOT NULL,
  `BrandName` varchar(45) NOT NULL,
  `ManufacturerId` varchar(5) NOT NULL,
  PRIMARY KEY (`BrandId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Customer` (
  `CustomerID` int NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(15) NOT NULL,
  `LastName` varchar(30) NOT NULL,
  `Address1` varchar(45) NOT NULL,
  `Address2` varchar(45) DEFAULT NULL,
  `City` varchar(30) NOT NULL,
  `State` varchar(2) DEFAULT NULL,
  `Country` varchar(3) NOT NULL,
  `Phone` varchar(15) NOT NULL,
  `Gender` varchar(15) NOT NULL,
  `Income` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`CustomerID`),
  UNIQUE KEY `CustomerID_UNIQUE` (`CustomerID`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Dealer` (
  `DealerID` varchar(5) NOT NULL,
  `Name` varchar(50) NOT NULL,
  `Address1` varchar(45) NOT NULL,
  `Address2` varchar(45) DEFAULT NULL,
  `City` varchar(30) NOT NULL,
  `State` varchar(2) DEFAULT NULL,
  `Country` varchar(3) NOT NULL,
  `Phone` varchar(15) NOT NULL,
  PRIMARY KEY (`DealerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `DealerInventory` (
  `VIN` varchar(17) NOT NULL,
  `DealerId` varchar(5) NOT NULL,
  `VehicleStatus` varchar(1) NOT NULL DEFAULT 'I',
  `InsertDate` date NOT NULL,
  PRIMARY KEY (`VIN`),
  UNIQUE KEY `DealerBrand` (`DealerId`,`VIN`),
  UNIQUE KEY `VIN_UNIQUE` (`VIN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `Manufacturer` (
  `ManufacturerId` varchar(5) NOT NULL,
  `MName` varchar(50) NOT NULL,
  `Address1` varchar(45) NOT NULL,
  `Address2` varchar(45) DEFAULT NULL,
  `City` varchar(30) NOT NULL,
  `State` varchar(2) DEFAULT NULL,
  `Country` varchar(3) NOT NULL,
  `Phone` varchar(15) NOT NULL,
  `CompanyOwned` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ManufacturerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `Model` (
  `BrandId` varchar(5) NOT NULL,
  `ModelId` varchar(20) NOT NULL,
  `ModelName` varchar(45) NOT NULL,
  `BodyStyle` varchar(45) NOT NULL,
  PRIMARY KEY (`BrandId`,`ModelId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `ModelPart` (
  `BrandId` varchar(5) NOT NULL,
  `ModelId` varchar(20) NOT NULL,
  `PartNumber` varchar(15) NOT NULL,
  PRIMARY KEY (`ModelId`,`PartNumber`,`BrandId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `Parts` (
  `PartNumber` varchar(15) NOT NULL,
  `Name` varchar(50) NOT NULL,
  `Type` varchar(15) NOT NULL,
  `Price` decimal(11,2) NOT NULL,
  `Stock` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`PartNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `PartsInventory` (
  `PartInventoryId` varchar(15) NOT NULL,
  `SuplierId` int NOT NULL,
  `PartNumber` varchar(15) NOT NULL,
  `SupplierPartNumber` varchar(20) NOT NULL,
  `ProductionDate` date NOT NULL,
  `SuppliedDate` date NOT NULL,
  `WarrantyDate` date DEFAULT NULL,
  `Status` varchar(1) NOT NULL DEFAULT 'I',
  PRIMARY KEY (`PartInventoryId`),
  UNIQUE KEY `PartInventoryId_UNIQUE` (`PartInventoryId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `Sales` (
  `SaleNumber` int NOT NULL AUTO_INCREMENT,
  `DealerId` varchar(5) NOT NULL,
  `SaleType` varchar(1) NOT NULL,
  `CustomerId` int NOT NULL,
  `SaleDate` datetime NOT NULL,
  `GrandTotal` decimal(11,2) NOT NULL,
  `TotalTax` decimal(11,2) NOT NULL,
  `TotalProducts` int NOT NULL,
  `Week` int NOT NULL,
  PRIMARY KEY (`SaleNumber`),
  UNIQUE KEY `SaleNumber_UNIQUE` (`SaleNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=1361 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `SalesPart` (
  `SaleNumber` int NOT NULL,
  `SaleLine` int NOT NULL,
  `PartInventoryID` varchar(15) NOT NULL,
  `Quantity` int NOT NULL,
  `Price` decimal(11,2) NOT NULL,
  `TaxPercentage` decimal(5,2) NOT NULL,
  `TaxAmount` decimal(11,2) NOT NULL,
  `Total` decimal(11,2) NOT NULL,
  PRIMARY KEY (`SaleNumber`,`SaleLine`),
  UNIQUE KEY `PUniq` (`SaleNumber`,`SaleLine`) /*!80000 INVISIBLE */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `SalesVehicle` (
  `SaleNumber` int NOT NULL,
  `SaleLine` int NOT NULL,
  `VIN` varchar(17) NOT NULL,
  `Price` decimal(11,2) NOT NULL,
  `TaxPercentage` decimal(5,2) NOT NULL,
  `TaxAmount` decimal(11,2) NOT NULL,
  `Total` decimal(11,2) NOT NULL,
  PRIMARY KEY (`SaleNumber`,`SaleLine`),
  UNIQUE KEY `PUniq` (`SaleNumber`,`SaleLine`) /*!80000 INVISIBLE */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `Supplier` (
  `SupplierId` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) NOT NULL,
  `Address1` varchar(45) NOT NULL,
  `Address2` varchar(45) DEFAULT NULL,
  `City` varchar(30) NOT NULL,
  `State` varchar(2) DEFAULT NULL,
  `Country` varchar(3) NOT NULL,
  `Phone` varchar(15) NOT NULL,
  `CompanyOwned` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`SupplierId`),
  UNIQUE KEY `SupplierId_UNIQUE` (`SupplierId`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `Vehicle` (
  `VIN` varchar(17) NOT NULL,
  `BrandID` varchar(5) NOT NULL,
  `ModelId` varchar(20) NOT NULL,
  `AssembleDate` date NOT NULL,
  `Color` varchar(15) NOT NULL,
  `ManufacturerId` varchar(5) NOT NULL,
  PRIMARY KEY (`VIN`),
  UNIQUE KEY `VIN_UNIQUE` (`VIN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 



