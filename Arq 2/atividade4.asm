.include "macros.asm"

.data
	Mat: .space 400 # 10x10 * 4 (inteiro)
	vet: .space 256 # 8x8 * 4
	
.text
	main:
		print_str("\nInforme a dimens�o N da matriz: ")
		scan_int($a1) # N�mero de linhas
	  	print_str("Informe a dimens�o M da matriz: ")
		scan_int($a2) # N�mero de colunas 	
		
		la $a0, Mat # Endere�o base de Mat
      	jal leitura # leitura(mat, nlin, ncol)
      	print_str("\n\n Matriz de entrada\n")
      	print_matrix(Mat, $a1, $a2)
      	
      	li $t0, 0 # i = 0
      	li $t1, 0 # j = 0
      	li $s0, 0 # Contador de vogais
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
      	la $a0, Mat # Endere�o base de Mat
      	jal diag
      	
      	end:
      	la $a0, Mat
      	jal palindromo
      	
      	la $a0, Mat # Endere�o base de Mat
      	jal linhas_impar
      	print_str("\n\n Matriz com linhas �mpares trocadas\n")
      	print_matrix(Mat, $a1, $a2)
      	la $a0 Mat 
      	jal colunas_par
      	print_str("\n Matriz com colunas pares trocadas\n")
      	print_matrix(Mat, $a1, $a2)
      	
      	mul $s0, $a1, $a2
 		jal sort_decrescente
      	print_str("\n Est�gio final da matriz ordenada\n")
      	print_matrix(Mat, $a1, $a2)
      	
      	terminate
      	
	indice:
		mul $v0, $t0, $a2 # i * ncol
   		add $v0, $v0, $t1 # (i * ncol) + j
   		sll $v0, $v0, 2 # [(i * ncol) + j] * 4 (inteiro)
   		add $v0, $v0, $a3 # Soma o endere�o base de mat
   		jr $ra # Retorna para o caller
   		
   	indice_aux:
		mul $t5, $t3, $a2 # i * ncol
   		add $t5, $t5, $t4 # (i * ncol) + j
   		sll $t5, $t5, 2 # [(i * ncol) + j] * 4 (inteiro)
   		add $t5, $t5, $a3 # Soma o endere�o base de mat
   		jr $ra # Retorna para o caller
   
	leitura:
   		subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endere�o base de mat
	l:
		print_str("\nInsira o valor de Mat[") 
		print_int($t0)
   		print_str("][")
   		print_int($t1)
   		print_str("]: ")
   		li $v0, 12 # C�digo de leitura de char
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
   
   	## Na tabela ascii as letras mai�sculas come�am em 65 e v�o at� 90 enquanto as min�sculas come�am em
   	## 97 e v�o at� 122, desse modo temos uma diferen�a de 32 entre uma letra mai�scula e min�scula.
   	## O trecho a seguir verifica se o caracter atual est� no intervalo que cont�m as minusculas, caso n�o
   	## subtrai 32 de seu valor transformando-a em mai�scula e ent�o armazenando na mesma posi��o da matriz
   	upper_vogals:
   		subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endere�o base de mat
	u:
		jal indice # Calcula o endere�o de mat[i][j]
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
   			addi $sp, $sp, 4 # Libera o espa�o na pilha
  			move $v0, $a3 # Endere�o base da matriz para retorno
   			jr $ra # Retorna para a main
   			
   	## As seguintes fun��es funcionam basicamente como 4 loops for, os mais externos salvam elemento a elemento
   	## e assim os dois loops internos percorrem novamente a matriz comparando cada um e registrando as ocorrencias
   	## de interesse
   	count_three:
   		subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endere�o base de mat
	c_out:
		jal indice # Calcula o endere�o de mat[i][j]
   		lb $t2, ($v0) # Valor em mat[i][j]
   		li $s1, 0 # contador de repeti��es de cada char
   		li $t3, 0 # Auxiliar de linhas para percorrer a matriz internamente
   		li $t4, 0 # Auxiliar de colunas para percorrer a matriz internamente
   		
   		subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endere�o base de mat
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
	   			addi $sp, $sp, 4 # Libera o espa�o na pilha
  				move $v0, $a3 # Endere�o base da matriz para retorno
	
   		next_out:
   			blt $s1, 3, n
   			### Adicionando os caracteres de forma �nica em um vetor para facilitar exibi��o futuramente
   			has_element(vet, $s4, $t2, $t7)
   			beq $t7, $t2, n
			sll $t6, $s4, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
			add $t6, $t6, $s3  # Carregando em $t1 = endereço de vetor[i] 
			sw $t2, 0($t6)  # Armazenando valor de $t2 na posição [i] $t1 do vetor
			addi $s4, $s4, 1  # Iterador do vetor +1
   			
   			n:
			addi $t1, $t1, 1 # j++
   			blt $t1, $a2, c_out # if(j < ncol) goto c_out
   			li $t1, 0 # j = 0
   			addi $t0, $t0, 1 # i++
   			blt $t0, $a1, c_out # if(i < nlin) goto c_out
   			li $t0, 0 # i = 0
	   		lw $ra, ($sp) # Recupera o retorno para a main
   			addi $sp, $sp, 4 # Libera o espa�o na pilha
  			move $v0, $a3 # Endere�o base da matriz para retorno
   			jr $ra # Retorna  

	diag:
		subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endere�o base de mat
   		li $t0, 0
   		li $t1, 0
	d:
		jal indice # Calcula o endere�o de mat[i][j]
   		lb $a0, ($v0) # Valor em mat[i][j]
   		li $v0, 11  # Informando que o syscall deve printar char
		syscall
   		
   		prox:
   		addi $t0, $t0, 1 # i++
   		move $t1, $t0 # Garantindo a diagonal j� que i == j
   		blt $t0, $a1, d # if(i < nlin) goto c_out
		lw $ra, ($sp) # Recupera o retorno para a main
   		addi $sp, $sp, 4 # Libera o espa�o na pilha
  		move $v0, $a3 # Endere�o base da matriz para retorno
   		jr $ra # Retorna  
   		
   	## Procedimento que vai carregar, em todas as linhas, o elemento na coluna 0 e o na coluna M-1 e verificar se 
   	## sao iguai. Caso sejam iguais carrega ao na coluna 1 e na coluna M-2 ate que a linha seja toda comparada ou 
   	## ate o momento que para alguma comparacao os valores sejam diferentes
   	palindromo:
   		subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endere�o base de mat
   		li $t0, 0 # linha i
   		li $t1, 0 # coluna j 
   		li $t3, 0 # linha i
   		sub $t4, $a2, 1  # coluna k M-1
   		li $s4, 0 # contador
   	p:
   		jal indice
   		lb $a0, ($v0) # Valor em mat[i][j]
   		jal indice_aux
   		lb $s2, ($t5) # Valor em mat[i][k]
   		bne $a0, $s2, next_line # sao diferentes vai pra proxima linha
   		addi $s4, $s4, 1 # contador ao final deve ser igual a qntd de colunas caso seja uma linha palindromo
   		
   		bne $s4, $a2, next_col
   		print_str("\n Palindromo na linha: ")
   		print_int($t0)
   		la $a0, Mat
   		
   		next_col:
			addi $t1, $t1, 1 # j++
			subi $t4, $t4, 1 # k--
   			blt $t1, $a2, p # if(j < ncol) goto u
   		next_line:
   			li $s4, 0 # reseta contador
   			li $t1, 0 # j = 0
   			subi $t4, $a2, 1 # resetando k para coluna M-1
   			addi $t0, $t0, 1 # i++
   			addi $t3, $t3, 1 
   			blt $t0, $a1, p # if(i < nlin) goto u
   			li $t0, 0 # i = 0
	   		lw $ra, ($sp) # Recupera o retorno para a main
   			addi $sp, $sp, 4 # Libera o espa�o na pilha
  			move $v0, $a3 # Endere�o base da matriz para retorno
   			jr $ra # Retorna para a main
   		
   	## Procedimento que trocar o conte�do das linhas de �ndice impar (1 troca com 3, 5 troca com 7, etc). Existe um
   	## contador de repeti��es que controla quantas linhas precisam ser trocadas (ex: em uma matriz 4x4, apenas 2 linhas
   	## s�o trocadas e portanto o procedimento ocorre uma unica vez). Uma vez estabelecido quantas vezes repetir e os intervalos
   	## de troca, basta armazenar o valor de mat[i][j] e salvar depois em mat[i+2][j].
   	linhas_impar:
   		subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endere�o base de mat
   		div $s5, $a1, 4 # Dividindo nLinhas por 4 para saber quantas trocas ser�o realizadas
      	li $t0, 1 # iniciando linhas em 1
      	li $t1 0 # iniciando colunas em 0
	limp:
   		beqz $s5, end_while1
   		swap2: 
	   		jal indice # Calcula o endere�o de mat[i][j]
   			lb $s1, ($v0) # Valor em mat[i][j] 
   			move $t3, $t0
	   		add $t0, $t0, 2 # i + 2 
   			jal indice
   			lb $s2, ($v0) # Valor em mat[i+2][j]
   			move $t0, $t3
   			jal indice 
   			sw $s2, ($v0) # mat[i][j] = mat[i+2][j]
   			move $t3, $t0
   			add $t0, $t0, 2 # i + 2 
   			jal indice
   			sw $s1, ($v0) # mat[i+2][j] = mat[i][j]
   			move $t0, $t3
   		
   		ne:
   			addi $t1, $t1, 1 # j++
   			blt $t1, $a2, limp # if(j < ncol) goto e
   			li $t1, 0 # j = 0
   			
			subi $s5, $s5, 1 # repetLinhas--
			beqz $s5, limp # se ainda tem repeti��es, somar 4 na linha para chegar na pr�xima troca
			addi $t0, $t0, 4 
			li $t1, 0
			j limp
			end_while1:
	   		lw $ra, ($sp) # Recupera o retorno para a main
   			addi $sp, $sp, 4 # Libera o espa�o na pilha
  			move $v0, $a3 # Endere�o base da matriz para retorno
   			jr $ra # Retorna para a main
   			
   	## Procedimento que trocar o conte�do das colunas de �ndice par (0 troca com 2, 4 troca com 6, etc). Existe um
   	## contador de repeti��es que controla quantas colunas precisam ser trocadas (ex: em uma matriz 4x4, apenas 2 colunas
   	## s�o trocadas e portanto o procedimento ocorre uma unica vez). Uma vez estabelecido quantas vezes repetir e os intervalos
   	## de troca, basta armazenar o valor de mat[i][j] e salvar depois em mat[i][j+2].
   	## Esse trecho precisou ser adaptado para comparar valores float na divis�o, pois a menos matriz posivel para
   	## que a troca de coluna pares seja possivel � de ordem Nx3, logo a divis�o por 4 daria um 0.75 e n�o deve ser 
   	## arredondado para divis�o inteira com valor 0.
   	colunas_par:
   		subi $sp, $sp, 4 # Espa�o para 1 item na pilha
   		sw $ra, ($sp) # Salva o retorno para a main
   		move $a3, $a0 # aux = endere�o base de mat
   		
   		## load de floats
   		li $s7, 0
		mtc1 $s7, $f0
		cvt.s.w $f0, $f0
   		li $s7, 1
		mtc1 $s7, $f1
		cvt.s.w $f1, $f1
   		mtc1 $a2, $f2
   		cvt.s.w $f2, $f2
		li $s7, 4
		mtc1 $s7, $f4
		cvt.s.w $f4, $f4

		div.s $f5, $f2, $f4 # divide nColunas por 4.0
      	li $t0, 0 # iniciando linhas em 0
      	li $t1 0 # iniciando colunas em 0
	cpar:
		c.le.s $f5, $f0 # se valor float em f5 for menor igual a 0, goto end_while2
		bc1t end_while2
   		swap3: 
	   		jal indice # Calcula o endere�o de mat[i][j]
   			lb $s1, ($v0) # Valor em mat[i][j] 
   			move $t3, $t1
	   		add $t1, $t1, 2 # j + 2 
   			jal indice
   			lb $s2, ($v0) # Valor em mat[i][j+2]
   			move $t1, $t3
   			jal indice 
   			sw $s2, ($v0) # mat[i][j] = mat[i][j+2]
   			move $t3, $t1
   			add $t1, $t1, 2 # j + 2 
   			jal indice
   			sw $s1, ($v0) # mat[i][j+2] = mat[i][j]
   			move $t1, $t3
   		
   		ne2:
   			addi $t0, $t0, 1 # i++
   			blt $t0, $a1, cpar # if(i < nlin) goto e
   			li $t0, 0 # i = 0
   			
			sub.s $f5, $f5, $f1 	 # repetColunas--
			
			c.le.s $f5, $f0 # se valor float em f5 for menor igual a 0, goto cpar
			bc1t cpar # se ainda tem repeti��es, somar 4 na coluna para chegar na pr�xima troca
			addi $t1, $t1, 4 
			li $t0, 0
			j cpar
			end_while2:
	   		lw $ra, ($sp) # Recupera o retorno para a main
   			addi $sp, $sp, 4 # Libera o espa�o na pilha
  			move $v0, $a3 # Endere�o base da matriz para retorno
   			jr $ra # Retorna para a main
   		
   	## Bubble sort de forma descrescente dos char na tabela ascii
	sort_decrescente:
		add $s5, $s0, -1  # $s5 = Tamanho do vetor -1 (pois s�o dois loops com essa condi��o de parada)
		la $s6, Mat
		li $t6, 0  # i
		loop1:
			beq $t6, $s5, end1  # Se i = tamanho do vetor -1
			li $s3, 1  # auxiliar para acessar o vet[j+1]
			li $s4, 0  # j
			loop2:
				beq $s4, $s5, end2	# Se j = tamanho do vetor -1
				sll $t1, $s4, 2  # Reg temp $t1 = 4*j (indice atual do vetor)
				add $t1, $t1, $s6  # Carregando em $t1 = endere�o de vetor[j]
				lw $t2, 0($t1)  # $t2 = valor de vetor[j]
				sll $t3, $s3, 2  # Reg temp $t3 = 4*j+1 (indice atual+1 do vetor)
				add $t3, $t3, $s6  # Carregando em $t3 = endere�o de vetor[j+1] 
				lw $t4, 0($t3)  # $t4 = valor de vetor[j+1]
				slt $t0, $t2, $t4  # Se vetor[j] < vetor[j+1], $t0=1
				bne $t0, 1, rept
				swap:
					add $t5, $t2, 0  # $t5 = vet[j] 
					sw $t4, 0($t1)  # vet[j] = vet[j+1], posi��o 0($t1) recebendo conte�do de $t4  
					sw $t5, 0($t3)  # vet[j+1] = vet[j], posi��o 0($t3) recebendo conte�do de $t5			
				rept:
					addi $s3, $s3, 1  # (j+1) = j+1
					addi $s4, $s4, 1  # j = j + 1
					j loop2
			
			end2:
				addi $t6, $t6, 1  # i = i + 1
				j loop1
		end1:
		jr $ra
