.include "macros.asm"

.data
	Mat: .space 64 # 4*4 * 4 (inteiro)
	
.text
	main:
		li $a1, 4
		la $a0, Mat # Endere�o base de Mat
      	addi $a2, $a1, 0 # N�mero de colunas
      	jal leitura # leitura(mat, nlin, ncol)
      	move $a0, $v0 # Endere�o da matriz lida
      	jal escrita # escrita(mat, nlin, ncol)
		
		li $s0, 0 # Soma dos valores na diagonal secund�ria
		li $s1, 0 # Aux para armazenar a soma de i + j
		
		move $a0, $v0
		jal diag_secund
		
		print_str("\n A soma dos elementos da diagonal secundaria: ")
      	print_int($s0)
      	
      	terminate
      	
	indice:
		mul $v0, $t0, $a2 # i * ncol
   		add $v0, $v0, $t1 # (i * ncol) + j
   		sll $v0, $v0, 2 # [(i * ncol) + j] * 4 (inteiro)
   		add $v0, $v0, $a3 # Soma o endere�o base de mat
   		jr $ra # Retorna para o caller
   
	leitura:
   		subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endere�o base de mat
	l:
		print_str(" Insira o valor de Mat[") 
		print_int($t0)
   		print_str("][")
   		print_int($t1)
   		print_str("]: ")
   		li $v0, 5 # C�digo de leitura de inteiro
   		syscall # Leitura do valor (retorna em $v0)
   		move $t2, $v0 # aux = valor lido
   		jal indice # Calcula o endere�o de mat[i][j]
   		sw $t2, ($v0) # mat[i][j] = aux
   		addi $t1, $t1, 1 # j++
   		blt $t1, $a2, l # if(j < ncol) goto l
   		li $t1, 0 # j = 0
   		addi $t0, $t0, 1 # i++
   		blt $t0, $a1, l # if(i < nlin) goto l
   		li $t0, 0 # i = 0
   		lw $ra, ($sp) # Recupera o retorno para a main
   		addi $sp, $sp, 4 # Libera o espa�o na pilha
   		move $v0, $a3 # Endere�o base da matriz para retorno
   		jr $ra # Retorna para a main
   
	escrita:
   		subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endere�o base de mat
	e:
		jal indice # Calcula o endere�o de mat[i][j]
   		lw $a0, ($v0) # Valor em mat[i][j]
   		li $v0, 1 # C�digo de impress�o de inteiro
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
   		addi $sp, $sp, 4 # Libera o espa�o na pilha
  		move $v0, $a3 # Endere�o base da matriz para retorno
   		jr $ra # Retorna para a main
   		
   		## A diagonal principal da matriz de ordem n tem elementos em que i + j = n + 1
   		## Neste exemplo a ordem da matriz � de ordem 4, a compara��o ser� feita se i+j do 
   		## elemento em quest�o � igual a 5, se for a soma � realizada, se n�o a matriz continua
   		## at� o fim
   		diag_secund:
   			subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   			sw $ra, ($sp) # Salva o retorno para a main
   			move $a3, $a0 # aux = endere�o base de mat
		ds:
			jal indice # Calcula o endere�o de mat[i][j]
   			lw $a0, ($v0) # Valor em mat[i][j]
   			add $t5, $t0, 1 # Posi��o aux de i
   			add $t6, $t1, 1 # Posi��o aux de j
   			add $s1, $t5, $t6
   			bne $s1, 5, next
   			add $s0, $s0, $a0
   		next:
   			addi $t1, $t1, 1 # j++
   			blt $t1, $a2, ds # if(j < ncol) goto e
   			li $t1, 0 # j = 0
   			addi $t0, $t0, 1 # i++
   			blt $t0, $a1, ds # if(i < nlin) goto e
   			li $t0, 0 # i = 0
	   		lw $ra, ($sp) # Recupera o retorno para a main
   			addi $sp, $sp, 4 # Libera o espa�o na pilha
  			move $v0, $a3 # Endere�o base da matriz para retorno
   			jr $ra # Retorna para a main	
