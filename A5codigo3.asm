.include "macros.asm"

main: 
	print_str("Programa para calcular N-esimo de Catalan\n")
	print_str("\nInforme chave N: ")
	scan_int($s0)
	add $t7, $s0, $zero
	
	add $t1, $t1, -1
	slt $t0, $t1, $s0  # Se $zero menor que $s0, $t0 = 1, logo $s0 positivo diferente de 0
	beq $t0, 0, error  # Se $t0 = 0, num em $s0 negativo e vai sair para erro
	
	jal catalan
	
	print_str("\nC(")
	print_int($t7)
	print_str(") = ")
	print_int($s6)
	
	catalan:
		li $s1, 1  # C(n) inicializado com 1
		beq $s0, $zero, return  # Se n = 0, retorna com 1
		beq $s0, 1, return  # Se n = 1, retorna com 1
		mulo $t2, $2, $s0  # $t2 = 2*n
		sub $t2, $t2, 1  # $t2 = 2*n - 1
		mul $t2, $t2, 2  # $t2 = 2(2*n - 1)
		add $t3, $s0, 1  # $t2 = n + 1
		div $t5, $t2, $t3  # $t5 =  2(2*n - 1)/n + 1
		sub $s0, $s0, 1  # $t4 = n - 1
		jal catalan
		mul $s6, $s1, $t5
		return:
			bne $s0, $zero, catalan
			jr $ra
	
	error: 
		print_str("Apenas chaves positvas\n")
		terminate