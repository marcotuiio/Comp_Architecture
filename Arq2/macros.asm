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
			slt $t0, $t2, $t4  # Se vetor[j] < vetor[j+1], $t0=1
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
	mul $s0, %n, %m
	li $t1, 0
	la $t2, %matrix
	li $t7, 0
	loop_print:	
			beq $s0, $t1, exit  # Se tamanho máximo do vetor ja foi alcan�ado, encerrar
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
	li $a1, 9
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

.macro count_char(%file_descriptor, %result)
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
