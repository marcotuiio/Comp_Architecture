## Carregar um vetor passando pelo usuário
.include "macros.asm"

.data
	vet: .space 256
	
.text

main:
	print_str("Informe o tamanho do vetor que será carregado: ")
	scan_int($s0)
	
	add $s1, $s0, 0  # Copiando tamanho informado
	li $s2, 0  # Iterador
	li $s3, 0  # Iterador
	li $s4, 0  # Iterador
	la $s5, vet  # Ponteiro para o começo do vetor
	li $s6, 0  # Variável soma		
	print_str("\n")
	
	loop_load:	
		beq $s0, 0, loop_sum
		sll $t1, $s2, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
		add $t1, $t1, $s5  # Carregando em $t1 = endereço de vetor[i] 
		print_str("v[")
		print_int($s3)
		print_str("] = ")
		scan_int($t2)
		sw $t2, 0($t1)  # Armazenando valor de $s2 na posição $t1 do veto
		addi $s0, $s0, -1  # Atualizando i = i-1
		addi $s2, $s2, 1  # Iterador do vetor +1
		addi $s3, $s3, 1  # Iterador estético +1
		j loop_load
	
	loop_sum:	
		beq $s1, 0, exit  # Se tamanho máximo do vetor ja foi alcaçando, encerrar
		sll $t1, $s4, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
		add $t1, $t1, $s5  # Carregando em $t1 = endereço de vetor[i] 
		lw $t2, 0($t1)  # $t2 = valor de vetor[i]
		add $s6, $s6, $t2  # Amazenando em  $s6 a soma dos elementos do vetor
		addi $s4, $s4, 1  # Atualizando i = i+1
		addi $s1, $s1, -1  # Atualizando i = i-1
		j loop_sum
	
	exit:
		print_str("\nSOMA = ")
		print_int($s6)
		terminate
