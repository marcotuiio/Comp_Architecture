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
	add $f12, %x, $zero  # Carregando $a0 com float %x a printar
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
	add $a0, %x, $zero  # Carregando $a0 com o char %c a printar
	addi $v0, $zero, 11  # Informando que o syscall deve printar char
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
	li $s1, 0
	li $s2, 0
	la $s3, %array
	loop_load:	
			beq $s0, $s2, exit
			sll $t1, $s1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t1, $t1, $s3  # Carregando em $t1 = endereço de vetor[i] 
			print_str("v[")
			print_int($s2)
			print_str("] = ")
			scan_int($t2)
			sw $t2, 0($t1)  # Armazenando valor de $t2 na posição [i] $t1 do vetor
			addi $s1, $s1, 1  # Iterador do vetor +1
			addi $s2, $s2, 1  # Iterador estético +1
			j loop_load
	exit:
.end_macro

.macro print_array(%array, %size)
	add $s0, %size, 0
	li $s1, 0
	la $s2, %array
	loop_print:	
			beq $s0, $s1, exit  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t1, $s1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t1, $t1, $s2  # Carregando em $t1 = endereço de vetor[i] 
			lw $t2, 0($t1)  # $t2 = valor de vetor[i]
			print_int($t2)
			print_str(" | ")
			addi $s1, $s1, 1  # Atualizando i = i+1
			j loop_print
	exit:
.end_macro

.macro sum_array(%array, %size, %sum)
	add $s0, %size, 0
	li $s1, 0
	la $s2, %array
	li $s3, 0
	loop_sum:	
			beq $s0, $s1, exit  # Se tamanho máximo do vetor ja foi alcançado, encerrar
			sll $t1, $s1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t1, $t1, $s2  # Carregando em $t1 = endereço de vetor[i] 
			lw $t2, 0($t1)  # $t2 = valor de vetor[i]
			add $s3, $s3, $t2  # Amazenando no endereço fornecido a soma dos elementos do vetor
			addi $s1, $s1, 1  # Atualizando i = i+1
			j loop_sum
	exit:
		la %sum, ($s3)
.end_macro

.macro sort_array(%array, %size)
	add $s0, %size, 0
	add $s5, $s0, -1  # $s5 = Tamanho do vetor -1 (pois são dois loops com essa condição de parada)
	la $s6, %array
	
	li $s3, 0  # i
	loop1:
		beq $s3, $s5, end1  # Se i = tamanho do vetor -1
		li $s2, 1  # auxiliar para acessar o vet[j+1]
		li $s4, 0  # j
		loop2:
			beq $s4, $s5, end2	# Se j = tamanho do vetor -1
			sll $t1, $s4, 2  # Reg temp $t1 = 4*j (indice atual do vetor)
			add $t1, $t1, $s6  # Carregando em $t1 = endereço de vetor[j]
			lw $t2, 0($t1)  # $t2 = valor de vetor[j]
			sll $t3, $s2, 2  # Reg temp $t3 = 4*j+1 (indice atual+1 do vetor)
			add $t3, $t3, $s6  # Carregando em $t3 = endereço de vetor[j+1] 
			lw $t4, 0($t3)  # $t4 = valor de vetor[j+1]
			
			sgt $t0, $t2, $t4  # Se vetor[j] > vetor[j+1], $t0=1
			bne $t0, 1, rept
			swap:
				add $t5, $t2, 0  # $t5 = vet[j] 
				sw $t4, 0($t1)  # vet[j] = vet[j+1], posição 0($t1) recebendo conteúdo de $t4  
				sw $t5, 0($t3)  # vet[j+1] = vet[j], posição 0($t3) recebendo conteúdo de $t5			
			rept:
				addi $s2, $s2, 1  # (j+1) = j+1
				addi $s4, $s4, 1  # j = j + 1
				j loop2
			
		end2:
			addi $s3, $s3, 1  # i = i + 1
			j loop1
	end1:
.end_macro

## Uteis
.macro fatorial(%n, %fat)
	add $t0, %n, 0
	li $t1, 1
	
	zero_um:
		beq $t0, 0, exit
		beq $t0, 1, exit
	
	loop:	
		beq $t0, 1, exit
		mul $t1, $t0, $t1
		sub $t0, $t0, 1 
		j loop
	
	exit:
		la %fat, ($t1)
.end_macro

.macro numero_perfeito(%n, %resultado) 
	# Ao fim, se %n for numero perfeito, %resultado = 1, senão %resultado = 0
	add $s0, %n, 0
	li $s5, 0  # Load inicial de $s5 com 0, armazenará a soma dos divisores 
	li $s1, 1  # Load inicial de divisores 
	# Obs: poderia começar $s5 em 1 e $s1 em 2 pois 1 é divisor universal, porém por 
	# motivos de estética optei por começar dos valores padrões
	loop: 
		beq $s1, $s0, result
		div $s0, $s1  # Dividindo $s0 por $s1 e assim o qouciente estará em LO e o resto em HI
		mfhi $t1  # Recuperando resto da divisão e armaenando em $t1
		bne $t1, $zero, repetir  # Se resto for zero, devo acumalar, senão preparar para repetir loop
		add $s5, $s5, $s1
								
		repetir:  # Preparação padrão para repetir loop
			add $s1, $s1, 1  # Somando mais 1 no divisor $s1
			j loop  # repetindo loop
			
	result:
		bne $s5, $s0, nope  # Se soma não for igual ao número passado, não é
		li $t0, 1
		la %resultado, ($t0)	
		#print_str(" É um número perfeito\n")
		j end
		nope:
			la %resultado, ($zero) 
			#print_str(" NÃO é um número perfeito\n")
	end:
.end_macro
