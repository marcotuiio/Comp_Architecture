.include "macros.asm"
	
.text
	main:
		print_str("\nInforme a quantidade N de elementos do vetor: ")
		scan_int($s1)
		mul $s2, $s1, 4
		calloc($s2, $s3) # VetA alocado dinamicamente com N * 4 bytes 
		scan_array_din($s3, $s1)
		calloc($s2, $s4) # Vetor auxiliar para nao contar elementos que ja foram contados
		init_array($s4, $s1)
		
		li $t1, 0  # Iterador externo
		li $t5, 0  # Iterador do vetor auxiliar
		loop1:	
			bge $t1, $s1, exit1  # Se tamanho maximo do vetor ja foi alcancado, encerrar
			sll $t4, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t4, $t4, $s3  # Carregando em $t1 = endereco de vetor[i] 
			l.s $f5, 0($t4)  # $t2 = valor de vetor[i]
			
			## todo esse trecho serve para verificar se o elemento ja foi contado, para não repetir print
			has_element_float($s4, $t5, $f5, $f10)
			c.eq.s $f10, $f5 # Se o elemento ja existe no vetor, bct1 = true entao pular pro proximo
			addi $t1, $t1, 1  # Atualizando i = i+1
			bc1t loop1
			sll $t4, $t5, 2
			add $t4, $t4, $s4
			s.s $f5, 0($t4)
			addi $t5, $t5, 1
			
			li $s5, 0 # Contador de repeticoes de cada valor
			li $t2, 0 # iterador interno
			loop2:
				bge $t2, $s1, exit2
				sll $t4, $t2, 2
				add $t4, $t4, $s3
				l.s $f6, 0($t4)
				c.eq.s $f5, $f6 # Se ambos os valores sao iguais, coprocessor = true
				add $t2, $t2, 1
				bc1f loop2
				addi $s5, $s5, 1
				j loop2
			exit2:
			print_str("\n Valor ")
			print_float($f5)
			print_str(" ocorre ")
			print_int($s5)
			print_str(" vez(es)")
			j loop1
		exit1:
		
		terminate
