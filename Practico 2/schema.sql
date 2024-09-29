DROP DATABASE IF EXISTS world;
CREATE DATABASE IF NOT EXISTS world;

USE world;

CREATE TABLE country (
	Code VARCHAR(255),
	Name VARCHAR(255),
	Continent VARCHAR(255),
	Region VARCHAR(255),
	SurfaceArea INT,
	IndepYear INT,
	Population INT,
	LifeExpectancy INT,
	GNP INT,
	GNPOld INT,
	LocalName VARCHAR(255),
	GovernmentForm VARCHAR(255),
	HeadOfState VARCHAR(255),
	Capital INT,
	Code2 VARCHAR(255),
	
	PRIMARY KEY (Code)
);

CREATE TABLE city (
	ID INT,
	Name VARCHAR(255),
	CountryCode VARCHAR(255),
	District VARCHAR(255),
	Population INT,
	
	PRIMARY KEY (ID),
	FOREIGN KEY (CountryCode) REFERENCES country (Code)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE countrylanguage (
	CountryCode VARCHAR(255),
	Language VARCHAR(255),
	IsOfficial VARCHAR(255),
	Percentage DECIMAL(5, 2),
	
	PRIMARY KEY (CountryCode, Language),
	FOREIGN KEY (CountryCode) REFERENCES country (Code)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	-- Restrictions
	CHECK (Percentage <= 100 AND Percentage >= 0)
);

CREATE TABLE continent(
	Name VARCHAR(255),
	Area INT,
	MassPercentage DECIMAL(5, 2),
	MostPoPulousCity INT,
	
	PRIMARY KEY (Name),
	-- Restrictions
	CHECK (MassPercentage <= 100 AND MassPercentage >= 0)
);

-- Add foreign key to continent
ALTER TABLE continent 
ADD FOREIGN KEY (MostPopulousCity) REFERENCES city (ID);

-- Country must reference continent
ALTER TABLE country
ADD FOREIGN KEY (Continent) REFERENCES continent (Name);

