.include "macros.asm"
.data
	vetor: .space 512  # Espaço para armazenar um vetor de no máximo 128 elementos
.text
	
main:
	print_str("\nInforme o tamanho do vetor: ")
	scan_int($s0)
	print_str("\nInforme uma chave K para quantidade entre 2 e 2*k: ")	
	scan_int($s1)
	print_str("\nInforme uma chave K para quantidade iguais a K: ")	
	scan_int($s2)
	print_str("\n")
	
	scan_array(vetor, $s0)
	sort_array(vetor, $s0)  # Ordenação feita através de uma macro implementada em macros.asm
	print_str("\n(a) Vetor ordenado:\n")
	print_array(vetor, $s0)
	
	sum_pares(vetor, $s0, $s4)
	print_str("\n\n(b) Soma do elementos pares:\n")
	print_int($s4)
	
	la $s6, vetor  # Atribuindo $s6 o endereço do vetor pois será usado nos itens sequintes
	print_str("\n\n(c) Quantidade de números no vetor maiores que K e menores que 2*K:\n")
	li $s5, 0  # Iterador
	li $s4, 0  # Variável contadora
	mul $t0, $s1, 2
	loop_cont:	
			beq $s0, $s5, exit  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t1, $s5, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t1, $t1, $s6  # Carregando em $t1 = endereço de vetor[i] 
			lw $t2, 0($t1)  # $t2 = valor de vetor[i]
			slt $t3, $s1, $t2  # K ($s1) deve ser menor que $t2, então $t3 = 1
			bne $t3, 1, repet  # Se $t3 = 0, então o elemento atual é menor que K e fora do intervalo
			slt $t3, $t2, $t0  # 2*K ($t0) deve ser maior que $t2, então $t3 = 1
			bne $t3, 1, repet  # Se $t3 = 0, então o elemento atual é maior que 2*K e fora do intervalo
			add $s4, $s4, 1  # Amazenando em $s4 o contador de elementos no intervalo
			repet:
				addi $s5, $s5, 1  # Atualizando i = i+1
				j loop_cont
	exit:
	bne $s4, $zero, pc
	print_str("Não existem números no intervalo aberto ")
	print_int($s1)
	print_str(" | ")
	print_int($t0) 
	print_str(" nesse vetor ")
	pc:
		print_int($s4)
	
	print_str("\n\n(d) Quantidade de números no iguais a K:\n")
	li $s5, 0  # Iterador
	li $s4, 0  # Variável contadora
	loop_iguais:	
			beq $s0, $s5, exit2  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t1, $s5, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t1, $t1, $s6  # Carregando em $t1 = endereço de vetor[i] 
			lw $t2, 0($t1)  # $t2 = valor de vetor[i]
			bne $s2, $t2, repet2  # Sair se elemento atual diferente de K
			add $s4, $s4, 1  # Amazenando em $s4 o contador de elementos iguais a K
			repet2:
				addi $s5, $s5, 1  # Atualizando i = i+1
				j loop_iguais
	exit2:
	bne $s4, $zero, pd
	print_str("Não existem números iguais a ")
	print_int($s2) 
	print_str(" nesse vetor ")
	pd:
		print_int($s4)
	
	print_str("\n\n (e) Soma dos números perfeitos menos a soma dos números semiprimos:\n")
	li $s4, 0  # Soma dos perfeitos
	li $s5, 0  # Iterador
	loop_perf:
		beq $s0, $s5, exit3  # Se tamanho máximo do vetor ja foi alcançado, encerrar
		sll $t1, $s5, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
		add $t1, $t1, $s6  # Carregando em $t1 = endereço de vetor[i] 
		lw $s1, 0($t1)  # $s1 = valor de vetor[i]
		numero_perfeito($s1, $t3)  # Macro para verificar se número em $s1 é perfeito 
		bne $t3, 1, repet3  # Se $t3 for 1, na macro ele foi considerado um número positivo
		add $s4, $s4, $s1  # Somanado em $s4 os números perfeitos
		repet3:
			addi $s5, $s5, 1  # Atualizando i = i + 1
			j loop_perf
	exit3:
	print_int($s4)	
	
	# Calcular semiprimos ???
		
	terminate
	
