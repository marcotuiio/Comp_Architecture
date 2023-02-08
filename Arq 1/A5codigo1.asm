.include "macros.asm"

.data
	alfabeto: .word 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'  # Declarando ALFABETO 
.text

main:
	print_str("\nInforme chave N positiva e menor ou igual a 26: ")
	scan_int($s0)

	slt $t0, $s0, $zero  # Se $zero menor que $s0, $t0 = 1, logo $s0 positivo diferente de 0
	beq $t0, 1, error  # Se $t0 = 0, num em $s0 negativo e vai sair para erro
	li $t1, 27
	slt $t0 $s0, $t1
	beq $t0, $zero, error
	
	la $s2, alfabeto
	li $s3, 0
	while:
		beq $s3, $s0, exit 
		sll $t0, $s3, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
		add $t0, $t0, $s2  # Carregando em $t1 = endereço de vetor[i] 
		lw $a0, 0($t0)  # $a0 = valor de vetor[i]
		li $v0, 11  # Informando que o syscall deve printar char
		syscall
		add $s3, $s3, 1  # iterador 
		j while
	exit:
	terminate
	
	error: 
		print_str("Apenas chaves entre 1 e 26\n")
		terminate
