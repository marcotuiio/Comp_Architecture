.include "macros.asm"

.data
	vetor: .space 256  # Espaço para armazenar um vetor de no máximo 64 elementos
.text
	
main:
	print_str("Programa para calcular n primeiros inteiros positivos que são múltiplos de a ou b\n")
	print_str("\nInforme chave n: ")
	scan_int($s0)
	print_str("Informe chave A: ")
	scan_int($s1)
	print_str("Informe chave B: ")
	scan_int($s2)

	slt $t0, $zero, $s0  # Se $zero menor que $s0, $t0 = 1, logo $s0 positivo diferente de 0
	beq $t0, 0, error  # Se $t0 = 0, num em $s0 negativo e vai sair para erro
	slt $t0, $zero, $s1  # Se $zero menor que $s1, $t0 = 1, logo $s0 positivo diferente de 0
	beq $t0, 0, error  # Se $t0 = 0, num em $s1 negativo e vai sair para erro
	slt $t0, $zero, $s2  # Se $zero menor que $s1, $t0 = 1, logo $s0 positivo diferente de 0
	beq $t0, 0, error  # Se $t0 = 0, num em $s1 negativo e vai sair para erro
	
	li $s5, 0  # Iterador no vetor
	la $s6, vetor
	
	# Inicializando vetor com A e B 
	sll $t6, $s5, 2  # Reg temp $t6 = 4*i (indice atual do vetor)
	add $t6, $t6, $s6  # Carregando em $t6 = endereço de vetor[i] 
	sw $s1, 0($t6)  # Armazenando valor de $t2 na posição [i] $t6 do vetor
	addi $s5, $s5, 1  # Iterador do vetor +1
	sll $t6, $s5, 2  # Reg temp $t6 = 4*i (indice atual do vetor)
	add $t6, $t6, $s6  # Carregando em $t6 = endereço de vetor[i] 
	sw $s2, 0($t6)  # Armazenando valor de $t2 na posição [i] $t6 do vetor
	addi $s5, $s5, 1  # Iterador do vetor +1
	
	li $s4, 2  # Variavel para multiplicar A e B, variando até no maximo N
	li $s7, 2  # Contador de numeros ja no vetor
	mul $s3, $s0, 2

	jal multiplos
	add $s1, $s0, $zero
	sort_array(vetor, $s7)  # Ordenando elementos no vetor de multiplos
	print_array(vetor, $s1)
	
	terminate
	
	multiplos:
		mul $t1, $s1, $s4  # $t1 = a * x, com x indo de 1 até no maximo N
		mul $t2, $s2, $s4  # $t2 = b * x, com x indo de 1 até no maximo N
	
		# Basicamente verifica se o elemento existe no vetor e, se for a primeira ocorrencia,
		# adiciona normalmente num vetor, senão pula para o proximo multiplo possível
 		# Ao final, teremos um vetor com 2*N posições que poderá facilmente ser ordenado e exibido
 		# porém só seram exibidos os N primeiros elementos desse vetor
 		
		has_element(vetor, $s7, $t1, $t0)  # Verifica se elemento ja existe no vetor
		bne $t0, $zero, again  # se $t9 != 0, elemento ja existe
		sll $t6, $s5, 2  # Reg temp $t6 = 4*i (indice atual do vetor)
		add $t6, $t6, $s6  # Carregando em $t6 = endereço de vetor[i] 
		sw $t1, 0($t6)  # Armazenando valor de $t2 na posição [i] $t6 do vetor
		addi $s5, $s5, 1  # Iterador do vetor +1
		addi $s7, $s7, 1
		
		again:
			has_element(vetor, $s7, $t2, $t0)  # Verifica se elemento ja existe no vetor
			bne $t0, $zero, repet  # se $t9 != 0, elemento ja existe
			sll $t6, $s5, 2  # Reg temp $t6 = 4*i (indice atual do vetor)
			add $t6, $t6, $s6  # Carregando em $t6 = endereço de vetor[i] 
			sw $t2, 0($t6)  # Armazenando valor de $t2 na posição [i] $t6 do vetor
			addi $s5, $s5, 1  # Iterador do vetor +1
			addi $s7, $s7, 1
		
		repet:
			add $s4, $s4, 1  # Somando 1 em $s4
			sgt $t0, $s7, $s3  # Verificando para não deixar o tamanho do vetor extrapolar N
			beq $t0, $zero, multiplos
			jr $ra
			
	error: 
		print_str("Apenas chaves positvas\n")
		terminate
