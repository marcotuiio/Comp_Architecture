.include "macros.asm"

main: 
	print_str("Programa para calcular N-esimo de Catalan\n")
	print_str("\nInforme chave N: ")
	scan_int($s0)
	
	add $t7, $s0, $zero
	add $t1, $t1, -1
	slt $t0, $t1, $s0  # Se -1 menor que $s0, $t0 = 1, logo $s0 positivo diferente de 0
	beq $t0, $zero, error  # Se $t0 = 0, num em $s0 negativo e vai sair para erro
	
	li $t0, 2  # $t0 = 2
	li $s6, 1  # C(n) inicializado com 1
	mtc1 $s6, $f6
	cvt.s.w $f6, $f6
	
	beq $s0, $zero, prints
	beq $s0, 1, prints
	jal catalan  # se n diferente de 0 e 1, faz o processo recursivo
	
	prints:
		print_str("\nC(")
		print_int($t7)
		print_str(") = ")
		print_float($f6)
		
	terminate
	
	catalan:
		mul $t2, $t0, $s0  # $t2 = 2*n 
		sub $t2, $t2, 1  # $t2 = 2*n - 1
		mul $t2, $t2, $t0  # $t2 = 2(2*n - 1)
		add $t3, $s0, 1  # $t3 = n + 1
		
		# Convertendo para float pois os numeros de Catalan precisam estar com precisão de ponto flutuante
		mtc1 $t2, $f0
		cvt.s.w $f0, $f0  # Em $f0 está 2(2*n - 1)
		mtc1 $t3, $f1
		cvt.s.w $f1, $f1	 # Em $f1 está n + 1
		
		div.s $f3, $f0, $f1  # $f3 = 2(2*n - 1)/n + 1
		mul.s $f6, $f6, $f3  # $f6 = $f6 * Catalan de n atual (acumulativo com os n-1 até que n=0)
		# print_float($f6)
		# print_str(" | ")
		sub $s0, $s0, 1  # $s0 = n - 1
		bne $s0, 1, catalan  # repetir a recursão enquanto n for diferente de 1
		jr $ra  # retornar da recursão
	
	error: 
		print_str("Apenas chaves positvas\n")
		terminate
