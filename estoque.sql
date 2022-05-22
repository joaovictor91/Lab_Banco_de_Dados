-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema estoque
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `estoque` ;

-- -----------------------------------------------------
-- Schema estoque
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `estoque` DEFAULT CHARACTER SET latin1 ;
USE `estoque` ;

-- -----------------------------------------------------
-- Table `estoque`.`cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`cliente` (
  `codigo` INT NOT NULL,
  `nome` VARCHAR(40) NULL,
  `cidade` VARCHAR(20) NULL,
  `estado` VARCHAR(2) NULL,
  PRIMARY KEY (`codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `estoque`.`fornecedor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`fornecedor` (
  `codigo` INT NOT NULL,
  `nome` VARCHAR(40) NULL,
  `cidade` VARCHAR(20) NULL,
  `estado` VARCHAR(2) NULL,
  `telefone` VARCHAR(14) NULL,
  PRIMARY KEY (`codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `estoque`.`compra`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`compra` (
  `numero` INT NOT NULL,
  `codigo_for` INT NOT NULL,
  `data` DATE NULL,
  `valor` FLOAT NULL DEFAULT 0,
  PRIMARY KEY (`numero`),
  INDEX `codigo_for` (`codigo_for` ASC),
  CONSTRAINT `compra_ibfk_1`
    FOREIGN KEY (`codigo_for`)
    REFERENCES `estoque`.`fornecedor` (`codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `estoque`.`produto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`produto` (
  `codigo` INT NOT NULL,
  `nome` VARCHAR(30) NULL,
  `preco_ven` FLOAT NULL DEFAULT 0,
  `preco_com` FLOAT NULL DEFAULT 0,
  `qtd` INT NULL DEFAULT 0,
  PRIMARY KEY (`codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `estoque`.`compra_produto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`compra_produto` (
  `numero_com` INT NOT NULL,
  `codigo_pro` INT NOT NULL,
  `qtd_com` INT NULL DEFAULT 0,
  `valor_uni` FLOAT NULL DEFAULT 0,
  `valor_tot` FLOAT NULL DEFAULT 0,
  PRIMARY KEY (`numero_com`, `codigo_pro`),
  INDEX `codigo_pro` (`codigo_pro` ASC),
  CONSTRAINT `compra_produto_ibfk_1`
    FOREIGN KEY (`codigo_pro`)
    REFERENCES `estoque`.`produto` (`codigo`),
  CONSTRAINT `compra_produto_ibfk_2`
    FOREIGN KEY (`numero_com`)
    REFERENCES `estoque`.`compra` (`numero`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `estoque`.`produtos_a_comprar`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`produtos_a_comprar` (
  `codigo_pro` INT NOT NULL,
  `preco_com` FLOAT NOT NULL DEFAULT 0,
  INDEX `codigo_pro` (`codigo_pro` ASC),
  PRIMARY KEY (`codigo_pro`),
  CONSTRAINT `produtos_a_comprar_ibfk_1`
    FOREIGN KEY (`codigo_pro`)
    REFERENCES `estoque`.`produto` (`codigo`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `estoque`.`venda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`venda` (
  `numero` INT NOT NULL,
  `codigo_cli` INT NOT NULL,
  `data` DATE NULL,
  `valor` FLOAT NULL DEFAULT 0,
  PRIMARY KEY (`numero`),
  INDEX `codigo_cli` (`codigo_cli` ASC),
  CONSTRAINT `venda_ibfk_1`
    FOREIGN KEY (`codigo_cli`)
    REFERENCES `estoque`.`cliente` (`codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `estoque`.`venda_produto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`venda_produto` (
  `numero_ven` INT NOT NULL,
  `codigo_pro` INT NOT NULL,
  `qtd_ven` INT NULL DEFAULT 0,
  `valor_uni` FLOAT NULL DEFAULT 0,
  `valor_tot` FLOAT NULL DEFAULT 0,
  PRIMARY KEY (`numero_ven`, `codigo_pro`),
  INDEX `codigo_pro` (`codigo_pro` ASC),
  CONSTRAINT `venda_produto_ibfk_1`
    FOREIGN KEY (`codigo_pro`)
    REFERENCES `estoque`.`produto` (`codigo`),
  CONSTRAINT `venda_produto_ibfk_2`
    FOREIGN KEY (`numero_ven`)
    REFERENCES `estoque`.`venda` (`numero`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

USE `estoque` ;

-- -----------------------------------------------------
-- Placeholder table for view `estoque`.`produtos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`produtos` (`NomeProd` INT, `QtdEstoque` INT);

-- -----------------------------------------------------
-- Placeholder table for view `estoque`.`ProdutosVendidos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`ProdutosVendidos` (`nome` INT, `qtd_ven` INT, `valor_uni` INT);

-- -----------------------------------------------------
-- Placeholder table for view `estoque`.`Compras`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `estoque`.`Compras` (`NomeForn` INT, `TotalCompra` INT);

-- -----------------------------------------------------
-- procedure ContaProdutos
-- -----------------------------------------------------

DELIMITER $$
USE `estoque`$$
#a
create procedure ContaProdutos(in NumVenda int, out QtdProd int)
begin
	select count(*) into QtdProd
    from venda_produto
    where numero_ven = NumVenda;
end;$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ValorTotalVenda
-- -----------------------------------------------------

DELIMITER $$
USE `estoque`$$
create procedure ValorTotalVenda(in datai date, in 
		dataf date, out valor_total float)
		begin
			select sum(valor) into valor_total
			from venda
            where data >= datai and data <= dataf;
            #where data between datai and dataf; #também pode ser utilizado o between
            #group by data; mas tem que ser informado a data no select
        end;$$

DELIMITER ;

-- -----------------------------------------------------
-- View `estoque`.`produtos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `estoque`.`produtos`;
USE `estoque`;
CREATE  OR REPLACE VIEW produtos (NomeProd,QtdEstoque) AS
	select nome,qtd
    from produto;

-- -----------------------------------------------------
-- View `estoque`.`ProdutosVendidos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `estoque`.`ProdutosVendidos`;
USE `estoque`;
CREATE  OR REPLACE VIEW ProdutosVendidos AS
	select p.nome, vp.qtd_ven, vp.valor_uni
    from produto p, venda_produto vp
    where p.codigo = vp.codigo_pro;

-- -----------------------------------------------------
-- View `estoque`.`Compras`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `estoque`.`Compras`;
USE `estoque`;
CREATE  OR REPLACE VIEW Compras (NomeForn, TotalCompra) AS
	select f.nome,sum(c.valor)
    from fornecedor f, compra c
    where f.codigo = c.codigo_for
    group by f.nome;
USE `estoque`;

DELIMITER $$
USE `estoque`$$
CREATE DEFINER = CURRENT_USER TRIGGER `estoque`.`compra_produto_AFTER_INSERT` AFTER INSERT ON `compra_produto` FOR EACH ROW
BEGIN
	declare QtdEst int;
	#a
    update produto
    set qtd= qtd + new.qtd_com, 
    preco_com = new.valor_uni,
    preco_com = new.valor_uni, 
    preco_ven = new.valor_uni*1.4
    where codigo = new.codigo_pro;
	#b
    update compra
    set valor = valor + new.valor_tot
    where numero = new.numero_com;
    #c
    select qtd into QtdEst
    from produto
    where codigo = new.codigo_pro;
    if (QtdEst > 3) then
		delete from produtos_a_comprar
        where codigo_pro = new.codigo_pro;
	end if;
    
	
END$$

USE `estoque`$$
CREATE DEFINER = CURRENT_USER TRIGGER `estoque`.`venda_produto_AFTER_INSERT` AFTER INSERT ON `venda_produto` FOR EACH ROW
BEGIN
	declare QtdEst int;
    declare PrecoCom float;
	#a
    update produto
    set qtd = qtd - new.qtd_ven
    where codigo = new.codigo_pro;
	#b
    update venda
    set valor = valor + new.valor_tot
    where numero = new.numero_ven;
    #c
    select qtd, preco_com into QtdEst, PrecoCom
    from produto
    where codigo = new.codigo_pro;
    if (QtdEst <= 3) then
		insert into produtos_a_comprar
        values (new.codigo_pro, PrecoCom);
    end if;
    
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `estoque`.`cliente`
-- -----------------------------------------------------
START TRANSACTION;
USE `estoque`;
INSERT INTO `estoque`.`cliente` (`codigo`, `nome`, `cidade`, `estado`) VALUES (1, 'Jose da Silva', 'Presidente Prudente', 'SP');
INSERT INTO `estoque`.`cliente` (`codigo`, `nome`, `cidade`, `estado`) VALUES (2, 'Maria da Silva', 'Presidente Prudente', 'SP');
INSERT INTO `estoque`.`cliente` (`codigo`, `nome`, `cidade`, `estado`) VALUES (3, 'Roberta Aparecida', 'Presidente Bernardes', 'SP');
INSERT INTO `estoque`.`cliente` (`codigo`, `nome`, `cidade`, `estado`) VALUES (4, 'Raquel da Silveira', 'Rancharia', 'SP');

COMMIT;


-- -----------------------------------------------------
-- Data for table `estoque`.`fornecedor`
-- -----------------------------------------------------
START TRANSACTION;
USE `estoque`;
INSERT INTO `estoque`.`fornecedor` (`codigo`, `nome`, `cidade`, `estado`, `telefone`) VALUES (1, 'Informatica Ltda', 'Presidente Prudente', 'SP', '(18) 3909-2345');
INSERT INTO `estoque`.`fornecedor` (`codigo`, `nome`, `cidade`, `estado`, `telefone`) VALUES (2, 'Varejão ME', 'Santo Anastácio', 'SP', '(18) 3222-6589');

COMMIT;


-- -----------------------------------------------------
-- Data for table `estoque`.`compra`
-- -----------------------------------------------------
START TRANSACTION;
USE `estoque`;
INSERT INTO `estoque`.`compra` (`numero`, `codigo_for`, `data`, `valor`) VALUES (1, 1, '2021-07-23', 0);
INSERT INTO `estoque`.`compra` (`numero`, `codigo_for`, `data`, `valor`) VALUES (2, 2, '2021-07-22', 0);

COMMIT;


-- -----------------------------------------------------
-- Data for table `estoque`.`produto`
-- -----------------------------------------------------
START TRANSACTION;
USE `estoque`;
INSERT INTO `estoque`.`produto` (`codigo`, `nome`, `preco_ven`, `preco_com`, `qtd`) VALUES (1, 'Tablet', 1000, 800, 7);
INSERT INTO `estoque`.`produto` (`codigo`, `nome`, `preco_ven`, `preco_com`, `qtd`) VALUES (2, 'Smartphone', 900, 800, 8);
INSERT INTO `estoque`.`produto` (`codigo`, `nome`, `preco_ven`, `preco_com`, `qtd`) VALUES (3, 'Smart TV', 2500, 2200, 10);
INSERT INTO `estoque`.`produto` (`codigo`, `nome`, `preco_ven`, `preco_com`, `qtd`) VALUES (4, 'Notebook', 3000, 2800, 3);

COMMIT;


-- -----------------------------------------------------
-- Data for table `estoque`.`compra_produto`
-- -----------------------------------------------------
START TRANSACTION;
USE `estoque`;
INSERT INTO `estoque`.`compra_produto` (`numero_com`, `codigo_pro`, `qtd_com`, `valor_uni`, `valor_tot`) VALUES (1, 3, 12, 2200, 26400);
INSERT INTO `estoque`.`compra_produto` (`numero_com`, `codigo_pro`, `qtd_com`, `valor_uni`, `valor_tot`) VALUES (1, 4, 3, 2800, 8400);
INSERT INTO `estoque`.`compra_produto` (`numero_com`, `codigo_pro`, `qtd_com`, `valor_uni`, `valor_tot`) VALUES (2, 1, 7, 800, 5600);
INSERT INTO `estoque`.`compra_produto` (`numero_com`, `codigo_pro`, `qtd_com`, `valor_uni`, `valor_tot`) VALUES (2, 2, 6, 800, 4800);

COMMIT;


-- -----------------------------------------------------
-- Data for table `estoque`.`venda`
-- -----------------------------------------------------
START TRANSACTION;
USE `estoque`;
INSERT INTO `estoque`.`venda` (`numero`, `codigo_cli`, `data`, `valor`) VALUES (1, 1, '2021-08-23', 0);
INSERT INTO `estoque`.`venda` (`numero`, `codigo_cli`, `data`, `valor`) VALUES (2, 2, '2021-07-22', 0);
INSERT INTO `estoque`.`venda` (`numero`, `codigo_cli`, `data`, `valor`) VALUES (3, 1, '2021-09-28', 0);

COMMIT;


-- -----------------------------------------------------
-- Data for table `estoque`.`venda_produto`
-- -----------------------------------------------------
START TRANSACTION;
USE `estoque`;
INSERT INTO `estoque`.`venda_produto` (`numero_ven`, `codigo_pro`, `qtd_ven`, `valor_uni`, `valor_tot`) VALUES (1, 1, 2, 1000, 2000);
INSERT INTO `estoque`.`venda_produto` (`numero_ven`, `codigo_pro`, `qtd_ven`, `valor_uni`, `valor_tot`) VALUES (1, 2, 3, 900, 2700);
INSERT INTO `estoque`.`venda_produto` (`numero_ven`, `codigo_pro`, `qtd_ven`, `valor_uni`, `valor_tot`) VALUES (1, 3, 2, 2500, 5000);
INSERT INTO `estoque`.`venda_produto` (`numero_ven`, `codigo_pro`, `qtd_ven`, `valor_uni`, `valor_tot`) VALUES (2, 2, 2, 900, 1800);
INSERT INTO `estoque`.`venda_produto` (`numero_ven`, `codigo_pro`, `qtd_ven`, `valor_uni`, `valor_tot`) VALUES (2, 3, 2, 2500, 5000);
INSERT INTO `estoque`.`venda_produto` (`numero_ven`, `codigo_pro`, `qtd_ven`, `valor_uni`, `valor_tot`) VALUES (3, 4, 1, 3000, 3000);

COMMIT;

