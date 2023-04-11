.include "macros.asm"

.data
	Error: .asciiz "Arquivo nao encontrado!\n"
	FilePath: .asciiz "C:\\Users\\marco\\Desktop\\UEL\\Comp_Architecture\\Arq2\\dados2.txt"
	Buffer: .asciiz " "
	vetor: .space 512
.text

	main:
		
		jal fopen
		move $s0, $v0
		
		la $s1, vetor
		li $s2, 0 # indice do vetor
		jal fscanf
		print_str("\n\n Numeros lidos de dados2.txt: ")
		jal print_array
		jal fclose
		
		li $t2, -1
		jal maior
		print_str("\n\n A) Maior numero do vetor: ")
		print_int($t2)

		li $t2, 99999
		jal menor
		print_str("\n\n B) Menor numero do vetor: ")
		print_int($t2)

		li $t2, 0 # qntd impares
		li $t3, 0 # qntd pares
		jal impares_pares
		print_str("\n\n C) Quantidade de numeros impares: ")
		print_int($t2)
		print_str("\n\n D) Quantidade de numeros pares: ")
		print_int($t3)

		li $t2, 0 # soma
		jal soma
		print_str("\n\n E) Soma dos numeros do vetor: ")
		print_int($t2)

		jal sort_crescente
		print_str("\n\n F) Vetor ordenado em ordem crescente: ")
		jal print_array

		jal sort_decrescente
		print_str("\n\n G) Vetor ordenado em ordem decrescente: ")
		jal print_array

		li $t2, 1 # produto
		jal produto
		print_str("\n\n H) Produto dos numeros do vetor: ")
		print_int($t2)

		jal fopen
		li $t0, 0 # contador
		jal count_chars
		print_str("\n\n I) Numero de characters no arquivo: ")
		print_int($t0)
		jal fclose

		terminate
		
	fopen:
		la $a0, FilePath
		li $a1, 0 # somente leitura
		li $v0, 13
		syscall
		blez $v0, erro # verifica se ocorreu erro ao abrir o arquivo
		jr $ra # retorna com o identificador do arquivo em $v0
		erro: 
			la $a0, Error
			li $v0, 4
			syscall
			li $v0, 10
			syscall

	fclose:
		move $a0, $s0
		li $v0, 16
		syscall
		jr $ra

	count_chars:
		move $a0, $s0
		la $a1, Buffer
		li $a2, 1
		count:
			li $v0, 14
			syscall
			addi $t0, $t0, 1
			bnez $v0, count # (if !EOF goto count)
			subi $t0, $t0, 1 # desconsiderando EOF
			jr $ra

	fscanf:
		move $a0, $s0
		la $a1, Buffer
		li $a2, 1

		read:
			li $v0, 14
			syscall
			beqz $v0, return_eof # (if !EOF goto count)
			lb $t0, ($a1) # lê o primeiro dígito do número
			beq $t0, 13, read
            beq $t0, 32, read # verifica se o dígito é um espaço em branco
            beq $t0, 10, read # verifica se o dígito é o fim de linha
			li $t1, 0
			bne $t0, 45, to_int # verifica se o dígito é um sinal de negativo
			li $t7, 1 # se for, seta a variavel de sinal para 1
			j read
			to_int:
				subi $t0, $t0, 48
				mul $t1, $t1, 10
				add $t1, $t1, $t0

				li $v0, 14
				syscall
				beqz $v0, save_number # (if EOF goto save_number and return_eof)
				lb $t0, ($a1) # lê o próximo dígito do número
				beq $t0, 13, save_number
				beq $t0, 10, save_number # verifica se o digito e fim de linha
				beq $t0, 32, save_number # verifica se o digito e espaco em branco
				
				j to_int

			save_number:
				sll $t4, $s2, 2
				add $t4, $t4, $s1
				bne $t7, 1, s 
				negativo:
					mul $t1, $t1, -1
				s:
					sw $t1, 0($t4)
					addi $s2, $s2, 1 
				li $t7, 0 # reinicializa a variavel de sinal
				li $t1, 0 # reinicializa a variavel do numero lido
				j read

		return_eof:
			jr $ra

    print_array:
        li $t1, 0
        loop:
            beq $s2, $t1, exit 
            sll $t5, $t1, 2 
            add $t5, $t5, $s1 
            lw $t4, 0($t5)  
            print_int($t4)
            print_str(" ")
            addi $t1, $t1, 1 
            j loop
		exit:
			jr $ra

	maior:
		li $t1, 0
		loop1:
			beq $s2, $t1, exit1
			sll $t5, $t1, 2
			add $t5, $t5, $s1
			lw $t4, 0($t5)
			addi $t1, $t1, 1
			bgt $t2, $t4, loop1
			move $t2, $t4
			j loop1
		exit1:
			jr $ra

	menor:
		li $t1, 0
		loop2:
			beq $s2, $t1, exit2
			sll $t5, $t1, 2
			add $t5, $t5, $s1
			lw $t4, 0($t5)
			addi $t1, $t1, 1
			blt $t2, $t4, loop2
			move $t2, $t4
			j loop2
		exit2:
			jr $ra

	impares_pares:
		li $t1, 0
		li $t6, 2
		loop3:
			beq $s2, $t1, exit3
			sll $t5, $t1, 2
			add $t5, $t5, $s1
			lw $t4, 0($t5)
			addi $t1, $t1, 1
			div $t4, $t6
			mfhi $t7
			beqz $t7, par # se resto da divisao por 2 for 0 == par, else == impar

			impar: 
				addi $t2, $t2, 1
				j loop3
			par:
				addi $t3, $t3, 1
				j loop3
		exit3:
			jr $ra

	soma:
		li $t1, 0
		loop4:
			beq $s2, $t1, exit4
			sll $t5, $t1, 2
			add $t5, $t5, $s1
			lw $t4, 0($t5)
			addi $t1, $t1, 1
			add $t2, $t2, $t4
			j loop4
		exit4:
			jr $ra	

	produto:
		li $t1, 0
		loop5:
			beq $s2, $t1, exit5
			sll $t5, $t1, 2
			add $t5, $t5, $s1
			lw $t4, 0($t5)
			addi $t1, $t1, 1
			mul $t2, $t2, $t4
			j loop5
		exit5:
			jr $ra


	sort_crescente:
		subi $s5, $s2, 1  # $s5 = Tamanho do vetor -1 (pois são dois loops com essa condição de parada)		
		li $t6, 0  # i
		lp1:
			beq $t6, $s5, end1  # Se i = tamanho do vetor -1
			li $s3, 1  # auxiliar para acessar o vet[j+1]
			li $s4, 0  # j
			lp2:
				beq $s4, $s5, end2	# Se j = tamanho do vetor -1
				sll $t1, $s4, 2  # Reg temp $t1 = 4*j (indice atual do vetor)
				add $t1, $t1, $s1  # Carregando em $t1 = endereço de vetor[j]
				lw $t2, 0($t1)  # $t2 = valor de vetor[j]
				sll $t3, $s3, 2  # Reg temp $t3 = 4*j+1 (indice atual+1 do vetor)
				add $t3, $t3, $s1  # Carregando em $t3 = endereço de vetor[j+1] 
				lw $t4, 0($t3)  # $t4 = valor de vetor[j+1]
				blt $t2, $t4, rept  # Se vetor[j] < vetor[j+1], $t0=0
				swap:
					move $t5, $t2  # $t5 = vet[j] 
					sw $t4, 0($t1)  # vet[j] = vet[j+1], posição 0($t1) recebendo conteúdo de $t4  
					sw $t5, 0($t3)  # vet[j+1] = vet[j], posição 0($t3) recebendo conteúdo de $t5			
				rept:
					addi $s3, $s3, 1  # (j+1) = j+1
					addi $s4, $s4, 1  # j = j + 1
					j lp2
				
			end2:
				addi $t6, $t6, 1  # i = i + 1
				j lp1
		end1:
			jr $ra

	sort_decrescente:
		subi $s5, $s2, 1  # $s5 = Tamanho do vetor -1 (pois são dois loops com essa condição de parada)		
		li $t6, 0  # i
		lp11:
			beq $t6, $s5, end11  # Se i = tamanho do vetor -1
			li $s3, 1  # auxiliar para acessar o vet[j+1]
			li $s4, 0  # j
			lp22:
				beq $s4, $s5, end22	# Se j = tamanho do vetor -1
				sll $t1, $s4, 2  # Reg temp $t1 = 4*j (indice atual do vetor)
				add $t1, $t1, $s1  # Carregando em $t1 = endereço de vetor[j]
				lw $t2, 0($t1)  # $t2 = valor de vetor[j]
				sll $t3, $s3, 2  # Reg temp $t3 = 4*j+1 (indice atual+1 do vetor)
				add $t3, $t3, $s1  # Carregando em $t3 = endereço de vetor[j+1] 
				lw $t4, 0($t3)  # $t4 = valor de vetor[j+1]
				bgt $t2, $t4, rept1  # Se vetor[j] < vetor[j+1], $t0=0
				swap1:
					move $t5, $t2  # $t5 = vet[j] 
					sw $t4, 0($t1)  # vet[j] = vet[j+1], posição 0($t1) recebendo conteúdo de $t4  
					sw $t5, 0($t3)  # vet[j+1] = vet[j], posição 0($t3) recebendo conteúdo de $t5			
				rept1:
					addi $s3, $s3, 1  # (j+1) = j+1
					addi $s4, $s4, 1  # j = j + 1
					j lp22
				
			end22:
				addi $t6, $t6, 1  # i = i + 1
				j lp11
		end11:
			jr $ra
		
