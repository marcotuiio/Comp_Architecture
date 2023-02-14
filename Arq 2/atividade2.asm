.include "macros.asm"

.data
	Mat: .space 400 # 3x3 * 4 (inteiro)
	
.text
	main:
		print_str("\nInforme a dimensão N da matriz quadrada: ")
		scan_int($a1) # Número de linhas
	  
		la $a0, Mat # Endereço base de Mat
      	addi $a2, $a1, 0 # Número de colunas
      	jal leitura # leitura(mat, nlin, ncol)
      	move $a0, $v0 # Endereço da matriz lida
      	jal escrita # escrita(mat, nlin, ncol)
      	
      	move $a0, $v0
      	li $s1, 9999
      	li $s3, -9999
      	li $s6, 2
      	jal menor
      	
      	move $a0, $v0
      	jal maior_impar
      	
      	print_str("\n Menor elemento é ")
      	print_int($s1)
      	print_str(" e está na linha ")
      	print_int($s2)
      	print_str("\n Maior elemento ímpar é ")
      	print_int($s3)
      	print_str(" e está na linha ")
      	print_int($s4)
		
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
   		
   	## Função que utiliza a função de indice para percorrer a matriz e assim vai comparando elemento
   	## a elemento e armazenando os valores de interesse
   	## $s1 armazena o menor elemento e $s2 armazena a linha do mesmo
   	## $s3 armazena o maior elemento ímpar e $s4 armazena a linha do mesmo	
   	menor:
   		subi $sp, $sp, 4 # Espaço para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endereço base de mat
   	min:
   		jal indice	
   		lw $a0, ($v0) # valor em mat[i][j]
   		bgt $a0, $s1, next
   		move $s1, $a0
   		move $s2, $t0	
   		next:
   			addi $t1, $t1, 1 # j++
   			blt $t1, $a2, min # if(j < ncol) goto e
   			li $t1, 0 # j = 0
   			addi $t0, $t0, 1 # i++
   			blt $t0, $a1, min # if(i < nlin) goto e
   			li $t0, 0 # i = 0
	   		lw $ra, ($sp) # Recupera o retorno para a main
   			addi $sp, $sp, 4 # Libera o espaço na pilha
  			move $v0, $a3 # Endereço base da matriz para retorno
   			jr $ra # Retorna para a main
   		
	maior_impar:
		subi $sp, $sp, 4 # Espaço para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endereço base de mat
	max:
		jal indice # Calcula o endereço de mat[i][j]
		lw $a0, ($v0) # valor em mat[i][j]
   		blt $a0, $s3, next2
   		move $s3, $a0
   		div $s3, $s6  # divisão do valor atual por 2
   		mfhi $s7  # resto da div em $s7
   		beq $s7, 0, next2
   		move $s4, $t0
   		next2:
   			li $t1, 0 # j = 0
   			addi $t0, $t0, 1 # i++
   			blt $t0, $a1, max # if(i < nlin) goto e
	   		li $t0, 0 # i = 0
		   	lw $ra, ($sp) # Recupera o retorno para a main
   			addi $sp, $sp, 4 # Libera o espaço na pilha
  			move $v0, $a3 # Endereço base da matriz para retorno
 	  		jr $ra # Retorna para a main
   		