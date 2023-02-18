.include "macros.asm"

.data
	Mat: .space 400 # 10x10 * 4 (inteiro)
	vet: .space 256 # 8x8 * 4
	
.text
	main:
		print_str("\nInforme a dimensão N da matriz: ")
		scan_int($a1) # Número de linhas
	  	print_str("Informe a dimensão M da matriz: ")
		scan_int($a2) # Número de colunas 	
		
		li $s0, 0 # Contador de vogais
		
		la $a0, Mat # Endereço base de Mat
      	jal leitura # leitura(mat, nlin, ncol)
      	print_str("\n\n Matriz de entrada\n")
      	print_matrix(Mat, $a1, $a2)
      	
      	la $a0, Mat
      	jal upper_vogals
      	
      	move $a0, $v0
      	la $s3, vet
      	li $s4, 0
      	jal count_three
      	
      	print_str("\n Quantidade de vogais na matriz de entrada: ")
      	print_int($s0)
      	print_str("\n Caracteres que repetem 3 ou mais vezes: ")
      	print_array_char(vet, $s4)
      	
      	bne $a1, $a2, end
     	print_str("\n Diagonal da matriz de entrada de ordem n: ")
      	la $a0, Mat # Endereço base de Mat
      	jal diag
      	end:
      	mul $s0, $a1, $a2
      	sort_array_decrescente(Mat, $s0)
      	print_str("\n\n Estágio final da matriz\n")
      	print_matrix(Mat, $a1, $a2)
      	
      	terminate
      	
	indice:
		mul $v0, $t0, $a2 # i * ncol
   		add $v0, $v0, $t1 # (i * ncol) + j
   		sll $v0, $v0, 2 # [(i * ncol) + j] * 4 (inteiro)
   		add $v0, $v0, $a3 # Soma o endereço base de mat
   		jr $ra # Retorna para o caller
   		
   	indice_aux:
		mul $t5, $t3, $a2 # i * ncol
   		add $t5, $t5, $t4 # (i * ncol) + j
   		sll $t5, $t5, 2 # [(i * ncol) + j] * 4 (inteiro)
   		add $t5, $t5, $a3 # Soma o endereço base de mat
   		jr $ra # Retorna para o caller
   
	leitura:
   		subi $sp, $sp, 4 # Espaço para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endereço base de mat
	l:
		print_str("\nInsira o valor de Mat[") 
		print_int($t0)
   		print_str("][")
   		print_int($t1)
   		print_str("]: ")
   		li $v0, 12 # Código de leitura de char
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
   
   	## Na tabela ascii as letras maiúsculas começam em 65 e vão até 90 enquanto as minúsculas começam em
   	## 97 e vão até 122, desse modo temos uma diferença de 32 entre uma letra maiúscula e minúscula.
   	## O trecho a seguir verifica se o caracter atual está no intervalo que contêm as minusculas, caso não
   	## subtrai 32 de seu valor transformando-a em maiúscula e então armazenando na mesma posição da matriz
   	upper_vogals:
   		subi $sp, $sp, 4 # Espaço para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endereço base de mat
	u:
		jal indice # Calcula o endereço de mat[i][j]
   		lb $t2, ($v0) # Valor em mat[i][j]
		beq $t2, 'a', change
		beq $t2, 'e', change
		beq $t2, 'i', change
		beq $t2, 'o', change
		beq $t2, 'u', change
		beq $t2, 'A', count
		beq $t2, 'E', count
		beq $t2, 'I', count
		beq $t2, 'O', count
		beq $t2, 'U', count
		j next
		change:
    			sub $t2, $t2, 32
    			sw $t2, ($v0)
    		count:
    			add $s0, $s0, 1
		
		next:
			addi $t1, $t1, 1 # j++
   			blt $t1, $a2, u # if(j < ncol) goto u
   			li $t1, 0 # j = 0
   			addi $t0, $t0, 1 # i++
   			blt $t0, $a1, u # if(i < nlin) goto u
   			li $t0, 0 # i = 0
	   		lw $ra, ($sp) # Recupera o retorno para a main
   			addi $sp, $sp, 4 # Libera o espaço na pilha
  			move $v0, $a3 # Endereço base da matriz para retorno
   			jr $ra # Retorna para a main
   			
   	## As seguintes funções funcionam basicamente como 4 loops for, os mais externos salvam elemento a elemento
   	## e assim os dois loops internos percorrem novamente a matriz comparando cada um e registrando as ocorrencias
   	## de interesse
   	count_three:
   		subi $sp, $sp, 4 # Espaço para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endereço base de mat
	c_out:
		jal indice # Calcula o endereço de mat[i][j]
   		lb $t2, ($v0) # Valor em mat[i][j]
   		li $s1, 0 # contador de repetições de cada char
   		li $t3, 0 # Auxiliar de linhas para percorrer a matriz internamente
   		li $t4, 0 # Auxiliar de colunas para percorrer a matriz internamente
   		
   		subi $sp, $sp, 4 # Espaço para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endereço base de mat
   		c_in:
   			jal indice_aux
   			lb $s2, ($t5)
   			bne $s2, $t2, next_in
   			add $s1, $s1, 1
   			next_in:
				addi $t4, $t4, 1 # j++
	   			blt $t4, $a2, c_in # if(j < ncol) goto c_in
   				li $t4, 0 # j = 0
   				addi $t3, $t3, 1 # i++
   				blt $t3, $a1, c_in # if(i < nlin) goto c_in
	   			li $t3, 0 # i = 0
	   			addi $sp, $sp, 4 # Libera o espaço na pilha
  				move $v0, $a3 # Endereço base da matriz para retorno
	
   		next_out:
   			blt $s1, 3, n
   			### Adicionando os caracteres em um vetor para facilitar exibição futuramente
   			has_element(vet, $s4, $t2, $t7)
   			beq $t7, $t2, n
			sll $t6, $s4, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t6, $t6, $s3  # Carregando em $t1 = endereÃ§o de vetor[i] 
			sw $t2, 0($t6)  # Armazenando valor de $t2 na posiÃ§Ã£o [i] $t1 do vetor
			addi $s4, $s4, 1  # Iterador do vetor +1
   			
   			n:
			addi $t1, $t1, 1 # j++
   			blt $t1, $a2, c_out # if(j < ncol) goto c_out
   			li $t1, 0 # j = 0
   			addi $t0, $t0, 1 # i++
   			blt $t0, $a1, c_out # if(i < nlin) goto c_out
   			li $t0, 0 # i = 0
	   		lw $ra, ($sp) # Recupera o retorno para a main
   			addi $sp, $sp, 4 # Libera o espaço na pilha
  			move $v0, $a3 # Endereço base da matriz para retorno
   			jr $ra # Retorna  

	diag:
		subi $sp, $sp, 4 # Espaço para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endereço base de mat
	d:
		jal indice # Calcula o endereço de mat[i][j]
   		lb $a0, ($v0) # Valor em mat[i][j]
   		li $v0, 11  # Informando que o syscall deve printar char
		syscall
   		
   		prox:
   		addi $t0, $t0, 1 # i++
   		add $t1, $t0, 0 # Garantindo a diagonal já que i == j
   		blt $t0, $a1, d # if(i < nlin) goto c_out
   		li $t0, 0 # i = 0
		lw $ra, ($sp) # Recupera o retorno para a main
   		addi $sp, $sp, 4 # Libera o espaço na pilha
  		move $v0, $a3 # Endereço base da matriz para retorno
   		jr $ra # Retorna  
   		