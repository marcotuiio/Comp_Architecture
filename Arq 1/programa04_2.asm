.include "macros.asm"

.data
	vetor: .space 512
.text

main:
	print_str("\nInforme o tamanho do vetor: ")
	scan_int($s0)
	print_str("\nInforme uma chave K: ")	
	scan_int($s1)
	print_str("\n")
	
	scan_array(vetor, $s0)
	la $s6, vetor 
	li $s3, 0
	
	repetir:
		beq $s3, $s1, end
		
		sub $s2, $s0, 1  # $s2 = tamanho-1
		sll $t1, $s2, 2  # Reg temp $t1 = vetor[tamanho-1], último elemento
		add $t1, $t1, $s6  # Carregando em $t1 = endereço de vetor[tamanho-1]
		lw $t2, 0($t1)  # $t2 = valor de vetor[tamanho-1]
		rotate1:
			beq $s2, $zero, exit  # enquanto i > 0
			sub $t4, $s2, 1  # $t3 = i - 1, aux
		
			sll $t1, $s2, 2  # Reg temp $t1 = vetor[i]
			add $t1, $t1, $s6  # Carregando em $t1 = endereço de vetor[i]
		
			sll $t3, $t4, 2  # Reg temp $t3 = vetor[i-1]
			add $t3, $t3, $s6  # Carregando em $t1 = endereço de vetor[tamanho-1]
			lw $t5, 0($t3)  # $t5 = conteudo da posição vetor[i-1]
		
			sw $t5, 0($t1)  # Armazenando na posição i o conteudo da posição i-1
			sub $s2, $s2, 1  # i = i - 1
 			j rotate1	
			
		exit:
			li $t1, 0  # Zerando $t1
			add $t1, $t1, $s6  # Acessando primeira posição do vetor
			sw $t2, 0($t1)  # Começo do vetor redefinido, vetor[0] = antigo último
			add $s3, $s3, 1
			j repetir
	
	end:		
		print_str("\nVetor rotacionado em ")
		print_int($s1)
		print_str(" posições\n")	
		print_array(vetor, $s0)
		terminate
	