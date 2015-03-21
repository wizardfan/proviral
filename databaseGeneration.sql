-- MySQL Script generated by MySQL Workbench
-- 02/26/15 02:45:39
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema proviral
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `proviral` ;
CREATE SCHEMA IF NOT EXISTS `proviral` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `proviral` ;

-- -----------------------------------------------------
-- Table `proviral`.`host`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`host` ;

CREATE TABLE IF NOT EXISTS `proviral`.`host` (
  `taxo_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `mnemonic` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`taxo_id`))
ENGINE = InnoDB
COMMENT = 'name is for general name, e.g. Arabidopsis\nmnemonic is for the value after \"_\" in the ID of Uniprot, e.g. ARATH';


-- -----------------------------------------------------
-- Table `proviral`.`virus`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`virus` ;

CREATE TABLE IF NOT EXISTS `proviral`.`virus` (
  `taxo_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `virus` VARCHAR(255) NOT NULL,
  `subtype` VARCHAR(80) NULL,
  `strain` VARCHAR(80) NULL,
  PRIMARY KEY (`taxo_id`))
ENGINE = InnoDB
COMMENT = 'name for the original description\nvirus is for the virus name\nsubtype of genotyp, serotype, subtype depending on the nature of virus\nstrain is for isolate or strain';


-- -----------------------------------------------------
-- Table `proviral`.`infection`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`infection` ;

CREATE TABLE IF NOT EXISTS `proviral`.`infection` (
  `host_taxo_id` INT NOT NULL,
  `virus_taxo_id` INT NOT NULL,
  PRIMARY KEY (`host_taxo_id`, `virus_taxo_id`),
  CONSTRAINT `fk_infection_host`
    FOREIGN KEY (`host_taxo_id`)
    REFERENCES `proviral`.`host` (`taxo_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_infection_virus`
    FOREIGN KEY (`virus_taxo_id`)
    REFERENCES `proviral`.`virus` (`taxo_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_infection_virus_idx` ON `proviral`.`infection` (`virus_taxo_id` ASC);

CREATE INDEX `fk_infection_host_idx` ON `proviral`.`infection` (`host_taxo_id` ASC);


-- -----------------------------------------------------
-- Table `proviral`.`source`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`source` ;

CREATE TABLE IF NOT EXISTS `proviral`.`source` (
  `source` VARCHAR(45) NOT NULL,
  `version` VARCHAR(45) NOT NULL,
  `reviewed` TINYINT(1) NOT NULL,
  PRIMARY KEY (`source`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `proviral`.`protein`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`protein` ;

CREATE TABLE IF NOT EXISTS `proviral`.`protein` (
  `accession` VARCHAR(45) NOT NULL,
  `id` VARCHAR(45) NOT NULL,
  `host_taxo_id` INT NULL,
  `virus_taxo_id` INT NULL,
  `source` VARCHAR(45) NOT NULL,
  `seq` BLOB NULL,
  PRIMARY KEY (`accession`),
  CONSTRAINT `protein_host_taxo_id`
    FOREIGN KEY (`host_taxo_id`)
    REFERENCES `proviral`.`host` (`taxo_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `protein_virus_taxo_id`
    FOREIGN KEY (`virus_taxo_id`)
    REFERENCES `proviral`.`virus` (`taxo_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `protein_source`
    FOREIGN KEY (`source`)
    REFERENCES `proviral`.`source` (`source`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = 'http://web.expasy.org/docs/userman.html#AC_line\naccession is the uniprot accession\nid is the uniprot id';

CREATE INDEX `protein_host_taxo_id_idx` ON `proviral`.`protein` (`host_taxo_id` ASC);

CREATE INDEX `protein_virus_taxo_id_idx` ON `proviral`.`protein` (`virus_taxo_id` ASC);

CREATE INDEX `protein_source_idx` ON `proviral`.`protein` (`source` ASC);


-- -----------------------------------------------------
-- Table `proviral`.`peptide`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`peptide` ;

CREATE TABLE IF NOT EXISTS `proviral`.`peptide` (
  `seq` VARCHAR(30) NOT NULL,
  `length` INT NOT NULL,
  `hydrophobicity` FLOAT NULL,
  `mz1` FLOAT NULL,
  `mz2` FLOAT NULL,
  `mz3` FLOAT NULL,
  `mz4` FLOAT NULL,
  `detectability` FLOAT NULL,
  PRIMARY KEY (`seq`))
ENGINE = InnoDB;

CREATE INDEX `idx_peptide_mz1` ON `proviral`.`peptide` (`mz1` ASC);

CREATE INDEX `idx_peptide_mz2` ON `proviral`.`peptide` (`mz2` ASC);

CREATE INDEX `idx_peptide_mz3` ON `proviral`.`peptide` (`mz3` ASC);

CREATE INDEX `idx_peptide_mz4` ON `proviral`.`peptide` (`mz4` ASC);

CREATE INDEX `idx_peptide_detect` ON `proviral`.`peptide` (`detectability` ASC);

CREATE INDEX `idx_peptide_hydro` ON `proviral`.`peptide` (`hydrophobicity` ASC);


-- -----------------------------------------------------
-- Table `proviral`.`peptide_existance`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`peptide_existance` ;

CREATE TABLE IF NOT EXISTS `proviral`.`peptide_existance` (
  `peptide_seq` VARCHAR(30) NOT NULL,
  `protein_accession` VARCHAR(45) NOT NULL,
  `count` INT NOT NULL,
  PRIMARY KEY (`peptide_seq`, `protein_accession`),
  CONSTRAINT `fk_peptide_existance_peptide`
    FOREIGN KEY (`peptide_seq`)
    REFERENCES `proviral`.`peptide` (`seq`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_peptide_existance_protein`
    FOREIGN KEY (`protein_accession`)
    REFERENCES `proviral`.`protein` (`accession`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_peptide_has_protein_protein1_idx` ON `proviral`.`peptide_existance` (`protein_accession` ASC);

CREATE INDEX `fk_peptide_has_protein_peptide1_idx` ON `proviral`.`peptide_existance` (`peptide_seq` ASC);


-- -----------------------------------------------------
-- Table `proviral`.`product_ion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`product_ion` ;

CREATE TABLE IF NOT EXISTS `proviral`.`product_ion` (
  `peptide_seq` VARCHAR(30) NOT NULL,
  `type` CHAR NOT NULL,
  `serial` INT NOT NULL,
  `mz` FLOAT NOT NULL,
  PRIMARY KEY (`peptide_seq`, `type`, `serial`),
  CONSTRAINT `fk_product_ion_seq`
    FOREIGN KEY (`peptide_seq`)
    REFERENCES `proviral`.`peptide` (`seq`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `idx_product_mz` ON `proviral`.`product_ion` (`mz` ASC);

CREATE INDEX `idx_product_type` ON `proviral`.`product_ion` (`type` ASC);

CREATE INDEX `idx_product_serial` ON `proviral`.`product_ion` (`serial` ASC);


-- -----------------------------------------------------
-- Table `proviral`.`host_interference`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`host_interference` ;

CREATE TABLE IF NOT EXISTS `proviral`.`host_interference` (
  `peptide` VARCHAR(30) NOT NULL,
  `host_taxo_id` INT NOT NULL,
  `count_protein` INT NOT NULL,
  PRIMARY KEY (`peptide`, `host_taxo_id`),
  CONSTRAINT `fk_host_interference_host`
    FOREIGN KEY (`host_taxo_id`)
    REFERENCES `proviral`.`host` (`taxo_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_host_interference_peptide`
    FOREIGN KEY (`peptide`)
    REFERENCES `proviral`.`peptide` (`seq`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk__idx` ON `proviral`.`host_interference` (`host_taxo_id` ASC);


-- -----------------------------------------------------
-- Table `proviral`.`host_interference_detail`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`host_interference_detail` ;

CREATE TABLE IF NOT EXISTS `proviral`.`host_interference_detail` (
  `peptide` VARCHAR(30) NOT NULL,
  `host_taxo_id` INT NOT NULL,
  `virus_taxo_id` INT NOT NULL,
  PRIMARY KEY (`peptide`, `host_taxo_id`, `virus_taxo_id`),
  CONSTRAINT `fk_host_interference_detail_peptide_and_host`
    FOREIGN KEY (`peptide` , `host_taxo_id`)
    REFERENCES `proviral`.`host_interference` (`peptide` , `host_taxo_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_host_interference_detail_virus`
    FOREIGN KEY (`virus_taxo_id`)
    REFERENCES `proviral`.`virus` (`taxo_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_host_interference_detail_virus_idx` ON `proviral`.`host_interference_detail` (`virus_taxo_id` ASC);


-- -----------------------------------------------------
-- Table `proviral`.`strain_signature`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`strain_signature` ;

CREATE TABLE IF NOT EXISTS `proviral`.`strain_signature` (
  `virus_taxo_id` INT NOT NULL,
  `host_taxo_id` INT NOT NULL,
  `signature` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`virus_taxo_id`, `signature`, `host_taxo_id`),
  CONSTRAINT `fk_strain_sig_infection`
    FOREIGN KEY (`virus_taxo_id` , `host_taxo_id`)
    REFERENCES `proviral`.`infection` (`virus_taxo_id` , `host_taxo_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_strain_sig_peptide`
    FOREIGN KEY (`signature`)
    REFERENCES `proviral`.`peptide` (`seq`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_virus_sig_infection_idx` ON `proviral`.`strain_signature` (`virus_taxo_id` ASC, `host_taxo_id` ASC);

CREATE INDEX `fk_virus_sig_peptide_idx` ON `proviral`.`strain_signature` (`signature` ASC);


-- -----------------------------------------------------
-- Table `proviral`.`virus_signature`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `proviral`.`virus_signature` ;

CREATE TABLE IF NOT EXISTS `proviral`.`virus_signature` (
  `virus` VARCHAR(255) NOT NULL,
  `host_taxo_id` INT NULL,
  `signature` VARCHAR(30) NULL,
  PRIMARY KEY (`virus`),
  CONSTRAINT `fk_virus_sig_peptide`
    FOREIGN KEY (`signature`)
    REFERENCES `proviral`.`peptide` (`seq`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_virus_sig_host`
    FOREIGN KEY (`host_taxo_id`)
    REFERENCES `proviral`.`host` (`taxo_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `fk_virus_sig_peptide_idx` ON `proviral`.`virus_signature` (`signature` ASC);

CREATE INDEX `fk_virus_sig_host_idx` ON `proviral`.`virus_signature` (`host_taxo_id` ASC);


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
