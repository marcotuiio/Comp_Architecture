.include "macros.asm"

.data
	alfabeto: .word A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z  # Declarando ALFABETO 
.text

main:
	print_str("\nInforme chave N positiva e menor ou igual a 26: ")
	scan_int($s0)

	slt $t0, $zero, $s0  # Se $zero menor que $s0, $t0 = 1, logo $s0 positivo diferente de 0
	beq $t0, 0, error  # Se $t0 = 0, num em $s0 negativo e vai sair para erro
	
	la $s2, alfabeto
	li $s3, $zero
	while:
		beq $s3, $s0, exit
		sll $t1, $s3, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
		add $t1, $t1, $s2  # Carregando em $t1 = endereço de vetor[i] 
		lw $t0, 0($t1)  # $t0 = valor de vetor[i]
		j while
	ezit:
	error: 
		print_str("Apenas chaves positvas\n")
		terminate