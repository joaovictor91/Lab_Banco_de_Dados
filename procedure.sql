DELIMITER $$
#a
create procedure ContaProdutos(in NumVenda int, out QtdProd int)
begin
	select count(*) into QtdProd
    from venda_produto
    where numero_ven = NumVenda;
end;
$$
#b
create procedure ValorTotalVenda(in datai date, in 
		dataf date, out valor_total float)
		begin
			select sum(valor) into valor_total
			from venda
            where data >= datai and data <= dataf;
            #where data between datai and dataf; #também pode ser utilizado o between
            #group by data; mas tem que ser informado a data no select
        end;
