.include "macros.asm"

.data
	Mat: .space 400 # 10x10 * 4 (inteiro)
	
.text
	main:
		print_str("\nInforme a dimensão N da matriz quadrada: ")
		scan_int($a1) # Número de linhas
	  
		la $a0, Mat # Endereço base de Mat
      	addi $a2, $a1, 0 # Número de colunas
      	jal leitura # leitura(mat, nlin, ncol)
      	move $a0, $v0 # Endereço da matriz lida
      	jal escrita # escrita(mat, nlin, ncol)
      	
      	li $s0, 9999 # Ao final, o menor valor abaixo da diagonal principal estará em $s0
      	li $s1, -9999 # Ao final, o maior valor acima da diagonal principal estará em $s1
      	li $s2, 0 # A = Soma dos valores acima da diag prin
      	li $s3, 0 # B = Soma dos valores abaixo da diag prin
      	li $s4, 0 # Subtração A-B
      	
      	move $a0, $v0
      	jal menor_maior
      	
      	sub $s4, $s2, $s3
      	
      	print_str("\n Menor elemento abaixo da diagonal principal é ")
      	print_int($s0)
      	print_str("\n Maior elemento acima da diagonal principal é ")
      	print_int($s1)
      	print_str("\n Subtração A - B = ")
      	print_int($s2)
      	print_str(" - ")
      	print_int($s3)
      	print_str(" = ")
      	print_int($s4)
      	
      	la $a0, Mat
      	move $a0, $v0
      	mul $s0, $a1, $a1
      	
      	print_str("\n\n Matriz ordenada em ordem crescente: \n")
      	sort_array(Mat, $s0)
      	
		li $t1, 0
		la $t2, Mat
		li $t7, 0
		loop_print:	
				beq $s0, $t1, exit  # Se tamanho mÃ¡ximo do vetor ja foi alcançado, encerrar
				sll $t3, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
				add $t3, $t3, $t2  # Carregando em $t1 = endereço de vetor[i] 
				lw $t4, 0($t3)  # $t2 = valor de vetor[i]
				print_int($t4)
				print_str(" ")
				addi $t1, $t1, 1  # Atualizando i = i+1
				addi $t7, $t7, 1
				bne $t7, $a1, loop_print
				print_str("\n")
				li $t7, 0
				j loop_print
		exit:
      	
		terminate
		
	indice:
		mul $v0, $t0, $a2 # i * ncol
   		add $v0, $v0, $t1 # (i * ncol) + j
   		sll $v0, $v0, 2 # [(i * ncol) + j] * 4 (inteiro)
   		add $v0, $v0, $a3 # Soma o endereço base de mat
   		jr $ra # Retorna para o caller
   
	leitura:
   		subi $sp, $sp, 4 # Espaço para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endereço base de mat
	l:
		print_str(" Insira o valor de Mat[") 
		print_int($t0)
   		print_str("][")
   		print_int($t1)
   		print_str("]: ")
   		li $v0, 5 # Código de leitura de inteiro
   		syscall # Leitura do valor (retorna em $v0)
   		move $t2, $v0 # aux = valor lido
   		jal indice # Calcula o endereço de mat[i][j]
   		sw $t2, ($v0) # mat[i][j] = aux
   		addi $t1, $t1, 1 # j++
   		blt $t1, $a2, l # if(j < ncol) goto l
   		li $t1, 0 # j = 0
   		addi $t0, $t0, 1 # i++
   		blt $t0, $a1, l # if(i < nlin) goto l
   		li $t0, 0 # i = 0
   		lw $ra, ($sp) # Recupera o retorno para a main
   		addi $sp, $sp, 4 # Libera o espaço na pilha
   		move $v0, $a3 # Endereço base da matriz para retorno
   		jr $ra # Retorna para a main
   
	escrita:
   		subi $sp, $sp, 4 # Espaço para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endereço base de mat
	e:
		jal indice # Calcula o endereço de mat[i][j]
   		lw $a0, ($v0) # Valor em mat[i][j]
   		li $v0, 1 # Código de impressão de inteiro
   		syscall # Imprime mat[i][j]
   		print_str(" ")
   		addi $t1, $t1, 1 # j++
   		blt $t1, $a2, e # if(j < ncol) goto e
   		print_str("\n")
   		li $t1, 0 # j = 0
   		addi $t0, $t0, 1 # i++
   		blt $t0, $a1, e # if(i < nlin) goto e
   		li $t0, 0 # i = 0
	   	lw $ra, ($sp) # Recupera o retorno para a main
   		addi $sp, $sp, 4 # Libera o espaço na pilha
  		move $v0, $a3 # Endereço base da matriz para retorno
   		jr $ra # Retorna para a main
   		
   	## Os elementos abaixo da diag princ têm i > j, ou seja, $t0 > $t1 	
   	## enquanto os elementos acima da diag princ têm i < j, ou seja, $t0 < $t1
   	menor_maior:
   		subi $sp, $sp, 4 # Espaço para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endereço base de mat
	shared:
		jal indice # Calcula o endereço de mat[i][j]
   		lw $a0, ($v0) # Valor em mat[i][j]
   		beq $t0, $t1, next
   		bgt $t0, $t1, menor # $t0 > $t1 vai pra menor
   		maior:
   		add $s2, $s2, $a0
   		blt $a0, $s1, next
   		move $s1, $a0
   		j next
   		menor: 
   		add $s3, $s3, $a0 # soma dos abaixo
   		bgt $a0, $s0, next # se valor em $a0 for maior que o de $s0, não troca
   		move $s0, $a0 # colocando em $s0 o menor valor
   		
   		next:
   			addi $t1, $t1, 1 # j++
   			blt $t1, $a2, shared # if(j < ncol) goto e
   			li $t1, 0 # j = 0
   			addi $t0, $t0, 1 # i++
   			blt $t0, $a1, shared # if(i < nlin) goto e
   			li $t0, 0 # i = 0
	   		lw $ra, ($sp) # Recupera o retorno para a main
   			addi $sp, $sp, 4 # Libera o espaço na pilha
  			move $v0, $a3 # Endereço base da matriz para retorno
   			jr $ra # Retorna para a main
   			
