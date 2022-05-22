#para conferir o proceder
#a
call ContaProdutos(1,@qtdp);
select @qtdp quantidade;
#b
call ValorTotalVenda("2021-07-21","2021-09-28",@vtv);
select @vtv ValorTotalVenda;