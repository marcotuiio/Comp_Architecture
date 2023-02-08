.include "macros.asm"

.data
	Mat: .space 36 # 3x3 * 4 (inteiro)
	
.text
	main: la $a0, Mat # Endereço base de Mat
      	li $a1, 3 # Número de linhas
      	li $a2, 3 # Número de colunas
      	jal leitura # leitura(mat, nlin, ncol)
      	move $a0, $v0 # Endereço da matriz lida
      	jal escrita # escrita(mat, nlin, ncol)
		terminate
		
	indice: mul $v0, $t0, $a2 # i * ncol
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
		move $a0, $t0 # Valor de i para impressão
   		li $v0, 1 # Código de impressão de inteiro
   		syscall # Imprime i
   		print_str("][")
   		move $a0, $t1 # Valor de j para impressão
   		li $v0, 1 # Código de impressão de inteiro
   		syscall # Imprime j
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
   		la $a0, 32 # Código ASCII para espaço
   		li $v0, 11 # Código de impressão de caractere
   		syscall # Imprime o espaço
   		addi $t1, $t1, 1 # j++
   		blt $t1, $a2, e # if(j < ncol) goto e
   		la $a0, 10 # Código ASCII para newline ('\n')
   		syscall # Pula a linha
   		li $t1, 0 # j = 0
   		addi $t0, $t0, 1 # i++
   		blt $t0, $a1, e # if(i < nlin) goto e
   		li $t0, 0 # i = 0
	   	lw $ra, ($sp) # Recupera o retorno para a main
   		addi $sp, $sp, 4 # Libera o espaço na pilha
  		move $v0, $a3 # Endereço base da matriz para retorno
   		jr $ra # Retorna para a main
