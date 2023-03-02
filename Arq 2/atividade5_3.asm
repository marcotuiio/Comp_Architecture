.include "macros.asm"

.data
	zeroFloat: .float 0.0
	
.text
	main:
		print_str("\nInforme a quantidade N de elementos dos vetores A e B: ")
		scan_int($s1)
		mul $s2, $s1, 4
		calloc($s2, $s3) # VetA alocado dinamicamente com N * 4 bytes 
		calloc($s2, $s4) # VetB	alocado dinamicamente com N * 4 bytes
		print_str("\nLeitura de VetA: ")
		scan_array_din($s3, $s1)
		print_str("\nLeitura de VetB: ")
		scan_array_din($s4, $s1)

#		print_array_din($s3, $s1)
#		print_array_din($s4, $s1)
		
		li $t1, 0  # Iterador
		lwc1 $f3, zeroFloat  # Variavel soma do vetor A
		par:	
			bge $t1, $s1, exit1  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t4, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t4, $t4, $s3  # Carregando em $t1 = endereço de vetor[i] 
			l.s $f5, 0($t4)  # $t2 = valor de vetor[i]
			add.s $f3, $f3, $f5  # Amazenando no endereço fornecido a soma dos elementos do vetor
			addi $t1, $t1, 1  # Atualizando i = i+1
			j par
		exit1:
		
		li $t1, 1  # Iterador
		lwc1 $f4, zeroFloat  # Variavel soma do vetor B
		impar:	
			bge $t1, $s1, exit2  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t4, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t4, $t4, $s4  # Carregando em $t1 = endereço de vetor[i] 
			l.s $f5, 0($t4)  # $t2 = valor de vetor[i]
			add.s $f4, $f4, $f5  # Amazenando no endereço fornecido a soma dos elementos do vetor
			addi $t1, $t1, 1  # Atualizando i = i+1
			j impar
		exit2:
		
		print_str("\n Soma das posi��es pares de A = ")
		print_float($f3)
		print_str("\n Soma das posi��es impares de B = ")
		print_float($f4)
		sub.s $f5, $f3, $f4
		print_str("\n A - B = ")
		print_float($f5)
		
		terminate
