### File for creating macros (subroutines)

.macro terminate
	addi $v0, $zero, 10  # Encerrando o programa
	syscall
.end_macro

## PRINTS
.macro print_int(%x)
	add $a0, %x, $zero  # Carregando $a0 com int %x a printar
	addi $v0, $zero, 1  # Informando que o syscall deve printar int
	syscall
.end_macro

.macro print_float(%x)
	mov.s $f12, %x  # Carregando $a0 com float %x a printar
	addi $v0, $zero, 2  # Informando que o syscall deve printar int
	syscall
.end_macro

.macro print_str(%str)
	.data
		toPrint: .asciiz %str
	.text	
	la $a0, toPrint  # Carregando em $a0 a string a printar (Separador)
	addi $v0, $zero, 4  # Informando que o syscall deve printar string
	syscall
.end_macro

.macro print_char(%c)
	lb $a0, %c  # Carregando $a0 com o char %c a printar
	li $v0, 11  # Informando que o syscall deve printar char
	syscall
.end_macro 

## SCANS
.macro scan_int(%a)
	addi $v0, $zero, 5  # Informando que o syscall deverá ler um int
	syscall
	add %a, $v0, $zero  # Armazenando A em $s0
.end_macro

.macro scan_float(%a)
	addi $v0, $zero, 6  # Informando que o syscall deverá ler um float
	syscall
	add %a, $f0, $zero  # Armazenando A em $s0
.end_macro

.macro scan_char(%a)
	addi $v0, $zero, 12  # Informando que o syscall deverá ler um float
	syscall
	add %a, $v0, $zero  # Armazenando A em $s0
.end_macro

## ARRAYS
.macro scan_array(%array, %size)
	add $s0, %size, 0
	li $t1, 0
	li $t2, 0
	la $t3, %array
	loop_load:	
			beq $s0, $t2, exit
			sll $t4, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t4, $t4, $t3  # Carregando em $t1 = endereço de vetor[i] 
			print_str("v[")
			print_int($t2)
			print_str("] = ")
			scan_int($t5)
			sw $t5, 0($t4)  # Armazenando valor de $t2 na posição [i] $t1 do vetor
			addi $t1, $t1, 1  # Iterador do vetor +1
			addi $t2, $t2, 1  # Iterador estético +1
			j loop_load
	exit:
.end_macro

.macro print_array(%array, %size)
	add $s0, %size, 0
	li $t1, 0
	la $t2, %array
	loop_print:	
			beq $s0, $t1, exit  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t3, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t3, $t3, $t2  # Carregando em $t1 = endereço de vetor[i] 
			lw $t4, 0($t3)  # $t2 = valor de vetor[i]
			print_int($t4)
			print_str(" | ")
			addi $t1, $t1, 1  # Atualizando i = i+1
			j loop_print
	exit:
.end_macro

.macro sum_array(%array, %size, %sum)
	add $s0, %size, 0
	li $t1, 0  # Iterador
	la $t2, %array
	li $t3, 0  # Variável soma
	loop_sum:	
			beq $s0, $t1, exit  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t4, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t4, $t4, $t2  # Carregando em $t1 = endereço de vetor[i] 
			lw $t5, 0($t4)  # $t2 = valor de vetor[i]
			add $t3, $t3, $t5  # Amazenando no endereço fornecido a soma dos elementos do vetor
			addi $t1, $t1, 1  # Atualizando i = i+1
			j loop_sum
	exit:
		la %sum, ($t3)
.end_macro

.macro sum_pares(%array, %size, %sum)
	add $s0, %size, 0
	li $t5, 0  # Iterador
	la $t6, %array
	li $t7, 0  # Variável soma
	loop_sum:	
			beq $s0, $t5, exit  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t1, $t5, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t1, $t1, $t6  # Carregando em $t1 = endereço de vetor[i] 
			lw $t2, 0($t1)  # $t2 = valor de vetor[i]
			li $t8, 2
			div $t2, $t8   # Dividindo vet[i] por 2 para saber se é par
			mfhi $t3
			bne $t3, 0, repet  # Se o resto da divisão for diferente de 0, número ímpar não somar
			add $t7, $t7, $t2  # Amazenando no endereço fornecido a soma dos elementos do vetor
			repet:	
				addi $t5, $t5, 1  # Atualizando i = i+1
				j loop_sum
	exit:
		la %sum, ($t7)
.end_macro

.macro sort_array(%array, %size)
	add $s0, %size, 0
	add $s5, $s0, -1  # $s5 = Tamanho do vetor -1 (pois são dois loops com essa condição de parada)
	la $s6, %array
	
	li $t6, 0  # i
	loop1:
		beq $t6, $s5, end1  # Se i = tamanho do vetor -1
		li $s3, 1  # auxiliar para acessar o vet[j+1]
		li $s4, 0  # j
		loop2:
			beq $s4, $s5, end2	# Se j = tamanho do vetor -1
			sll $t1, $s4, 2  # Reg temp $t1 = 4*j (indice atual do vetor)
			add $t1, $t1, $s6  # Carregando em $t1 = endereço de vetor[j]
			lw $t2, 0($t1)  # $t2 = valor de vetor[j]
			sll $t3, $s3, 2  # Reg temp $t3 = 4*j+1 (indice atual+1 do vetor)
			add $t3, $t3, $s6  # Carregando em $t3 = endereço de vetor[j+1] 
			lw $t4, 0($t3)  # $t4 = valor de vetor[j+1]
			
			sgt $t0, $t2, $t4  # Se vetor[j] > vetor[j+1], $t0=1
			bne $t0, 1, rept
			swap:
				add $t5, $t2, 0  # $t5 = vet[j] 
				sw $t4, 0($t1)  # vet[j] = vet[j+1], posição 0($t1) recebendo conteúdo de $t4  
				sw $t5, 0($t3)  # vet[j+1] = vet[j], posição 0($t3) recebendo conteúdo de $t5			
			rept:
				addi $s3, $s3, 1  # (j+1) = j+1
				addi $s4, $s4, 1  # j = j + 1
				j loop2
			
		end2:
			addi $t6, $t6, 1  # i = i + 1
			j loop1
	end1:
.end_macro

.macro rotate_array(%array, %size)
		add $s0, %size, 0
		la $t6, %array
		sub $t7, $s0, 1  # $s2 = tamanho-1
		sll $t1, $t7, 2  # Reg temp $t1 = vetor[tamanho-1], último elemento
		add $t1, $t1, $t6  # Carregando em $t1 = endereço de vetor[tamanho-1]
		lw $t2, 0($t1)  # $t2 = valor de vetor[tamanho-1]
		rotate1:
			beq $t7, $zero, exit  # enquanto i > 0
			sub $t4, $t7, 1  # $t3 = i - 1, aux
		
			sll $t1, $t7, 2  # Reg temp $t1 = vetor[i]
			add $t1, $t1, $t6  # Carregando em $t1 = endereço de vetor[i]
		
			sll $t3, $t4, 2  # Reg temp $t3 = vetor[i-1]
			add $t3, $t3, $t6  # Carregando em $t1 = endereço de vetor[tamanho-1]
			lw $t5, 0($t3)  # $t5 = conteudo da posição vetor[i-1]
		
			sw $t5, 0($t1)  # Armazenando na posição i o conteudo da posição i-1
			sub $t7, $t7, 1  # i = i - 1
 			j rotate1	
			
		exit:
			li $t1, 0  # Zerando $t1
			add $t1, $t1, $t6  # Acessando primeira posição do vetor
			sw $t2, 0($t1)  # Começo do vetor redefinido, vetor[0] = antigo último
.end_macro

.macro has_element(%array, %size, %element, %result)
	add $s7, %size, 0
	add $t9, %element, 0
	li $t4, 0
	la $t5, %array
	loop_load:	
			beq $s7, $t4, exit
			sll $t7, $t4, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t7, $t7, $t5  # Carregando em $t1 = endereço de vetor[i]
			lw $t8, 0($t7)  # $t2 = valor de vetor[i]
			beq $t8, $t9, equals
			addi $t4, $t4, 1  # Iterador do vetor +1
			j loop_load
	equals:
		la %result, ($t8)
		j end
	exit:
		la %result, ($zero)
	end:
.end_macro


## Uteis
.macro fatorial(%n, %fat)
	add $t0, %n, 0
	li $t1, 1
	
	zero_um:
		beq $t0, 0, exit  # Se número passado for igual a zero ou 1, dispensa loop
		beq $t0, 1, exit
	
	loop:	
		beq $t0, 1, exit  # Enquanto $t0 for diferente de 1
		mul $t1, $t0, $t1  # Armazenando em $t1 o produto de n * (n-1)
		sub $t0, $t0, 1  # Realizando n-1
		j loop
	
	exit:
		la %fat, ($t1)  # Armazendando o resultado no registrador passado
.end_macro

.macro perfect_number(%n, %resultado) 
	# Ao fim, se %n for numero perfeito, %resultado = 1, senão %resultado = 0
	add $t0, %n, 0
	li $t5, 0  # Load inicial de $t5 com 0, armazenará a soma dos divisores 
	li $t1, 1  # Load inicial de divisores 
	# Obs: poderia começar $t5 em 1 e $t1 em 2 pois 1 é divisor universal, porém por 
	# motivos de estética optei por começar dos valores padrões
	loop: 
		beq $t1, $t0, result
		div $t0, $t1  # Dividindo $t0 por $t1 e assim o qouciente estará em LO e o resto em HI
		mfhi $t2  # Recuperando resto da divisão e armaenando em $t2
		bne $t2, $zero, repetir  # Se resto for zero, devo acumalar, senão preparar para repetir loop
		add $t5, $t5, $t1
								
		repetir:  # Preparação padrão para repetir loop
			add $t1, $t1, 1  # Somando mais 1 no divisor $s1
			j loop  # repetindo loop
			
	result:
		bne $t5, $t0, nope  # Se soma não for igual ao número passado, não é
		li $t3, 1
		la %resultado, ($t3)	
		#print_str(" É um número perfeito\n")
		j end
		nope:
			la %resultado, ($zero) 
			#print_str(" NÃO é um número perfeito\n")
	end:
.end_macro

.macro semi_primes(%n, %result)
	add $t0, %n, 0  # em $t0 está o número a ser verificado
	li $t1, 0  # $t1 é um contador
	li $t2, 2  # iterador i iniciando em 2
	li $t5, 2
	
	for:
		mul $t3, $t2, $t2  # para flag de parada do for 
		sgt $t4, $t0, $t3  # sair se i*i chegar em num ($t3<=$t2)
		bne $t4, 1, exit1  
		sgt $t4, $t5, $t1  # se contador < 2, $t4 = 1 
		bne $t4, 1, exit1 # sair se contador chegar em 2 ($t1<2) 
		while:
			div $t0, $t2  # dividindo num / i
			mfhi $t4  # resto da divisão num / i em $t4
			bne $t4, $zero, repet  # enquanto resto de num / i = 0
			mflo $t0  # $t0 passa a ser igual ao resultado da divisão anterior 
			add $t1, $t1, 1  # contador = contador + 1, computando qntd de números primos
			j while
		repet:
			add $t2, $t2, 1  # i = i + 1
			j for	
	exit1:
	
	sgt $t5, $t0, 1  # se $t0 > 1, $t5 = 1
	bne $t5, 1, sets
	add $t1, $t1, 1  # contador = contador + 1
	
	sets:
		la %result, ($zero)  # deixando por garantia resultado falso, retorna 0 no endereço de result
		bne $t1, 2, return  # se contador = 2 então é semiprimo 
		la %result, 1  # retorna 1 no endereço passado de resultado
		# print_str("\nÉ SEMIPRIMO")
		
	return:	
.end_macro
