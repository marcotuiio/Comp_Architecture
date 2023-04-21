### File for creating macros (subroutines)

.macro terminate
	addi $v0, $zero, 10  # Encerrando o programa
	syscall
.end_macro

.macro calloc(%size, %return)
	li $v0, 9
	la $a0, (%size)
	syscall
	la %return, ($v0) 
.end_macro

## PRINTS
.macro print_int(%x)
	add $a0, %x, $zero  # Carregando $a0 com int %x a printar
	addi $v0, $zero, 1  # Informando que o syscall deve printar int
	syscall
.end_macro

.macro print_float(%x)
	mov.s $f12, %x  # Carregando $a0 com float %x a printar
	li $v0, 2  # Informando que o syscall deve printar int
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
	move $a0, %c  # Carregando $a0 com o char %c a printar
	li $v0, 11  # Informando que o syscall deve printar char
	syscall
.end_macro 

## SCANS
.macro scan_int(%a)
	li $v0, 5  # Informando que o syscall deverá ler um int
	syscall
	add %a, $v0, $zero  # Armazenando A em $s0
.end_macro

.macro scan_float(%a)
	li $v0, 6  # Informando que o syscall deverá ler um float
	syscall
	mov.s %a, $f0
.end_macro

.macro scan_char(%a)
	addi $v0, $zero, 12  # Informando que o syscall deverá ler um float
	syscall
	add %a, $v0, $zero  # Armazenando A em $s0
.end_macro

.macro scan_str(%input, %size)
	li $v0, 8  # Informando que o syscall deverá ler uma string
	move $a0, %input  # Carregando em $a0 o endereço de memória da string a ser lida
	move $a1, %size  # Carregando em $a1 o tamanho máximo da string a ser lida
	syscall
.end_macro

.macro strcmp(%str1, %str2, %return)
	move $s0, %str1  # Carregando em $s0 o endereço da primeira string
	move $s7, %str2  # Carregando em $s7 o endereço da segunda string

	print_str("Comparando ")
	move $a0, $s0
	li $v0, 4
	syscall
	print_str(" com ")
	move $a0, $s7
	li $v0, 4
	syscall

	li $t5, 0      # inicializa contador de posição na string
	loop_strcmp:
		lbu $t2, ($s0) # carrega byte da primeira string
		lbu $t6, ($s7) # carrega byte da segunda string
		beqz $t2, end  # se chegar ao final da string, sai do loop
		bne $t2, $t6, dif # se os bytes são diferentes, sai do loop
		addi $s0, $s0, 1 # avança posição na primeira string
		addi $s7, $s7, 1 # avança posição na segunda string
		j loop_strcmp         # volta ao início do loop
	dif:
		li $v1, 1       # as strings são diferentes
		j return
	end:
		li $v1, 0       # as strings são iguais
	return:
		move %return, $v1
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

.macro scan_array_din(%array, %size)
	add $s7, %size, 0
	li $t1, 0
	li $t2, 0
	loop_load:	
			beq $s7, $t2, exit
			sll $t4, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t4, $t4, %array  # Carregando em $t1 = endereço de vetor[i] 
			print_str("v[")
			print_int($t2)
			print_str("] = ")
			scan_float($f1)
			s.s $f1, 0($t4)  # Armazenando valor real em $f1 na posição [i] $t4 do vetor
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

.macro print_array_din(%array, %size)
	add $s0, %size, 0
	li $t1, 0
	loop_print:	
			beq $s0, $t1, exit  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t3, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t3, $t3, %array  # Carregando em $t3 = endereço de vetor[i] 
			l.s $f2, 0($t3)  # $t2 = valor de vetor[i]
			print_float($f2)
			print_str(" | ")
			addi $t1, $t1, 1  # Atualizando i = i+1
			j loop_print
	exit:
.end_macro

.macro print_array_char(%array, %size)
	add $s0, %size, 0
	li $t1, 0
	la $t2, %array
	loop_print:	
			beq $s0, $t1, exit  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t3, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t3, $t3, $t2  # Carregando em $t1 = endereço de vetor[i] 
			lb $a0, 0($t3)  # $t2 = valor de vetor[i]
			li $v0, 11  # Informando que o syscall deve printar char
			syscall
			print_str(" | ")
			addi $t1, $t1, 1  # Atualizando i = i+1
			j loop_print
	exit:
.end_macro

.macro clean_string(%string)
	move $a0, %string
	li $t8, 0         # inicializa o contador de posição da string        
	cleaning:
		sll $t2, $t8, 0
		add $t2, $t2, $a0
		lb $t1, 0($t2)     # carrega o caractere
		beqz $t1, end_cleaning # termina o loop se o caractere é zero
		sb $zero, 0($t2)   # substitui o caractere por zero
		addi $t8, $t8, 1  # avança para o próximo caractere
		bnez $t1, cleaning    # repete o loop se o próximo caractere não é zero
	end_cleaning:
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

.macro bubble_sort(%array, %size)
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
			blt $t2, $t4, rept  # Se vet[j] < vet[j+1], não fazer swap
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

.macro sort_array_decrescente(%array, %size)
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
			bgt $t2, $t4, rept  # Se vet[j] > vet[j+1], não fazer swap
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

.macro insertion_sort(%array, %size)
	move $s0, %array
	move $s1, %size
	li $t1, 1 # i = 1
	loop_for:
		beq $t1, $s1, end_for  # Se i = tamanho do vetor, encerrar
		sub $t2, $t1, 1 # j = i - 1
		
		sll $t3, $t1, 2  # Reg temp $t3 = 4*i (indice atual do vetor)
		add $t3, $t3, $s0  # Carregando em $t3 = endereço de vetor[i]
		lw $t4, 0($t3)  # $t4 = valor de vetor[i]

		sll $t5, $t2, 2  # Reg temp $t5 = 4*j (indice atual do vetor)
		add $t5, $t5, $s0  # Carregando em $t5 = endereço de vetor[j]
		lw $t6, 0($t5)  # $t6 = valor de vetor[j]

		loop_while:
			bltz $t2, end_while  # Se j < 0, encerrar
			blt $t6, $t4, end_while

			addi $t5, $t2, 1 # $t5 = j+1
			sll $t5, $t5, 2  # Reg temp $t5 = 4*(j+1) (indice atual do vetor)
			add $t5, $t5, $s0  # Carregando em $t5 = endereço de vetor[j+1]
			sw $t6, 0($t5)  # vetor[j+1] = vetor[j]

			subi $t2, $t2, 1  # j = j - 1
			sll $t5, $t2, 2  # Reg temp $t5 = 4*j (indice atual do vetor)
			add $t5, $t5, $s0  # Carregando em $t5 = endereço de vetor[j]
			lw $t6, 0($t5)  # $t6 = valor de vetor[j]
			j loop_while
		
			end_while:
				addi $t5, $t2, 1 # $t5 = j+1
				sll $t5, $t5, 2  # Reg temp $t5 = 4*(j+1) (indice atual do vetor)
				add $t5, $t5, $s0  # Carregando em $t5 = endereço de vetor[j+1]
				sw $t4, 0($t5)  # vetor[j+1] = vetor[i]
				addi $t1, $t1, 1  # i = i + 1
				j loop_for
		end_for:
			j loop
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

.macro has_element_float(%array, %size, %element, %result)
	add $s7, %size, 0
	mov.s $f0, %element
	li $t0, 0
	.data
		errorFloat: .float -9999.0
	.text
	loop_load:	
			beq $s7, $t0, exit
			sll $t7, $t0, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t7, $t7, %array  # Carregando em $t1 = endereço de vetor[i]
			l.s $f8, 0($t7)  # $t2 = valor de vetor[i]
			c.eq.s $f8, $f0
			bc1t equals
			addi $t0, $t0, 1  # Iterador do vetor +1
			j loop_load
	equals:
		mov.s %result, $f8
		j end
	exit:
		lwc1 %result, errorFloat
	end:
.end_macro

.macro print_matrix(%matrix, %n, %m) # imprime matriz com n linhas e m colunas
	mul $t6, %n, %m
	li $t1, 0
	la $t2, %matrix
	li $t7, 0
	loop_print:	
			beq $t6, $t1, exit  # Se tamanho máximo do vetor ja foi alcan�ado, encerrar
			sll $t3, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t3, $t3, $t2  # Carregando em $t1 = endere�o de vetor[i] 
			lb $a0, 0($t3)  # $a0 = valor de vetor[i]
			li $v0, 11  # Informando que o syscall deve printar char
			syscall
			print_str(" ")
			addi $t1, $t1, 1  # Atualizando i = i+1
			addi $t7, $t7, 1
			bne $t7, %m, loop_print
			print_str("\n")
			li $t7, 0
			j loop_print
		exit:
.end_macro

.macro init_array(%array, %size)

    li $t5, 0 # inicializa iterador com 0
    .data
		bigFloat: .float 9999.0
	.text
	lwc1 $f5, bigFloat
    loop:
        beq $t5, %size, exit # verifica se iterador >= tamanho do vetor, caso verdadeiro, pula para a sa�da
        sll $t7, $t5, 2 # multiplica iterador por 4 (tamanho de uma palavra) para obter o deslocamento de byte correspondente � posi��o do vetor
        add $t7, $t7, %array # adiciona deslocamento � base do vetor para obter o endere�o da posi��o atual
        s.s $f5, 0($t7) # armazena o valor na posi��o atual
        addi $t5, $t5, 1 # incrementa o iterador
        j loop # pula para o in�cio do loop
    exit:
.end_macro

## Uteis
.macro fatorial(%n, %fat)
	add $t0, %n, 0
	li $t1, 1
	
	zero_um:
		beq $t0, 0, exit  # Se numero passado for igual a zero ou 1, dispensa loop
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

.macro potencia(%x, %pot, %result) # n ^pot
	mov.s $f3, %x
	addi $t4, %pot, 0
	li $t5, 0 # contador
	.data
		oneFloat: .float 1.0
	.text
	lwc1 $f5, oneFloat
	loop:	
		beq $t5, $t4, end
		mul.s $f5, $f5, $f3
		add $t5, $t5, 1
		j loop
	end:
	mov.s %result, $f5
.end_macro

.macro all_primes(%n, %vetor)
	move $s1, %n
	li $t0, 2 
	sll $t4, $s3, 2 
	add $t4, $t4, $s2
	sw $t0, 0($t4)
	addi $s3, $s3, 1

	li $t0, 3
	sll $t4, $s3, 2 
	add $t4, $t4, $s2
	sw $t0, 0($t4)
	addi $s3, $s3, 1

	li $t0, 5  # numero inicial a ser testado que funciona nesse processo
	li $t1, 2  # divisor
	subi $t2, $t0, 1 # limite do loop
	primo: 
		bgt $t0, $s1, fim
		bge $t1, $t2, next
		div $t0, $t1 # n atual / divisor
		mfhi $t3 # resto da divisao
		beqz $t3, next # se resto for zero, nao eh primo
		addi $t1, $t1, 1 # proximo divisor
		bne $t1, $t2, primo
		salvar:
			sll $t4, $s3, 2 
			add $t4, $t4, $s2
			sw $t0, 0($t4)
			addi $s3, $s3, 1 
		next:
			addi $t0, $t0, 1 # proximo numero a ser testado
			li $t1, 2 # divisor
			sub $t2, $t0, 1 # limite do loop 
			j primo
	fim:
		move %vetor, $s2
.end_macro

## FILES
.macro fopen_read(%file_name, %file_descriptor)
	.data
		Error: .asciiz "Arquivo nao encontrado!\n"
		file: .asciiz %file_name
	.text
	la $a0, file
	li $a1, 0 # somente leitura
	li $v0, 13
	syscall
	bgez $v0, fim
	erro: 
		la $a0, Error
		li $v0, 4
		syscall
		li $v0, 10
		syscall
	fim:
		move %file_descriptor, $v0
.end_macro

.macro fopen_write(%file_name, %file_descriptor)
	.data
		Error: .asciiz "Arquivo nao encontrado!\n"
		file: .asciiz %file_name
	.text
	la $a0, file
	li $a1, 1
	li $v0, 13
	syscall
	bgez $v0, fim
	erro: 
		la $a0, Error
		li $v0, 4
		syscall
		li $v0, 10
		syscall
	fim:
		move %file_descriptor, $v0
.end_macro

.macro fclose(%file_descriptor)
	move $a0, %file_descriptor
	li $v0, 16
	syscall
.end_macro

.macro count_char_file(%file_descriptor, %result)
	.data
		buffer: .asciiz " "
	.text
		move $a0, %file_descriptor
		la $a1, buffer
		li $a2, 1
		count:
			li $v0, 14
			syscall
			addi $t0, $t0, 1
			bnez $v0, count # (if !EOF goto count)
			subi $t0, $t0, 1 # desconsiderando EOF
		move %result, $t0
.end_macro

.macro count_char_str(%string, %result)
	move $a0, %string
	li $t0, 0
	count:
		lb $t1, ($a0)
		beq $t1, 0, end
		addi $t0, $t0, 1
		addi $a0, $a0, 1
		j count
	end:
		move %result, $t0
.end_macro

.macro fscanf(%file_descriptor, %array_result)
	.data
		buffer: .asciiz " "
	.text
	move $a0, %file_descriptor
	la $a1, buffer
	li $a2, 1
	li $t1, 0
		read:
			li $v0, 14
			syscall
			beqz $v0, return_eof # (if !EOF goto count)
			lb $t0, ($a1) # lê o primeiro dígito do número
			
			beq $t0, 10, save_number # verifica se o dígito é um \n
			beq $t0, 13, read # verifica se o dígito é um \r
			beq $t0, 32, read # verifica se o dígito é um espaço em branco
			li $t1, 0
			bne $t0, 45, to_int # verifica se o dígito é um sinal de negativo
			li $t7, 1
			j read
			to_int:
				subi $t0, $t0, 48
				mul $t1, $t1, 10
				add $t1, $t1, $t0
				
				li $v0, 14
				syscall
				beqz $v0, return_eof # (if !EOF goto count)				
				lb $t0, ($a1) # lê o próximo dígito do número
				beq $t0, 10, save_number # verifica se o dígito é um \n
				beq $t0, 13, save_number # verifica se o dígito é um \r
				beq $t0, 32, save_number # verifica se o dígito é um espaço em branc

				j to_int

			save_number:
				# sll $t4, $t3, 2
				# add $t4, $t4, $s1
				# sw $t1, 0($t4)
				# addi $t3, $t3, 1 
				bne $t7, 0, p
				negativo: 
					mul $t1, $t1, -1
				p:
					print_int($t1)
				li $t7, 0
				li $t1, 0
				j read

		return_eof:
.end_macro

.macro array_to_string(%array, %size, %resultado)
	.data
		string: .space 1024
	.text
	li $t0, 0 # contador vetor
	li $t1, 0 # iterador string
	la $t2, string
	move $s6, %array
	move $s7, %size
	lp:
		beq $t0, $s7, sai 
		sll $t5, $t0, 2
		add $t5, $t5, $s6
		lw $t4, 0($t5)
		addi $t0, $t0, 1

		blt $t4, 100, dezena

		centena:
			li $t5, 100
			li $t6, 48
			div $t4, $t5
			mflo $t7

			add $t7, $t7, $t6
			sll $t5, $t1, 0
			add $t5, $t5, $t2
			sb $t7, 0($t5)
			addi $t1, $t1, 1

		dezena_especial:
				li $t5, 10
				li $t6, 48
				div $t4, $t5
				mflo $t7
				div $t7, $t5
				mfhi $t7

				add $t7, $t7, $t6
				sll $t5, $t1, 0
				add $t5, $t5, $t2
				sb $t7, 0($t5)
				addi $t1, $t1, 1

				li $t5, 10
				div $t4, $t5
				j unidade

		dezena: 
			li $t5, 10
			li $t6, 48
			div $t4, $t5
			blt $t4, 10, unidade
			mflo $t7

			add $t7, $t7, $t6
			sll $t5, $t1, 0
			add $t5, $t5, $t2
			sb $t7, 0($t5)
			addi $t1, $t1, 1

		unidade:   
			mfhi $t7
			add $t7, $t7, $t6
			sll $t5, $t1, 0
			add $t5, $t5, $t2
			sb $t7, 0($t5)
			addi $t1, $t1, 1

		space:
			li $t6, 32
			sll $t5, $t1, 0
			add $t5, $t5, $t2
			sb $t6, 0($t5)
			addi $t1, $t1, 1
		j lp
	sai:
		li $t6, 10
		sll $t5, $t1, 0
		add $t5, $t5, $t2
		sb $t6, 0($t5)

		move %resultado, $t2
.end_macro

## LINKED LIST
.macro create_linked_list(%header)
	.data
		list: .word 12, 0, 0 # word size, number of elements, head
	.text
	la (%header), list
	lw $t0, 0(%header)
	calloc($t0, %header)
.end_macro

.macro add_node(%list, %info)
	.data 
		list: .word 12, 0, 0 # word size, number of elements, head
		node: .word 12, 0, 0 # word size, info, next 
	.text
	move $s0, %list
	move $t2, %info
	
	la $s2, node
	lw $a0, 0($s2) # load word size
	calloc($a0, $s3)
	sw $t2, 4($s3) # node->info = info
	sw $zero, 8($s3) # node->next = null
	
	lw $t1, 8($s0) # load head
	beqz $t1, first_node # if head == null, first_node
	traverse:
		lw $t2, 8($t1) # load next
		beqz $t2, save_node # if next == null, plus
		next_node:
			move $t1, $t2 # previous = next
			j traverse
		save_node:
			sw $s3, 8($t1) # previous->next = node
			j plus

	first_node:
		sw $s3, 8($s0) # head = node
	plus:
		lw $t2, 4($s0) # load size
		addi $t2, $t2, 1 # size++
		sw $t2, 4($s0) # list->size = size
	j loop
.end_macro

.macro delete_node(%list, %value)
    .data 
		list: .word 12, 0, 0 # word size, number of elements, head
		node: .word 12, 0, 0 # word size, info, next 
	.text
	move $s0, %list
	move $t2, %info

	lw $t1, 8($s0) # load head
	beqz $t1, loop # if head == null, loop
	remove_loop:
		lw $t3, 4($t1) # load current info
		beq $t2, $t3, remove
		move $t4, $t1 # save previous
		lw $t1, 8($t1) # load next
		bnez $t1, remove_loop
		print_str("\nInfo not found\n")
		j loop
		remove:
			print_str("\nNode found: ")
			print_int($t3)
			# t1 = current to be removed
			# t4 = previous
			lw $t5, 8($s0) # load head
			bne $t1, $t5, not_head # if current == head, remove_head
			if_head:
				lw $t5, 8($t1) # load next
				sw $t5, 8($s0) # head = next
				j minus
			not_head:    
				lw $t5, 8($t1) # load next
				sw $t5, 8($t4) # previous->next = next
			minus:
				lw $t1, 4($s0) # load word size
				subi $t1, $t1, 1
				sw $t1, 4($s0) # list->size--
			print_str("\nNode removed\n")
			j loop
.end_macro

.macro print_linked_list(%list)
	.data 
		list: .word 12, 0, 0 # word size, number of elements, head
		node: .word 12, 0, 0 # word size, info, next 
	.text
	move $s0, %list
	print_list:
        lw $t2, 8($s0) # load head
        beqz $t2, loop # if head == null, loop
        print_str("\nList: ")
        print_loop:
            lw $t3, 4($t2) # load info
            print_int($t3)
            print_str(" ")
            lw $t2, 8($t2) # load next
            bnez $t2, print_loop
        print_str("\n")
        j loop
.end_macro

.macro print_list_size(%list)
	.data 
		list: .word 12, 0, 0 # word size, number of elements, head
		node: .word 12, 0, 0 # word size, info, next 
	.text
	move $s0, %list
	print_size:
        lw $t2, 4($s0) # load size
        print_str("\nSize: ")
        print_int($t2)
        print_str("\n")
        j loop
.end_macro

.macro sort_list_ascending(%list)
	.data 
		list: .word 12, 0, 0 # word size, number of elements, head
		node: .word 12, 0, 0 # word size, info, next 
	.text
	print_str("\nSorting list in ascending order\n")
	move $s0, %list
	lw $t1, 8($s0) # load head
	beqz $t1, loop

	lw $t2, 4($s0) # size
	subi $t2, $t2, 1 # flag 
	li $t3, 0 # i
	lp1:
		beq $t3, $t2, end1
		lw $t1, 8($s0)
		li $t4, 0 # j
		lp2:
			beq $t4, $t2, end2
			lw $t5, 4($t1) # vet[j]
			lw $t6, 8($t1) # next 
			lw $t7, 4($t6) # vet[j+1]
			blt $t5, $t7, rept1 # if vet[j] < vet[j+1], NEXT
			swap1:
				sw $t7, 4($t1) # vet[j] = valor vet[j+1]
				sw $t5, 4($t6) # vet[j+1] = valor vet[j]
			rept1:
				lw $t1, 8($t1)
				addi $t4, $t4, 1
				j lp2
		end2:
			addi $t3, $t3, 1
			j lp1
	end1:
		j loop
.end_macro

.macro find_index_list(%list, %value)
	.data 
		list: .word 12, 0, 0 # word size, number of elements, head
		node: .word 12, 0, 0 # word size, info, next 
	.text
	move $s0, %list
	move $t2, %value

	lw $t1, 8($s0) # load head
	beqz $t1, loop # if head == null, loop
	li $t5, 0
	looking_loop:
		lw $t3, 4($t1) # load current info
		beq $t2, $t3, found
		move $t4, $t1 # save previous
		lw $t1, 8($t1) # load next
		addi $t5, $t5, 1
		bnez $t1, looking_loop
		print_str("\nInfo not found\n")
		j loop
		found:
			print_str("\nNode found, ")
			print_int($t3)
			print_str(" in index ")
			print_int($t5)
			print_str("\n")
			j loop
.end_macro