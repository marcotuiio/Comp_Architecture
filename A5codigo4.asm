.include "macros.asm"

main:
	print_str("Programa para calcular k^n\n")
	print_str("\nInforme chave k: ")
	scan_int($s0)
	print_str("Informe chave n: ")
	scan_int($s1)
	
	add $t1, $t1, -1
	positivo:
		slt $t0, $t1, $s0  # Se $zero menor que $s0, $t0 = 1, logo $s0 positivo diferente de 0
		beq $t0, 0, error  # Se $t0 = 0, num em $s0 negativo e vai sair para erro
		slt $t0, $t1, $s1  # Se $zero menor que $s1, $t0 = 1, logo $s0 positivo diferente de 0
		beq $t0, 0, error  # Se $t0 = 0, num em $s1 negativo e vai sair para erro
		add $s2, $s1, $zero
		li $s3, 1  # Carregando $s3 com 1
		beq $s1, $zero, end
		jal potencias
		end:
			print_str("\nResultado de: ")
			print_int($s0)
			print_str("^")
			print_int($s1)
			print_str(" = ")
			print_int($s3)
			terminate
	
	potencias:
		sub $s2, $s2, 1
		mul $s3, $s3, $s0  # Armazenando em $s3, $s3*$s0
		bne $s2, $zero, potencias  # Repetir enquanto n for diferente de 0
		jr $ra
		
	error: 
		print_str("Apenas chaves positvas\n")
		terminate